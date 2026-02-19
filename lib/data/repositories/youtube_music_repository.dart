import 'package:firelink_audio/domain/repositories/music_repository.dart';
import 'package:firelink_audio/domain/entities/track.dart';
import '../datasources/youtube_datasource.dart';

/// Implementação de [MusicRepository] usando YouTube via
/// [YoutubeDataSource] (youtube_explode_dart).
class YoutubeMusicRepository implements MusicRepository {
  YoutubeMusicRepository({required YoutubeDataSource youtubeDataSource})
    : _yt = youtubeDataSource;

  final YoutubeDataSource _yt;

  @override
  Future<List<Track>> getTrendingTracks({String genre = 'all-music'}) async {
    return _yt.getTrendingTracks(genre: genre);
  }

  @override
  Future<String> getPlayableFilePath(String trackId) async {
    return _yt.downloadAudio(trackId);
  }

  @override
  Future<Track?> getRelatedTrack(
    Track track, {
    Set<String> excludeIds = const {},
  }) async {
    return _yt.getRelatedVideo(
      title: track.title,
      artist: track.artist,
      currentId: track.trackId,
      excludeIds: excludeIds,
    );
  }

  @override
  Future<List<Track>> searchTracks(String query) async {
    return _yt.searchTracks(query);
  }
}
