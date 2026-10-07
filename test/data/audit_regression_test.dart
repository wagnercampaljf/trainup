import 'package:flutter_test/flutter_test.dart';
import 'package:trainup/core/database/app_database.dart';
import 'package:trainup/features/body_measurements/data/body_measurement_repository.dart';
import 'package:trainup/features/body_measurements/domain/body_metric.dart';
import 'package:trainup/features/profile/data/profile_repository.dart';
import 'package:trainup/features/workout_plans/data/workout_plan_repository.dart';
import 'package:trainup/features/workouts/data/workout_session_repository.dart';
import 'package:trainup/features/workouts/domain/workout_calculations.dart';

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

  test(
    'sessão encerrada rejeita alteração de série e mantém histórico',
    () async {
      final id = await sessions.startFromPlan(planId);
      final set = (await sessions.getSession(id))!.exercises.single.sets.first;
      await sessions.completeSet(set.id, repetitions: 10, weightKg: 30);
      await sessions.finishSession(id);
      await expectLater(
        sessions.updateSet(set.id, weightKg: 100),
        throwsStateError,
      );
      await expectLater(sessions.uncompleteSet(set.id), throwsStateError);
      expect((await sessions.getSession(id))!.volume, 300);
    },
  );

  test('série com zero reps não pode produzir recorde de carga', () async {
    final id = await sessions.startFromPlan(planId);
    final set = (await sessions.getSession(id))!.exercises.single.sets.first;
    expect(
      () => sessions.completeSet(set.id, repetitions: 0, weightKg: 100),
      throwsArgumentError,
    );
  });

  test('ficha desativada não inicia treino', () async {
    await plans.deletePlan(planId);
    await expectLater(sessions.startFromPlan(planId), throwsStateError);
    expect(await sessions.getRunningSession(), isNull);
  });

  test('rascunho obsoleto não apaga séries após remoção concorrente', () async {
    final stale = (await plans.getPlan(planId))!;
    final current = (await plans.getPlan(planId))!;
    current.exercises.clear();
    await plans.savePlan(current);
    await expectLater(plans.savePlan(stale), throwsStateError);
    expect((await plans.getPlan(planId))!.exercises, isEmpty);
  });

  test('atualização da ficha ignora séries não executadas', () async {
    final id = await sessions.startFromPlan(planId);
    final sets = (await sessions.getSession(id))!.exercises.single.sets;
    await sessions.completeSet(sets.first.id, repetitions: 11, weightKg: 32.5);
    await sessions.updateSet(sets.last.id, weightKg: 999);
    await sessions.finishSession(id);
    await plans.updatePlanFromSession(id);
    expect(
      (await plans.getPlan(planId))!.exercises.single.sets
          .map((s) => s.weightKg),
      [32.5],
    );
  });

  test(
    'usar último treino mantém alinhamento de séries já concluídas',
    () async {
      final id = await sessions.startFromPlan(planId);
      final e = (await sessions.getSession(id))!.exercises.single;
      await sessions.completeSet(
        e.sets.first.id,
        repetitions: 12,
        weightKg: 30,
      );
      await sessions.applyValuesToPendingSets(e.exercise.id, <SetValues>[
        (repetitions: 12, weightKg: 30),
        (repetitions: 10, weightKg: 35),
        (repetitions: 8, weightKg: 42.5),
      ]);
      expect(
        (await sessions.getSession(id))!.exercises.single.sets
            .map((s) => s.weightKg),
        [30, 35, 42.5],
      );
    },
  );

  test('sessão em andamento não gera recorde definitivo', () async {
    final first = await sessions.startFromPlan(
      planId,
      now: DateTime(2026, 9, 1),
    );
    var set = (await sessions.getSession(first))!.exercises.single.sets.first;
    await sessions.completeSet(set.id, repetitions: 10, weightKg: 30);
    await sessions.finishSession(first);
    final second = await sessions.startFromPlan(
      planId,
      now: DateTime(2026, 9, 2),
    );
    set = (await sessions.getSession(second))!.exercises.single.sets.first;
    await sessions.completeSet(set.id, repetitions: 10, weightKg: 100);
    expect((await sessions.recordsFor(second)).isEmpty, isTrue);
  });
  test('recorde de volume agrega exercício repetido na mesma sessão', () async {
    final supino = await exerciseByName(db, 'Supino reto');
    Future<int> run(DateTime now, double weight) async {
      final id = await sessions.startFromPlan(planId, now: now);
      await sessions.addExercise(id, supino.id, initialSets: 1);
      final detail = (await sessions.getSession(id))!;
      for (final e in detail.exercises) {
        await sessions.completeSet(
          e.sets.first.id,
          repetitions: 10,
          weightKg: weight,
        );
      }
      await sessions.finishSession(id);
      return id;
    }

    await run(DateTime(2026, 9, 1), 30);
    final second = await run(DateTime(2026, 9, 2), 20);
    // 400 kg neste treino não supera os 600 kg do primeiro.
    expect((await sessions.recordsFor(second)).volumeExercises, isEmpty);
    final third = await run(DateTime(2026, 9, 3), 40);
    expect((await sessions.recordsFor(third)).volumeExercises, ['Supino reto']);
  });
  test('exercício repetido: comparação conta uma vez e último treino junta ocorrências', () async {
    final supino = await exerciseByName(db, 'Supino reto');
    Future<int> run(DateTime now, double weight) async {
      final id = await sessions.startFromPlan(planId, now: now);
      await sessions.addExercise(id, supino.id, initialSets: 1);
      final detail = (await sessions.getSession(id))!;
      for (final e in detail.exercises) {
        await sessions.completeSet(
          e.sets.first.id,
          repetitions: 10,
          weightKg: weight,
        );
      }
      await sessions.finishSession(
        id,
        finishedAt: now.add(const Duration(hours: 1)),
      );
      return id;
    }

    await run(DateTime(2026, 9, 1), 30);
    final second = await run(DateTime(2026, 9, 2), 35);
    final comparison = await sessions.compareWithPrevious(second);
    expect(comparison.exercisesWithLoadIncrease, 1);

    // As duas ocorrências do treino anterior aparecem em "Último treino".
    final last = await sessions.lastPerformance(supino.id);
    expect(last.map((s) => s.weightKg), [35, 35]);
  });

  test(
    'P05: série concluída não aceita 0 repetições; pendente aceita',
    () async {
      final id = await sessions.startFromPlan(planId);
      final sets = (await sessions.getSession(id))!.exercises.single.sets;
      await sessions.completeSet(sets.first.id, repetitions: 12, weightKg: 30);
      await expectLater(
        sessions.updateSet(sets.first.id, repetitions: 0),
        throwsArgumentError,
      );
      final saved = (await sessions.getSession(id))!
          .exercises
          .single
          .sets
          .first;
      expect(saved.repetitions, 12);
      expect(saved.completed, isTrue);
      // Série ainda não executada pode ser planejada com 0.
      await sessions.updateSet(sets.last.id, repetitions: 0);
      expect(
        (await sessions.getSession(id))!.exercises.single.sets.last.repetitions,
        0,
      );
    },
  );

  test('P06: ficha excluída durante o treino não impede finalizar', () async {
    final id = await sessions.startFromPlan(planId);
    final set = (await sessions.getSession(id))!.exercises.single.sets.first;
    await sessions.completeSet(set.id, repetitions: 12, weightKg: 30);
    await plans.deletePlan(planId);
    await sessions.finishSession(id);
    expect(await plans.updatePlanFromSession(id), isFalse);
    final history = await sessions.watchHistory().first;
    expect(history.single.id, id);
    expect(history.single.setCount, 1);
  });

  test('repositórios rejeitam NaN e infinito antes de persistir', () async {
    for (final invalid in [
      double.nan,
      double.infinity,
      double.negativeInfinity,
    ]) {
      expect(
        () => BodyMeasurementRepository(db).create(
          BodyMeasurementInput(
            date: DateTime(2026),
            values: {BodyMetric.weight: 95, BodyMetric.waist: invalid},
          ),
        ),
        throwsArgumentError,
      );
      await expectLater(
        ProfileRepository(db)
            .saveProfile(ProfileInput(name: 'Teste', heightCm: invalid)),
        throwsArgumentError,
      );
      final plan = (await plans.getPlan(planId))!;
      plan.exercises.single.sets.first.weightKg = invalid;
      await expectLater(plans.savePlan(plan), throwsArgumentError);
    }
    expect(
      (await plans.getPlan(planId))!.exercises.single.sets.first.weightKg,
      30,
    );
  });

  test('sessão cancelada rejeita inclusão e conclusão de séries', () async {
    final id = await sessions.startFromPlan(planId);
    final exercise = (await sessions.getSession(id))!.exercises.single;
    await sessions.cancelSession(id);
    await expectLater(sessions.addSet(exercise.exercise.id), throwsStateError);
    await expectLater(
      sessions.completeSet(
        exercise.sets.first.id,
        repetitions: 12,
        weightKg: 30,
      ),
      throwsStateError,
    );
    await expectLater(
      sessions.setSkipped(exercise.exercise.id, skipped: true),
      throwsStateError,
    );
    expect(await sessions.watchHistory().first, isEmpty);
  });
}
