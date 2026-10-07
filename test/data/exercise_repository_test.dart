import 'package:flutter_test/flutter_test.dart';
import 'package:trainup/core/database/app_database.dart';
import 'package:trainup/features/exercises/data/exercise_repository.dart';
import 'package:trainup/features/exercises/domain/exercise_exceptions.dart';
import 'package:trainup/features/exercises/domain/muscle_group.dart';
import 'package:trainup/features/workouts/data/workout_session_repository.dart';

import '../helpers/fixtures.dart';
import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late ExerciseRepository repo;

  setUp(() {
    db = createTestDatabase();
    repo = ExerciseRepository(db);
  });
  tearDown(() => db.close());

  test('cria exercício personalizado', () async {
    final id = await repo.create(
      name: 'Crucifixo inverso',
      muscleGroup: MuscleGroup.shoulders,
    );
    final exercise = await repo.getById(id);
    expect(exercise!.isCustom, isTrue);
    expect(exercise.normalizedName, 'crucifixo inverso');
  });

  test('bloqueia duplicado por nome normalizado', () async {
    expect(
      () =>
          repo.create(name: '  SUPINO   réto ', muscleGroup: MuscleGroup.chest),
      throwsA(isA<DuplicateExerciseException>()),
    );
  });

  test('renomear para nome existente é bloqueado', () async {
    final supino = await exerciseByName(db, 'Supino reto');
    expect(
      () => repo.update(
        supino.id,
        name: 'Crucifixo',
        muscleGroup: MuscleGroup.chest,
      ),
      throwsA(isA<DuplicateExerciseException>()),
    );
  });

  test('busca e filtro por grupo', () async {
    final results = await repo
        .watchActive(query: 'rosca', group: MuscleGroup.biceps)
        .first;
    expect(results.map((e) => e.name), ['Rosca alternada', 'Rosca direta']);
  });

  test('exercício sem uso é apagado; com histórico é desativado', () async {
    final id = await repo.create(name: 'Teste', muscleGroup: MuscleGroup.other);
    expect(await repo.delete(id), ExerciseDeletion.deleted);
    expect(await repo.getById(id), isNull);

    final planId = await createFichaA(db);
    final sessions = WorkoutSessionRepository(db);
    final sessionId = await sessions.startFromPlan(planId);
    await sessions.finishSession(sessionId);

    final supino = await exerciseByName(db, 'Supino reto');
    expect(await repo.delete(supino.id), ExerciseDeletion.deactivated);
    final after = await repo.getById(supino.id);
    expect(after!.isActive, isFalse);
    final detail = await sessions.getSession(sessionId);
    expect(
      detail!.exercises.single.exercise.exerciseNameSnapshot,
      'Supino reto',
    );

    // Recriar com o mesmo nome reativa o registro (mantém o histórico).
    final recreated = await repo.create(
      name: 'Supino reto',
      muscleGroup: MuscleGroup.chest,
    );
    expect(recreated, supino.id);
    expect((await repo.getById(supino.id))!.isActive, isTrue);
  });
}
