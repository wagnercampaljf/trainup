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
import 'package:trainup/features/profile/presentation/onboarding_status.dart';
import 'package:trainup/features/settings/data/settings_repository.dart';
import 'package:trainup/features/timer/presentation/timer_controller.dart';
import 'package:trainup/features/workouts/data/workout_session_repository.dart';

import '../helpers/demo_data.dart';
import '../helpers/test_database.dart';

Future<void> settle(WidgetTester tester, [int frames = 12]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(() => initializeDateFormatting(appLocale));

  Future<(AppDatabase, int)> seedRunning(WidgetTester tester) async {
    final db = createTestDatabase();
    tearDownWidgetsAndDatabase(tester, db);
    final id = await tester.runAsync(() async {
      final now = DateTime.now();
      final demo = await DemoData.seed(db, now: now);
      return DemoData.startRunning(db, demo.planIds.first, now: now);
    });
    return (db, id!);
  }

  Future<ProviderContainer> openApp(
    WidgetTester tester,
    AppDatabase db, {
    double width = 360,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = Size(width * 3, 800 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
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
    return ProviderScope.containerOf(rootNavigatorKey.currentContext!);
  }

  final timerButton = find.byKey(const Key('timer_button'));

  testWidgets('no treino o timer fica encaixado; fora dele, flutua', (
    tester,
  ) async {
    final (db, sessionId) = await seedRunning(tester);
    final container = await openApp(tester, db);
    // Parado, não flutua sobre o Início.
    expect(timerButton, findsNothing);

    unawaited(rootNavigatorKey.currentContext!.push(Routes.workout(sessionId)));
    await settle(tester);
    // Um só controle: o encaixado na barra inferior do treino.
    expect(timerButton, findsOneWidget);
    final dock = tester.getRect(timerButton);
    final bar = tester.getRect(find.byType(NavigationToolbar).first);
    expect(dock.top, greaterThan(600), reason: 'fica na barra inferior');
    expect(bar.bottom, lessThan(dock.top));

    container
        .read(timerControllerProvider.notifier)
        .start(const Duration(seconds: 90));
    await settle(tester, 3);
    expect(find.byKey(const Key('dock_timer_toggle')), findsOneWidget);
    await tester.tap(find.byKey(const Key('dock_timer_toggle')));
    await settle(tester, 3);
    expect(container.read(timerControllerProvider).snapshot.isPaused, isTrue);

    // Outra tela por cima (escolher exercício): o botão global volta.
    unawaited(rootNavigatorKey.currentContext!.push(Routes.pickExercise));
    await settle(tester);
    expect(timerButton, findsOneWidget);
    expect(tester.getRect(timerButton).bottom, lessThan(800));
    await tester.tap(find.byType(BackButton));
    await settle(tester);
    expect(timerButton, findsOneWidget);
    expect(find.byKey(const Key('dock_timer_toggle')), findsOneWidget);
    container.read(timerControllerProvider.notifier).reset();
    await settle(tester, 3);
  });

  testWidgets('teclado aberto esconde o botão flutuante', (tester) async {
    final (db, _) = await seedRunning(tester);
    final container = await openApp(tester, db);
    container
        .read(timerControllerProvider.notifier)
        .start(const Duration(seconds: 90));
    await settle(tester, 3);
    expect(timerButton, findsOneWidget);
    tester.view.viewInsets = const FakeViewPadding(bottom: 900);
    await settle(tester, 2);
    expect(timerButton, findsNothing);
    tester.view.resetViewInsets();
    await settle(tester, 2);
    expect(timerButton, findsOneWidget);
    container.read(timerControllerProvider.notifier).reset();
    await settle(tester, 3);
  });

  for (final (width, scale) in const [
    (320.0, 1.0),
    (320.0, 1.3),
    (390.0, 2.0),
  ]) {
    testWidgets(
      'séries cabem sem overflow em ${width.toInt()} pt, fonte $scale',
      (tester) async {
        final (db, sessionId) = await seedRunning(tester);
        await openApp(tester, db, width: width, textScale: scale);
        unawaited(
          rootNavigatorKey.currentContext!.push(Routes.workout(sessionId)),
        );
        await settle(tester);
        expect(tester.takeException(), isNull);

        final detail = (await tester.runAsync(
          () => WorkoutSessionRepository(db).getSession(sessionId),
        ))!;
        final set = detail.exercises.first.sets[2];
        for (final key in [
          'complete_set_${set.id}',
          'set_weight_${set.id}',
          'set_reps_${set.id}',
        ]) {
          final rect = tester.getRect(find.byKey(Key(key)));
          expect(rect.right, lessThanOrEqualTo(width), reason: key);
          expect(rect.left, greaterThanOrEqualTo(0), reason: key);
        }
        // Alvos de toque confortáveis para concluir e ajustar a carga.
        final complete = tester.getSize(
          find.byKey(Key('complete_set_${set.id}')),
        );
        expect(complete.width, greaterThanOrEqualTo(48));
        expect(complete.height, greaterThanOrEqualTo(48));
        for (final label in ['Aumentar 2,5 kg', 'Diminuir 2,5 kg']) {
          final size = tester.getSize(find.bySemanticsLabel(label).first);
          expect(size.width, greaterThanOrEqualTo(48), reason: label);
          expect(size.height, greaterThanOrEqualTo(48), reason: label);
        }
        // O campo de carga não é encolhido (sem FittedBox).
        final field = tester.getSize(find.byKey(Key('set_weight_${set.id}')));
        expect(field.width, greaterThanOrEqualTo(60));
      },
    );
  }

  testWidgets('concluídas todas as séries, "Finalizar treino" ganha destaque', (
    tester,
  ) async {
    final (db, sessionId) = await seedRunning(tester);
    await tester.runAsync(() async {
      final repo = WorkoutSessionRepository(db);
      final detail = (await repo.getSession(sessionId))!;
      for (final e in detail.exercises) {
        for (final s in e.sets.where((s) => !s.completed)) {
          await repo.completeSet(
            s.id,
            repetitions: s.repetitions,
            weightKg: s.weightKg,
          );
        }
      }
    });
    await openApp(tester, db);
    unawaited(rootNavigatorKey.currentContext!.push(Routes.workout(sessionId)));
    await settle(tester);
    expect(find.byKey(const Key('finish_workout_done')), findsOneWidget);
    await tester.tap(find.byKey(const Key('finish_workout_done')));
    await settle(tester, 4);
    expect(find.text('Finalizar treino?'), findsOneWidget);
    expect(find.textContaining('já salvas'), findsOneWidget);
    expect(find.textContaining('não marcada'), findsNothing);
  });
}
