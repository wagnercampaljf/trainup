import 'package:flutter_test/flutter_test.dart';
import 'package:trainup/core/database/app_database.dart';
import 'package:trainup/features/body_measurements/data/body_measurement_repository.dart';
import 'package:trainup/features/body_measurements/domain/body_metric.dart';
import 'package:trainup/features/profile/data/profile_repository.dart';

import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  test('onboarding cria perfil e medição inicial', () async {
    final profiles = ProfileRepository(db);
    expect(await profiles.hasProfile(), isFalse);
    await profiles.completeOnboarding(
      const ProfileInput(name: 'Wagner', heightCm: 178),
      BodyMeasurementInput(
        date: DateTime(2026, 10, 1),
        values: {BodyMetric.weight: 95, BodyMetric.waist: 100},
      ),
    );
    expect(await profiles.hasProfile(), isTrue);
    final latest = await BodyMeasurementRepository(db).watchLatest().first;
    expect(latest!.weightKg, 95);
    expect(latest.waist, 100);
  });

  test('perfil rejeita altura implausível', () {
    expect(
      () =>
          ProfileRepository(db)
              .saveProfile(const ProfileInput(name: 'A', heightCm: 20)),
      throwsArgumentError,
    );
  });

  test('novas medições geram histórico (não sobrescrevem)', () async {
    final repo = BodyMeasurementRepository(db);
    await repo.create(
      BodyMeasurementInput(
        date: DateTime(2026, 10, 1),
        values: {BodyMetric.weight: 95},
      ),
    );
    final id = await repo.create(
      BodyMeasurementInput(
        date: DateTime(2026, 10, 15),
        values: {BodyMetric.weight: 93.5},
      ),
    );
    final all = await repo.watchAll().first;
    expect(all.map((m) => m.weightKg), [93.5, 95]);

    await repo.update(
      id,
      BodyMeasurementInput(
        date: DateTime(2026, 10, 15),
        values: {BodyMetric.weight: 93},
        notes: 'Em jejum',
      ),
    );
    expect((await repo.getById(id))!.notes, 'Em jejum');
    await repo.delete(id);
    expect(await repo.watchAll().first, hasLength(1));
  });

  test('peso é obrigatório e gordura limitada a 0..100', () {
    final repo = BodyMeasurementRepository(db);
    expect(
      () => repo.create(
        BodyMeasurementInput(date: DateTime(2026), values: const {}),
      ),
      throwsArgumentError,
    );
    expect(
      () => repo.create(
        BodyMeasurementInput(
          date: DateTime(2026),
          values: {BodyMetric.weight: 90, BodyMetric.bodyFat: 120},
        ),
      ),
      throwsArgumentError,
    );
  });
}
