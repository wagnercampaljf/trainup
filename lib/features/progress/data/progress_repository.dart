import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/utils/clock.dart';
import '../../settings/presentation/settings_controller.dart';
import '../../workouts/domain/session_status.dart';
import '../domain/exercise_progress.dart';
import '../domain/training_frequency.dart';

class ProgressRepository {
  ProgressRepository(this._db);

  final AppDatabase _db;

  static final _completed = Variable.withString(SessionStatus.completed.name);

  Set<ResultSetImplementation<dynamic, dynamic>> get _tables => {
    _db.workoutSessions,
    _db.workoutSessionExercises,
    _db.workoutSessionSets,
    _db.exercises,
  };

  /// Execuções do exercício em treinos concluídos, da mais recente para a
  /// mais antiga. Uma entrada por sessão (agrega se repetido na sessão).
  Stream<List<ExerciseSessionEntry>> watchExerciseHistory(int exerciseId) => _db
      .customSelect(
        '''
        SELECT s.id AS session_id, s.started_at, ss.weight_kg, ss.repetitions
        FROM workout_session_sets ss
        JOIN workout_session_exercises se ON se.id = ss.session_exercise_id
        JOIN workout_sessions s ON s.id = se.session_id
        WHERE se.exercise_id = ? AND s.status = ? AND ss.completed = 1 AND ss.repetitions > 0
        ORDER BY s.started_at DESC, s.id DESC, se.position, ss.position
        ''',
        variables: [Variable.withInt(exerciseId), _completed],
        readsFrom: _tables,
      )
      .watch()
      .map(_groupBySession);

  static List<ExerciseSessionEntry> _groupBySession(List<QueryRow> rows) {
    final entries = <ExerciseSessionEntry>[];
    for (final row in rows) {
      final sessionId = row.read<int>('session_id');
      final set = (
        weightKg: row.read<double>('weight_kg'),
        repetitions: row.read<int>('repetitions'),
      );
      if (entries.isNotEmpty && entries.last.sessionId == sessionId) {
        entries.last.sets.add(set);
      } else {
        entries.add(
          ExerciseSessionEntry(
            sessionId: sessionId,
            date: row.read<DateTime>('started_at'),
            sets: [set],
          ),
        );
      }
    }
    return entries;
  }

  /// Evolução da carga (maior peso por treino) de cada exercício com ao
  /// menos uma série concluída, do treinado mais recentemente ao mais antigo.
  Stream<List<ExerciseLoadEvolution>> watchLoadEvolution() => _db
      .customSelect(
        '''
        SELECT e.id, e.name, s.started_at, MAX(ss.weight_kg) AS max_weight
        FROM workout_session_sets ss
        JOIN workout_session_exercises se ON se.id = ss.session_exercise_id
        JOIN workout_sessions s ON s.id = se.session_id
        JOIN exercises e ON e.id = se.exercise_id
        WHERE s.status = ? AND ss.completed = 1 AND ss.repetitions > 0
        GROUP BY e.id, s.id
        ORDER BY s.started_at, s.id
        ''',
        variables: [_completed],
        readsFrom: _tables,
      )
      .watch()
      .map((rows) {
        final names = <int, String>{};
        final weights = <int, List<double>>{};
        final lastDates = <int, DateTime>{};
        for (final r in rows) {
          final id = r.read<int>('id');
          names[id] = r.read<String>('name');
          (weights[id] ??= []).add(r.read<double>('max_weight'));
          lastDates[id] = r.read<DateTime>('started_at');
        }
        return [
          for (final id in names.keys)
            ExerciseLoadEvolution(
              exerciseId: id,
              name: names[id]!,
              lastDate: lastDates[id]!,
              maxWeights: weights[id]!,
            ),
        ]..sort((a, b) => b.lastDate.compareTo(a.lastDate));
      });

  /// Treinos concluídos desde [from], em ordem cronológica.
  Stream<List<CompletedWorkout>> watchCompletedWorkouts({
    required DateTime from,
    DateTime? until,
  }) => _db
      .customSelect(
        '''
        SELECT id, started_at, plan_name_snapshot FROM workout_sessions
        WHERE status = ? AND started_at >= ?
          ${until == null ? '' : 'AND started_at < ?'}
        ORDER BY started_at, id
        ''',
        variables: [
          _completed,
          Variable.withDateTime(from),
          if (until != null) Variable.withDateTime(until),
        ],
        readsFrom: {_db.workoutSessions},
      )
      .watch()
      .map(
        (rows) => [
          for (final r in rows)
            (
              id: r.read<int>('id'),
              startedAt: r.read<DateTime>('started_at'),
              planName: r.read<String>('plan_name_snapshot'),
            ),
        ],
      );

  /// Indicadores do mês corrente e evolução de carga.
  Stream<DashboardStats> watchDashboard(DateTime now) {
    final monthStart = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);
    final month = _db
        .customSelect(
          '''
          SELECT
            (SELECT COUNT(*) FROM workout_sessions
               WHERE status = ?1 AND started_at >= ?2 AND started_at < ?3)
               AS workouts,
            (SELECT COALESCE(SUM(ss.weight_kg * ss.repetitions), 0.0)
               FROM workout_sessions s
               JOIN workout_session_exercises se ON se.session_id = s.id
               JOIN workout_session_sets ss ON ss.session_exercise_id = se.id
               WHERE s.status = ?1 AND s.started_at >= ?2
                 AND s.started_at < ?3 AND ss.completed = 1 AND ss.repetitions > 0) AS volume
          ''',
          variables: [
            _completed,
            Variable.withDateTime(monthStart),
            Variable.withDateTime(nextMonth),
          ],
          readsFrom: _tables,
        )
        .watchSingle();
    return month.asyncMap((r) async {
      return DashboardStats(
        workoutsThisMonth: r.read<int>('workouts'),
        volumeThisMonth: r.read<double>('volume'),
        exercisesImproved: await _countImprovedExercises(),
      );
    });
  }

  /// Exercícios cuja maior carga no treino mais recente supera a do
  /// primeiro treino registrado.
  Future<int> _countImprovedExercises() async {
    final rows = await _db
        .customSelect(
          '''
      SELECT se.exercise_id, MAX(ss.weight_kg) AS max_weight
      FROM workout_session_sets ss
      JOIN workout_session_exercises se ON se.id = ss.session_exercise_id
      JOIN workout_sessions s ON s.id = se.session_id
      WHERE s.status = ? AND ss.completed = 1 AND ss.repetitions > 0
      GROUP BY se.exercise_id, s.id
      ORDER BY s.started_at, s.id
      ''',
          variables: [_completed],
        )
        .get();
    final first = <int, double>{};
    final last = <int, double>{};
    for (final row in rows) {
      final id = row.read<int>('exercise_id');
      final weight = row.read<double>('max_weight');
      first.putIfAbsent(id, () => weight);
      last[id] = weight;
    }
    return last.entries.where((e) => e.value > first[e.key]!).length;
  }
}

final progressRepositoryProvider = Provider(
  (ref) => ProgressRepository(ref.watch(databaseProvider)),
);

final exerciseHistoryProvider =
    StreamProvider.family<List<ExerciseSessionEntry>, int>(
      (ref, exerciseId) => ref
          .watch(progressRepositoryProvider)
          .watchExerciseHistory(exerciseId),
    );

final loadEvolutionProvider = StreamProvider<List<ExerciseLoadEvolution>>(
  (ref) => ref.watch(progressRepositoryProvider).watchLoadEvolution(),
);

/// Frequência da semana e do mês, com a meta das configurações.
final trainingFrequencyProvider = StreamProvider<TrainingFrequency>((ref) {
  final now = ref.watch(clockProvider)();
  final goal = ref.watch(settingsProvider.select((s) => s.weeklyGoal));
  return ref
      .watch(progressRepositoryProvider)
      .watchCompletedWorkouts(from: TrainingFrequency.historyStart(now))
      .map(
        (workouts) => TrainingFrequency.from(
          workouts.map((w) => w.startedAt),
          now: now,
          weeklyGoal: goal,
        ),
      );
});

/// Treinos concluídos no mês de [month] (calendário do histórico).
final monthWorkoutsProvider =
    StreamProvider.family<List<CompletedWorkout>, DateTime>(
      (ref, month) => ref
          .watch(progressRepositoryProvider)
          .watchCompletedWorkouts(
            from: DateTime(month.year, month.month),
            until: DateTime(month.year, month.month + 1),
          ),
    );

final dashboardStatsProvider = StreamProvider<DashboardStats>((ref) {
  final now = ref.watch(clockProvider)();
  return ref.watch(progressRepositoryProvider).watchDashboard(now);
});
