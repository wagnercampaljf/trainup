import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:trainup/app.dart';
import 'package:trainup/core/database/app_database.dart';
import 'package:trainup/core/database/database_provider.dart';
import 'package:trainup/core/platform/file_sharing.dart';
import 'package:trainup/core/router/app_router.dart';
import 'package:trainup/core/router/routes.dart';
import 'package:trainup/core/utils/formatters.dart';
import 'package:trainup/features/profile/presentation/onboarding_status.dart';
import 'package:trainup/features/settings/data/settings_repository.dart';
import 'package:trainup/features/workout_plans/data/workout_plan_repository.dart';

import '../helpers/demo_data.dart';
import '../helpers/test_database.dart';

Future<void> settle(WidgetTester tester, [int frames = 12]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

class _PickCounter extends FileSharing {
  var picks = 0;

  @override
  Future<void> shareFile({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    String? text,
  }) async {}

  @override
  Future<PickedFile?> pickFile() async {
    picks++;
    return null;
  }
}

void main() {
  setUpAll(() => initializeDateFormatting(appLocale));

  Future<_PickCounter> openApp(WidgetTester tester, AppDatabase db) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final sharing = _PickCounter();
    final settings = await tester.runAsync(() => SettingsRepository(db).load());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          onboardingStatusProvider.overrideWithValue(
            OnboardingStatus(completed: true),
          ),
          initialSettingsProvider.overrideWithValue(settings!),
          fileSharingProvider.overrideWithValue(sharing),
        ],
        child: const TrainUpApp(),
      ),
    );
    await settle(tester);
    return sharing;
  }

  testWidgets('primeiro uso oferece criar e importar ficha', (tester) async {
    final db = createTestDatabase();
    tearDownWidgetsAndDatabase(tester, db);
    await tester.runAsync(
      () => DemoData.seedProfileOnly(db, now: DateTime.now()),
    );
    final sharing = await openApp(tester, db);

    // Início: as duas opções ficam no painel de destaque.
    expect(find.byKey(const Key('home_create_plan')), findsOneWidget);
    await tester.tap(find.byKey(const Key('home_import_plan')));
    await settle(tester, 4);
    expect(sharing.picks, 1);

    // Fichas: o estado vazio também oferece a importação.
    await tester.tap(find.text('Fichas'));
    await settle(tester);
    await tester.tap(find.byKey(const Key('plans_empty_import')));
    await settle(tester, 4);
    expect(sharing.picks, 2);
  });

  testWidgets('Início destaca a ficha há mais tempo sem treinar', (
    tester,
  ) async {
    final db = createTestDatabase();
    tearDownWidgetsAndDatabase(tester, db);
    await tester.runAsync(() => DemoData.seed(db, now: DateTime.now()));
    await openApp(tester, db);
    final hero = find.byKey(const Key('home_next_plan'));
    expect(hero, findsOneWidget);
    expect(
      find.descendant(of: hero, matching: find.textContaining('Há mais tempo')),
      findsOneWidget,
    );
    // O botão de iniciar fica na área inicial da tela (360 × 800).
    final start = tester.getRect(find.byKey(const Key('home_start_workout')));
    expect(start.bottom, lessThan(800 - 72));
  });

  testWidgets('menu do exercício reordena a ficha sem arrastar', (
    tester,
  ) async {
    final db = createTestDatabase();
    tearDownWidgetsAndDatabase(tester, db);
    final demo = (await tester.runAsync(
      () => DemoData.seed(db, now: DateTime.now()),
    ))!;
    await openApp(tester, db);
    final planId = demo.planIds.first;
    unawaited(rootNavigatorKey.currentContext!.push(Routes.editPlan(planId)));
    await settle(tester);

    await tester.tap(find.byKey(const Key('plan_exercise_menu_0')));
    await settle(tester, 4);
    await tester.tap(find.text('Mover para baixo'));
    await settle(tester, 4);
    await tester.tap(find.byKey(const Key('save_plan')));
    await settle(tester);

    final plan = await tester.runAsync(
      () => WorkoutPlanRepository(db).getPlan(planId),
    );
    expect(plan!.exercises.take(2).map((e) => e.exerciseName), [
      'Supino inclinado',
      'Supino reto',
    ]);
  });
}
