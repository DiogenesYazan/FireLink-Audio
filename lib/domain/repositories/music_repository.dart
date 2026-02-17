import '../entities/track.dart';

/// Interface abstrata do repositório de música.
///
/// Define o contrato para buscar tracks e resolver URLs de stream.
abstract class MusicRepository {
  /// Busca tracks por [query] no SoundCloud.
  Future<List<Track>> searchTracks(String query);

  /// Retorna tracks trending/charts do SoundCloud para o [genre] dado.
  Future<List<Track>> getTrendingTracks({String genre = 'all-music'});

  /// Resolve a URL de stream de áudio para a track com [trackId].
  Future<Uri> getStreamUrl(String trackId);
}
