import '../../workouts/domain/workout_calculations.dart';
import 'chart_point.dart';

/// Execução de um exercício em um treino (somente séries concluídas).
class ExerciseSessionEntry {
  const ExerciseSessionEntry({
    required this.sessionId,
    required this.date,
    required this.sets,
  });

  final int sessionId;
  final DateTime date;
  final List<SetValues> sets;

  double get maxWeight => sets.isEmpty ? 0 : _maxWeight(sets);

  double get averageWeight => sets.isEmpty
      ? 0
      : sets.fold<double>(0, (sum, s) => sum + s.weightKg) / sets.length;

  double get volume => totalVolume(sets);

  /// Melhor série = maior volume em uma única série (peso × reps).
  double get bestSetVolume => sets.fold<double>(0, (best, s) {
    final v = setVolume(s.weightKg, s.repetitions);
    return v > best ? v : best;
  });
}

double _maxWeight(List<SetValues> sets) => maxWeight(sets) ?? 0;

/// Métricas disponíveis no gráfico de evolução de carga.
enum ExerciseMetric {
  maxWeight('Maior peso', 'kg'),
  averageWeight('Peso médio', 'kg'),
  volume('Volume total', 'kg'),
  bestSet('Melhor série', 'kg');

  const ExerciseMetric(this.label, this.unit);

  final String label;
  final String unit;

  double valueOf(ExerciseSessionEntry entry) => switch (this) {
    maxWeight => entry.maxWeight,
    averageWeight => entry.averageWeight,
    volume => entry.volume,
    bestSet => entry.bestSetVolume,
  };

  /// Pontos em ordem cronológica a partir de entradas em qualquer ordem.
  List<ChartPoint> series(List<ExerciseSessionEntry> entries) {
    final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));
    return [for (final e in sorted) ChartPoint(e.date, valueOf(e))];
  }
}

/// Indicadores agregados do exercício.
class ExerciseStats {
  const ExerciseStats({
    required this.sessionCount,
    this.maxWeight,
    this.lastWeight,
    this.maxVolume,
  });

  /// [entries] do mais recente para o mais antigo.
  factory ExerciseStats.from(List<ExerciseSessionEntry> entries) {
    if (entries.isEmpty) return const ExerciseStats(sessionCount: 0);
    var best = 0.0;
    var bestVolume = 0.0;
    for (final e in entries) {
      if (e.maxWeight > best) best = e.maxWeight;
      if (e.volume > bestVolume) bestVolume = e.volume;
    }
    return ExerciseStats(
      sessionCount: entries.length,
      maxWeight: best,
      lastWeight: entries.first.maxWeight,
      maxVolume: bestVolume,
    );
  }

  final int sessionCount;
  final double? maxWeight;
  final double? lastWeight;
  final double? maxVolume;
}

/// Exercício com histórico (lista da tela de evolução).
class ExerciseWithHistory {
  const ExerciseWithHistory({
    required this.exerciseId,
    required this.name,
    required this.sessionCount,
    required this.lastDate,
  });

  final int exerciseId;
  final String name;
  final int sessionCount;
  final DateTime lastDate;
}

/// Indicadores resumidos da Home.
class DashboardStats {
  const DashboardStats({
    required this.workoutsThisMonth,
    required this.volumeThisMonth,
    required this.exercisesImproved,
  });

  final int workoutsThisMonth;
  final double volumeThisMonth;
  final int exercisesImproved;
}
