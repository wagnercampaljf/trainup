import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../domain/app_preferences.dart';

class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  /// Lê as configurações, criando a linha padrão se necessário.
  Future<AppSettingsRow> load() async {
    final row = await _db.select(_db.appSettings).getSingleOrNull();
    if (row != null) return row;
    await _db.into(_db.appSettings).insert(const AppSettingsCompanion());
    return _db.select(_db.appSettings).getSingle();
  }

  Future<void> save(AppSettingsRow settings) =>
      _db.into(_db.appSettings).insertOnConflictUpdate(settings);
}

final settingsRepositoryProvider = Provider(
  (ref) => SettingsRepository(ref.watch(databaseProvider)),
);

/// Configurações carregadas no startup (sobrescrito em `main.dart`).
final initialSettingsProvider = Provider<AppSettingsRow>(
  (ref) => const AppSettingsRow(
    id: 1,
    themePreference: ThemePreference.system,
    autoStartTimer: true,
    timerSound: true,
    timerVibration: true,
    defaultRestSeconds: 90,
    weightIncrementKg: 2.5,
    weightUnit: WeightUnit.kg,
  ),
);
