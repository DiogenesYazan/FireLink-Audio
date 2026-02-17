import '../../domain/entities/track.dart';
import '../../domain/repositories/liked_songs_repository.dart';
import '../datasources/local_storage_datasource.dart';
import '../models/track_model.dart';

/// Implementação do repositório de músicas curtidas.
///
/// Mantém cache in-memory sincronizado com SharedPreferences.
class LikedSongsRepositoryImpl implements LikedSongsRepository {
  LikedSongsRepositoryImpl({
    required LocalStorageDatasource localStorageDatasource,
  }) : _localStorageDatasource = localStorageDatasource;

  final LocalStorageDatasource _localStorageDatasource;

  // Cache in-memory para acesso rápido.
  List<Track>? _cachedTracks;
  Set<String>? _cachedIds;

  @override
  Future<List<Track>> getLikedTracks() async {
    if (_cachedTracks != null) {
      return List.from(_cachedTracks!);
    }

    final jsonList = await _localStorageDatasource.loadLikedTracks();
    _cachedTracks = jsonList.map((json) => TrackModel.fromJson(json)).toList();
    _cachedIds = _cachedTracks!.map((t) => t.trackId).toSet();

    return List.from(_cachedTracks!);
  }

  @override
  Future<bool> toggleLike(Track track) async {
    // Carrega cache se necessário.
    if (_cachedTracks == null) {
      await getLikedTracks();
    }

    final trackId = track.trackId;
    final isCurrentlyLiked = _cachedIds!.contains(trackId);

    if (isCurrentlyLiked) {
      // Remove da lista.
      _cachedTracks!.removeWhere((t) => t.trackId == trackId);
      _cachedIds!.remove(trackId);
    } else {
      // Adiciona no início (mais recente primeiro).
      _cachedTracks!.insert(0, track);
      _cachedIds!.add(trackId);
    }

    // Persiste.
    final jsonList = _cachedTracks!
        .map(
          (t) => TrackModel(
            trackId: t.trackId,
            title: t.title,
            artist: t.artist,
            duration: t.duration,
            thumbnailUrl: t.thumbnailUrl,
            streamUrl: t.streamUrl,
          ).toJson(),
        )
        .toList();

    await _localStorageDatasource.saveLikedTracks(jsonList);

    return !isCurrentlyLiked; // Retorna true se foi curtido.
  }

  @override
  Future<bool> isLiked(String trackId) async {
    if (_cachedIds == null) {
      await getLikedTracks();
    }
    return _cachedIds!.contains(trackId);
  }

  @override
  Future<Set<String>> getLikedTrackIds() async {
    if (_cachedIds == null) {
      await getLikedTracks();
    }
    return Set.from(_cachedIds!);
  }
}
