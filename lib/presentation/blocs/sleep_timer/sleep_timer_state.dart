part of 'sleep_timer_cubit.dart';

/// Estado do Sleep Timer.
class SleepTimerState extends Equatable {
  const SleepTimerState({
    this.isActive = false,
    this.remaining = Duration.zero,
    this.total = Duration.zero,
  });

  final bool isActive;
  final Duration remaining;
  final Duration total;

  /// Progresso de 0.0 a 1.0.
  double get progress =>
      total.inSeconds > 0 ? remaining.inSeconds / total.inSeconds : 0.0;

  /// Texto formatado ex: "12:34".
  String get remainingText {
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  SleepTimerState copyWith({
    bool? isActive,
    Duration? remaining,
    Duration? total,
  }) {
    return SleepTimerState(
      isActive: isActive ?? this.isActive,
      remaining: remaining ?? this.remaining,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [isActive, remaining, total];
}
