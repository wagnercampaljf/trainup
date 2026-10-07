import 'package:flutter_test/flutter_test.dart';
import 'package:trainup/core/database/app_database.dart';
import 'package:trainup/features/workout_plans/data/workout_plan_repository.dart';
import 'package:trainup/features/workout_plans/domain/plan_models.dart';

import '../helpers/fixtures.dart';
import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late WorkoutPlanRepository repo;

  setUp(() {
    db = createTestDatabase();
    repo = WorkoutPlanRepository(db);
  });
  tearDown(() => db.close());

  test('salva ficha com séries diferentes por série', () async {
    final id = await createFichaA(db);
    final plan = (await repo.getPlan(id))!;
    expect(plan.name, 'Ficha A');
    final sets = plan.exercises.single.sets;
    expect(sets.map((s) => (s.repetitions, s.weightKg)), [
      (12, 30.0),
      (10, 35.0),
      (8, 40.0),
    ]);
    final summaries = await repo.watchActivePlans().first;
    expect(summaries.single.exerciseCount, 1);
  });

  test('nome obrigatório', () {
    expect(() => repo.savePlan(PlanDraft(name: '  ')), throwsArgumentError);
  });

  test('edita, reordena e mantém id do exercício existente', () async {
    final id = await createFichaA(db);
    final plan = (await repo.getPlan(id))!;
    final originalId = plan.exercises.single.id;
    final crucifixo = await exerciseByName(db, 'Crucifixo');
    plan.exercises.insert(
      0,
      PlanExerciseDraft(
        exerciseId: crucifixo.id,
        exerciseName: crucifixo.name,
        muscleGroup: crucifixo.muscleGroup,
        sets: [PlanSetDraft(repetitions: 15, weightKg: 10)],
      ),
    );
    plan.exercises.last.sets.removeLast();
    await repo.savePlan(plan);

    final updated = (await repo.getPlan(id))!;
    expect(updated.exercises.map((e) => e.exerciseName), [
      'Crucifixo',
      'Supino reto',
    ]);
    expect(updated.exercises.last.id, originalId);
    expect(updated.exercises.last.sets, hasLength(2));
  });

  test('exclusão é lógica', () async {
    final id = await createFichaA(db);
    await repo.deletePlan(id);
    expect(await repo.watchActivePlans().first, isEmpty);
    expect(await repo.watchPlan(id).first, isNull);
  });
}
