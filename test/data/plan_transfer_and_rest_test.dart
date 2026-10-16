import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:trainup/core/database/app_database.dart';
import 'package:trainup/features/exercises/data/exercise_repository.dart';
import 'package:trainup/features/exercises/domain/muscle_group.dart';
import 'package:trainup/features/workout_plans/data/plan_transfer_repository.dart';
import 'package:trainup/features/workout_plans/data/workout_plan_repository.dart';
import 'package:trainup/features/workout_plans/domain/plan_models.dart';
import 'package:trainup/features/workout_plans/domain/plan_transfer.dart';
import 'package:trainup/features/workouts/data/workout_session_repository.dart';

import '../helpers/fixtures.dart';
import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late WorkoutPlanRepository plans;
  late WorkoutSessionRepository sessions;
  late PlanTransferRepository transfer;

  setUp(() {
    db = createTestDatabase();
    plans = WorkoutPlanRepository(db);
    sessions = WorkoutSessionRepository(db);
    transfer = PlanTransferRepository(db, plans);
  });
  tearDown(() => db.close());

  group('descanso', () {
    test('alterar no treino em andamento grava só na sessão', () async {
      final planId = await createFichaA(db);
      final sessionId = await sessions.startFromPlan(planId);
      final exercise = (await sessions.getSession(sessionId))!
          .exercises
          .single
          .exercise;
      expect(exercise.restSeconds, 90);

      await sessions.updateRest(exercise.id, 150);
      final updated = (await sessions.getSession(sessionId))!
          .exercises
          .single
          .exercise;
      expect(updated.restSeconds, 150);
      expect((await plans.getPlan(planId))!.exercises.single.restSeconds, 90);

      await sessions.updateRest(exercise.id, null);
      expect(
        (await sessions.getSession(sessionId))!
            .exercises
            .single
            .exercise
            .restSeconds,
        isNull,
      );
    });

    test('não altera treino encerrado nem aceita valor inválido', () async {
      final planId = await createFichaA(db);
      final sessionId = await sessions.startFromPlan(planId);
      final exerciseId = (await sessions.getSession(sessionId))!
          .exercises
          .single
          .exercise
          .id;
      expect(() => sessions.updateRest(exerciseId, 5000), throwsArgumentError);
      await sessions.finishSession(sessionId);
      expect(() => sessions.updateRest(exerciseId, 60), throwsStateError);
    });

    test('alterar na ficha; ficha excluída retorna false', () async {
      final planId = await createFichaA(db);
      final planExerciseId = (await plans.getPlan(planId))!
          .exercises
          .single
          .id!;
      expect(await plans.updateExerciseRest(planExerciseId, 45), isTrue);
      expect((await plans.getPlan(planId))!.exercises.single.restSeconds, 45);

      await plans.deletePlan(planId);
      expect(await plans.updateExerciseRest(planExerciseId, 60), isFalse);
    });

    test(
      '"atualizar a ficha" ao finalizar leva o descanso do treino',
      () async {
        final planId = await createFichaA(db);
        final sessionId = await sessions.startFromPlan(planId);
        final detail = (await sessions.getSession(sessionId))!;
        final exercise = detail.exercises.single;
        await sessions.updateRest(exercise.exercise.id, 120);
        await sessions.completeSet(
          exercise.sets.first.id,
          repetitions: 12,
          weightKg: 32.5,
        );
        await sessions.finishSession(sessionId);

        expect(await plans.updatePlanFromSession(sessionId), isTrue);
        final plan = (await plans.getPlan(planId))!;
        expect(plan.exercises.single.restSeconds, 120);
        expect(plan.exercises.single.sets.single.weightKg, 32.5);
      },
    );
  });

  group('exportar e importar fichas', () {
    test('ida e volta em outro aparelho cria ficha e exercícios', () async {
      final planId = await createFichaA(db);
      // Exercício personalizado, que não existe no outro aparelho.
      final customId = await ExerciseRepository(db)
          .create(name: 'Supino Smith 45°', muscleGroup: MuscleGroup.chest);
      final otherId = await plans.savePlan(
        PlanDraft(
          name: 'Ficha B',
          exercises: [
            PlanExerciseDraft(
              exerciseId: customId,
              exerciseName: 'Supino Smith 45°',
              muscleGroup: MuscleGroup.chest,
              notes: 'Pegada média',
              sets: [PlanSetDraft(repetitions: 10, weightKg: 20)],
            ),
          ],
        ),
      );

      final json = (await transfer.exportPlans([planId, otherId])).toJson();

      // "Outro aparelho": banco novo, só com o catálogo padrão.
      final other = createTestDatabase();
      addTearDown(other.close);
      final otherPlans = WorkoutPlanRepository(other);
      final otherTransfer = PlanTransferRepository(other, otherPlans);
      final bundle = PlanBundle.fromJson(json);
      expect(await otherTransfer.missingExercises(bundle), [
        'Supino Smith 45°',
      ]);

      final result = await otherTransfer.importPlans(bundle);
      expect(result.planIds, hasLength(2));
      expect(result.createdExercises, ['Supino Smith 45°']);

      final imported = (await otherPlans.getPlan(result.planIds.first))!;
      expect(imported.name, 'Ficha A');
      expect(imported.description, 'Peito e tríceps');
      final supino = imported.exercises.single;
      expect(supino.exerciseName, 'Supino reto');
      expect(supino.restSeconds, 90);
      expect(supino.sets.map((s) => (s.repetitions, s.weightKg)), [
        (12, 30.0),
        (10, 35.0),
        (8, 40.0),
      ]);
      // O exercício do catálogo padrão foi reutilizado, não duplicado.
      final supinos = await (other.select(
        other.exercises,
      )..where((e) => e.normalizedName.equals('supino reto'))).get();
      expect(supinos, hasLength(1));
      expect(supino.exerciseId, supinos.single.id);

      final b = (await otherPlans.getPlan(result.planIds.last))!;
      expect(b.name, 'Ficha B');
      expect(b.exercises.single.exerciseName, 'Supino Smith 45°');
      expect(b.exercises.single.muscleGroup, MuscleGroup.chest);
      expect(b.exercises.single.notes, 'Pegada média');
      expect(b.exercises.single.restSeconds, isNull);
    });

    test(
      'nome repetido vira "(importada)"; exercício inativo é reativado',
      () async {
        final planId = await createFichaA(db);
        final json = (await transfer.exportPlans([planId])).toJson();
        final supino = await exerciseByName(db, 'Supino reto');

        // Exercício desativado (usado e depois excluído do catálogo).
        await (db.update(db.exercises)..where((e) => e.id.equals(supino.id)))
            .write(const ExercisesCompanion(isActive: Value(false)));

        final first = await transfer.importPlans(PlanBundle.fromJson(json));
        final second = await transfer.importPlans(PlanBundle.fromJson(json));
        expect(first.createdExercises, isEmpty);
        expect(
          (await plans.getPlan(first.planIds.single))!.name,
          'Ficha A (importada)',
        );
        expect(
          (await plans.getPlan(second.planIds.single))!.name,
          'Ficha A (importada 2)',
        );
        final reactivated = await exerciseByName(db, 'Supino reto');
        expect(reactivated.id, supino.id);
        expect(reactivated.isActive, isTrue);
      },
    );

    test('ficha excluída não é exportada', () async {
      final planId = await createFichaA(db);
      await plans.deletePlan(planId);
      expect((await transfer.exportPlans([planId])).plans, isEmpty);
    });
  });
}
