import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/exercises/domain/muscle_group.dart';
import '../../features/profile/domain/sex.dart';
import '../../features/settings/domain/app_preferences.dart';
import '../../features/timer/domain/timer_status.dart';
import '../../features/workouts/domain/session_status.dart';
import '../utils/text_normalizer.dart';
import 'database_file.dart';
import 'seed_data.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    UserProfiles,
    BodyMeasurements,
    Exercises,
    WorkoutPlans,
    WorkoutPlanExercises,
    WorkoutPlanSets,
    WorkoutSessions,
    WorkoutSessionExercises,
    WorkoutSessionSets,
    AppSettings,
    TimerStates,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Banco persistente no diretório de documentos do aplicativo.
  ///
  /// Instalações anteriores ao nome TrainUp usavam `minha_ficha.sqlite`; o
  /// arquivo é renomeado na primeira abertura (ver [resolveDatabasePath]).
  factory AppDatabase.open() => AppDatabase(
    driftDatabase(
      name: databaseName,
      native: DriftNativeOptions(
        databasePath: () async =>
            resolveDatabasePath(await getApplicationDocumentsDirectory()),
      ),
    ),
  );

  /// Versão atual do schema.
  ///
  /// Ao alterar tabelas: incremente este número, adicione um passo em
  /// [_migrateStep] e rode `dart run drift_dev make-migrations`.
  /// Nunca apague/recrie tabelas com dados do usuário.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seed();
    },
    onUpgrade: (m, from, to) async {
      for (var version = from; version < to; version++) {
        await _migrateStep(m, version);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Migra do schema [from] para `from + 1`.
  Future<void> _migrateStep(Migrator m, int from) async {
    switch (from) {
      // Exemplo para a próxima versão:
      // case 1:
      //   await m.addColumn(exercises, exercises.someNewColumn);
      default:
        throw StateError('Migração não suportada a partir da versão $from');
    }
  }

  Future<void> _seed() async {
    await batch((b) {
      b.insertAll(exercises, [
        for (final (name, group) in seedExercises)
          ExercisesCompanion.insert(
            name: name,
            normalizedName: normalizeName(name),
            muscleGroup: group,
            isCustom: const Value(false),
          ),
      ]);
      b.insert(appSettings, const AppSettingsCompanion());
      b.insert(
        timerStates,
        TimerStatesCompanion.insert(
          status: TimerStatus.idle,
          durationMs: 90000,
        ),
      );
    });
  }
}
