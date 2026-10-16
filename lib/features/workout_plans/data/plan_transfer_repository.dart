import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/utils/text_normalizer.dart';
import '../domain/plan_models.dart';
import '../domain/plan_transfer.dart';
import 'workout_plan_repository.dart';

/// Resultado de uma importação.
class PlanImportResult {
  const PlanImportResult({
    required this.planIds,
    required this.createdExercises,
  });

  final List<int> planIds;

  /// Exercícios que não existiam no catálogo e foram criados.
  final List<String> createdExercises;
}

/// Exporta e importa fichas entre aparelhos (arquivo JSON, ver
/// [PlanBundle]). A importação sempre cria fichas novas: nada existente é
/// sobrescrito, e o histórico não é tocado.
class PlanTransferRepository {
  PlanTransferRepository(this._db, this._plans);

  final AppDatabase _db;
  final WorkoutPlanRepository _plans;

  /// Fichas ativas de [planIds], na ordem pedida.
  Future<PlanBundle> exportPlans(List<int> planIds) async {
    final plans = <TransferPlan>[];
    for (final id in planIds) {
      final active = await (_db.select(
        _db.workoutPlans,
      )..where((p) => p.id.equals(id) & p.isActive.equals(true))).get();
      if (active.isEmpty) continue;
      final draft = await _plans.getPlan(id);
      if (draft == null) continue;
      plans.add(
        TransferPlan(
          name: draft.name,
          description: draft.description,
          exercises: [
            for (final e in draft.exercises)
              TransferExercise(
                name: e.exerciseName,
                muscleGroup: e.muscleGroup,
                restSeconds: e.restSeconds,
                notes: e.notes,
                sets: [
                  for (final s in e.sets)
                    TransferSet(
                      repetitions: s.repetitions,
                      weightKg: s.weightKg,
                      notes: s.notes,
                    ),
                ],
              ),
          ],
        ),
      );
    }
    return PlanBundle(plans: plans, exportedAt: DateTime.now());
  }

  /// Nomes dos exercícios do arquivo que ainda não existem no catálogo
  /// (serão criados na importação).
  Future<List<String>> missingExercises(PlanBundle bundle) async {
    final known = (await _db.select(_db.exercises).get())
        .map((e) => e.normalizedName)
        .toSet();
    final missing = <String, String>{};
    for (final plan in bundle.plans) {
      for (final exercise in plan.exercises) {
        final normalized = normalizeName(exercise.name);
        if (!known.contains(normalized)) {
          missing.putIfAbsent(normalized, () => exercise.name);
        }
      }
    }
    return missing.values.toList();
  }

  /// Cria as fichas do arquivo. Exercícios são associados pelo nome
  /// (sem acentos/maiúsculas); os que faltam são criados como
  /// personalizados e os desativados são reativados.
  Future<PlanImportResult> importPlans(PlanBundle bundle) => _db.transaction(
    () async {
      final created = <String>[];
      final exerciseIds = <String, int>{};

      Future<Exercise> resolve(TransferExercise item) async {
        final normalized = normalizeName(item.name);
        final cached = exerciseIds[normalized];
        if (cached != null) {
          return (_db.select(
            _db.exercises,
          )..where((e) => e.id.equals(cached))).getSingle();
        }
        var exercise = await (_db.select(
          _db.exercises,
        )..where((e) => e.normalizedName.equals(normalized))).getSingleOrNull();
        if (exercise == null) {
          final id = await _db
              .into(_db.exercises)
              .insert(
                ExercisesCompanion.insert(
                  name: item.name,
                  normalizedName: normalized,
                  muscleGroup: item.muscleGroup,
                ),
              );
          created.add(item.name);
          exercise = await (_db.select(
            _db.exercises,
          )..where((e) => e.id.equals(id))).getSingle();
        } else if (!exercise.isActive) {
          await (_db.update(
            _db.exercises,
          )..where((e) => e.id.equals(exercise!.id))).write(
            ExercisesCompanion(
              isActive: const Value(true),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
        exerciseIds[normalized] = exercise.id;
        return exercise;
      }

      final usedNames =
          (await (_db.select(
                _db.workoutPlans,
              )..where((p) => p.isActive.equals(true))).get())
              .map((p) => normalizeName(p.name))
              .toSet();
      final planIds = <int>[];
      for (final plan in bundle.plans) {
        final name = _uniqueName(plan.name, usedNames);
        usedNames.add(normalizeName(name));
        final exercises = <PlanExerciseDraft>[];
        for (final item in plan.exercises) {
          final exercise = await resolve(item);
          exercises.add(
            PlanExerciseDraft(
              exerciseId: exercise.id,
              exerciseName: exercise.name,
              muscleGroup: exercise.muscleGroup,
              restSeconds: item.restSeconds,
              notes: item.notes,
              sets: [
                for (final s in item.sets)
                  PlanSetDraft(
                    repetitions: s.repetitions,
                    weightKg: s.weightKg,
                    notes: s.notes,
                  ),
              ],
            ),
          );
        }
        planIds.add(
          await _plans.savePlan(
            PlanDraft(
              name: name,
              description: plan.description,
              exercises: exercises,
            ),
          ),
        );
      }
      return PlanImportResult(planIds: planIds, createdExercises: created);
    },
  );

  /// "Ficha A" já existe → "Ficha A (importada)", "Ficha A (importada 2)"…
  static String _uniqueName(String name, Set<String> used) {
    if (!used.contains(normalizeName(name))) return name;
    for (var i = 1; ; i++) {
      final suffix = i == 1 ? ' (importada)' : ' (importada $i)';
      final base = name.length + suffix.length > 100
          ? name.substring(0, 100 - suffix.length).trimRight()
          : name;
      final candidate = '$base$suffix';
      if (!used.contains(normalizeName(candidate))) return candidate;
    }
  }
}

final planTransferRepositoryProvider = Provider(
  (ref) => PlanTransferRepository(
    ref.watch(databaseProvider),
    ref.watch(workoutPlanRepositoryProvider),
  ),
);
