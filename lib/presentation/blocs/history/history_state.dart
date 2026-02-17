part of 'history_cubit.dart';

enum HistoryStatus { initial, loading, loaded, error }

class HistoryState extends Equatable {
  const HistoryState({
    this.status = HistoryStatus.initial,
    this.recentTracks = const [],
    this.errorMessage,
  });

  final HistoryStatus status;
  final List<Track> recentTracks;
  final String? errorMessage;

  HistoryState copyWith({
    HistoryStatus? status,
    List<Track>? recentTracks,
    String? errorMessage,
  }) {
    return HistoryState(
      status: status ?? this.status,
      recentTracks: recentTracks ?? this.recentTracks,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, recentTracks, errorMessage];
}
