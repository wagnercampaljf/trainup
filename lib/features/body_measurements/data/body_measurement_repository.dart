import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../domain/body_metric.dart';

class BodyMeasurementRepository {
  BodyMeasurementRepository(this._db);

  final AppDatabase _db;

  /// Histórico do mais recente para o mais antigo.
  Stream<List<BodyMeasurement>> watchAll() =>
      (_db.select(_db.bodyMeasurements)..orderBy([
            (m) => OrderingTerm.desc(m.date),
            (m) => OrderingTerm.desc(m.id),
          ]))
          .watch();

  Stream<BodyMeasurement?> watchLatest() =>
      (_db.select(_db.bodyMeasurements)
            ..orderBy([
              (m) => OrderingTerm.desc(m.date),
              (m) => OrderingTerm.desc(m.id),
            ])
            ..limit(1))
          .watchSingleOrNull();

  Future<BodyMeasurement?> getById(int id) => (_db.select(
    _db.bodyMeasurements,
  )..where((m) => m.id.equals(id))).getSingleOrNull();

  Future<int> create(BodyMeasurementInput input) =>
      _db.into(_db.bodyMeasurements).insert(_companion(input));

  Future<void> update(int id, BodyMeasurementInput input) async {
    await (_db.update(_db.bodyMeasurements)..where((m) => m.id.equals(id)))
        .write(_companion(input).copyWith(updatedAt: Value(DateTime.now())));
  }

  Future<void> delete(int id) =>
      (_db.delete(_db.bodyMeasurements)..where((m) => m.id.equals(id))).go();

  static BodyMeasurementsCompanion _companion(BodyMeasurementInput input) {
    final weight = input[BodyMetric.weight];
    if (weight == null) {
      throw ArgumentError('Peso é obrigatório');
    }
    for (final entry in input.values.entries) {
      final value = entry.value;
      if (value != null &&
          (!value.isFinite || value < entry.key.min || value > entry.key.max)) {
        throw ArgumentError('${entry.key.label} fora do intervalo válido');
      }
    }
    Value<double?> v(BodyMetric m) => Value(input[m]);
    final notes = input.notes?.trim();
    return BodyMeasurementsCompanion(
      date: Value(DateTime(input.date.year, input.date.month, input.date.day)),
      weightKg: Value(weight),
      bodyFatPercentage: v(BodyMetric.bodyFat),
      neck: v(BodyMetric.neck),
      shoulders: v(BodyMetric.shoulders),
      chest: v(BodyMetric.chest),
      leftArm: v(BodyMetric.leftArm),
      rightArm: v(BodyMetric.rightArm),
      leftForearm: v(BodyMetric.leftForearm),
      rightForearm: v(BodyMetric.rightForearm),
      waist: v(BodyMetric.waist),
      abdomen: v(BodyMetric.abdomen),
      hips: v(BodyMetric.hips),
      leftThigh: v(BodyMetric.leftThigh),
      rightThigh: v(BodyMetric.rightThigh),
      leftCalf: v(BodyMetric.leftCalf),
      rightCalf: v(BodyMetric.rightCalf),
      notes: Value(notes == null || notes.isEmpty ? null : notes),
    );
  }
}

final bodyMeasurementRepositoryProvider = Provider(
  (ref) => BodyMeasurementRepository(ref.watch(databaseProvider)),
);

final bodyMeasurementsProvider = StreamProvider<List<BodyMeasurement>>(
  (ref) => ref.watch(bodyMeasurementRepositoryProvider).watchAll(),
);

final latestBodyMeasurementProvider = StreamProvider<BodyMeasurement?>(
  (ref) => ref.watch(bodyMeasurementRepositoryProvider).watchLatest(),
);
