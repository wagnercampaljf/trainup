import 'dart:convert';
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
import 'package:trainup/features/body_measurements/domain/body_metric.dart';
import 'package:trainup/features/profile/data/profile_repository.dart';
import 'package:trainup/features/profile/presentation/onboarding_status.dart';
import 'package:trainup/features/settings/data/settings_repository.dart';
import 'package:trainup/features/workout_plans/data/workout_plan_repository.dart';
import 'package:trainup/features/workout_plans/domain/plan_transfer.dart';
import 'package:trainup/features/workouts/data/workout_session_repository.dart';

import '../helpers/fixtures.dart';
import '../helpers/test_database.dart';

Future<void> settle(WidgetTester tester, [int frames = 12]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Registra o que seria compartilhado e devolve um arquivo "escolhido".
class _FakeFileSharing extends FileSharing {
  final shared = <({String fileName, String mimeType, Uint8List bytes})>[];
  PickedFile? fileToPick;

  @override
  Future<void> shareFile({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    String? text,
  }) async {
    shared.add((fileName: fileName, mimeType: mimeType, bytes: bytes));
  }

  @override
  Future<PickedFile?> pickFile() async => fileToPick;
}

void main() {
  setUpAll(() => initializeDateFormatting(appLocale));

  late _FakeFileSharing sharing;

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

  Future<void> openApp(WidgetTester tester, AppDatabase db) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    sharing = _FakeFileSharing();
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
  }

  void go(String location) => rootNavigatorKey.currentContext!.push(location);

  testWidgets('altera o descanso durante o treino e grava na ficha', (
    tester,
  ) async {
    final db = await seed(tester);
    final ids = await tester.runAsync(() async {
      final planId = await createFichaA(db);
      return (planId, await WorkoutSessionRepository(db).startFromPlan(planId));
    });
    final (planId, sessionId) = ids!;
    await openApp(tester, db);
    go(Routes.workout(sessionId));
    await settle(tester);
    expect(find.textContaining('descanso 1min30s'), findsOneWidget);

    await tester.tap(find.byTooltip('Opções de Supino reto'));
    await settle(tester, 4);
    await tester.tap(find.text('Alterar descanso'));
    await settle(tester, 4);
    await tester.tap(find.byKey(const Key('rest_option_120')));
    await tester.pump();
    // "Salvar também na ficha" já vem marcado.
    await tester.tap(find.byKey(const Key('rest_save')));
    await settle(tester);

    expect(find.textContaining('descanso 2min'), findsOneWidget);
    final saved = await tester.runAsync(() async {
      final session = await WorkoutSessionRepository(db).getSession(sessionId);
      final plan = await WorkoutPlanRepository(db).getPlan(planId);
      return (
        session!.exercises.single.exercise.restSeconds,
        plan!.exercises.single.restSeconds,
      );
    });
    expect(saved, (120, 120));
  });

  testWidgets('altera o descanso direto no detalhe da ficha', (tester) async {
    final db = await seed(tester);
    final planId = await tester.runAsync(() => createFichaA(db));
    await openApp(tester, db);
    go(Routes.plan(planId!));
    await settle(tester);
    expect(find.text('Descanso: 1min30s'), findsOneWidget);

    await tester.tap(find.byTooltip('Alterar descanso de Supino reto'));
    await settle(tester, 4);
    expect(find.byKey(const Key('rest_apply_to_plan')), findsNothing);
    await tester.tap(find.byKey(const Key('rest_option_default')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('rest_save')));
    await settle(tester);

    expect(find.text('Descanso: 1min30s (padrão)'), findsOneWidget);
    final rest = await tester.runAsync(
      () => WorkoutPlanRepository(db).getPlan(planId),
    );
    expect(rest!.exercises.single.restSeconds, isNull);
  });

  testWidgets('resumo do treino oferece compartilhar uma imagem', (
    tester,
  ) async {
    final db = await seed(tester);
    final sessionId = await tester.runAsync(() async {
      final sessions = WorkoutSessionRepository(db);
      final id = await sessions.startFromPlan(await createFichaA(db));
      for (final set in (await sessions.getSession(
        id,
      ))!.exercises.single.sets) {
        await sessions.completeSet(
          set.id,
          repetitions: set.repetitions,
          weightKg: set.weightKg,
        );
      }
      await sessions.finishSession(id);
      return id;
    });
    await openApp(tester, db);
    go(Routes.workoutSummary(sessionId!));
    await settle(tester);

    await tester.tap(find.byKey(const Key('summary_share')));
    await settle(tester);
    expect(find.text('Compartilhar treino'), findsOneWidget);
    expect(find.text('TREINO CONCLUÍDO'), findsWidgets);
    expect(find.text('Registrado com o app TrainUp'), findsOneWidget);

    // A captura da imagem usa o motor de renderização real.
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('share_workout_image')));
      // A geração do PNG é assíncrona e mais lenta com a suíte inteira
      // rodando: espera o resultado, com limite.
      for (var i = 0; i < 100 && sharing.shared.isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    });
    await settle(tester);
    expect(sharing.shared, hasLength(1));
    final image = sharing.shared.single;
    expect(image.mimeType, 'image/png');
    expect(image.fileName, startsWith('treino-trainup-'));
    // Assinatura PNG.
    expect(image.bytes.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
  });

  testWidgets('exporta a ficha e importa o arquivo recebido', (tester) async {
    final db = await seed(tester);
    final planId = await tester.runAsync(() => createFichaA(db));
    await openApp(tester, db);
    go(Routes.plan(planId!));
    await settle(tester);

    await tester.tap(find.byKey(const Key('export_plan')));
    await settle(tester);
    final file = sharing.shared.single;
    expect(file.fileName, 'trainup-ficha-a.json');
    expect(file.mimeType, 'application/json');
    final bundle = PlanBundle.fromJson(utf8.decode(file.bytes));
    expect(bundle.plans.single.name, 'Ficha A');

    // Importa o mesmo arquivo (como o aluno faria) pela tela de fichas.
    await tester.tap(find.byType(BackButton));
    await settle(tester);
    await tester.tap(find.text('Fichas'));
    await settle(tester);
    sharing.fileToPick = (name: file.fileName, bytes: file.bytes);
    await tester.tap(find.byKey(const Key('plans_menu')));
    await settle(tester, 4);
    await tester.tap(find.text('Importar fichas'));
    await settle(tester);
    expect(find.text('Importar ficha?'), findsOneWidget);
    expect(find.text('Supino reto'), findsOneWidget);
    await tester.tap(find.byKey(const Key('import_confirm')));
    await settle(tester);

    // Abre a ficha importada (nome repetido recebe sufixo).
    expect(find.text('Ficha A (importada)'), findsWidgets);
    final active = await tester.runAsync(
      () => WorkoutPlanRepository(db).watchActivePlans().first,
    );
    expect(active!.map((p) => p.name), ['Ficha A', 'Ficha A (importada)']);
  });

  testWidgets('arquivo inválido mostra erro e não importa nada', (
    tester,
  ) async {
    final db = await seed(tester);
    await openApp(tester, db);
    sharing.fileToPick = (
      name: 'foto.jpg',
      bytes: Uint8List.fromList([0xFF, 0xD8, 0xFF, 0x00]),
    );
    await tester.tap(find.text('Fichas'));
    await settle(tester);
    await tester.tap(find.byKey(const Key('plans_menu')));
    await settle(tester, 4);
    await tester.tap(find.text('Importar fichas'));
    await settle(tester);
    expect(find.text('Não foi possível importar'), findsOneWidget);
    expect(
      find.text('Este arquivo não é uma ficha do TrainUp.'),
      findsOneWidget,
    );
  });
}
