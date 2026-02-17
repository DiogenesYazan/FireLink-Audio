import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../models/lyrics_model.dart';

/// DataSource para buscar letras de músicas na API lrclib.net.
///
/// A API é gratuita, sem API key, e retorna letras em texto puro
/// e/ou sincronizadas no formato LRC.
///
/// Documentação: https://lrclib.net/docs
class LyricsDataSource {
  LyricsDataSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Remove padrões comuns de títulos do SoundCloud que atrapalham
  /// a busca de letras (ex: "Official Audio", "Lyrics", "ft.", etc.).
  String _cleanTitle(String title) {
    var cleaned = title;

    // Remove padrões entre parênteses e colchetes.
    cleaned = cleaned.replaceAll(
      RegExp(
        r'\(.*?(official|audio|video|lyrics|lyric|remix|extended|explicit|clean).*?\)',
        caseSensitive: false,
      ),
      '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(
        r'\[.*?(official|audio|video|lyrics|lyric|remix|extended|explicit|clean).*?\]',
        caseSensitive: false,
      ),
      '',
    );

    // Remove "feat.", "ft.", "featuring", "with".
    cleaned = cleaned.replaceAll(
      RegExp(r'\s+(feat\.?|ft\.?|featuring|with)\s+.*', caseSensitive: false),
      '',
    );

    // Remove "prod. by", "produced by".
    cleaned = cleaned.replaceAll(
      RegExp(r'\s+(prod\.?\s+by|produced\s+by)\s+.*', caseSensitive: false),
      '',
    );

    // Remove múltiplos espaços e trim.
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    return cleaned;
  }

  /// Remove padrões comuns de nomes de artistas que podem atrapalhar a busca.
  String _cleanArtist(String artist) {
    var cleaned = artist;

    // Remove "@" do início (comum em usernames do SoundCloud).
    cleaned = cleaned.replaceAll(RegExp(r'^@'), '');

    // Remove padrões entre parênteses.
    cleaned = cleaned.replaceAll(RegExp(r'\(.*?\)'), '');

    // Remove múltiplos espaços e trim.
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    return cleaned;
  }

  /// Busca letras para [trackName] do artista [artistName].
  ///
  /// Aplica limpeza nos nomes para remover padrões que atrapalham
  /// a busca (ex: "Official Audio", "feat.", etc.).
  ///
  /// Tenta primeiro uma busca por campos (track_name + artist_name)
  /// com nomes limpos, depois com originais como fallback.
  ///
  /// Retorna `null` se nenhuma letra for encontrada.
  Future<LyricsModel?> searchLyrics({
    required String trackName,
    required String artistName,
  }) async {
    // Limpa os nomes.
    final cleanedTitle = _cleanTitle(trackName);
    final cleanedArtist = _cleanArtist(artistName);

    // Tentativa 1: busca com nomes limpos.
    var result = await _fetchLyrics(
      queryParams: {'track_name': cleanedTitle, 'artist_name': cleanedArtist},
    );

    // Tentativa 2: busca geral com nomes limpos.
    result ??= await _fetchLyrics(
      queryParams: {'q': '$cleanedTitle $cleanedArtist'},
    );

    // Tentativa 3: fallback com nomes originais (se diferentes dos limpos).
    if (result == null &&
        (cleanedTitle != trackName || cleanedArtist != artistName)) {
      result = await _fetchLyrics(
        queryParams: {'track_name': trackName, 'artist_name': artistName},
      );
    }

    return result;
  }

  Future<LyricsModel?> _fetchLyrics({
    required Map<String, String> queryParams,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.lrclibBaseUrl}/api/search',
    ).replace(queryParameters: queryParams);

    try {
      final response = await _client
          .get(uri, headers: {'User-Agent': ApiConstants.userAgent})
          .timeout(const Duration(seconds: ApiConstants.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isEmpty) return null;

        // Retorna o primeiro resultado que tenha letras.
        for (final item in data) {
          final lyrics = LyricsModel.fromJson(item as Map<String, dynamic>);
          if (lyrics.hasLyrics || lyrics.instrumental) return lyrics;
        }
        return null;
      }

      return null;
    } catch (_) {
      // Falha silenciosa — letras são funcionalidade secundária.
      return null;
    }
  }

  /// Libera recursos do cliente HTTP.
  void dispose() {
    _client.close();
  }
}
