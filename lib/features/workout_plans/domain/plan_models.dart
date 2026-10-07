import '../../exercises/domain/muscle_group.dart';

/// Série planejada (mutável para facilitar a edição em formulário).
class PlanSetDraft {
  PlanSetDraft({required this.repetitions, required this.weightKg, this.notes});

  int repetitions;
  double weightKg;
  String? notes;

  PlanSetDraft copy() =>
      PlanSetDraft(repetitions: repetitions, weightKg: weightKg, notes: notes);
}

/// Exercício dentro da ficha com suas séries.
class PlanExerciseDraft {
  PlanExerciseDraft({
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    this.id,
    this.notes,
    this.restSeconds,
    List<PlanSetDraft>? sets,
  }) : sets = sets ?? [];

  /// `null` para exercícios ainda não salvos.
  final int? id;
  final int exerciseId;
  final String exerciseName;
  final MuscleGroup muscleGroup;
  String? notes;
  int? restSeconds;
  final List<PlanSetDraft> sets;
}

/// Ficha completa (leitura e edição).
class PlanDraft {
  PlanDraft({
    this.id,
    this.name = '',
    this.description,
    List<PlanExerciseDraft>? exercises,
  }) : exercises = exercises ?? [];

  final int? id;
  String name;
  String? description;
  final List<PlanExerciseDraft> exercises;

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets.length);
}

/// Item da listagem de fichas.
class PlanSummary {
  const PlanSummary({
    required this.id,
    required this.name,
    required this.exerciseCount,
    this.description,
    this.lastPerformedAt,
  });

  final int id;
  final String name;
  final String? description;
  final int exerciseCount;
  final DateTime? lastPerformedAt;
}
