import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../domain/entities/track.dart';
import '../models/track_model.dart';

/// Informações de stream cacheadas para uma track do SoundCloud.
class _StreamInfo {
  _StreamInfo({required this.url, required this.expiresAt});

  final Uri url;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// DataSource que consome a API v2 do SoundCloud.
///
/// Usa autodescoberta do client_id via web scraping dos bundles JS
/// do SoundCloud (mesma abordagem de yt-dlp e outros projetos).
/// Fallback para client_id registrado se a descoberta falhar.
class SoundCloudDataSource {
  SoundCloudDataSource() : _client = http.Client();

  final http.Client _client;

  /// Client ID resolvido dinamicamente.
  String? _resolvedClientId;

  /// Cache de stream URLs: trackId → _StreamInfo.
  final Map<String, _StreamInfo> _streamCache = {};

  // ── Client ID Discovery ─────────────────────────────────

  /// Regex para encontrar client_id nos bundles JS do SoundCloud.
  static final _clientIdPattern = RegExp(
    r'client_id\s*:\s*"([a-zA-Z0-9]{32})"',
  );

  /// Descobre o client_id usado pelo web player do SoundCloud.
  ///
  /// 1. Busca soundcloud.com e extrai URLs de scripts JS
  /// 2. Busca os scripts e procura por client_id:"..."
  /// 3. Retorna o primeiro client_id encontrado
  Future<String> _getClientId() async {
    if (_resolvedClientId != null) return _resolvedClientId!;

    debugPrint('SoundCloudDataSource: Descobrindo client_id...');

    try {
      // 1. Busca a página principal do SoundCloud.
      final pageResponse = await _client
          .get(
            Uri.parse('https://soundcloud.com'),
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
                  '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
              'Accept': 'text/html',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (pageResponse.statusCode != 200) {
        throw Exception('Página SC retornou ${pageResponse.statusCode}');
      }

      // 2. Extrai URLs de scripts JS (crossorigin src="...").
      final scriptUrls = RegExp(
        r'<script[^>]+crossorigin[^>]+src="(https://a-v2\.sndcdn\.com/[^"]+\.js)"',
      ).allMatches(pageResponse.body).map((m) => m.group(1)!).toList();

      if (scriptUrls.isEmpty) {
        // Tenta padrão alternativo sem crossorigin.
        final altUrls = RegExp(
          r'src="(https://a-v2\.sndcdn\.com/[^"]+\.js)"',
        ).allMatches(pageResponse.body).map((m) => m.group(1)!).toList();
        scriptUrls.addAll(altUrls);
      }

      debugPrint(
        'SoundCloudDataSource: Encontrados ${scriptUrls.length} scripts JS.',
      );

      // 3. Busca os últimos scripts (mais provável conter client_id).
      for (final url in scriptUrls.reversed) {
        try {
          final jsResponse = await _client
              .get(
                Uri.parse(url),
                headers: {
                  'User-Agent':
                      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                },
              )
              .timeout(const Duration(seconds: 10));

          if (jsResponse.statusCode != 200) continue;

          final match = _clientIdPattern.firstMatch(jsResponse.body);
          if (match != null) {
            _resolvedClientId = match.group(1)!;
            debugPrint(
              'SoundCloudDataSource: client_id descoberto: $_resolvedClientId',
            );
            return _resolvedClientId!;
          }
        } catch (_) {
          continue;
        }
      }

      throw Exception('client_id não encontrado nos scripts');
    } catch (e) {
      debugPrint(
        'SoundCloudDataSource: Autodescoberta falhou ($e), '
        'usando client_id registrado.',
      );
      _resolvedClientId = ApiConstants.soundCloudClientId;
      return _resolvedClientId!;
    }
  }

  // ── Busca ───────────────────────────────────────────────

  /// Busca tracks pelo texto [query].
  Future<List<Track>> searchTracks(String query) async {
    final clientId = await _getClientId();
    final uri = Uri.parse('${ApiConstants.soundCloudBaseUrl}/search/tracks')
        .replace(
          queryParameters: {'q': query, 'client_id': clientId, 'limit': '20'},
        );

    final response = await _request(uri);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final collection = data['collection'] as List<dynamic>? ?? [];

    return _parseTracks(collection);
  }

  // ── Trending / Charts ──────────────────────────────────

  /// Retorna as tracks mais populares de um [genre].
  ///
  /// [genre] deve ser um slug SoundCloud, por exemplo:
  /// `all-music`, `pop`, `electronic`, `hiphoprap`, `rbsoul`, `rock`,
  /// `latin`, `danceedm`, `country`, `reggae`.
  Future<List<Track>> getTrendingTracks({String genre = 'all-music'}) async {
    // Tenta o endpoint de charts primeiro.
    try {
      return await _fetchCharts(genre);
    } catch (e) {
      debugPrint(
        'SoundCloudDataSource: Charts falhou ($e), usando busca popular.',
      );
    }

    // Fallback: busca por termos populares mapeados ao gênero.
    final query = _genreSearchFallback[genre] ?? 'top hits 2026';
    return searchTracks(query);
  }

  /// Tenta buscar charts/trending da API.
  ///
  /// Tenta múltiplos endpoints: /charts?kind=trending, /charts?kind=top,
  /// e /discover/set/charts-top:{genre}.
  Future<List<Track>> _fetchCharts(String genre) async {
    final clientId = await _getClientId();

    // Endpoints para tentar em ordem.
    final endpoints = [
      Uri.parse('${ApiConstants.soundCloudBaseUrl}/charts').replace(
        queryParameters: {
          'kind': 'trending',
          'genre': 'soundcloud:genres:$genre',
          'client_id': clientId,
          'limit': '20',
        },
      ),
      Uri.parse('${ApiConstants.soundCloudBaseUrl}/charts').replace(
        queryParameters: {
          'kind': 'top',
          'genre': 'soundcloud:genres:$genre',
          'client_id': clientId,
          'limit': '20',
        },
      ),
    ];

    for (final uri in endpoints) {
      try {
        final response = await _request(uri);
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final collection = data['collection'] as List<dynamic>? ?? [];

        final trackMaps = <Map<String, dynamic>>[];
        for (final item in collection) {
          final trackData = (item as Map<String, dynamic>)['track'];
          if (trackData != null) {
            trackMaps.add(trackData as Map<String, dynamic>);
          }
        }

        final tracks = _parseTracks(trackMaps);
        if (tracks.isNotEmpty) return tracks;
      } catch (_) {
        continue;
      }
    }

    throw Exception('Nenhum endpoint de charts funcionou');
  }

  /// Mapeamento de gêneros para termos de busca populares (fallback).
  static const _genreSearchFallback = <String, String>{
    'all-music': 'top hits 2026',
    'pop': 'pop hits 2026',
    'electronic': 'electronic music best',
    'hiphoprap': 'hip hop rap best 2026',
    'rbsoul': 'r&b soul best',
    'rock': 'rock best hits',
    'latin': 'latin music reggaeton 2026',
    'danceedm': 'edm dance music best',
    'country': 'country music best hits',
    'reggae': 'reggae best hits',
  };

  // ── Stream URL ─────────────────────────────────────────

  /// Resolve a URL de stream de áudio para [trackId].
  Future<Uri> getStreamUrl(String trackId) async {
    // Verifica cache.
    final cached = _streamCache[trackId];
    if (cached != null && !cached.isExpired) {
      return cached.url;
    }

    final clientId = await _getClientId();

    // 1. Busca detalhes da track.
    final trackUri = Uri.parse(
      '${ApiConstants.soundCloudBaseUrl}/tracks/$trackId',
    ).replace(queryParameters: {'client_id': clientId});

    final trackResponse = await _request(trackUri);
    final trackData = jsonDecode(trackResponse.body) as Map<String, dynamic>;

    final trackAuth = trackData['track_authorization'] as String? ?? '';
    final media = trackData['media'] as Map<String, dynamic>?;
    final transcodings = media?['transcodings'] as List<dynamic>? ?? [];

    if (transcodings.isEmpty) {
      throw Exception('Nenhum transcoding encontrado para track $trackId');
    }

    // 2. Prefere progressive (download direto) sobre HLS.
    Map<String, dynamic>? chosen;
    for (final t in transcodings) {
      final tc = t as Map<String, dynamic>;
      final format = tc['format'] as Map<String, dynamic>?;
      final protocol = format?['protocol'] as String? ?? '';
      if (protocol == 'progressive') {
        chosen = tc;
        break;
      }
    }
    chosen ??= transcodings.first as Map<String, dynamic>;

    final transcodingUrl = chosen['url'] as String? ?? '';
    if (transcodingUrl.isEmpty) {
      throw Exception('URL de transcoding vazia para track $trackId');
    }

    // 3. Resolve URL final.
    final resolveUri = Uri.parse(transcodingUrl).replace(
      queryParameters: {
        'client_id': clientId,
        'track_authorization': trackAuth,
      },
    );

    final resolveResponse = await _request(resolveUri);
    final resolveData =
        jsonDecode(resolveResponse.body) as Map<String, dynamic>;
    final streamUrlStr = resolveData['url'] as String? ?? '';

    if (streamUrlStr.isEmpty) {
      throw Exception('Stream URL vazia retornada para track $trackId');
    }

    final streamUrl = Uri.parse(streamUrlStr);

    // 4. Cache por ~10 minutos.
    _streamCache[trackId] = _StreamInfo(
      url: streamUrl,
      expiresAt: DateTime.now().add(const Duration(minutes: 10)),
    );

    // Limita cache.
    if (_streamCache.length > 100) {
      _streamCache.remove(_streamCache.keys.first);
    }

    return streamUrl;
  }

  // ── Helpers ────────────────────────────────────────────

  /// Converte lista de maps JSON em [TrackModel].
  List<Track> _parseTracks(List<dynamic> items) {
    final tracks = <Track>[];
    for (final item in items) {
      try {
        final map = item as Map<String, dynamic>;
        if (map['streamable'] == false) continue;
        tracks.add(TrackModel.fromSoundCloud(map));
      } catch (e) {
        debugPrint('SoundCloudDataSource: Erro ao parsear track: $e');
      }
    }
    return tracks;
  }

  /// Executa uma requisição GET.
  Future<http.Response> _request(Uri uri) async {
    final response = await _client
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
                '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          },
        )
        .timeout(Duration(seconds: ApiConstants.httpTimeoutSeconds));

    if (response.statusCode != 200) {
      throw Exception(
        'SoundCloud API erro ${response.statusCode}: ${response.reasonPhrase} '
        '(${uri.path})',
      );
    }

    return response;
  }
}
