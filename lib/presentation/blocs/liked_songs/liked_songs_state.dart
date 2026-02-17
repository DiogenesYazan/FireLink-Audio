part of 'liked_songs_cubit.dart';

enum LikedSongsStatus { initial, loading, loaded, error }

class LikedSongsState extends Equatable {
  const LikedSongsState({
    this.status = LikedSongsStatus.initial,
    this.likedTracks = const [],
    this.likedTrackIds = const {},
    this.errorMessage,
  });

  final LikedSongsStatus status;
  final List<Track> likedTracks;
  final Set<String> likedTrackIds;
  final String? errorMessage;

  LikedSongsState copyWith({
    LikedSongsStatus? status,
    List<Track>? likedTracks,
    Set<String>? likedTrackIds,
    String? errorMessage,
  }) {
    return LikedSongsState(
      status: status ?? this.status,
      likedTracks: likedTracks ?? this.likedTracks,
      likedTrackIds: likedTrackIds ?? this.likedTrackIds,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, likedTracks, likedTrackIds, errorMessage];
}
