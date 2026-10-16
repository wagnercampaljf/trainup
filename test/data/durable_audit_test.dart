import 'dart:io';

import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainup/core/database/app_database.dart';
import 'package:trainup/features/body_measurements/data/body_measurement_repository.dart';
import 'package:trainup/features/body_measurements/domain/body_metric.dart';
import 'package:trainup/features/profile/data/profile_repository.dart';
import 'package:trainup/features/progress/data/progress_repository.dart';
import 'package:trainup/features/progress/domain/exercise_progress.dart';
import 'package:trainup/features/settings/data/settings_repository.dart';
import 'package:trainup/features/settings/domain/app_preferences.dart';
import 'package:trainup/features/timer/data/timer_repository.dart';
import 'package:trainup/features/timer/domain/timer_snapshot.dart';
import 'package:trainup/features/workout_plans/data/workout_plan_repository.dart';
import 'package:trainup/features/workouts/data/workout_session_repository.dart';

import '../helpers/fixtures.dart';

class _UnsupportedUpgrade extends AppDatabase {
  _UnsupportedUpgrade(super.executor);
  @override
  int get schemaVersion => 2;
}

void main() {
  test('fluxo completo em arquivo SQLite fechado e reaberto preserva todos os dados', () async {
    final directory = await Directory.systemTemp.createTemp('trainup_audit_');
    final file = File('${directory.path}/audit.sqlite');
    var db = AppDatabase(NativeDatabase(file));
    addTearDown(() async {
      await db.close();
      await directory.delete(recursive: true);
    });
    final date = DateTime(2026, 10, 1, 18);
    await ProfileRepository(db).completeOnboarding(
      const ProfileInput(name: 'Teste', heightCm: 178),
      BodyMeasurementInput(
        date: date,
        values: {
          BodyMetric.weight: 95,
          BodyMetric.bodyFat: 20,
          for (final metric in BodyMetric.circumferences) metric: 95.2,
        },
      ),
    );
    final planId = await createFichaA(db);
    var sessions = WorkoutSessionRepository(db);
    final first = await sessions.startFromPlan(planId, now: date);
    var detail = (await sessions.getSession(first))!;
    await sessions.completeSet(
      detail.exercises.single.sets.first.id,
      repetitions: 12,
      weightKg: 30,
    );
    await TimerRepository(db)
        .save(const TimerSnapshot.idle(Duration(minutes: 3)).start(date));
    final settings = await SettingsRepository(db).load();
    await SettingsRepository(db).save(
      settings.copyWith(
        themePreference: ThemePreference.dark,
        autoStartTimer: false,
      ),
    );
    await db.close();

    db = AppDatabase(NativeDatabase(file));
    await db.validateDatabaseSchema();
    sessions = WorkoutSessionRepository(db);
    expect((await sessions.getRunningSession())!.id, first);
    detail = (await sessions.getSession(first))!;
    expect(detail.exercises.single.sets.first.completed, isTrue);
    expect((await ProfileRepository(db).getProfile())!.name, 'Teste');
    expect(
      (await SettingsRepository(db).load()).themePreference,
      ThemePreference.dark,
    );
    expect((await SettingsRepository(db).load()).autoStartTimer, isFalse);
    final timer = await TimerRepository(db).load();
    expect(
      timer.remaining(date.add(const Duration(seconds: 40))).inSeconds,
      140,
    );
    expect(timer.hasExpired(date.add(const Duration(minutes: 4))), isTrue);
    for (final set in detail.exercises.single.sets.skip(1)) {
      await sessions.completeSet(
        set.id,
        repetitions: set.repetitions,
        weightKg: set.weightKg,
      );
    }
    await sessions.finishSession(
      first,
      finishedAt: date.add(const Duration(hours: 1)),
    );
    final plans = WorkoutPlanRepository(db);
    final plan = (await plans.getPlan(planId))!;
    plan.name = 'Ficha A editada';
    plan.exercises.single.sets.last.weightKg = 42.5;
    await plans.savePlan(plan);
    expect(
      (await sessions.getSession(first))!.session.planNameSnapshot,
      'Ficha A',
    );
    expect(
      (await sessions.getSession(first))!.exercises.single.sets.last.weightKg,
      40,
    );
    expect((await sessions.getSession(first))!.volume, 1030);
    for (final (day, weight) in [(2, 42.5), (3, 45.0)]) {
      final id = await sessions.startFromPlan(
        planId,
        now: date.add(Duration(days: day)),
      );
      final sets = (await sessions.getSession(id))!.exercises.single.sets;
      for (final set in sets) {
        await sessions.completeSet(
          set.id,
          repetitions: set.repetitions,
          weightKg: set.id == sets.last.id ? weight : set.weightKg,
        );
      }
      await sessions.finishSession(id);
    }
    final supino = await exerciseByName(db, 'Supino reto');
    final progress = await ProgressRepository(db)
        .watchExerciseHistory(supino.id)
        .first;
    expect(ExerciseMetric.maxWeight.series(progress).map((p) => p.value), [
      40,
      42.5,
      45,
    ]);
    expect(ExerciseStats.from(progress).maxWeight, 45);
    final measurements = BodyMeasurementRepository(db);
    final secondMeasurement = await measurements.create(
      BodyMeasurementInput(date: date, values: {BodyMetric.weight: 93}),
    );
    expect((await measurements.watchAll().first).map((m) => m.weightKg), [
      93,
      95,
    ]);
    await measurements.update(
      secondMeasurement,
      BodyMeasurementInput(
        date: date.subtract(const Duration(days: 1)),
        values: {BodyMetric.weight: 93.5},
      ),
    );
    expect((await measurements.watchAll().first).map((m) => m.weightKg), [
      95,
      93.5,
    ]);
    await db.close();
    db = AppDatabase(NativeDatabase(file));
    expect(
      await WorkoutSessionRepository(db).watchHistory().first,
      hasLength(3),
    );
    expect(await BodyMeasurementRepository(db).watchAll().first, hasLength(2));
    expect(
      (await db.customSelect('PRAGMA integrity_check').getSingle())
          .data
          .values
          .single,
      'ok',
    );
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
  });

  test('upgrade sem passo explícito falha sem apagar banco v1', () async {
    final directory = await Directory.systemTemp.createTemp(
      'trainup_migration_',
    );
    final file = File('${directory.path}/audit.sqlite');
    final original = AppDatabase(NativeDatabase(file));
    await ProfileRepository(original)
        .saveProfile(const ProfileInput(name: 'Preservar', heightCm: 178));
    await original.close();
    final upgrade = _UnsupportedUpgrade(NativeDatabase(file));
    await expectLater(
      upgrade.select(upgrade.userProfiles).get(),
      throwsStateError,
    );
    await upgrade.close();
    final reopened = AppDatabase(NativeDatabase(file));
    try {
      expect(
        (await ProfileRepository(reopened).getProfile())!.name,
        'Preservar',
      );
      expect(
        (await reopened.customSelect('PRAGMA user_version').getSingle())
            .read<int>('user_version'),
        1,
      );
    } finally {
      await reopened.close();
      await directory.delete(recursive: true);
    }
  });
}
