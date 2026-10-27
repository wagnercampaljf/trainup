import 'package:intl/intl.dart';

import '../../features/settings/domain/app_preferences.dart';

const appLocale = 'pt_BR';

final _date = DateFormat('dd/MM/yyyy', appLocale);
final _shortDate = DateFormat('dd/MM', appLocale);
final _dateTime = DateFormat("dd/MM/yyyy 'às' HH:mm", appLocale);

String formatDate(DateTime date) => _date.format(date);

String formatShortDate(DateTime date) => _shortDate.format(date);

String formatDateTime(DateTime date) => _dateTime.format(date);

final _monthYear = DateFormat("MMMM 'de' y", appLocale);

/// Mês por extenso com inicial maiúscula: "Outubro de 2026".
String formatMonthYear(DateTime date) {
  final text = _monthYear.format(date);
  return text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}

/// Número com vírgula decimal e separador de milhar (pt-BR).
String formatDecimal(num value, {int maxDecimals = 2}) {
  final format = NumberFormat.decimalPattern(appLocale)
    ..minimumFractionDigits = 0
    ..maximumFractionDigits = maxDecimals;
  return format.format(value);
}

/// Peso armazenado em kg formatado na unidade de exibição.
String formatWeight(double kg, {WeightUnit unit = WeightUnit.kg}) =>
    '${formatDecimal(unit.fromKg(kg))} ${unit.symbol}';

/// Volume (kg) sem casas decimais: "8.420 kg".
String formatVolume(double kg, {WeightUnit unit = WeightUnit.kg}) =>
    '${formatDecimal(unit.fromKg(kg), maxDecimals: 0)} ${unit.symbol}';

/// Diferença com sinal explícito: "+2,5", "-1".
String formatSigned(num value, {int maxDecimals = 2}) {
  final text = formatDecimal(value.abs(), maxDecimals: maxDecimals);
  if (value > 0) return '+$text';
  if (value < 0) return '-$text';
  return text;
}

/// Duração legível de treino: "1h08min", "45min", "30s".
String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours > 0) return '${hours}h${minutes.toString().padLeft(2, '0')}min';
  if (duration.inMinutes > 0) return '${duration.inMinutes}min';
  return '${duration.inSeconds}s';
}

/// Tempo de descanso sem perder segundos: "45s", "1min30s", "2min".
String formatRest(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60);
  if (minutes == 0) return '${seconds}s';
  if (seconds == 0) return '${minutes}min';
  return '${minutes}min${seconds.toString().padLeft(2, '0')}s';
}

/// Relógio "mm:ss" (ou "h:mm:ss" acima de uma hora).
String formatClock(Duration duration) {
  final safe = duration.isNegative ? Duration.zero : duration;
  final hours = safe.inHours;
  final minutes = safe.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = safe.inSeconds.remainder(60).toString().padLeft(2, '0');
  return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
}

/// Converte texto digitado pelo usuário ("42,5", "1.042,5", "42.5") em
/// número. Retorna `null` para vazio ou inválido.
double? parseDecimal(String? input) {
  if (input == null) return null;
  var text = input.trim().replaceAll(' ', '');
  if (text.isEmpty) return null;
  if (text.contains(',')) {
    // Formato pt-BR: ponto é separador de milhar.
    text = text.replaceAll('.', '').replaceAll(',', '.');
  }
  final value = double.tryParse(text);
  if (value == null || value.isNaN || value.isInfinite) return null;
  return value;
}

/// Valor para preencher campos de texto editáveis ("42,5", "40").
String decimalToInput(double? value) =>
    value == null ? '' : formatDecimal(value).replaceAll('.', '');
