import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:trainup/app.dart';
import 'package:trainup/core/database/app_database.dart';
import 'package:trainup/core/database/database_provider.dart';
import 'package:trainup/core/router/app_router.dart';
import 'package:trainup/core/router/routes.dart';
import 'package:trainup/core/utils/formatters.dart';
import 'package:trainup/features/body_measurements/domain/body_metric.dart';
import 'package:trainup/features/profile/data/profile_repository.dart';
import 'package:trainup/features/profile/presentation/onboarding_status.dart';
import 'package:trainup/features/settings/data/settings_repository.dart';
import 'package:trainup/features/workouts/data/workout_session_repository.dart';

import '../helpers/fixtures.dart';
import '../helpers/test_database.dart';

Future<void> settle(WidgetTester tester, [int frames = 12]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(() => initializeDateFormatting(appLocale));

  final now = DateTime.now();

  /// Treino concluído da Ficha A em [at], com [weight] kg em todas as séries.
  Future<int> workoutAt(
    AppDatabase db,
    int planId,
    DateTime at,
    double weight,
  ) async {
    final sessions = WorkoutSessionRepository(db);
    final id = await sessions.startFromPlan(planId, now: at);
    for (final set in (await sessions.getSession(id))!.exercises.single.sets) {
      await sessions.completeSet(set.id, repetitions: 10, weightKg: weight);
    }
    await sessions.finishSession(
      id,
      finishedAt: at.add(const Duration(hours: 1)),
    );
    return id;
  }

  Future<AppDatabase> seed(
    WidgetTester tester,
    Future<void> Function(AppDatabase db, int planId) workouts,
  ) async {
    final db = createTestDatabase();
    tearDownWidgetsAndDatabase(tester, db);
    await tester.runAsync(() async {
      await ProfileRepository(db).completeOnboarding(
        const ProfileInput(name: 'Wagner', heightCm: 178),
        BodyMeasurementInput(
          date: DateTime(2026, 9, 1),
          values: {BodyMetric.weight: 95},
        ),
      );
      await workouts(db, await createFichaA(db));
    });
    return db;
  }

  Future<void> openApp(WidgetTester tester, AppDatabase db) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    final settings = await tester.runAsync(() => SettingsRepository(db).load());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          onboardingStatusProvider.overrideWithValue(
            OnboardingStatus(completed: true),
          ),
          initialSettingsProvider.overrideWithValue(settings!),
        ],
        child: const TrainUpApp(),
      ),
    );
    await settle(tester);
  }

  testWidgets('Home mostra a semana contra a meta configurada', (tester) async {
    final db = await seed(tester, (db, planId) async {
      await workoutAt(
        db,
        planId,
        now.subtract(const Duration(minutes: 90)),
        40,
      );
      // Mês anterior.
      await workoutAt(db, planId, DateTime(now.year, now.month - 1, 10), 40);
    });
    await openApp(tester, db);

    expect(find.byKey(const Key('frequency_card')), findsOneWidget);
    expect(find.text('1 de 3 treinos'), findsOneWidget);
    expect(
      find.text('Faltam 2 treinos para a meta da semana.'),
      findsOneWidget,
    );
    expect(find.text('Mês passado'), findsOneWidget);

    // Meta de 1 treino por semana nas configurações.
    unawaited(rootNavigatorKey.currentContext!.push(Routes.settings));
    await settle(tester);
    await tester.scrollUntilVisible(find.byKey(const Key('weekly_goal')), 200);
    await tester.tap(find.byKey(const Key('weekly_goal')));
    await settle(tester, 4);
    await tester.tap(find.text('1 treino').last);
    await settle(tester);
    await tester.tap(find.byType(BackButton));
    await settle(tester);

    expect(find.text('1 de 1 treinos'), findsOneWidget);
    expect(find.text('Meta da semana cumprida! 💪'), findsOneWidget);
    final goal = await tester.runAsync(() => SettingsRepository(db).load());
    expect(goal!.weeklyGoal, 1);
  });

  testWidgets('calendário do histórico marca o dia e abre o treino', (
    tester,
  ) async {
    final db = await seed(tester, (db, planId) async {
      await workoutAt(
        db,
        planId,
        now.subtract(const Duration(minutes: 90)),
        40,
      );
    });
    await openApp(tester, db);
    await tester.tap(find.text('Histórico'));
    await settle(tester);

    expect(find.text(formatMonthYear(now)), findsOneWidget);
    expect(find.text('1 treino no mês'), findsOneWidget);
    final today = now.subtract(const Duration(minutes: 90)).day;
    await tester.tap(find.byKey(Key('calendar_day_$today')));
    await settle(tester);
    expect(find.byTooltip('Excluir treino'), findsOneWidget);

    // Mês anterior sem treinos; não dá para avançar além do mês atual.
    await tester.tap(find.byType(BackButton));
    await settle(tester);
    await tester.tap(find.byTooltip('Mês anterior'));
    await settle(tester);
    expect(find.text('0 treinos no mês'), findsOneWidget);
    await tester.tap(find.byTooltip('Próximo mês'));
    await settle(tester);
    expect(find.text('1 treino no mês'), findsOneWidget);
    final next = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.chevron_right).first,
    );
    expect(next.onPressed, isNull);
  });

  testWidgets('Evolução mostra a carga do primeiro ao último treino', (
    tester,
  ) async {
    final db = await seed(tester, (db, planId) async {
      await workoutAt(db, planId, now.subtract(const Duration(days: 20)), 40);
      await workoutAt(db, planId, now.subtract(const Duration(days: 10)), 45);
      await workoutAt(db, planId, now.subtract(const Duration(days: 2)), 50);
    });
    await openApp(tester, db);
    await tester.tap(find.text('Evolução'));
    await settle(tester);

    expect(find.text('Cargas'), findsOneWidget);
    expect(find.text('40 kg → 50 kg · 3 treinos'), findsOneWidget);
    expect(find.text('+10 kg'), findsOneWidget);
    expect(find.text('+25%'), findsOneWidget);
    expect(
      find.textContaining('1 de 1 exercício com aumento de carga'),
      findsOneWidget,
    );

    // Toque abre o gráfico do exercício.
    await tester.tap(find.text('Supino reto'));
    await settle(tester);
    expect(find.text('Maior peso'), findsWidgets);
  });
}
