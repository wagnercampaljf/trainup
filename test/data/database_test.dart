import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:trainup/core/database/app_database.dart';
import 'package:trainup/core/database/seed_data.dart';
import 'package:trainup/features/workouts/domain/session_status.dart';

import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  test('cria schema com seed de exercícios, settings e timer', () async {
    final exercises = await db.select(db.exercises).get();
    expect(exercises, hasLength(seedExercises.length));
    expect(exercises.every((e) => !e.isCustom), isTrue);
    expect(await db.select(db.appSettings).getSingle(), isNotNull);
    expect(await db.select(db.timerStates).getSingle(), isNotNull);
  });

  test('foreign keys estão ativas', () async {
    final insert = db
        .into(db.workoutPlanExercises)
        .insert(
          WorkoutPlanExercisesCompanion.insert(
            workoutPlanId: 999,
            exerciseId: 1,
            position: 0,
          ),
        );
    await expectLater(insert, throwsA(isA<Exception>()));
  });

  test('constraints rejeitam valores inválidos', () async {
    final insert = db
        .into(db.bodyMeasurements)
        .insert(
          BodyMeasurementsCompanion.insert(
            date: DateTime(2026),
            weightKg: 95,
            bodyFatPercentage: const Value(120),
          ),
        );
    await expectLater(insert, throwsA(isA<Exception>()));
  });

  test('excluir ficha mantém sessão com snapshot', () async {
    final planId = await db
        .into(db.workoutPlans)
        .insert(WorkoutPlansCompanion.insert(name: 'Ficha A'));
    final sessionId = await db
        .into(db.workoutSessions)
        .insert(
          WorkoutSessionsCompanion.insert(
            workoutPlanId: Value(planId),
            planNameSnapshot: 'Ficha A',
            startedAt: DateTime(2026),
            status: SessionStatus.completed,
          ),
        );
    await (db.delete(db.workoutPlans)..where((p) => p.id.equals(planId))).go();
    final session = await (db.select(
      db.workoutSessions,
    )..where((s) => s.id.equals(sessionId))).getSingle();
    expect(session.workoutPlanId, isNull);
    expect(session.planNameSnapshot, 'Ficha A');
  });
}
