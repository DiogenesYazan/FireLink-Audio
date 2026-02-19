import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../player/player_bloc.dart';

part 'sleep_timer_state.dart';

/// Cubit para o Sleep Timer.
///
/// Conta regressiva e pausa o player automaticamente quando o timer expira.
class SleepTimerCubit extends Cubit<SleepTimerState> {
  SleepTimerCubit({required this.playerBloc}) : super(const SleepTimerState());

  final PlayerBloc playerBloc;
  Timer? _timer;

  /// Inicia o timer com a duração especificada.
  void start(Duration duration) {
    cancel(); // Cancela qualquer timer ativo.

    emit(SleepTimerState(isActive: true, remaining: duration, total: duration));

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final newRemaining = state.remaining - const Duration(seconds: 1);

      if (newRemaining <= Duration.zero) {
        // Timer expirou — pause o player.
        playerBloc.add(const PlayerPlayPauseToggled());
        cancel();
        return;
      }

      emit(state.copyWith(remaining: newRemaining));
    });
  }

  /// Cancela o timer ativo.
  void cancel() {
    _timer?.cancel();
    _timer = null;
    emit(const SleepTimerState());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
