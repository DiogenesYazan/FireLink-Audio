part of 'player_bloc.dart';

/// Status do player de áudio.
enum PlayerStatus { idle, loading, playing, paused, error }

/// Modo de repetição do player.
enum PlayerRepeatMode { off, all, one }

/// Estado do PlayerBloc.
class PlayerState extends Equatable {
  const PlayerState({
    this.status = PlayerStatus.idle,
    this.currentTrack,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.volume = 0.7,
    this.queue = const [],
    this.queueIndex = 0,
    this.shuffleEnabled = false,
    this.repeatMode = PlayerRepeatMode.off,
    this.originalQueue = const [],
    this.errorMessage,
  });

  final PlayerStatus status;
  final Track? currentTrack;
  final Duration position;
  final Duration duration;
  final Duration bufferedPosition;
  final double volume;
  final List<Track> queue;
  final int queueIndex;
  final bool shuffleEnabled;
  final PlayerRepeatMode repeatMode;
  final List<Track> originalQueue; // Fila original antes do shuffle.
  final String? errorMessage;

  /// Se o player está atualmente reproduzindo áudio.
  bool get isPlaying => status == PlayerStatus.playing;

  /// Se há uma próxima track na fila.
  bool get hasNext => queueIndex < queue.length - 1;

  /// Se há uma track anterior na fila.
  bool get hasPrevious => queueIndex > 0;

  PlayerState copyWith({
    PlayerStatus? status,
    Track? currentTrack,
    Duration? position,
    Duration? duration,
    Duration? bufferedPosition,
    double? volume,
    List<Track>? queue,
    int? queueIndex,
    bool? shuffleEnabled,
    PlayerRepeatMode? repeatMode,
    List<Track>? originalQueue,
    String? errorMessage,
  }) {
    return PlayerState(
      status: status ?? this.status,
      currentTrack: currentTrack ?? this.currentTrack,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      volume: volume ?? this.volume,
      queue: queue ?? this.queue,
      queueIndex: queueIndex ?? this.queueIndex,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      originalQueue: originalQueue ?? this.originalQueue,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentTrack,
    position,
    duration,
    bufferedPosition,
    volume,
    queue,
    queueIndex,
    shuffleEnabled,
    repeatMode,
    originalQueue,
    errorMessage,
  ];
}
