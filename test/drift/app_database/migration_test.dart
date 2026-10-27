import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainup/core/database/app_database.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

/// Migrações validadas contra os snapshots de `drift_schemas/`
/// (gerados por `dart run drift_dev make-migrations`).
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('schema resultante igual ao de uma instalação nova', () {
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      for (final toVersion in versions.skip(i + 1)) {
        test('v$fromVersion → v$toVersion', () async {
          final schema = await verifier.schemaAt(fromVersion);
          final db = AppDatabase(schema.newConnection());
          await verifier.migrateAndValidate(db, toVersion);
          await db.close();
        });
      }
    }
  });

  test('v1 → v2 preserva as configurações e cria a meta semanal (3)', () async {
    const settings = (
      id: 1,
      themePreference: 'dark',
      autoStartTimer: 0,
      timerSound: 1,
      timerVibration: 0,
      defaultRestSeconds: 120,
      weightIncrementKg: 1.25,
      weightUnit: 'kg',
    );
    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) => batch.insert(
        oldDb.appSettings,
        v1.AppSettingsCompanion.insert(
          id: const Value(1),
          themePreference: Value(settings.themePreference),
          autoStartTimer: Value(settings.autoStartTimer),
          timerSound: Value(settings.timerSound),
          timerVibration: Value(settings.timerVibration),
          defaultRestSeconds: Value(settings.defaultRestSeconds),
          weightIncrementKg: Value(settings.weightIncrementKg),
          weightUnit: Value(settings.weightUnit),
        ),
      ),
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.appSettings).get(), [
          v2.AppSettingsData(
            id: settings.id,
            themePreference: settings.themePreference,
            autoStartTimer: settings.autoStartTimer,
            timerSound: settings.timerSound,
            timerVibration: settings.timerVibration,
            defaultRestSeconds: settings.defaultRestSeconds,
            weightIncrementKg: settings.weightIncrementKg,
            weightUnit: settings.weightUnit,
            weeklyGoal: 3,
          ),
        ]);
      },
    );
  });
}
