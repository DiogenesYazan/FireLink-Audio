import '../entities/lyrics.dart';

/// Interface abstrata do repositório de letras.
abstract class LyricsRepository {
  /// Busca letras para a música [title] do artista [artist].
  /// Retorna `null` se não encontrar.
  Future<Lyrics?> getLyrics(String title, String artist);
}
