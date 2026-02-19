import 'package:equatable/equatable.dart';

import '../../../domain/entities/track.dart';

/// Estado do gerenciador de tracks offline.
class OfflineState extends Equatable {
  const OfflineState({
    this.tracks = const [],
    this.downloadingTrackIds = const {},
  });

  /// Lista completa de tracks offline (com metadados).
  final List<Track> tracks;

  /// IDs das tracks que estão sendo baixadas agora.
  final Set<String> downloadingTrackIds;

  /// IDs das tracks baixadas (getter utilitário).
  Set<String> get offlineTrackIds => tracks.map((t) => t.trackId).toSet();

  bool isOffline(String trackId) => offlineTrackIds.contains(trackId);
  bool isDownloading(String trackId) => downloadingTrackIds.contains(trackId);

  OfflineState copyWith({
    List<Track>? tracks,
    Set<String>? downloadingTrackIds,
  }) {
    return OfflineState(
      tracks: tracks ?? this.tracks,
      downloadingTrackIds: downloadingTrackIds ?? this.downloadingTrackIds,
    );
  }

  @override
  List<Object?> get props => [tracks, downloadingTrackIds];
}
