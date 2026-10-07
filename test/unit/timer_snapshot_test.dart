import 'package:flutter_test/flutter_test.dart';
import 'package:trainup/features/timer/domain/timer_snapshot.dart';
import 'package:trainup/features/timer/domain/timer_status.dart';

void main() {
  final t0 = DateTime(2026, 10, 4, 10);
  DateTime at(int seconds) => t0.add(Duration(seconds: seconds));
  const ninety = Duration(seconds: 90);

  test('restante é calculado pelo relógio', () {
    final timer = const TimerSnapshot.idle(ninety).start(t0);
    expect(timer.remaining(at(0)), ninety);
    expect(timer.remaining(at(30)), const Duration(seconds: 60));
    // Ex.: app ficou 5 minutos em segundo plano.
    expect(timer.remaining(at(300)), Duration.zero);
    expect(timer.hasExpired(at(300)), isTrue);
    expect(timer.endsAt, at(90));
  });

  test('pausar congela e continuar retoma de onde parou', () {
    var timer = const TimerSnapshot.idle(ninety).start(t0);
    timer = timer.pause(at(30));
    expect(timer.status, TimerStatus.paused);
    expect(timer.remaining(at(500)), const Duration(seconds: 60));
    timer = timer.resume(at(500));
    expect(timer.remaining(at(510)), const Duration(seconds: 50));
    expect(timer.hasExpired(at(560)), isTrue);
  });

  test('adicionar e reduzir tempo', () {
    var timer = const TimerSnapshot.idle(ninety).start(t0);
    timer = timer.adjust(const Duration(seconds: 15), at(10));
    expect(timer.remaining(at(10)), const Duration(seconds: 95));
    timer = timer.adjust(const Duration(seconds: -30), at(10));
    expect(timer.remaining(at(10)), const Duration(seconds: 65));
    // Nunca reduz abaixo de 1s restante.
    timer = timer.adjust(const Duration(minutes: -10), at(10));
    expect(timer.remaining(at(10)), const Duration(seconds: 1));
  });

  test('ajuste em timer parado altera a duração com limites', () {
    var timer = const TimerSnapshot.idle(ninety);
    timer = timer.adjust(const Duration(seconds: 15), t0);
    expect(timer.duration, const Duration(seconds: 105));
    timer = timer.adjust(const Duration(minutes: -10), t0);
    expect(timer.duration, TimerSnapshot.minDuration);
  });

  test('concluído e reset', () {
    final finished = const TimerSnapshot.idle(ninety).start(t0).finish();
    expect(finished.isFinished, isTrue);
    expect(finished.remaining(at(1000)), Duration.zero);
    final restarted = finished.adjust(const Duration(seconds: 30), at(100));
    expect(restarted.isRunning, isTrue);
    expect(restarted.remaining(at(100)), const Duration(seconds: 30));
    final reset = finished.reset();
    expect(reset.isIdle, isTrue);
    expect(reset.duration, ninety);
  });
}
