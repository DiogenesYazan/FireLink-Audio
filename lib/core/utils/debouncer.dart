import 'dart:async';

/// Debouncer utilitário para atrasar execuções (ex: busca enquanto digita).
class Debouncer {
  Debouncer({this.duration = const Duration(milliseconds: 500)});

  final Duration duration;
  Timer? _timer;

  /// Agenda [action] para ser executada após [duration].
  /// Cancela qualquer timer anterior.
  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Cancela o timer pendente sem executar.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Libera recursos.
  void dispose() {
    cancel();
  }
}
