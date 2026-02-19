import '../entities/track.dart';

/// Interface abstrata do repositório de música.
///
/// Define o contrato para buscar tracks e resolver o arquivo de áudio para playback.
abstract class MusicRepository {
  /// Busca tracks por [query].
  Future<List<Track>> searchTracks(String query);

  /// Retorna tracks trending para o [genre] dado.
  Future<List<Track>> getTrendingTracks({String genre = 'all-music'});

  /// Retorna uma track recomendada/relacionada para autoplay.
  /// [excludeIds] são IDs de tracks que já estão na fila.
  Future<Track?> getRelatedTrack(
    Track track, {
    Set<String> excludeIds = const {},
  });

  /// Baixa o áudio da track e retorna o caminho do arquivo local.
  Future<String> getPlayableFilePath(String trackId);
}
