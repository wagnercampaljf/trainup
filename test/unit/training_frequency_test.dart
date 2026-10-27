import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:trainup/core/utils/formatters.dart';
import 'package:trainup/features/progress/domain/exercise_progress.dart';
import 'package:trainup/features/progress/domain/training_frequency.dart';

void main() {
  setUpAll(() => initializeDateFormatting(appLocale));

  // Quarta-feira, 21/10/2026.
  final now = DateTime(2026, 10, 21, 18);

  group('semana', () {
    test('começa na segunda-feira às 00:00', () {
      expect(startOfWeek(now), DateTime(2026, 10, 19));
      expect(startOfWeek(DateTime(2026, 10, 19)), DateTime(2026, 10, 19));
      expect(startOfWeek(DateTime(2026, 10, 25, 23)), DateTime(2026, 10, 19));
      // Semana que atravessa o mês.
      expect(startOfWeek(DateTime(2026, 11, 1)), DateTime(2026, 10, 26));
    });

    test('conta treinos e dias da semana atual', () {
      final f = TrainingFrequency.from(
        [
          DateTime(2026, 10, 18, 20), // domingo anterior: fora
          DateTime(2026, 10, 19, 7),
          DateTime(2026, 10, 19, 19), // dois no mesmo dia
          DateTime(2026, 10, 21, 8),
        ],
        now: now,
        weeklyGoal: 4,
      );
      expect(f.weekCount, 3);
      expect(f.weekDays, {DateTime.monday, DateTime.wednesday});
      expect(f.goalReached, isFalse);
      expect(f.remainingThisWeek, 1);
    });
  });

  test('conta o mês atual e o anterior', () {
    final f = TrainingFrequency.from(
      [
        DateTime(2026, 9, 1),
        DateTime(2026, 9, 30, 23),
        DateTime(2026, 10, 1),
        DateTime(2026, 10, 21),
        DateTime(2026, 8, 31), // dois meses atrás: fora
      ],
      now: now,
      weeklyGoal: 3,
    );
    expect(f.monthCount, 2);
    expect(f.previousMonthCount, 2);
  });

  group('sequência de semanas na meta', () {
    List<DateTime> weekOf(DateTime monday, int count) => [
      for (var i = 0; i < count; i++) monday.add(Duration(days: i)),
    ];

    test('semana atual incompleta não quebra a sequência', () {
      final f = TrainingFrequency.from(
        [
          ...weekOf(DateTime(2026, 9, 28), 3),
          ...weekOf(DateTime(2026, 10, 5), 3),
          ...weekOf(DateTime(2026, 10, 12), 4),
          DateTime(2026, 10, 19), // semana atual: 1 de 3
        ],
        now: now,
        weeklyGoal: 3,
      );
      expect(f.streakWeeks, 3);
    });

    test('semana atual com a meta cumprida entra na sequência', () {
      final f = TrainingFrequency.from(
        [...weekOf(DateTime(2026, 10, 12), 2), ...weekOf(now, 2)],
        now: now,
        weeklyGoal: 2,
      );
      expect(f.goalReached, isTrue);
      expect(f.streakWeeks, 2);
    });

    test('semana abaixo da meta zera a sequência', () {
      final f = TrainingFrequency.from(
        [
          ...weekOf(DateTime(2026, 9, 28), 3),
          ...weekOf(DateTime(2026, 10, 5), 1), // quebra
          ...weekOf(DateTime(2026, 10, 12), 3),
        ],
        now: now,
        weeklyGoal: 3,
      );
      expect(f.streakWeeks, 1);
    });

    test('o histórico consultado cobre a sequência e o mês anterior', () {
      final start = TrainingFrequency.historyStart(now);
      expect(start.isBefore(DateTime(2026, 9)), isTrue);
      expect(
        startOfWeek(now).difference(start).inDays,
        7 * TrainingFrequency.historyWeeks,
      );
    });
  });

  group('evolução da carga', () {
    ExerciseLoadEvolution evolution(List<double> weights) =>
        ExerciseLoadEvolution(
          exerciseId: 1,
          name: 'Supino reto',
          lastDate: now,
          maxWeights: weights,
        );

    test('primeira, última, maior carga e diferença', () {
      final e = evolution([30, 35, 32.5, 40]);
      expect(e.firstWeight, 30);
      expect(e.lastWeight, 40);
      expect(e.bestWeight, 40);
      expect(e.change, 10);
      expect(e.percent, closeTo(33.3, .1));
      expect(e.isAtBest, isTrue);
    });

    test('um treino só ou carga inicial zero não tem percentual', () {
      expect(evolution([40]).percent, isNull);
      expect(evolution([0, 10]).percent, isNull);
      expect(evolution([40, 37.5]).change, -2.5);
      expect(evolution([40, 37.5]).isAtBest, isFalse);
    });
  });

  test('mês por extenso', () {
    expect(formatMonthYear(DateTime(2026, 10)), 'Outubro de 2026');
    expect(formatMonthYear(DateTime(2027, 3)), 'Março de 2027');
  });
}
