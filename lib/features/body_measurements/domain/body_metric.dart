import '../../../core/database/app_database.dart';

/// Indicadores corporais acompanhados no histórico.
enum BodyMetric {
  weight('Peso', 'kg', 20, 400),
  bodyFat('Gordura corporal', '%', 0, 100),
  neck('Pescoço', 'cm', 1, 300),
  shoulders('Ombros', 'cm', 1, 300),
  chest('Peitoral', 'cm', 1, 300),
  leftArm('Braço esquerdo', 'cm', 1, 300),
  rightArm('Braço direito', 'cm', 1, 300),
  leftForearm('Antebraço esquerdo', 'cm', 1, 300),
  rightForearm('Antebraço direito', 'cm', 1, 300),
  waist('Cintura', 'cm', 1, 300),
  abdomen('Abdômen', 'cm', 1, 300),
  hips('Quadril', 'cm', 1, 300),
  leftThigh('Coxa esquerda', 'cm', 1, 300),
  rightThigh('Coxa direita', 'cm', 1, 300),
  leftCalf('Panturrilha esquerda', 'cm', 1, 300),
  rightCalf('Panturrilha direita', 'cm', 1, 300);

  const BodyMetric(this.label, this.unit, this.min, this.max);

  final String label;
  final String unit;
  final double min;
  final double max;

  /// Medidas em cm (exclui peso e gordura).
  static List<BodyMetric> get circumferences =>
      values.where((m) => m.unit == 'cm').toList();

  double? valueOf(BodyMeasurement m) => switch (this) {
    weight => m.weightKg,
    bodyFat => m.bodyFatPercentage,
    neck => m.neck,
    shoulders => m.shoulders,
    chest => m.chest,
    leftArm => m.leftArm,
    rightArm => m.rightArm,
    leftForearm => m.leftForearm,
    rightForearm => m.rightForearm,
    waist => m.waist,
    abdomen => m.abdomen,
    hips => m.hips,
    leftThigh => m.leftThigh,
    rightThigh => m.rightThigh,
    leftCalf => m.leftCalf,
    rightCalf => m.rightCalf,
  };
}

/// Dados de uma medição a criar/editar.
class BodyMeasurementInput {
  const BodyMeasurementInput({
    required this.date,
    required this.values,
    this.notes,
  });

  final DateTime date;

  /// Deve conter [BodyMetric.weight]. Ausente/nulo = não informado.
  final Map<BodyMetric, double?> values;
  final String? notes;

  double? operator [](BodyMetric metric) => values[metric];
}
