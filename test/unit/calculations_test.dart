import 'package:flutter_test/flutter_test.dart';
import 'package:trainup/features/progress/domain/exercise_progress.dart';
import 'package:trainup/features/progress/domain/progress_calculations.dart';
import 'package:trainup/features/workouts/domain/workout_calculations.dart';

void main() {
  test('cenários obrigatórios: 620 kg, +25%, máximo 45 kg', () {
    expect(
      totalVolume([
        (weightKg: 30.0, repetitions: 10),
        (weightKg: 40.0, repetitions: 8),
      ]),
      620,
    );
    expect(percentChange(40, 50), 25);
    expect(
      maxWeight([
        (weightKg: 40.0, repetitions: 10),
        (weightKg: 42.5, repetitions: 10),
        (weightKg: 45.0, repetitions: 8),
      ]),
      45,
    );
  });
  group('volume', () {
    test('série = peso × repetições', () {
      expect(setVolume(40, 8), 320);
      expect(setVolume(0, 12), 0);
    });

    test('soma das séries', () {
      final sets = [
        (weightKg: 30.0, repetitions: 12),
        (weightKg: 35.0, repetitions: 10),
        (weightKg: 40.0, repetitions: 8),
      ];
      expect(totalVolume(sets), 360 + 350 + 320);
      expect(maxWeight(sets), 40);
      expect(maxWeight(const []), isNull);
    });
  });

  group('evolução percentual', () {
    test('((atual - inicial) / inicial) × 100', () {
      expect(percentChange(40, 42.5), closeTo(6.25, 1e-9));
      expect(percentChange(100, 92), closeTo(-8, 1e-9));
    });

    test('divisão por zero retorna null', () {
      expect(percentChange(0, 10), isNull);
    });

    test('resumo da série', () {
      final summary = ProgressSummary.fromValues([100, 97, 94, 92])!;
      expect(summary.initial, 100);
      expect(summary.current, 92);
      expect(summary.max, 100);
      expect(summary.absoluteChange, -8);
      expect(summary.percent, closeTo(-8, 1e-9));
      expect(ProgressSummary.fromValues([]), isNull);
    });
  });

  test('duração nunca negativa', () {
    final start = DateTime(2026, 10, 4, 10);
    expect(
      sessionDuration(start, start.add(const Duration(minutes: 68))),
      const Duration(hours: 1, minutes: 8),
    );
    expect(
      sessionDuration(start, start.subtract(const Duration(minutes: 1))),
      Duration.zero,
    );
  });

  group('métricas do exercício', () {
    final older = ExerciseSessionEntry(
      sessionId: 1,
      date: DateTime(2026, 1, 1),
      sets: [
        (weightKg: 30.0, repetitions: 12),
        (weightKg: 40.0, repetitions: 8),
      ],
    );
    final newer = ExerciseSessionEntry(
      sessionId: 2,
      date: DateTime(2026, 1, 8),
      sets: [
        (weightKg: 30.0, repetitions: 12),
        (weightKg: 42.5, repetitions: 8),
      ],
    );

    test('valores por treino', () {
      expect(newer.maxWeight, 42.5);
      expect(newer.averageWeight, 36.25);
      expect(newer.volume, 360 + 340);
      expect(newer.bestSetVolume, 360);
    });

    test('série cronológica independe da ordem de entrada', () {
      final points = ExerciseMetric.maxWeight.series([newer, older]);
      expect(points.map((p) => p.value), [40, 42.5]);
    });

    test('estatísticas (lista do mais recente ao mais antigo)', () {
      final stats = ExerciseStats.from([newer, older]);
      expect(stats.sessionCount, 2);
      expect(stats.maxWeight, 42.5);
      expect(stats.lastWeight, 42.5);
      expect(stats.maxVolume, 700);
    });
  });
}
