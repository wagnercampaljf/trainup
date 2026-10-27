// Capturas das telas principais com fontes reais, nos dois temas.
//
// Não roda na suíte normal. Para gerar:
//   bash tool/docker_flutter.sh test test/screenshots \
//     --dart-define=CAPTURE_DIR=build/screenshots/after
//
// Os dados são de demonstração (test/helpers/demo_data.dart).
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:trainup/app.dart';
import 'package:trainup/core/database/app_database.dart';
import 'package:trainup/core/database/database_provider.dart';
import 'package:trainup/core/router/app_router.dart';
import 'package:trainup/core/router/routes.dart';
import 'package:trainup/core/utils/clock.dart';
import 'package:trainup/core/utils/formatters.dart';
import 'package:trainup/features/profile/presentation/onboarding_status.dart';
import 'package:trainup/features/settings/data/settings_repository.dart';
import 'package:trainup/features/settings/domain/app_preferences.dart';
import 'package:trainup/features/timer/presentation/timer_controller.dart';

import '../helpers/demo_data.dart';
import '../helpers/fixtures.dart';
import '../helpers/test_database.dart';

const _outputDir = String.fromEnvironment('CAPTURE_DIR');

Future<void> _loadFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'] ?? '/sdk/flutter';
  final dir = '$root/bin/cache/artifacts/material_fonts';
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final file in files) {
      final bytes = File(file).readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }

  await load('Roboto', [
    for (final w in ['Regular', 'Medium', 'Bold', 'Black', 'Light'])
      '$dir/Roboto-$w.ttf',
  ]);
  await load('MaterialIcons', ['$dir/MaterialIcons-Regular.otf']);
  final fontsDir = Directory('assets/fonts');
  if (fontsDir.existsSync()) {
    final byFamily = <String, List<String>>{};
    for (final file in fontsDir.listSync().whereType<File>()) {
      final name = file.uri.pathSegments.last;
      if (!name.endsWith('.ttf')) continue;
      byFamily.putIfAbsent(name.split('-').first, () => []).add(file.path);
    }
    for (final MapEntry(:key, :value) in byFamily.entries) {
      await load(key, value);
    }
  }
}

Future<void> _settle(WidgetTester tester, [int frames = 14]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Desmonta o app ainda no corpo do teste: timers da UI (relógio do treino,
/// aviso do descanso) são cancelados antes da verificação do framework.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await _settle(tester, 60);
}

class _Config {
  const _Config(this.width, this.textScale, this.dark);

  final double width;
  final double textScale;
  final bool dark;

  String get suffix =>
      '${dark ? 'dark' : 'light'}_${width.toInt()}'
      '${textScale == 1 ? '' : '_x${textScale.toString().replaceAll('.', '')}'}';
}

void main() {
  if (_outputDir.isEmpty) return;
  setUpAll(() async {
    Intl.defaultLocale = appLocale;
    await initializeDateFormatting(appLocale);
    await _loadFonts();
  });

  final boundaryKey = GlobalKey();
  final now = DateTime.now();
  var offset = Duration.zero;

  Future<void> capture(WidgetTester tester, String name, _Config config) =>
      tester.runAsync(() async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 3);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File('$_outputDir/${name}_${config.suffix}.png');
        file.parent.createSync(recursive: true);
        file.writeAsBytesSync(data!.buffer.asUint8List());
      });

  Future<void> shot(WidgetTester tester, String name, _Config config) async {
    // Sombras reais só no quadro capturado (o teste exige a variável de
    // depuração restaurada ao terminar).
    debugDisableShadows = false;
    void repaint(RenderObject object) {
      object.markNeedsPaint();
      object.visitChildren(repaint);
    }

    tester.binding.renderViews.forEach(repaint);
    await tester.pump();
    try {
      await capture(tester, name, config);
    } finally {
      debugDisableShadows = true;
    }
  }

  Future<ProviderContainer> open(
    WidgetTester tester,
    AppDatabase db,
    _Config config, {
    bool onboarded = true,
  }) async {
    tester.view.physicalSize = Size(config.width * 3, 800 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.textScaleFactorTestValue = config.textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final settings = await tester.runAsync(() async {
      final repo = SettingsRepository(db);
      final loaded = await repo.load();
      final themed = loaded.copyWith(
        themePreference: config.dark
            ? ThemePreference.dark
            : ThemePreference.light,
      );
      await repo.save(themed);
      return themed;
    });
    offset = Duration.zero;
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundaryKey,
        child: ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            onboardingStatusProvider.overrideWithValue(
              OnboardingStatus(completed: onboarded),
            ),
            initialSettingsProvider.overrideWithValue(settings!),
            clockProvider.overrideWithValue(() => now.add(offset)),
          ],
          child: const TrainUpApp(),
        ),
      ),
    );
    await _settle(tester);
    return ProviderScope.containerOf(rootNavigatorKey.currentContext!);
  }

  BuildContext nav() => rootNavigatorKey.currentContext!;
  void push(String location) => unawaited(nav().push(location));

  const configs = [
    _Config(360, 1, false),
    _Config(360, 1, true),
    _Config(320, 1.3, false),
    _Config(390, 2, true),
  ];

  for (final config in configs) {
    testWidgets('telas com histórico ${config.suffix}', (tester) async {
      final db = createTestDatabase();
      tearDownWidgetsAndDatabase(tester, db);
      final demo = (await tester.runAsync(() => DemoData.seed(db, now: now)))!;
      await open(tester, db, config);

      await shot(tester, '01_inicio', config);
      nav().go(Routes.plans);
      await _settle(tester);
      await shot(tester, '05_fichas', config);
      push(Routes.plan(demo.planIds.first));
      await _settle(tester);
      await shot(tester, '06_ficha_detalhe', config);
      nav().pop();
      nav().go(Routes.history);
      await _settle(tester);
      await shot(tester, '07_historico', config);
      nav().go(Routes.progress);
      await _settle(tester);
      await shot(tester, '08_evolucao_cargas', config);
      final supino = (await tester.runAsync(
        () => exerciseByName(db, 'Supino reto'),
      ))!;
      push(Routes.exercise(supino.id));
      await _settle(tester);
      await shot(tester, '09_exercicio_detalhe', config);
      nav().pop();
      await _settle(tester, 4);
      push(Routes.workoutSummary(demo.lastSessionId));
      await _settle(tester);
      await shot(tester, '10_resumo', config);
      nav().pop();
      nav().go(Routes.profile);
      await _settle(tester);
      await shot(tester, '11_perfil', config);
      await _unmount(tester);
    });

    // Treino em andamento: Início, execução e temporizador. Os dados são
    // gravados antes de abrir o app (escrever com a UI aberta trava).
    testWidgets('treino em andamento ${config.suffix}', (tester) async {
      final db = createTestDatabase();
      tearDownWidgetsAndDatabase(tester, db);
      final runningId = (await tester.runAsync(() async {
        final demo = await DemoData.seed(db, now: now);
        return DemoData.startRunning(db, demo.planIds.first, now: now);
      }))!;
      final container = await open(tester, db, config);
      await shot(tester, '02_inicio_treino_ativo', config);
      push(Routes.workout(runningId));
      await _settle(tester);
      container
          .read(timerControllerProvider.notifier)
          .start(const Duration(seconds: 90));
      offset = const Duration(seconds: 28);
      await _settle(tester);
      await shot(tester, '03_treino_timer_rodando', config);
      offset = const Duration(seconds: 95);
      await _settle(tester, 6);
      await shot(tester, '04_treino_descanso_concluido', config);
      await _settle(tester, 60);
      await shot(tester, '04b_treino_aviso_minimizado', config);
      await _unmount(tester);
    });

    testWidgets('primeiro uso ${config.suffix}', (tester) async {
      final db = createTestDatabase();
      tearDownWidgetsAndDatabase(tester, db);
      await open(tester, db, config, onboarded: false);
      await shot(tester, '12_onboarding', config);
      await _unmount(tester);
    });

    testWidgets('sem fichas ${config.suffix}', (tester) async {
      final db = createTestDatabase();
      tearDownWidgetsAndDatabase(tester, db);
      await tester.runAsync(() => DemoData.seedProfileOnly(db, now: now));
      await open(tester, db, config);
      await shot(tester, '13_inicio_vazio', config);
      nav().go(Routes.plans);
      await _settle(tester);
      await shot(tester, '14_fichas_vazio', config);
      nav().go(Routes.progress);
      await _settle(tester);
      await shot(tester, '15_evolucao_vazio', config);
      await _unmount(tester);
    });
  }
}
