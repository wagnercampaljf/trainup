import 'package:trainup/core/database/app_database.dart';
import 'package:trainup/features/workout_plans/data/workout_plan_repository.dart';
import 'package:trainup/features/workout_plans/domain/plan_models.dart';

Future<Exercise> exerciseByName(AppDatabase db, String name) =>
    (db.select(db.exercises)..where((e) => e.name.equals(name))).getSingle();

/// Cria a "Ficha A" com Supino reto: 12×30, 10×35, 8×40 (cenário do MVP).
Future<int> createFichaA(AppDatabase db, {int? restSeconds = 90}) async {
  final supino = await exerciseByName(db, 'Supino reto');
  return WorkoutPlanRepository(db).savePlan(
    PlanDraft(
      name: 'Ficha A',
      description: 'Peito e tríceps',
      exercises: [
        PlanExerciseDraft(
          exerciseId: supino.id,
          exerciseName: supino.name,
          muscleGroup: supino.muscleGroup,
          restSeconds: restSeconds,
          sets: [
            PlanSetDraft(repetitions: 12, weightKg: 30),
            PlanSetDraft(repetitions: 10, weightKg: 35),
            PlanSetDraft(repetitions: 8, weightKg: 40),
          ],
        ),
      ],
    ),
  );
}
