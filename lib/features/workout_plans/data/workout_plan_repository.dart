import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../workouts/domain/session_status.dart';
import '../domain/plan_models.dart';

class WorkoutPlanRepository {
  WorkoutPlanRepository(this._db);

  final AppDatabase _db;

  /// Fichas ativas com contagem de exercícios e data do último treino.
  Stream<List<PlanSummary>> watchActivePlans() {
    return _db
        .customSelect(
          '''
          SELECT p.id, p.name, p.description,
            (SELECT COUNT(*) FROM workout_plan_exercises pe
               WHERE pe.workout_plan_id = p.id) AS exercise_count,
            (SELECT MAX(s.started_at) FROM workout_sessions s
               WHERE s.workout_plan_id = p.id AND s.status = ?)
               AS last_performed_at
          FROM workout_plans p
          WHERE p.is_active = 1
          ORDER BY p.sort_order, p.name COLLATE NOCASE
          ''',
          variables: [Variable.withString(SessionStatus.completed.name)],
          readsFrom: {
            _db.workoutPlans,
            _db.workoutPlanExercises,
            _db.workoutSessions,
          },
        )
        .watch()
        .map(
          (rows) => [
            for (final row in rows)
              PlanSummary(
                id: row.read<int>('id'),
                name: row.read<String>('name'),
                description: row.readNullable<String>('description'),
                exerciseCount: row.read<int>('exercise_count'),
                lastPerformedAt: row.readNullable<DateTime>(
                  'last_performed_at',
                ),
              ),
          ],
        );
  }

  /// Ficha completa com exercícios e séries ordenados.
  Stream<PlanDraft?> watchPlan(int planId) {
    // Observa todas as tabelas envolvidas para refletir qualquer alteração.
    return _db
        .customSelect(
          'SELECT id FROM workout_plans WHERE id = ? AND is_active = 1',
          variables: [Variable.withInt(planId)],
          readsFrom: {
            _db.workoutPlans,
            _db.workoutPlanExercises,
            _db.workoutPlanSets,
            _db.exercises,
          },
        )
        .watch()
        .asyncMap((rows) => rows.isEmpty ? null : getPlan(planId));
  }

  Future<PlanDraft?> getPlan(int planId) async {
    final plan = await (_db.select(
      _db.workoutPlans,
    )..where((p) => p.id.equals(planId))).getSingleOrNull();
    return plan == null ? null : _loadDraft(plan);
  }

  Future<PlanDraft> _loadDraft(WorkoutPlan plan) async {
    final rows =
        await (_db.select(_db.workoutPlanExercises).join([
                innerJoin(
                  _db.exercises,
                  _db.exercises.id.equalsExp(
                    _db.workoutPlanExercises.exerciseId,
                  ),
                ),
              ])
              ..where(_db.workoutPlanExercises.workoutPlanId.equals(plan.id))
              ..orderBy([OrderingTerm.asc(_db.workoutPlanExercises.position)]))
            .get();
    final planExerciseIds = [
      for (final r in rows) r.readTable(_db.workoutPlanExercises).id,
    ];
    final sets =
        await (_db.select(_db.workoutPlanSets)
              ..where((s) => s.planExerciseId.isIn(planExerciseIds))
              ..orderBy([(s) => OrderingTerm.asc(s.position)]))
            .get();
    return PlanDraft(
      id: plan.id,
      name: plan.name,
      description: plan.description,
      exercises: [
        for (final row in rows)
          _toExerciseDraft(
            row.readTable(_db.workoutPlanExercises),
            row.readTable(_db.exercises),
            sets,
          ),
      ],
    );
  }

  PlanExerciseDraft _toExerciseDraft(
    WorkoutPlanExercise planExercise,
    Exercise exercise,
    List<WorkoutPlanSet> allSets,
  ) => PlanExerciseDraft(
    id: planExercise.id,
    exerciseId: exercise.id,
    exerciseName: exercise.name,
    muscleGroup: exercise.muscleGroup,
    notes: planExercise.notes,
    restSeconds: planExercise.restSeconds,
    sets: [
      for (final s in allSets.where((s) => s.planExerciseId == planExercise.id))
        PlanSetDraft(
          repetitions: s.repetitions,
          weightKg: s.weightKg,
          notes: s.notes,
        ),
    ],
  );

  /// Cria ou atualiza a ficha inteira em uma transação.
  ///
  /// Exercícios existentes mantêm o id (atualizados), removidos são
  /// apagados e novos inseridos; as séries de cada exercício são regravadas.
  /// Treinos já executados não são afetados (são cópias independentes).
  Future<int> savePlan(PlanDraft draft) => _db.transaction(() async {
    final name = draft.name.trim();
    if (name.isEmpty) throw ArgumentError('Nome da ficha obrigatório');
    for (final exercise in draft.exercises) {
      for (final set in exercise.sets) {
        if (set.repetitions < 0 || set.weightKg < 0 || !set.weightKg.isFinite) {
          throw ArgumentError('Repetições e peso devem ser ≥ 0');
        }
      }
    }
    final description = draft.description?.trim();
    final now = DateTime.now();
    final planId = draft.id;
    final int id;
    if (planId == null) {
      id = await _db
          .into(_db.workoutPlans)
          .insert(
            WorkoutPlansCompanion.insert(
              name: name,
              description: Value(
                description?.isEmpty ?? true ? null : description,
              ),
            ),
          );
    } else {
      id = planId;
      final existing = await (_db.select(
        _db.workoutPlans,
      )..where((p) => p.id.equals(id))).getSingleOrNull();
      if (existing == null || !existing.isActive) {
        throw StateError('Ficha não encontrada ou desativada');
      }
      await (_db.update(_db.workoutPlans)..where((p) => p.id.equals(id))).write(
        WorkoutPlansCompanion(
          name: Value(name),
          description: Value(description?.isEmpty ?? true ? null : description),
          updatedAt: Value(now),
        ),
      );
    }

    final existingIds =
        (await (_db.select(
              _db.workoutPlanExercises,
            )..where((e) => e.workoutPlanId.equals(id))).get())
            .map((e) => e.id)
            .toSet();
    final seen = <int>{};
    for (final exercise in draft.exercises) {
      final exerciseId = exercise.id;
      if (exerciseId != null &&
          (!existingIds.contains(exerciseId) || !seen.add(exerciseId))) {
        throw StateError('A ficha foi alterada; recarregue antes de salvar');
      }
    }
    final keptIds = [
      for (final e in draft.exercises)
        if (e.id != null) e.id!,
    ];
    await (_db.delete(_db.workoutPlanExercises)
          ..where((pe) => pe.workoutPlanId.equals(id) & pe.id.isNotIn(keptIds)))
        .go();

    for (final (index, exercise) in draft.exercises.indexed) {
      final notes = exercise.notes?.trim();
      final companion = WorkoutPlanExercisesCompanion(
        workoutPlanId: Value(id),
        exerciseId: Value(exercise.exerciseId),
        position: Value(index),
        notes: Value(notes?.isEmpty ?? true ? null : notes),
        restSeconds: Value(exercise.restSeconds),
        updatedAt: Value(now),
      );
      final int planExerciseId;
      if (exercise.id == null) {
        planExerciseId = await _db
            .into(_db.workoutPlanExercises)
            .insert(companion);
      } else {
        planExerciseId = exercise.id!;
        await (_db.update(
          _db.workoutPlanExercises,
        )..where((pe) => pe.id.equals(planExerciseId))).write(companion);
      }
      await _replaceSets(planExerciseId, exercise.sets);
    }
    return id;
  });

  Future<void> _replaceSets(int planExerciseId, List<PlanSetDraft> sets) async {
    await (_db.delete(
      _db.workoutPlanSets,
    )..where((s) => s.planExerciseId.equals(planExerciseId))).go();
    await _db.batch((b) {
      b.insertAll(_db.workoutPlanSets, [
        for (final (index, set) in sets.indexed)
          WorkoutPlanSetsCompanion.insert(
            planExerciseId: planExerciseId,
            position: index,
            repetitions: set.repetitions,
            weightKg: set.weightKg,
            notes: Value(set.notes),
          ),
      ]);
    });
  }

  /// Altera só o descanso de um exercício da ficha (`null` = padrão).
  ///
  /// Retorna `false` se o exercício não está mais em uma ficha ativa.
  Future<bool> updateExerciseRest(int planExerciseId, int? restSeconds) {
    if (restSeconds != null && (restSeconds < 0 || restSeconds > 3600)) {
      throw ArgumentError('Descanso deve estar entre 0 e 3600 segundos');
    }
    return _db.transaction(() async {
      final row =
          await (_db.select(_db.workoutPlanExercises).join([
                innerJoin(
                  _db.workoutPlans,
                  _db.workoutPlans.id.equalsExp(
                    _db.workoutPlanExercises.workoutPlanId,
                  ),
                ),
              ])..where(
                _db.workoutPlanExercises.id.equals(planExerciseId) &
                    _db.workoutPlans.isActive.equals(true),
              ))
              .getSingleOrNull();
      if (row == null) return false;
      final now = DateTime.now();
      await (_db.update(
        _db.workoutPlanExercises,
      )..where((pe) => pe.id.equals(planExerciseId))).write(
        WorkoutPlanExercisesCompanion(
          restSeconds: Value(restSeconds),
          updatedAt: Value(now),
        ),
      );
      await (_db.update(_db.workoutPlans)
            ..where((p) => p.id.equals(row.readTable(_db.workoutPlans).id)))
          .write(WorkoutPlansCompanion(updatedAt: Value(now)));
      return true;
    });
  }

  /// Soft delete: a ficha some das listas, o histórico permanece.
  Future<void> deletePlan(int planId) async {
    await (_db.update(
      _db.workoutPlans,
    )..where((p) => p.id.equals(planId))).write(
      WorkoutPlansCompanion(
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Atualiza a ficha com o que foi executado na sessão (escolha explícita
  /// do usuário ao finalizar): séries concluídas e descanso. Exercícios
  /// pulados não alteram a ficha; exercícios adicionados durante o treino são
  /// incluídos ao final.
  ///
  /// Retorna `false` (sem alterar nada) se a ficha não existe mais ou foi
  /// excluída.
  Future<bool> updatePlanFromSession(int sessionId) =>
      _db.transaction(() async {
        final session = await (_db.select(
          _db.workoutSessions,
        )..where((s) => s.id.equals(sessionId))).getSingle();
        if (session.status != SessionStatus.completed) {
          throw StateError('Finalize o treino antes de atualizar a ficha');
        }
        final planId = session.workoutPlanId;
        if (planId == null) return false;
        final plan = await (_db.select(
          _db.workoutPlans,
        )..where((p) => p.id.equals(planId))).getSingleOrNull();
        if (plan == null || !plan.isActive) return false;
        final draft = await getPlan(planId);
        if (draft == null) return false;

        final sessionExercises =
            await (_db.select(_db.workoutSessionExercises)
                  ..where((e) => e.sessionId.equals(sessionId))
                  ..orderBy([(e) => OrderingTerm.asc(e.position)]))
                .get();
        for (final sessionExercise in sessionExercises) {
          if (sessionExercise.skipped) continue;
          final sets =
              await (_db.select(_db.workoutSessionSets)
                    ..where(
                      (s) =>
                          s.sessionExerciseId.equals(sessionExercise.id) &
                          s.completed.equals(true),
                    )
                    ..orderBy([(s) => OrderingTerm.asc(s.position)]))
                  .get();
          if (sets.isEmpty) continue;
          final newSets = [
            for (final s in sets)
              PlanSetDraft(repetitions: s.repetitions, weightKg: s.weightKg),
          ];
          final existing = draft.exercises
              .where((e) => e.id == sessionExercise.planExerciseId)
              .firstOrNull;
          if (existing != null) {
            existing
              ..restSeconds = sessionExercise.restSeconds
              ..sets.clear()
              ..sets.addAll(newSets);
          } else {
            draft.exercises.add(
              PlanExerciseDraft(
                exerciseId: sessionExercise.exerciseId,
                exerciseName: sessionExercise.exerciseNameSnapshot,
                muscleGroup: sessionExercise.muscleGroupSnapshot,
                restSeconds: sessionExercise.restSeconds,
                sets: newSets,
              ),
            );
          }
        }
        await savePlan(draft);
        return true;
      });
}

final workoutPlanRepositoryProvider = Provider(
  (ref) => WorkoutPlanRepository(ref.watch(databaseProvider)),
);

final activePlansProvider = StreamProvider<List<PlanSummary>>(
  (ref) => ref.watch(workoutPlanRepositoryProvider).watchActivePlans(),
);

final planDetailProvider = StreamProvider.family<PlanDraft?, int>(
  (ref, id) => ref.watch(workoutPlanRepositoryProvider).watchPlan(id),
);
