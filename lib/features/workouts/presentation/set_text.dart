import '../../../core/utils/formatters.dart';
import '../domain/workout_calculations.dart';

/// "12 × 30 kg"
String formatSet(int repetitions, double weightKg) =>
    '$repetitions × ${formatWeight(weightKg)}';

/// "12 × 30 · 10 × 35 · 8 × 40 kg" (resumo compacto de várias séries).
String formatSetsInline(Iterable<SetValues> sets) {
  final list = sets.toList();
  if (list.isEmpty) return 'Nenhuma série';
  return '${list.map((s) => '${s.repetitions} × ${formatDecimal(s.weightKg)}').join(' · ')} kg';
}
