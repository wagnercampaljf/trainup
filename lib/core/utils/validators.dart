import 'formatters.dart';

/// Validadores reutilizáveis de formulário. Retornam a mensagem de erro ou
/// `null` quando o valor é válido.
abstract final class Validators {
  static String? required(String? value, {String field = 'Campo'}) =>
      (value == null || value.trim().isEmpty) ? '$field obrigatório' : null;

  /// Número decimal dentro de [min]..[max]. Se [optional], vazio é válido.
  static String? decimalRange(
    String? value, {
    required double min,
    required double max,
    bool optional = false,
    String unit = '',
  }) {
    if (value == null || value.trim().isEmpty) {
      return optional ? null : 'Obrigatório';
    }
    final number = parseDecimal(value);
    if (number == null) return 'Número inválido';
    if (number < min || number > max) {
      final suffix = unit.isEmpty ? '' : ' $unit';
      return 'Entre ${formatDecimal(min)} e ${formatDecimal(max)}$suffix';
    }
    return null;
  }

  static String? bodyWeight(String? value) =>
      decimalRange(value, min: 20, max: 400, unit: 'kg');

  static String? height(String? value) =>
      decimalRange(value, min: 50, max: 272, unit: 'cm');

  static String? bodyFat(String? value) =>
      decimalRange(value, min: 0, max: 100, optional: true, unit: '%');

  static String? bodyMeasure(String? value) =>
      decimalRange(value, min: 1, max: 300, optional: true, unit: 'cm');

  static String? repetitions(String? value) {
    if (value == null || value.trim().isEmpty) return 'Obrigatório';
    final reps = int.tryParse(value.trim());
    if (reps == null) return 'Inteiro';
    return reps < 0 ? '≥ 0' : null;
  }

  static String? liftWeight(String? value) =>
      decimalRange(value, min: 0, max: 1000);
}
