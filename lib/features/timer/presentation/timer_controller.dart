import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/alert_feedback.dart';
import '../../../core/utils/clock.dart';
import '../../settings/presentation/settings_controller.dart';
import '../data/timer_repository.dart';
import '../domain/timer_snapshot.dart';

/// Estado exibido pela interface do temporizador.
class TimerUiState {
  const TimerUiState({required this.snapshot, required this.remaining});

  final TimerSnapshot snapshot;
  final Duration remaining;

  double get progress {
    final total = snapshot.duration.inMilliseconds;
    if (total == 0) return 1;
    return 1 - remaining.inMilliseconds / total;
  }
}

/// Temporizador global único do aplicativo.
///
/// Mantém um só [Timer.periodic] (apenas enquanto conta) para atualizar a
/// interface. O tempo restante é sempre derivado do relógio e do
/// [TimerSnapshot] persistido, então sobrevive a navegação, segundo plano e
/// reinício do app.
class TimerController extends Notifier<TimerUiState> {
  static const tickInterval = Duration(milliseconds: 250);

  /// Janela em que um término "recente" ainda dispara vibração/som.
  static const _feedbackWindow = Duration(seconds: 10);

  Timer? _ticker;

  DateTime _now() => ref.read(clockProvider)();

  @override
  TimerUiState build() {
    ref.onDispose(() => _ticker?.cancel());
    var snapshot = ref.read(initialTimerSnapshotProvider);
    if (snapshot.hasExpired(_now())) {
      // Terminou enquanto o app estava fechado: mostra como concluído.
      snapshot = snapshot.finish();
      unawaited(_persist(snapshot));
    }
    _syncTicker(snapshot);
    return _ui(snapshot);
  }

  TimerUiState _ui(TimerSnapshot snapshot) =>
      TimerUiState(snapshot: snapshot, remaining: snapshot.remaining(_now()));

  void _set(TimerSnapshot snapshot) {
    state = _ui(snapshot);
    _syncTicker(snapshot);
    unawaited(_persist(snapshot));
  }

  Future<void> _persist(TimerSnapshot snapshot) =>
      ref.read(timerRepositoryProvider).save(snapshot);

  void _syncTicker(TimerSnapshot snapshot) {
    if (snapshot.isRunning) {
      _ticker ??= Timer.periodic(tickInterval, (_) => refresh());
    } else {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  /// Recalcula o restante (chamado pelo ticker e ao voltar do background).
  ///
  /// [feedback] `false` quando o fim já foi avisado pelo sistema (aviso
  /// agendado enquanto o app estava fora da tela).
  void refresh({bool feedback = true}) {
    final snapshot = state.snapshot;
    final now = _now();
    if (snapshot.hasExpired(now)) {
      final endsAt = snapshot.endsAt;
      _set(snapshot.finish());
      if (feedback &&
          endsAt != null &&
          now.difference(endsAt) <= _feedbackWindow) {
        final settings = ref.read(settingsProvider);
        unawaited(
          ref
              .read(alertFeedbackProvider)
              .timerFinished(
                vibrate: settings.timerVibration,
                sound: settings.timerSound,
              ),
        );
      }
      return;
    }
    state = _ui(snapshot);
  }

  /// Inicia uma contagem nova (com [duration] ou a duração configurada).
  void start([Duration? duration]) =>
      _set(state.snapshot.start(_now(), newDuration: duration));

  void pause() => _set(state.snapshot.pause(_now()));

  void resume() => _set(state.snapshot.resume(_now()));

  void reset() => _set(state.snapshot.reset());

  /// Define a duração padrão sem iniciar (ou reinicia se já rodando).
  void setDuration(Duration duration) {
    final snapshot = state.snapshot;
    if (snapshot.isRunning || snapshot.isPaused) {
      _set(snapshot.start(_now(), newDuration: duration));
    } else {
      _set(snapshot.withDuration(duration));
    }
  }

  /// Adiciona/remove tempo do restante.
  void adjust(Duration delta) => _set(state.snapshot.adjust(delta, _now()));

  void toggle() {
    final snapshot = state.snapshot;
    if (snapshot.isRunning) {
      pause();
    } else if (snapshot.isPaused) {
      resume();
    } else {
      start();
    }
  }
}

final timerControllerProvider = NotifierProvider<TimerController, TimerUiState>(
  TimerController.new,
);
