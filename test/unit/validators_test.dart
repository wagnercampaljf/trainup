import 'package:flutter_test/flutter_test.dart';
import 'package:trainup/core/utils/validators.dart';

void main() {
  test('obrigatório', () {
    expect(Validators.required(''), isNotNull);
    expect(Validators.required('  '), isNotNull);
    expect(Validators.required('Ficha A'), isNull);
  });

  test('altura e peso corporal plausíveis', () {
    expect(Validators.height('178'), isNull);
    expect(Validators.height('17'), isNotNull);
    expect(Validators.height('400'), isNotNull);
    expect(Validators.bodyWeight('95'), isNull);
    expect(Validators.bodyWeight('94,2'), isNull);
    expect(Validators.bodyWeight('5'), isNotNull);
  });

  test('gordura entre 0 e 100 e opcional', () {
    expect(Validators.bodyFat(''), isNull);
    expect(Validators.bodyFat('22,5'), isNull);
    expect(Validators.bodyFat('101'), isNotNull);
    expect(Validators.bodyFat('-1'), isNotNull);
  });

  test('repetições e carga ≥ 0', () {
    expect(Validators.repetitions('0'), isNull);
    expect(Validators.repetitions('12'), isNull);
    expect(Validators.repetitions('-1'), isNotNull);
    expect(Validators.repetitions('1,5'), isNotNull);
    expect(Validators.liftWeight('0'), isNull);
    expect(Validators.liftWeight('42,5'), isNull);
    expect(Validators.liftWeight('-2'), isNotNull);
  });
}
