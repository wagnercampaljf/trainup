import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../domain/session_models.dart';
import '../domain/session_status.dart';
import '../domain/workout_calculations.dart';

/// Já existe um treino em andamento.
class SessionAlreadyRunningException implements Exception {
  const SessionAlreadyRunningException(this.sessionId);

  final int sessionId;

  @override
  String toString() => 'Você já possui um treino em andamento.';
}

class WorkoutSessionRepository {
  WorkoutSessionRepository(this._db);

  final AppDatabase _db;

  static final _completed = Variable.withString(SessionStatus.completed.name);

  Future<void> _requireRunning(int sessionId) async {
    final session = await (_db.select(
      _db.workoutSessions,
    )..where((s) => s.id.equals(sessionId))).getSingleOrNull();
    if (session == null || session.status != SessionStatus.running) {
      throw StateError('O treino não está em andamento');
    }
  }

  Future<void> _requireEditableExercise(int exerciseId) async {
    final exercise = await (_db.select(
      _db.workoutSessionExercises,
    )..where((e) => e.id.equals(exerciseId))).getSingle();
    await _requireRunning(exercise.sessionId);
  }

  Future<WorkoutSessionSet> _requireEditableSet(int setId) async {
    final set = await (_db.select(
      _db.workoutSessionSets,
    )..where((s) => s.id.equals(setId))).getSingle();
    await _requireEditableExercise(set.sessionExerciseId);
    return set;
  }

  // ---------------------------------------------------------------------------
  // Sessão em andamento
  // ---------------------------------------------------------------------------

  Stream<WorkoutSession?> watchRunningSession() =>
      (_db.select(_db.workoutSessions)
            ..where((s) => s.status.equalsValue(SessionStatus.running))
            ..orderBy([(s) => OrderingTerm.desc(s.startedAt)])
            ..limit(1))
          .watchSingleOrNull();

  Future<WorkoutSession?> getRunningSession() =>
      (_db.select(_db.workoutSessions)
            ..where((s) => s.status.equalsValue(SessionStatus.running))
            ..orderBy([(s) => OrderingTerm.desc(s.startedAt)])
            ..limit(1))
          .getSingleOrNull();

  /// Cria uma sessão copiando (snapshot) exercícios e séries da ficha.
  ///
  /// Depois de criada, a sessão é independente: editar a ficha não a altera.
  Future<int> startFromPlan(int planId, {DateTime? now}) =>
      _db.transaction(() async {
        final running = await getRunningSession();
        if (running != null) throw SessionAlreadyRunningException(running.id);

        final plan = await (_db.select(
          _db.workoutPlans,
        )..where((p) => p.id.equals(planId))).getSingle();
        if (!plan.isActive) throw StateError('Ficha desativada');
        final startedAt = now ?? DateTime.now();
        final sessionId = await _db
            .into(_db.workoutSessions)
            .insert(
              WorkoutSessionsCompanion.insert(
                workoutPlanId: Value(plan.id),
                planNameSnapshot: plan.name,
                startedAt: startedAt,
                status: SessionStatus.running,
              ),
            );

        final planExercises =
            await (_db.select(_db.workoutPlanExercises).join([
                    innerJoin(
                      _db.exercises,
                      _db.exercises.id.equalsExp(
                        _db.workoutPlanExercises.exerciseId,
                      ),
                    ),
                  ])
                  ..where(_db.workoutPlanExercises.workoutPlanId.equals(planId))
                  ..orderBy([
                    OrderingTerm.asc(_db.workoutPlanExercises.position),
                  ]))
                .get();

        for (final (index, row) in planExercises.indexed) {
          final planExercise = row.readTable(_db.workoutPlanExercises);
          final exercise = row.readTable(_db.exercises);
          final sessionExerciseId = await _db
              .into(_db.workoutSessionExercises)
              .insert(
                WorkoutSessionExercisesCompanion.insert(
                  sessionId: sessionId,
                  exerciseId: exercise.id,
                  planExerciseId: Value(planExercise.id),
                  exerciseNameSnapshot: exercise.name,
                  muscleGroupSnapshot: exercise.muscleGroup,
                  position: index,
                  notes: Value(planExercise.notes),
                  restSeconds: Value(planExercise.restSeconds),
                ),
              );
          final planSets =
              await (_db.select(_db.workoutPlanSets)
                    ..where((s) => s.planExerciseId.equals(planExercise.id))
                    ..orderBy([(s) => OrderingTerm.asc(s.position)]))
                  .get();
          await _db.batch((b) {
            b.insertAll(_db.workoutSessionSets, [
              for (final (setIndex, s) in planSets.indexed)
                WorkoutSessionSetsCompanion.insert(
                  sessionExerciseId: sessionExerciseId,
                  position: setIndex,
                  plannedRepetitions: Value(s.repetitions),
                  plannedWeightKg: Value(s.weightKg),
                  repetitions: s.repetitions,
                  weightKg: s.weightKg,
                ),
            ]);
          });
        }
        return sessionId;
      });

  // ---------------------------------------------------------------------------
  // Leitura
  // ---------------------------------------------------------------------------

  Stream<SessionDetail?> watchSession(int sessionId) => _db
      .customSelect(
        'SELECT id FROM workout_sessions WHERE id = ?',
        variables: [Variable.withInt(sessionId)],
        readsFrom: {
          _db.workoutSessions,
          _db.workoutSessionExercises,
          _db.workoutSessionSets,
        },
      )
      .watch()
      .asyncMap((rows) => rows.isEmpty ? null : getSession(sessionId));

  Future<SessionDetail?> getSession(int sessionId) async {
    final session = await (_db.select(
      _db.workoutSessions,
    )..where((s) => s.id.equals(sessionId))).getSingleOrNull();
    if (session == null) return null;
    final exercises =
        await (_db.select(_db.workoutSessionExercises)
              ..where((e) => e.sessionId.equals(sessionId))
              ..orderBy([(e) => OrderingTerm.asc(e.position)]))
            .get();
    final sets =
        await (_db.select(_db.workoutSessionSets)
              ..where(
                (s) =>
                    s.sessionExerciseId.isIn([for (final e in exercises) e.id]),
              )
              ..orderBy([(s) => OrderingTerm.asc(s.position)]))
            .get();
    return SessionDetail(
      session: session,
      exercises: [
        for (final e in exercises)
          SessionExerciseDetail(
            exercise: e,
            sets: sets.where((s) => s.sessionExerciseId == e.id).toList(),
          ),
      ],
    );
  }

  /// Séries concluídas do exercício na última sessão finalizada que o
  /// contém, anterior a [before] (se informado) e diferente de
  /// [excludeSessionId]. Se o exercício aparece mais de uma vez na sessão,
  /// as séries de todas as ocorrências são retornadas, em ordem.
  Future<List<WorkoutSessionSet>> lastPerformance(
    int exerciseId, {
    int? excludeSessionId,
    DateTime? before,
  }) async {
    final row = await _db
        .customSelect(
          '''
      SELECT s.id FROM workout_session_exercises se
      JOIN workout_sessions s ON s.id = se.session_id
      WHERE se.exercise_id = ? AND s.status = ? AND s.id != ?
        AND s.started_at < ?
        AND EXISTS (SELECT 1 FROM workout_session_sets ss
                    WHERE ss.session_exercise_id = se.id
                      AND ss.completed = 1 AND ss.repetitions > 0)
      ORDER BY s.started_at DESC, s.id DESC
      LIMIT 1
      ''',
          variables: [
            Variable.withInt(exerciseId),
            _completed,
            Variable.withInt(excludeSessionId ?? -1),
            Variable.withDateTime(before ?? DateTime(9999)),
          ],
        )
        .getSingleOrNull();
    if (row == null) return const [];
    final sets = _db.workoutSessionSets;
    final exercises = _db.workoutSessionExercises;
    final query =
        _db.select(sets).join([
            innerJoin(
              exercises,
              exercises.id.equalsExp(sets.sessionExerciseId),
            ),
          ])
          ..where(
            exercises.sessionId.equals(row.read<int>('id')) &
                exercises.exerciseId.equals(exerciseId) &
                sets.completed.equals(true) &
                sets.repetitions.isBiggerThanValue(0),
          )
          ..orderBy([
            OrderingTerm.asc(exercises.position),
            OrderingTerm.asc(sets.position),
          ]);
    return [for (final r in await query.get()) r.readTable(sets)];
  }

  /// Maior peso concluído do exercício em treinos finalizados, exceto
  /// [excludeSessionId]. `null` se nunca executado.
  Future<double?> bestWeight(int exerciseId, {int? excludeSessionId}) async {
    final row = await _db
        .customSelect(
          '''
      SELECT MAX(ss.weight_kg) AS best FROM workout_session_sets ss
      JOIN workout_session_exercises se ON se.id = ss.session_exercise_id
      JOIN workout_sessions s ON s.id = se.session_id
      WHERE se.exercise_id = ? AND s.status = ? AND s.id != ?
        AND ss.completed = 1 AND ss.repetitions > 0
      ''',
          variables: [
            Variable.withInt(exerciseId),
            _completed,
            Variable.withInt(excludeSessionId ?? -1),
          ],
        )
        .getSingle();
    return row.readNullable<double>('best');
  }

  // ---------------------------------------------------------------------------
  // Edição durante o treino (cada ação é salva imediatamente)
  // ---------------------------------------------------------------------------

  Future<void> updateSet(int setId, {int? repetitions, double? weightKg}) {
    if ((repetitions ?? 0) < 0 ||
        (weightKg ?? 0) < 0 ||
        (weightKg != null && !weightKg.isFinite)) {
      throw ArgumentError('Repetições e peso devem ser ≥ 0');
    }
    return _db.transaction(() async {
      final set = await _requireEditableSet(setId);
      // Série concluída com 0 repetições sumiria das estatísticas mantendo a
      // marcação de concluída: para zerar, desfaça a conclusão antes.
      if (set.completed && repetitions == 0) {
        throw ArgumentError('Série concluída precisa de ao menos 1 repetição');
      }
      await (_db.update(
        _db.workoutSessionSets,
      )..where((s) => s.id.equals(setId))).write(
        WorkoutSessionSetsCompanion(
          repetitions: repetitions == null
              ? const Value.absent()
              : Value(repetitions),
          weightKg: weightKg == null ? const Value.absent() : Value(weightKg),
        ),
      );
    });
  }

  /// Marca a série como concluída com os valores realmente executados.
  Future<void> completeSet(
    int setId, {
    required int repetitions,
    required double weightKg,
    DateTime? completedAt,
  }) {
    if (repetitions <= 0 || weightKg < 0 || !weightKg.isFinite) {
      throw ArgumentError('Informe repetições > 0 e peso finito ≥ 0');
    }
    return _db.transaction(() async {
      await _requireEditableSet(setId);
      await (_db.update(
        _db.workoutSessionSets,
      )..where((s) => s.id.equals(setId))).write(
        WorkoutSessionSetsCompanion(
          repetitions: Value(repetitions),
          weightKg: Value(weightKg),
          completed: const Value(true),
          completedAt: Value(completedAt ?? DateTime.now()),
        ),
      );
    });
  }

  Future<void> uncompleteSet(int setId) => _db.transaction(() async {
    await _requireEditableSet(setId);
    await (_db.update(
      _db.workoutSessionSets,
    )..where((s) => s.id.equals(setId))).write(
      const WorkoutSessionSetsCompanion(
        completed: Value(false),
        completedAt: Value(null),
      ),
    );
  });

  /// Adiciona uma série copiando os valores da última série do exercício.
  Future<int> addSet(int sessionExerciseId) => _db.transaction(() async {
    await _requireEditableExercise(sessionExerciseId);
    final last =
        await (_db.select(_db.workoutSessionSets)
              ..where((s) => s.sessionExerciseId.equals(sessionExerciseId))
              ..orderBy([(s) => OrderingTerm.desc(s.position)])
              ..limit(1))
            .getSingleOrNull();
    return _db
        .into(_db.workoutSessionSets)
        .insert(
          WorkoutSessionSetsCompanion.insert(
            sessionExerciseId: sessionExerciseId,
            position: (last?.position ?? -1) + 1,
            repetitions: last?.repetitions ?? 10,
            weightKg: last?.weightKg ?? 0,
          ),
        );
  });

  /// Remove uma série ainda não executada. Séries concluídas são mantidas.
  Future<bool> removePendingSet(int setId) => _db.transaction(() async {
    await _requireEditableSet(setId);
    final deleted = await (_db.delete(
      _db.workoutSessionSets,
    )..where((s) => s.id.equals(setId) & s.completed.equals(false))).go();
    return deleted > 0;
  });

  /// Adiciona um exercício à sessão (não altera a ficha).
  Future<int> addExercise(
    int sessionId,
    int exerciseId, {
    int? restSeconds,
    int initialSets = 3,
  }) => _db.transaction(() async {
    await _requireRunning(sessionId);
    final exercise = await (_db.select(
      _db.exercises,
    )..where((e) => e.id.equals(exerciseId))).getSingle();
    final maxPosition =
        await (_db.selectOnly(_db.workoutSessionExercises)
              ..addColumns([_db.workoutSessionExercises.position.max()])
              ..where(_db.workoutSessionExercises.sessionId.equals(sessionId)))
            .map((r) => r.read(_db.workoutSessionExercises.position.max()))
            .getSingle();
    final sessionExerciseId = await _db
        .into(_db.workoutSessionExercises)
        .insert(
          WorkoutSessionExercisesCompanion.insert(
            sessionId: sessionId,
            exerciseId: exercise.id,
            exerciseNameSnapshot: exercise.name,
            muscleGroupSnapshot: exercise.muscleGroup,
            position: (maxPosition ?? -1) + 1,
            restSeconds: Value(restSeconds),
          ),
        );
    // Sugere as cargas do último treino deste exercício, se houver.
    final last = await lastPerformance(exerciseId, excludeSessionId: sessionId);
    final template = last.isNotEmpty
        ? [for (final s in last) (s.repetitions, s.weightKg)]
        : List.filled(initialSets, (10, 0.0));
    await _db.batch((b) {
      b.insertAll(_db.workoutSessionSets, [
        for (final (index, (reps, weight)) in template.indexed)
          WorkoutSessionSetsCompanion.insert(
            sessionExerciseId: sessionExerciseId,
            position: index,
            repetitions: reps,
            weightKg: weight,
          ),
      ]);
    });
    return sessionExerciseId;
  });

  Future<void> setSkipped(int sessionExerciseId, {required bool skipped}) =>
      _db.transaction(() async {
        await _requireEditableExercise(sessionExerciseId);
        await (_db.update(_db.workoutSessionExercises)
              ..where((e) => e.id.equals(sessionExerciseId)))
            .write(WorkoutSessionExercisesCompanion(skipped: Value(skipped)));
      });

  /// Aplica as cargas/reps de [values] às séries pendentes, em ordem.
  Future<void> applyValuesToPendingSets(
    int sessionExerciseId,
    List<SetValues> values,
  ) => _db.transaction(() async {
    await _requireEditableExercise(sessionExerciseId);
    final sets =
        await (_db.select(_db.workoutSessionSets)
              ..where((s) => s.sessionExerciseId.equals(sessionExerciseId))
              ..orderBy([(s) => OrderingTerm.asc(s.position)]))
            .get();
    for (final (index, set) in sets.indexed) {
      if (index >= values.length) break;
      if (set.completed) continue;
      await updateSet(
        set.id,
        repetitions: values[index].repetitions,
        weightKg: values[index].weightKg,
      );
    }
  });

  Future<void> updateNotes(int sessionId, String? notes) {
    final trimmed = notes?.trim();
    return (_db.update(
      _db.workoutSessions,
    )..where((s) => s.id.equals(sessionId))).write(
      WorkoutSessionsCompanion(
        notes: Value(trimmed == null || trimmed.isEmpty ? null : trimmed),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Finalização
  // ---------------------------------------------------------------------------

  /// Finaliza a sessão calculando a duração. Séries não concluídas são
  /// mantidas como não executadas (não contam em volume/estatísticas).
  Future<void> finishSession(int sessionId, {DateTime? finishedAt}) =>
      _db.transaction(() async {
        final session = await (_db.select(
          _db.workoutSessions,
        )..where((s) => s.id.equals(sessionId))).getSingle();
        if (session.status != SessionStatus.running) return;
        var end = finishedAt ?? DateTime.now();
        if (end.isBefore(session.startedAt)) end = session.startedAt;
        await (_db.update(
          _db.workoutSessions,
        )..where((s) => s.id.equals(sessionId))).write(
          WorkoutSessionsCompanion(
            status: const Value(SessionStatus.completed),
            finishedAt: Value(end),
            durationSeconds: Value(
              sessionDuration(session.startedAt, end).inSeconds,
            ),
            updatedAt: Value(DateTime.now()),
          ),
        );
      });

  /// Cancela o treino em andamento. Ele deixa de aparecer no histórico.
  Future<void> cancelSession(int sessionId) =>
      (_db.update(_db.workoutSessions)..where(
            (s) =>
                s.id.equals(sessionId) &
                s.status.equalsValue(SessionStatus.running),
          ))
          .write(
            WorkoutSessionsCompanion(
              status: const Value(SessionStatus.cancelled),
              finishedAt: Value(DateTime.now()),
              updatedAt: Value(DateTime.now()),
            ),
          );

  /// Exclui definitivamente um treino do histórico (ação explícita).
  Future<void> deleteSession(int sessionId) => (_db.delete(
    _db.workoutSessions,
  )..where((s) => s.id.equals(sessionId))).go();

  // ---------------------------------------------------------------------------
  // Histórico
  // ---------------------------------------------------------------------------

  static const _summarySelect = '''
    SELECT s.id, s.started_at, s.plan_name_snapshot, s.duration_seconds,
      s.notes,
      (SELECT COUNT(DISTINCT se.id) FROM workout_session_exercises se
         JOIN workout_session_sets ss ON ss.session_exercise_id = se.id
         WHERE se.session_id = s.id AND ss.completed = 1 AND ss.repetitions > 0) AS exercise_count,
      (SELECT COUNT(*) FROM workout_session_exercises se
         JOIN workout_session_sets ss ON ss.session_exercise_id = se.id
         WHERE se.session_id = s.id AND ss.completed = 1 AND ss.repetitions > 0) AS set_count,
      (SELECT COALESCE(SUM(ss.weight_kg * ss.repetitions), 0.0)
         FROM workout_session_exercises se
         JOIN workout_session_sets ss ON ss.session_exercise_id = se.id
         WHERE se.session_id = s.id AND ss.completed = 1 AND ss.repetitions > 0) AS volume
    FROM workout_sessions s
  ''';

  SessionSummary _toSummary(QueryRow row) => SessionSummary(
    id: row.read<int>('id'),
    startedAt: row.read<DateTime>('started_at'),
    planName: row.read<String>('plan_name_snapshot'),
    durationSeconds: row.readNullable<int>('duration_seconds'),
    notes: row.readNullable<String>('notes'),
    exerciseCount: row.read<int>('exercise_count'),
    setCount: row.read<int>('set_count'),
    volume: row.read<double>('volume'),
  );

  Set<ResultSetImplementation<dynamic, dynamic>> get _sessionTables => {
    _db.workoutSessions,
    _db.workoutSessionExercises,
    _db.workoutSessionSets,
  };

  /// Treinos concluídos, do mais recente ao mais antigo (paginado).
  Stream<List<SessionSummary>> watchHistory({int limit = 20}) => _db
      .customSelect(
        '$_summarySelect WHERE s.status = ? '
        'ORDER BY s.started_at DESC, s.id DESC LIMIT ?',
        variables: [_completed, Variable.withInt(limit)],
        readsFrom: _sessionTables,
      )
      .watch()
      .map((rows) => rows.map(_toSummary).toList());

  Future<SessionSummary?> getSummary(int sessionId) async {
    final row = await _db
        .customSelect(
          '$_summarySelect WHERE s.id = ?',
          variables: [Variable.withInt(sessionId)],
        )
        .getSingleOrNull();
    return row == null ? null : _toSummary(row);
  }

  /// Compara com o treino anterior da mesma ficha.
  Future<SessionComparison> compareWithPrevious(int sessionId) async {
    final detail = await getSession(sessionId);
    if (detail == null) {
      return const SessionComparison(
        previousVolume: null,
        exercisesWithLoadIncrease: 0,
      );
    }
    final session = detail.session;
    final previous = await _db
        .customSelect(
          '''
      SELECT id FROM workout_sessions
      WHERE status = ? AND id != ? AND started_at < ?
        AND (workout_plan_id = ? OR
             (workout_plan_id IS NULL AND plan_name_snapshot = ?))
      ORDER BY started_at DESC LIMIT 1
      ''',
          variables: [
            _completed,
            Variable.withInt(sessionId),
            Variable.withDateTime(session.startedAt),
            Variable<int>(session.workoutPlanId),
            Variable.withString(session.planNameSnapshot),
          ],
        )
        .getSingleOrNull();
    final previousVolume = previous == null
        ? null
        : (await getSummary(previous.read<int>('id')))?.volume;

    // Um exercício repetido na sessão conta uma única vez.
    final maxByExercise = <int, double>{};
    for (final exercise in detail.exercises) {
      final max = exercise.maxWeight;
      if (max == null) continue;
      final id = exercise.exercise.exerciseId;
      final previous = maxByExercise[id];
      if (previous == null || max > previous) maxByExercise[id] = max;
    }
    var increased = 0;
    for (final MapEntry(key: exerciseId, value: current)
        in maxByExercise.entries) {
      final last = await lastPerformance(
        exerciseId,
        excludeSessionId: sessionId,
        before: session.startedAt,
      );
      final lastMax = maxWeight(last.values);
      if (lastMax != null && current > lastMax) increased++;
    }
    return SessionComparison(
      previousVolume: previousVolume,
      exercisesWithLoadIncrease: increased,
    );
  }

  /// Recordes batidos nesta sessão em relação a todos os treinos
  /// finalizados anteriores. Sem histórico anterior não há recorde.
  Future<SessionRecords> recordsFor(int sessionId) async {
    final detail = await getSession(sessionId);
    if (detail == null || detail.session.status != SessionStatus.completed) {
      return const SessionRecords();
    }
    final startedAt = Variable.withDateTime(detail.session.startedAt);
    final id = Variable.withInt(sessionId);

    final bestTotal = await _db
        .customSelect(
          '''
      SELECT MAX(v) AS best FROM (
        SELECT SUM(ss.weight_kg * ss.repetitions) AS v
        FROM workout_sessions s
        JOIN workout_session_exercises se ON se.session_id = s.id
        JOIN workout_session_sets ss ON ss.session_exercise_id = se.id
        WHERE s.status = ? AND s.id != ? AND s.started_at < ?
          AND ss.completed = 1 AND ss.repetitions > 0
        GROUP BY s.id)
      ''',
          variables: [_completed, id, startedAt],
        )
        .getSingle();
    final previousBestTotal = bestTotal.readNullable<double>('best');

    final maxWeightRecords = <String>[];
    final volumeRecords = <String>[];
    final grouped = <int, List<SessionExerciseDetail>>{};
    for (final exercise in detail.exercises) {
      grouped.putIfAbsent(exercise.exercise.exerciseId, () => []).add(exercise);
    }
    for (final occurrences in grouped.values) {
      final exercise = SessionExerciseDetail(
        exercise: occurrences.first.exercise,
        sets: [for (final occurrence in occurrences) ...occurrence.sets],
      );
      if (!exercise.hasCompletedSets) continue;
      final exerciseId = Variable.withInt(exercise.exercise.exerciseId);
      final previous = await _db
          .customSelect(
            '''
        SELECT MAX(w) AS best_weight, MAX(v) AS best_volume FROM (
          SELECT MAX(ss.weight_kg) AS w,
                 SUM(ss.weight_kg * ss.repetitions) AS v
          FROM workout_sessions s
          JOIN workout_session_exercises se ON se.session_id = s.id
          JOIN workout_session_sets ss ON ss.session_exercise_id = se.id
          WHERE se.exercise_id = ? AND s.status = ? AND s.id != ?
            AND s.started_at < ? AND ss.completed = 1 AND ss.repetitions > 0
          GROUP BY s.id)
        ''',
            variables: [exerciseId, _completed, id, startedAt],
          )
          .getSingle();
      final bestWeight = previous.readNullable<double>('best_weight');
      final bestVolume = previous.readNullable<double>('best_volume');
      final name = exercise.exercise.exerciseNameSnapshot;
      if (bestWeight != null && (exercise.maxWeight ?? 0) > bestWeight) {
        maxWeightRecords.add(name);
      }
      if (bestVolume != null && exercise.volume > bestVolume) {
        volumeRecords.add(name);
      }
    }
    return SessionRecords(
      totalVolume:
          previousBestTotal != null && detail.volume > previousBestTotal,
      maxWeightExercises: maxWeightRecords,
      volumeExercises: volumeRecords,
    );
  }
}

final workoutSessionRepositoryProvider = Provider(
  (ref) => WorkoutSessionRepository(ref.watch(databaseProvider)),
);

final runningSessionProvider = StreamProvider<WorkoutSession?>(
  (ref) => ref.watch(workoutSessionRepositoryProvider).watchRunningSession(),
);

final sessionDetailProvider = StreamProvider.family<SessionDetail?, int>(
  (ref, id) => ref.watch(workoutSessionRepositoryProvider).watchSession(id),
);

/// Quantidade de itens carregados no histórico (aumenta ao rolar).
class HistoryLimit extends Notifier<int> {
  static const pageSize = 20;

  @override
  int build() => pageSize;

  void loadMore() => state += pageSize;
}

final historyLimitProvider = NotifierProvider<HistoryLimit, int>(
  HistoryLimit.new,
);

final historyProvider = StreamProvider<List<SessionSummary>>((ref) {
  final limit = ref.watch(historyLimitProvider);
  return ref.watch(workoutSessionRepositoryProvider).watchHistory(limit: limit);
});

/// Séries do último treino do exercício (para progressão de carga).
final lastPerformanceProvider =
    FutureProvider.family<
      List<WorkoutSessionSet>,
      ({int exerciseId, int sessionId})
    >(
      (ref, args) => ref
          .watch(workoutSessionRepositoryProvider)
          .lastPerformance(args.exerciseId, excludeSessionId: args.sessionId),
    );

/// Maior carga já registrada antes deste treino (para "novo recorde").
final previousBestWeightProvider =
    FutureProvider.family<double?, ({int exerciseId, int sessionId})>(
      (ref, args) => ref
          .watch(workoutSessionRepositoryProvider)
          .bestWeight(args.exerciseId, excludeSessionId: args.sessionId),
    );
