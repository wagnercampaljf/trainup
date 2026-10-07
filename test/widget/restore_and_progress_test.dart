import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:trainup/app.dart';
import 'package:trainup/core/database/app_database.dart';
import 'package:trainup/core/database/database_provider.dart';
import 'package:trainup/core/router/app_router.dart';
import 'package:trainup/core/router/routes.dart';
import 'package:trainup/core/utils/formatters.dart';
import 'package:trainup/features/body_measurements/data/body_measurement_repository.dart';
import 'package:trainup/features/body_measurements/domain/body_metric.dart';
import 'package:trainup/features/profile/data/profile_repository.dart';
import 'package:trainup/features/profile/presentation/onboarding_status.dart';
import 'package:trainup/features/settings/data/settings_repository.dart';
import 'package:trainup/features/workouts/data/workout_session_repository.dart';
import 'package:trainup/features/workout_plans/data/workout_plan_repository.dart';
import 'package:trainup/features/timer/presentation/timer_controller.dart';

import '../helpers/fixtures.dart';
import '../helpers/test_database.dart';

Future<void> settle(WidgetTester tester, [int frames = 12]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Abre o app sobre um banco já existente (simula reabrir o aplicativo).
Future<ProviderContainer> openApp(WidgetTester tester, AppDatabase db) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  final settings = await tester.runAsync(() => SettingsRepository(db).load());
  late ProviderContainer container;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        onboardingStatusProvider.overrideWithValue(
          OnboardingStatus(completed: true),
        ),
        initialSettingsProvider.overrideWithValue(settings!),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          container = ProviderScope.containerOf(context);
          return const TrainUpApp();
        },
      ),
    ),
  );
  await settle(tester);
  return container;
}

void main() {
  setUpAll(() => initializeDateFormatting(appLocale));

  Future<AppDatabase> seed(WidgetTester tester) async {
    final db = createTestDatabase();
    tearDownWidgetsAndDatabase(tester, db);
    await tester.runAsync(
      () => ProfileRepository(db).completeOnboarding(
        const ProfileInput(name: 'Wagner', heightCm: 178),
        BodyMeasurementInput(
          date: DateTime(2026, 9, 1),
          values: {BodyMetric.weight: 95},
        ),
      ),
    );
    return db;
  }

  testWidgets('treino em andamento é oferecido ao reabrir o app', (
    tester,
  ) async {
    final db = await seed(tester);
    await tester.runAsync(() async {
      final planId = await createFichaA(db);
      final sessions = WorkoutSessionRepository(db);
      final id = await sessions.startFromPlan(planId);
      final set = (await sessions.getSession(id))!.exercises.single.sets.first;
      await sessions.completeSet(set.id, repetitions: 12, weightKg: 30);
    });

    await openApp(tester, db);
    expect(find.text('Treino em andamento'), findsWidgets);
    await tester.tap(find.byKey(const Key('resume_running_workout')));
    await settle(tester);

    expect(find.text('SUPINO RETO'), findsOneWidget);
    expect(find.text('1 de 3 séries · 360 kg'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('cancelar o treino encerra o descanso em andamento', (
    tester,
  ) async {
    final db = await seed(tester);
    await tester.runAsync(() async {
      final planId = await createFichaA(db);
      await WorkoutSessionRepository(db).startFromPlan(planId);
    });
    final container = await openApp(tester, db);
    await tester.tap(find.byKey(const Key('resume_running_workout')));
    await settle(tester);
    container
        .read(timerControllerProvider.notifier)
        .start(const Duration(seconds: 90));
    await settle(tester, 2);

    await tester.tap(find.byTooltip('Mais opções'));
    await settle(tester, 4);
    await tester.tap(find.text('Cancelar treino').last);
    await settle(tester, 4);
    await tester.tap(find.widgetWithText(FilledButton, 'Cancelar treino'));
    await settle(tester);

    expect(container.read(timerControllerProvider).snapshot.isIdle, isTrue);
    final running = await tester.runAsync(
      () => WorkoutSessionRepository(db).getRunningSession(),
    );
    expect(running, isNull);
  });

  testWidgets('botão do timer some enquanto os controles estão abertos', (
    tester,
  ) async {
    final db = await seed(tester);
    await openApp(tester, db);
    expect(find.byKey(const Key('timer_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('timer_button')));
    await settle(tester);
    expect(find.text('Pronto para iniciar'), findsOneWidget);
    expect(find.byKey(const Key('timer_button')), findsNothing);

    await tester.tapAt(const Offset(200, 40));
    await settle(tester);
    expect(find.text('Pronto para iniciar'), findsNothing);
    expect(find.byKey(const Key('timer_button')), findsOneWidget);
    // A navegação continua intacta (nada foi remontado).
    expect(find.text('Olá, Wagner'), findsOneWidget);
  });

  testWidgets('evolução de carga 40 → 42,5 kg e evolução corporal', (
    tester,
  ) async {
    final db = await seed(tester);
    await tester.runAsync(() async {
      final planId = await createFichaA(db);
      final sessions = WorkoutSessionRepository(db);
      for (final (day, lastWeight) in [(1, 40.0), (4, 42.5)]) {
        final id = await sessions.startFromPlan(
          planId,
          now: DateTime(2026, 10, day, 18),
        );
        final sets = (await sessions.getSession(id))!.exercises.single.sets;
        for (final set in sets) {
          await sessions.completeSet(
            set.id,
            repetitions: set.repetitions,
            weightKg: set == sets.last ? lastWeight : set.weightKg,
          );
        }
        await sessions.finishSession(
          id,
          finishedAt: DateTime(2026, 10, day, 19),
        );
      }
      await BodyMeasurementRepository(db).create(
        BodyMeasurementInput(
          date: DateTime(2026, 10, 4),
          values: {BodyMetric.weight: 93.5},
        ),
      );
    });

    final container = await openApp(tester, db);
    final supino = (await tester.runAsync(
      () => exerciseByName(db, 'Supino reto'),
    ))!;
    unawaited(
      container.read(appRouterProvider).push(Routes.exercise(supino.id)),
    );
    await settle(tester);

    expect(find.byType(LineChart), findsOneWidget);
    expect(find.text('Maior carga'), findsOneWidget);
    expect(find.text('42,5 kg'), findsWidgets);
    expect(find.text('40 kg'), findsWidgets);
    expect(find.text('+2,5 kg'), findsOneWidget);
    expect(find.text('+6,3%'), findsOneWidget);

    container.read(appRouterProvider).go(Routes.progress);
    await settle(tester);
    await tester.tap(find.text('Corporal'));
    await settle(tester);
    expect(find.byType(LineChart), findsOneWidget);
    expect(find.text('-1,5 kg'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('edição de ficha salva e volta sem pedir descarte', (
    tester,
  ) async {
    final db = await seed(tester);
    final id = (await tester.runAsync(() => createFichaA(db)))!;
    final container = await openApp(tester, db);
    unawaited(container.read(appRouterProvider).push(Routes.plan(id)));
    await settle(tester);
    unawaited(container.read(appRouterProvider).push(Routes.editPlan(id)));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('plan_name')), 'Ficha editada');
    await tester.tap(find.byKey(const Key('save_plan')));
    // A gravação é disparada pela UI (zona de teste): os frames precisam
    // avançar para o SQLite concluir a transação e a rota ser fechada.
    await settle(tester);
    expect(find.text('Descartar alterações?'), findsNothing);
    expect(find.text('Editar ficha'), findsNothing);
    final plan = await tester.runAsync(
      () => WorkoutPlanRepository(db).getPlan(id),
    );
    expect(plan!.name, 'Ficha editada');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('salvar ficha sem alterações também fecha o editor', (
    tester,
  ) async {
    final db = await seed(tester);
    final id = (await tester.runAsync(() => createFichaA(db)))!;
    final container = await openApp(tester, db);
    unawaited(container.read(appRouterProvider).push(Routes.plan(id)));
    await settle(tester);
    unawaited(container.read(appRouterProvider).push(Routes.editPlan(id)));
    await settle(tester);
    final save = tester.widget<TextButton>(find.byKey(const Key('save_plan')));
    expect(save.onPressed, isNotNull, reason: 'SALVAR deve estar habilitado');
    await tester.tap(find.byKey(const Key('save_plan')));
    await settle(tester);
    expect(find.text('Editar ficha'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('timer global preserva contagem entre abas e perfil', (
    tester,
  ) async {
    final db = await seed(tester);
    final container = await openApp(tester, db);
    final controller = container.read(timerControllerProvider.notifier);
    controller.start(const Duration(seconds: 90));
    final startedAt = container
        .read(timerControllerProvider)
        .snapshot
        .startedAt;
    for (final route in [
      Routes.history,
      Routes.profile,
      Routes.plans,
      Routes.home,
    ]) {
      container.read(appRouterProvider).go(route);
      await settle(tester, 4);
      final state = container.read(timerControllerProvider);
      expect(state.snapshot.startedAt, startedAt);
      expect(state.snapshot.isRunning, isTrue);
      expect(state.remaining.inSeconds, inInclusiveRange(1, 90));
      expect(find.byKey(const Key('timer_button')), findsOneWidget);
    }
    controller.reset();
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
