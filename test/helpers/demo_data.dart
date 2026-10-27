import 'package:trainup/core/database/app_database.dart';
import 'package:trainup/features/body_measurements/data/body_measurement_repository.dart';
import 'package:trainup/features/body_measurements/domain/body_metric.dart';
import 'package:trainup/features/profile/data/profile_repository.dart';
import 'package:trainup/features/workout_plans/data/workout_plan_repository.dart';
import 'package:trainup/features/workout_plans/domain/plan_models.dart';
import 'package:trainup/features/workouts/data/workout_session_repository.dart';

import 'fixtures.dart';

/// Dados de demonstração (apenas testes e capturas de tela): perfil, três
/// fichas, ~8 semanas de treinos com cargas progressivas e medidas.
class DemoData {
  DemoData._(this.planIds, this.lastSessionId);

  final List<int> planIds;
  final int lastSessionId;

  static const _plans = [
    (
      'Ficha A',
      'Peito e tríceps',
      [
        ('Supino reto', [(12, 40.0), (10, 45.0), (8, 50.0), (8, 50.0)]),
        ('Supino inclinado', [(12, 30.0), (10, 32.0), (8, 34.0)]),
        ('Crucifixo', [(12, 14.0), (12, 14.0), (12, 14.0)]),
        ('Tríceps pulley', [(12, 25.0), (12, 25.0), (10, 27.5)]),
      ],
    ),
    (
      'Ficha B',
      'Costas e bíceps',
      [
        ('Puxada frontal', [(12, 45.0), (10, 50.0), (8, 55.0)]),
        ('Remada baixa', [(12, 40.0), (10, 45.0), (10, 45.0)]),
        ('Rosca direta', [(12, 12.0), (10, 14.0), (8, 14.0)]),
      ],
    ),
    (
      'Ficha C',
      'Pernas',
      [
        ('Agachamento', [(12, 60.0), (10, 70.0), (8, 80.0)]),
        ('Leg press', [(12, 120.0), (12, 140.0), (10, 160.0)]),
        ('Cadeira extensora', [(12, 35.0), (12, 35.0), (12, 40.0)]),
        ('Panturrilha', [(15, 50.0), (15, 50.0), (15, 50.0)]),
      ],
    ),
  ];

  /// Só o perfil, com a medida inicial (primeiro uso após o cadastro).
  static Future<void> seedProfileOnly(
    AppDatabase db, {
    required DateTime now,
    String name = 'Lucas Andrade',
  }) => ProfileRepository(db).completeOnboarding(
    ProfileInput(name: name, heightCm: 178),
    BodyMeasurementInput(
      date: now.subtract(const Duration(days: 56)),
      values: {BodyMetric.weight: 84.2, BodyMetric.bodyFat: 21},
    ),
  );

  /// Cria tudo a partir de [now].
  static Future<DemoData> seed(
    AppDatabase db, {
    required DateTime now,
    String name = 'Lucas Andrade',
  }) async {
    await seedProfileOnly(db, now: now, name: name);
    final plans = WorkoutPlanRepository(db);
    final planIds = <int>[];
    for (final (planName, description, exercises) in _plans) {
      final drafts = <PlanExerciseDraft>[];
      for (final (exerciseName, sets) in exercises) {
        final exercise = await exerciseByName(db, exerciseName);
        drafts.add(
          PlanExerciseDraft(
            exerciseId: exercise.id,
            exerciseName: exercise.name,
            muscleGroup: exercise.muscleGroup,
            restSeconds: 90,
            sets: [
              for (final (reps, weight) in sets)
                PlanSetDraft(repetitions: reps, weightKg: weight),
            ],
          ),
        );
      }
      planIds.add(
        await plans.savePlan(
          PlanDraft(
            name: planName,
            description: description,
            exercises: drafts,
          ),
        ),
      );
    }

    final sessions = WorkoutSessionRepository(db);
    // Seg/qua/sex nas últimas 8 semanas (algumas faltas), até ontem.
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    var lastSessionId = 0;
    var rotation = 0;
    for (var week = 8; week >= 0; week--) {
      for (final offset in const [0, 2, 4]) {
        final day = monday.subtract(Duration(days: week * 7 - offset));
        if (!day.isBefore(today)) continue;
        // Faltas ocasionais, para a frequência não parecer perfeita.
        if ((week + offset) % 5 == 3) continue;
        final planIndex = rotation % 3;
        final progression = rotation ~/ 3;
        rotation++;
        final start = day.add(const Duration(hours: 18, minutes: 30));
        final id = await sessions.startFromPlan(planIds[planIndex], now: start);
        final detail = (await sessions.getSession(id))!;
        var minute = 3;
        for (final exercise in detail.exercises) {
          for (final set in exercise.sets) {
            await sessions.completeSet(
              set.id,
              repetitions: set.repetitions,
              weightKg: _progressed(set.weightKg, progression),
              completedAt: start.add(Duration(minutes: minute)),
            );
            minute += 3;
          }
        }
        await sessions.finishSession(
          id,
          finishedAt: start.add(Duration(minutes: minute + 2)),
        );
        lastSessionId = id;
      }
    }

    final measurements = BodyMeasurementRepository(db);
    for (final (days, weight) in const [(42, 83.6), (28, 82.9), (14, 82.1)]) {
      await measurements.create(
        BodyMeasurementInput(
          date: now.subtract(Duration(days: days)),
          values: {BodyMetric.weight: weight},
        ),
      );
    }

    return DemoData._(planIds, lastSessionId);
  }

  /// Treino da ficha [planId] em andamento: iniciado há 18 min, com duas
  /// séries do primeiro exercício concluídas.
  static Future<int> startRunning(
    AppDatabase db,
    int planId, {
    required DateTime now,
  }) async {
    final sessions = WorkoutSessionRepository(db);
    final id = await sessions.startFromPlan(
      planId,
      now: now.subtract(const Duration(minutes: 18)),
    );
    final sets = (await sessions.getSession(id))!.exercises.first.sets;
    for (final set in sets.take(2)) {
      await sessions.completeSet(
        set.id,
        repetitions: set.repetitions,
        weightKg: _progressed(set.weightKg, 3),
      );
    }
    return id;
  }

  /// +2,5 kg a cada rodada de fichas (carga de demonstração).
  static double _progressed(double weight, int step) =>
      weight == 0 ? 0 : weight + step * 2.5;
}
