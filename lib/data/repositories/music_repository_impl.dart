import '../../domain/entities/track.dart';
import '../../domain/repositories/music_repository.dart';
import '../datasources/soundcloud_datasource.dart';

/// Implementação do [MusicRepository] usando SoundCloud como fonte.
///
/// Usa [SoundCloudDataSource] para buscar tracks, charts e resolver URLs de stream.
/// Mantém cache in-memory de URLs já resolvidas.
class MusicRepositoryImpl implements MusicRepository {
  MusicRepositoryImpl({required SoundCloudDataSource soundCloudDataSource})
    : _soundCloud = soundCloudDataSource;

  final SoundCloudDataSource _soundCloud;

  /// Cache de URLs de stream já resolvidas: trackId → Uri.
  final Map<String, Uri> _streamUrlCache = {};

  @override
  Future<List<Track>> searchTracks(String query) async {
    if (query.trim().isEmpty) return [];
    return _soundCloud.searchTracks(query);
  }

  @override
  Future<List<Track>> getTrendingTracks({String genre = 'all-music'}) async {
    return _soundCloud.getTrendingTracks(genre: genre);
  }

  @override
  Future<Uri> getStreamUrl(String trackId) async {
    // Retorna do cache se disponível.
    final cached = _streamUrlCache[trackId];
    if (cached != null) return cached;

    final url = await _soundCloud.getStreamUrl(trackId);

    // Armazena no cache (limitado a 50 entradas para não estourar memória).
    if (_streamUrlCache.length >= 50) {
      _streamUrlCache.remove(_streamUrlCache.keys.first);
    }
    _streamUrlCache[trackId] = url;

    return url;
  }
}
