import 'timer_status.dart';

/// Estado imutável do temporizador regressivo.
///
/// Não guarda "segundos restantes": guarda quando a contagem começou
/// ([startedAt]) e quanto já havia decorrido antes ([elapsedBefore], que
/// acumula períodos anteriores a pausas). O restante é sempre calculado a
/// partir do relógio, então continua correto após o app ficar em segundo
/// plano, com a tela bloqueada ou após ser fechado e reaberto.
class TimerSnapshot {
  const TimerSnapshot({
    required this.status,
    required this.duration,
    this.startedAt,
    this.elapsedBefore = Duration.zero,
  });

  const TimerSnapshot.idle(this.duration)
    : status = TimerStatus.idle,
      startedAt = null,
      elapsedBefore = Duration.zero;

  static const minDuration = Duration(seconds: 5);
  static const maxDuration = Duration(hours: 1);

  final TimerStatus status;

  /// Duração total configurada.
  final Duration duration;

  /// Início do trecho atual de contagem (somente quando [TimerStatus.running]).
  final DateTime? startedAt;

  /// Tempo decorrido antes de [startedAt].
  final Duration elapsedBefore;

  bool get isRunning => status == TimerStatus.running;
  bool get isPaused => status == TimerStatus.paused;
  bool get isFinished => status == TimerStatus.finished;
  bool get isIdle => status == TimerStatus.idle;

  /// Instante em que a contagem termina (somente rodando).
  DateTime? get endsAt => isRunning && startedAt != null
      ? startedAt!.add(duration - elapsedBefore)
      : null;

  Duration elapsed(DateTime now) {
    switch (status) {
      case TimerStatus.idle:
        return Duration.zero;
      case TimerStatus.paused:
        return elapsedBefore;
      case TimerStatus.finished:
        return duration;
      case TimerStatus.running:
        final running = now.difference(startedAt ?? now);
        return elapsedBefore + (running.isNegative ? Duration.zero : running);
    }
  }

  Duration remaining(DateTime now) {
    final left = duration - elapsed(now);
    return left.isNegative ? Duration.zero : left;
  }

  /// Fração concluída (0..1) para indicadores de progresso.
  double progress(DateTime now) {
    if (duration.inMilliseconds == 0) return 1;
    return (elapsed(now).inMilliseconds / duration.inMilliseconds).clamp(
      0.0,
      1.0,
    );
  }

  /// `true` se está rodando mas o tempo já se esgotou.
  bool hasExpired(DateTime now) => isRunning && remaining(now) == Duration.zero;

  /// Inicia uma nova contagem de [newDuration] (ou da duração atual).
  TimerSnapshot start(DateTime now, {Duration? newDuration}) => TimerSnapshot(
    status: TimerStatus.running,
    duration: _clamp(newDuration ?? duration),
    startedAt: now,
  );

  TimerSnapshot pause(DateTime now) {
    if (!isRunning) return this;
    return TimerSnapshot(
      status: TimerStatus.paused,
      duration: duration,
      elapsedBefore: elapsed(now),
    );
  }

  TimerSnapshot resume(DateTime now) {
    if (!isPaused) return this;
    return TimerSnapshot(
      status: TimerStatus.running,
      duration: duration,
      startedAt: now,
      elapsedBefore: elapsedBefore,
    );
  }

  TimerSnapshot finish() => TimerSnapshot(
    status: TimerStatus.finished,
    duration: duration,
    elapsedBefore: duration,
  );

  TimerSnapshot reset() => TimerSnapshot.idle(duration);

  /// Altera a duração configurada (sem iniciar).
  TimerSnapshot withDuration(Duration value) => TimerSnapshot(
    status: isFinished ? TimerStatus.idle : status,
    duration: _clamp(value),
    startedAt: isFinished ? null : startedAt,
    elapsedBefore: isFinished ? Duration.zero : elapsedBefore,
  );

  /// Soma (ou subtrai, se negativo) tempo ao restante.
  ///
  /// Em um timer concluído, adicionar tempo inicia nova contagem curta.
  TimerSnapshot adjust(Duration delta, DateTime now) {
    if (isIdle) return withDuration(duration + delta);
    if (isFinished) {
      return delta.isNegative ? this : start(now, newDuration: delta);
    }
    final newDuration = duration + delta;
    final minimum = elapsed(now) + const Duration(seconds: 1);
    final bounded = newDuration < minimum ? minimum : newDuration;
    return TimerSnapshot(
      status: status,
      duration: bounded > maxDuration ? maxDuration : bounded,
      startedAt: startedAt,
      elapsedBefore: elapsedBefore,
    );
  }

  static Duration _clamp(Duration value) {
    if (value < minDuration) return minDuration;
    if (value > maxDuration) return maxDuration;
    return value;
  }

  @override
  bool operator ==(Object other) =>
      other is TimerSnapshot &&
      other.status == status &&
      other.duration == duration &&
      other.startedAt == startedAt &&
      other.elapsedBefore == elapsedBefore;

  @override
  int get hashCode => Object.hash(status, duration, startedAt, elapsedBefore);

  @override
  String toString() =>
      'TimerSnapshot($status, $duration, $startedAt, $elapsedBefore)';
}
