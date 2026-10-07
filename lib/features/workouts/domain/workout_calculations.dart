/// Dados mínimos de uma série para cálculos.
typedef SetValues = ({double weightKg, int repetitions});

/// Volume de uma série: peso × repetições.
double setVolume(double weightKg, int repetitions) => weightKg * repetitions;

/// Soma do volume de uma lista de séries (já filtradas como concluídas).
double totalVolume(Iterable<SetValues> sets) =>
    sets.fold(0, (sum, s) => sum + setVolume(s.weightKg, s.repetitions));

/// Maior peso entre as séries, ou `null` se vazio.
double? maxWeight(Iterable<SetValues> sets) {
  double? result;
  for (final s in sets) {
    if (result == null || s.weightKg > result) result = s.weightKg;
  }
  return result;
}

/// Duração entre início e fim (nunca negativa).
Duration sessionDuration(DateTime startedAt, DateTime finishedAt) {
  final diff = finishedAt.difference(startedAt);
  return diff.isNegative ? Duration.zero : diff;
}
