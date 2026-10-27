import '../../../core/database/app_database.dart';
import 'workout_calculations.dart' as calc;

extension SessionSetValues on Iterable<WorkoutSessionSet> {
  Iterable<WorkoutSessionSet> get completed =>
      where((s) => s.completed && s.repetitions > 0);

  Iterable<calc.SetValues> get values =>
      map((s) => (weightKg: s.weightKg, repetitions: s.repetitions));
}

/// Exercício de uma sessão com suas séries.
class SessionExerciseDetail {
  const SessionExerciseDetail({required this.exercise, required this.sets});

  final WorkoutSessionExercise exercise;
  final List<WorkoutSessionSet> sets;

  List<WorkoutSessionSet> get completedSets => sets.completed.toList();

  bool get hasCompletedSets => completedSets.isNotEmpty;

  bool get isDone => sets.isNotEmpty && sets.every((s) => s.completed);

  double get volume => calc.totalVolume(sets.completed.values);

  double? get maxWeight => calc.maxWeight(sets.completed.values);
}

/// Sessão completa (cabeçalho + exercícios + séries).
class SessionDetail {
  const SessionDetail({required this.session, required this.exercises});

  final WorkoutSession session;
  final List<SessionExerciseDetail> exercises;

  int get completedSetCount =>
      exercises.fold(0, (sum, e) => sum + e.completedSets.length);

  int get performedExerciseCount =>
      exercises.where((e) => e.hasCompletedSets).length;

  /// Séries do treino: todas as dos exercícios ativos e, dos pulados, só as
  /// que chegaram a ser concluídas.
  int get plannedSetCount => exercises.fold(
    0,
    (sum, e) =>
        sum + (e.exercise.skipped ? e.completedSets.length : e.sets.length),
  );

  /// Séries ainda não marcadas nos exercícios ativos.
  int get pendingSetCount => exercises
      .where((e) => !e.exercise.skipped)
      .fold(0, (sum, e) => sum + e.sets.where((s) => !s.completed).length);

  /// Exercício da próxima série pendente (o "em execução").
  SessionExerciseDetail? get currentExercise {
    final next = nextPendingSet;
    if (next == null) return null;
    for (final e in exercises) {
      if (e.sets.any((s) => s.id == next.id)) return e;
    }
    return null;
  }

  double get volume => exercises.fold(0, (sum, e) => sum + e.volume);

  Duration duration(DateTime now) {
    final seconds = session.durationSeconds;
    if (seconds != null) return Duration(seconds: seconds);
    return calc.sessionDuration(session.startedAt, session.finishedAt ?? now);
  }

  /// Próxima série pendente (exercícios não pulados, em ordem).
  WorkoutSessionSet? get nextPendingSet {
    for (final e in exercises) {
      if (e.exercise.skipped) continue;
      for (final s in e.sets) {
        if (!s.completed) return s;
      }
    }
    return null;
  }
}

/// Linha do histórico de treinos.
class SessionSummary {
  const SessionSummary({
    required this.id,
    required this.startedAt,
    required this.planName,
    required this.exerciseCount,
    required this.setCount,
    required this.volume,
    this.durationSeconds,
    this.notes,
  });

  final int id;
  final DateTime startedAt;
  final String planName;
  final int? durationSeconds;
  final int exerciseCount;
  final int setCount;
  final double volume;
  final String? notes;

  Duration? get duration =>
      durationSeconds == null ? null : Duration(seconds: durationSeconds!);
}

/// Comparação de uma sessão com o treino anterior da mesma ficha.
class SessionComparison {
  const SessionComparison({
    required this.previousVolume,
    required this.exercisesWithLoadIncrease,
  });

  /// `null` quando não há treino anterior da mesma ficha.
  final double? previousVolume;
  final int exercisesWithLoadIncrease;
}

/// Recordes pessoais batidos em uma sessão.
class SessionRecords {
  const SessionRecords({
    this.totalVolume = false,
    this.maxWeightExercises = const [],
    this.volumeExercises = const [],
  });

  final bool totalVolume;
  final List<String> maxWeightExercises;
  final List<String> volumeExercises;

  bool get isEmpty =>
      !totalVolume && maxWeightExercises.isEmpty && volumeExercises.isEmpty;
}
