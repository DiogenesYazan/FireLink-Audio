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

  /// Busca letras para [trackName] do artista [artistName].
  ///
  /// Tenta primeiro uma busca por campos (track_name + artist_name)
  /// e, se não encontrar resultados, faz fallback para busca geral.
  ///
  /// Retorna `null` se nenhuma letra for encontrada.
  Future<LyricsModel?> searchLyrics({
    required String trackName,
    required String artistName,
  }) async {
    // Tentativa 1: busca por campos específicos.
    var result = await _fetchLyrics(
      queryParams: {'track_name': trackName, 'artist_name': artistName},
    );

    // Tentativa 2: busca geral como fallback.
    result ??= await _fetchLyrics(queryParams: {'q': '$trackName $artistName'});

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
