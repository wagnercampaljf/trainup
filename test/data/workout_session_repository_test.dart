import 'package:flutter_test/flutter_test.dart';
import 'package:trainup/core/database/app_database.dart';
import 'package:trainup/features/exercises/data/exercise_repository.dart';
import 'package:trainup/features/progress/data/progress_repository.dart';
import 'package:trainup/features/progress/domain/exercise_progress.dart';
import 'package:trainup/features/workout_plans/data/workout_plan_repository.dart';
import 'package:trainup/features/workouts/data/workout_session_repository.dart';
import 'package:trainup/features/workouts/domain/session_models.dart';
import 'package:trainup/features/workouts/domain/session_status.dart';

import '../helpers/fixtures.dart';
import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late WorkoutSessionRepository sessions;
  late WorkoutPlanRepository plans;
  late int planId;

  setUp(() async {
    db = createTestDatabase();
    sessions = WorkoutSessionRepository(db);
    plans = WorkoutPlanRepository(db);
    planId = await createFichaA(db);
  });
  tearDown(() => db.close());

  /// Executa a ficha concluindo todas as séries; [lastWeight] altera a
  /// última série antes de concluí-la.
  Future<int> runWorkout(DateTime start, {double? lastWeight}) async {
    final id = await sessions.startFromPlan(planId, now: start);
    final detail = (await sessions.getSession(id))!;
    final sets = detail.exercises.single.sets;
    for (final (index, set) in sets.indexed) {
      final isLast = index == sets.length - 1;
      await sessions.completeSet(
        set.id,
        repetitions: set.repetitions,
        weightKg: isLast && lastWeight != null ? lastWeight : set.weightKg,
        completedAt: start.add(Duration(minutes: index * 3)),
      );
    }
    await sessions.finishSession(
      id,
      finishedAt: start.add(const Duration(minutes: 68)),
    );
    return id;
  }

  test('sessão é snapshot independente da ficha', () async {
    final sessionId = await sessions.startFromPlan(planId);
    final plan = (await plans.getPlan(planId))!..name = 'Ficha A (nova)';
    plan.exercises.single.sets.clear();
    await plans.savePlan(plan);

    final detail = (await sessions.getSession(sessionId))!;
    expect(detail.session.planNameSnapshot, 'Ficha A');
    expect(detail.exercises.single.sets, hasLength(3));
  });

  test('não permite dois treinos em andamento', () async {
    await sessions.startFromPlan(planId);
    expect(
      () => sessions.startFromPlan(planId),
      throwsA(isA<SessionAlreadyRunningException>()),
    );
  });

  test('série concluída é salva imediatamente', () async {
    final id = await sessions.startFromPlan(planId);
    final set = (await sessions.getSession(id))!.exercises.single.sets.first;
    await sessions.completeSet(set.id, repetitions: 11, weightKg: 32.5);
    // Simula reabrir o app: lê direto do banco, sessão ainda em andamento.
    final reloaded = (await sessions.getSession(id))!;
    expect(reloaded.session.status, SessionStatus.running);
    final saved = reloaded.exercises.single.sets.first;
    expect(saved.completed, isTrue);
    expect(saved.weightKg, 32.5);
    expect(saved.repetitions, 11);
    expect(saved.completedAt, isNotNull);
  });

  test('adicionar/remover séries e pular afeta só a sessão', () async {
    final id = await sessions.startFromPlan(planId);
    final exercise = (await sessions.getSession(id))!.exercises.single;
    await sessions.addSet(exercise.exercise.id);
    var detail = (await sessions.getSession(id))!;
    final added = detail.exercises.single.sets.last;
    expect(added.weightKg, 40);
    expect(await sessions.removePendingSet(added.id), isTrue);

    final first = detail.exercises.single.sets.first;
    await sessions.completeSet(first.id, repetitions: 12, weightKg: 30);
    expect(await sessions.removePendingSet(first.id), isFalse);

    await sessions.setSkipped(exercise.exercise.id, skipped: true);
    detail = (await sessions.getSession(id))!;
    expect(detail.exercises.single.exercise.skipped, isTrue);
    expect((await plans.getPlan(planId))!.exercises.single.sets, hasLength(3));
  });

  test('fluxo do MVP: histórico, último treino e evolução 40 → 42,5', () async {
    final first = await runWorkout(DateTime(2026, 10, 1, 18));
    final second = await runWorkout(
      DateTime(2026, 10, 4, 18),
      lastWeight: 42.5,
    );

    final history = await sessions.watchHistory().first;
    expect(history.map((h) => h.id), [second, first]);
    final latest = history.first;
    expect(latest.planName, 'Ficha A');
    expect(latest.exerciseCount, 1);
    expect(latest.setCount, 3);
    expect(latest.volume, 360 + 350 + 8 * 42.5);
    expect(latest.duration, const Duration(minutes: 68));

    final supino = await exerciseByName(db, 'Supino reto');
    final last = await sessions.lastPerformance(supino.id);
    expect(last.map((s) => s.weightKg), [30, 35, 42.5]);

    final progress = ProgressRepository(db);
    final entries = await progress.watchExerciseHistory(supino.id).first;
    final points = ExerciseMetric.maxWeight.series(entries);
    expect(points.map((p) => p.value), [40, 42.5]);
    final stats = ExerciseStats.from(entries);
    expect(stats.maxWeight, 42.5);
    expect(stats.sessionCount, 2);

    final comparison = await sessions.compareWithPrevious(second);
    expect(comparison.previousVolume, 1030);
    expect(comparison.exercisesWithLoadIncrease, 1);

    final records = await sessions.recordsFor(second);
    expect(records.maxWeightExercises, ['Supino reto']);
    expect(records.totalVolume, isTrue);
    expect((await sessions.recordsFor(first)).isEmpty, isTrue);

    final dashboard = await progress
        .watchDashboard(DateTime(2026, 10, 5))
        .first;
    expect(dashboard.workoutsThisMonth, 2);
    expect(dashboard.exercisesImproved, 1);
  });

  test('renomear exercício não altera histórico', () async {
    await runWorkout(DateTime(2026, 10, 1));
    final supino = await exerciseByName(db, 'Supino reto');
    await ExerciseRepository(db).update(
      supino.id,
      name: 'Supino Reto Barra',
      muscleGroup: supino.muscleGroup,
    );
    final history = await sessions.watchHistory().first;
    final detail = (await sessions.getSession(history.single.id))!;
    expect(
      detail.exercises.single.exercise.exerciseNameSnapshot,
      'Supino reto',
    );
  });

  test('cancelar remove do histórico; finalizar calcula duração', () async {
    final id = await sessions.startFromPlan(planId);
    await sessions.cancelSession(id);
    expect(await sessions.watchHistory().first, isEmpty);
    expect(await sessions.getRunningSession(), isNull);
  });

  test('atualizar ficha a partir do treino é opcional e explícito', () async {
    final id = await runWorkout(DateTime(2026, 10, 1), lastWeight: 42.5);
    expect(
      (await plans.getPlan(planId))!.exercises.single.sets.last.weightKg,
      40,
    );
    await plans.updatePlanFromSession(id);
    expect(
      (await plans.getPlan(planId))!.exercises.single.sets.last.weightKg,
      42.5,
    );
  });

  test('exercício adicionado durante o treino sugere última carga', () async {
    final first = await runWorkout(DateTime(2026, 10, 1));
    expect(first, isPositive);
    final id = await sessions.startFromPlan(planId);
    final rosca = await exerciseByName(db, 'Rosca direta');
    await sessions.addExercise(id, rosca.id);
    final detail = (await sessions.getSession(id))!;
    expect(detail.exercises.map((e) => e.exercise.exerciseNameSnapshot), [
      'Supino reto',
      'Rosca direta',
    ]);
    expect(detail.exercises.last.sets, hasLength(3));
    expect(detail.exercises.last.sets.completed, isEmpty);
  });
}
