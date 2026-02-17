import '../../domain/entities/lyrics.dart';
import '../../domain/repositories/lyrics_repository.dart';
import '../datasources/lyrics_datasource.dart';

/// Implementação do [LyricsRepository] usando lrclib.net.
///
/// Mantém cache in-memory de letras já buscadas para evitar
/// requisições duplicadas.
class LyricsRepositoryImpl implements LyricsRepository {
  LyricsRepositoryImpl({required LyricsDataSource lyricsDataSource})
    : _lyrics = lyricsDataSource;

  final LyricsDataSource _lyrics;

  /// Cache: "title|artist" → Lyrics (ou null para "não encontrado").
  final Map<String, Lyrics?> _cache = {};

  @override
  Future<Lyrics?> getLyrics(String title, String artist) async {
    final key = '${title.toLowerCase()}|${artist.toLowerCase()}';

    if (_cache.containsKey(key)) return _cache[key];

    final result = await _lyrics.searchLyrics(
      trackName: title,
      artistName: artist,
    );

    // Cache inclusive de resultados null (evita rebusca).
    if (_cache.length >= 100) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = result;

    return result;
  }
}
