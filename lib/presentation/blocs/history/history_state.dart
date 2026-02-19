part of 'history_cubit.dart';

enum HistoryStatus { initial, loading, loaded, error }

class HistoryState extends Equatable {
  const HistoryState({
    this.status = HistoryStatus.initial,
    this.recentTracks = const [],
    this.timestamps = const {},
    this.errorMessage,
  });

  final HistoryStatus status;
  final List<Track> recentTracks;

  /// Mapa de trackId → timestamp de quando foi tocada.
  final Map<String, DateTime> timestamps;

  final String? errorMessage;

  HistoryState copyWith({
    HistoryStatus? status,
    List<Track>? recentTracks,
    Map<String, DateTime>? timestamps,
    String? errorMessage,
  }) {
    return HistoryState(
      status: status ?? this.status,
      recentTracks: recentTracks ?? this.recentTracks,
      timestamps: timestamps ?? this.timestamps,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, recentTracks, timestamps, errorMessage];
}
