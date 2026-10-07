/// Evolução percentual: ((atual - inicial) / inicial) × 100.
///
/// Retorna `null` quando o valor inicial é zero (divisão indefinida).
double? percentChange(double initial, double current) {
  if (initial == 0) return null;
  return (current - initial) / initial * 100;
}

/// Resumo de uma série temporal de valores (ordem cronológica).
class ProgressSummary {
  const ProgressSummary({
    required this.initial,
    required this.current,
    required this.max,
    required this.min,
  });

  /// Retorna `null` se não houver valores.
  static ProgressSummary? fromValues(List<double> chronological) {
    if (chronological.isEmpty) return null;
    var max = chronological.first;
    var min = chronological.first;
    for (final v in chronological) {
      if (v > max) max = v;
      if (v < min) min = v;
    }
    return ProgressSummary(
      initial: chronological.first,
      current: chronological.last,
      max: max,
      min: min,
    );
  }

  final double initial;
  final double current;
  final double max;
  final double min;

  double get absoluteChange => current - initial;

  double? get percent => percentChange(initial, current);
}
