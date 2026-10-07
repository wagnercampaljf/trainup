import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:trainup/core/utils/formatters.dart';
import 'package:trainup/core/utils/text_normalizer.dart';

void main() {
  setUpAll(() => initializeDateFormatting(appLocale));

  group('parseDecimal', () {
    test('aceita vírgula e ponto', () {
      expect(parseDecimal('42,5'), 42.5);
      expect(parseDecimal('42.5'), 42.5);
      expect(parseDecimal(' 40 '), 40);
      expect(parseDecimal('1.042,5'), 1042.5);
    });

    test('retorna null para vazio ou inválido', () {
      expect(parseDecimal(''), isNull);
      expect(parseDecimal(null), isNull);
      expect(parseDecimal('abc'), isNull);
    });
  });

  group('formatação pt-BR', () {
    test('decimal com vírgula e milhar com ponto', () {
      expect(formatDecimal(42.5), '42,5');
      expect(formatDecimal(40), '40');
      expect(formatVolume(8420), '8.420 kg');
      expect(formatWeight(42.5), '42,5 kg');
      expect(decimalToInput(1042.5), '1042,5');
    });

    test('datas dd/MM/yyyy', () {
      expect(formatDate(DateTime(2026, 10, 4)), '04/10/2026');
      expect(formatShortDate(DateTime(2026, 1, 8)), '08/01');
    });

    test('durações', () {
      expect(formatDuration(const Duration(hours: 1, minutes: 8)), '1h08min');
      expect(formatDuration(const Duration(minutes: 45)), '45min');
      expect(formatDuration(const Duration(seconds: 30)), '30s');
      expect(formatClock(const Duration(seconds: 92)), '01:32');
      expect(formatClock(const Duration(seconds: -3)), '00:00');
    });

    test('descanso mantém os segundos', () {
      expect(formatRest(const Duration(seconds: 45)), '45s');
      expect(formatRest(const Duration(seconds: 60)), '1min');
      expect(formatRest(const Duration(seconds: 75)), '1min15s');
      expect(formatRest(const Duration(seconds: 90)), '1min30s');
      expect(formatRest(const Duration(seconds: 150)), '2min30s');
      expect(formatRest(const Duration(minutes: 3)), '3min');
      // Opções do seletor de descanso padrão não podem ter rótulos repetidos.
      final labels = [
        30,
        45,
        60,
        90,
        120,
        150,
        180,
        240,
        300,
      ].map((s) => formatRest(Duration(seconds: s))).toSet();
      expect(labels, hasLength(9));
    });

    test('sinal explícito', () {
      expect(formatSigned(2.5), '+2,5');
      expect(formatSigned(-620), '-620');
      expect(formatSigned(0), '0');
    });
  });

  test('normalizeName remove acentos, caixa e espaços', () {
    expect(normalizeName('  Tríceps   Francês! '), 'triceps frances');
    expect(normalizeName('Supino Reto'), normalizeName('supino  reto'));
  });
}
