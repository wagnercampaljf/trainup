import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:trainup/app.dart';
import 'package:trainup/core/database/database_provider.dart';
import 'package:trainup/core/utils/alert_feedback.dart';
import 'package:trainup/core/utils/formatters.dart';
import 'package:trainup/features/profile/presentation/onboarding_status.dart';
import 'package:trainup/features/settings/data/settings_repository.dart';
import 'package:trainup/features/timer/presentation/timer_controller.dart';
import 'package:trainup/features/workouts/data/workout_session_repository.dart';

import '../helpers/test_database.dart';

/// Avança frames sem `pumpAndSettle` (o timer global gera frames contínuos).
Future<void> settle(WidgetTester tester, [int frames = 12]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Finder keyPrefix(String prefix) => find.byWidgetPredicate(
  (w) =>
      w.key is ValueKey<String> &&
      (w.key! as ValueKey<String>).value.startsWith(prefix),
);

class _SilentFeedback extends AlertFeedback {
  @override
  Future<void> timerFinished({required bool vibrate, required bool sound}) =>
      Future.value();
}

void main() {
  setUpAll(() => initializeDateFormatting(appLocale));

  testWidgets('fluxo completo: perfil, ficha, treino, timer e histórico', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    final db = createTestDatabase();
    tearDownWidgetsAndDatabase(tester, db);
    final settings = await tester.runAsync(() => SettingsRepository(db).load());

    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          onboardingStatusProvider.overrideWithValue(
            OnboardingStatus(completed: false),
          ),
          initialSettingsProvider.overrideWithValue(settings!),
          alertFeedbackProvider.overrideWithValue(_SilentFeedback()),
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

    // 1. Onboarding: sem e-mail; política de privacidade acessível antes do
    // cadastro (exigência das lojas).
    expect(find.byKey(const Key('profile_email')), findsNothing);
    await tester.tap(find.byKey(const Key('onboarding_privacy')));
    await settle(tester);
    expect(find.text('Política de privacidade'), findsOneWidget);
    expect(find.text('Resumo'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Backup do sistema'), 300);
    expect(find.text('Backup do sistema'), findsOneWidget);
    // `pageBack` procura o BackButton do Material legado; o app usa
    // material_ui.
    await tester.tap(find.byType(BackButton));
    await settle(tester);

    // Perfil + medidas iniciais.
    await tester.enterText(find.byKey(const Key('profile_name')), 'Wagner');
    await tester.enterText(find.byKey(const Key('profile_height')), '178');
    await tester.tap(find.byKey(const Key('onboarding_next')));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('metric_weight')), '95');
    await tester.tap(find.byKey(const Key('onboarding_next')));
    await settle(tester);
    expect(find.text('Olá, Wagner'), findsOneWidget);

    // 2. Criar ficha com Supino reto 12×30, 10×35, 8×40.
    await tester.tap(find.text('Fichas'));
    await settle(tester);
    expect(find.text('Você ainda não possui nenhuma ficha.'), findsOneWidget);
    await tester.tap(find.text('CRIAR PRIMEIRA FICHA'));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('plan_name')), 'Ficha A');
    await tester.tap(find.byKey(const Key('add_exercise')));
    await settle(tester);
    await tester.enterText(
      find.byKey(const Key('exercise_search')),
      'supino reto',
    );
    await settle(tester);
    await tester.tap(find.text('Supino reto'));
    await settle(tester);
    const plannedSets = [('12', '30'), ('10', '35'), ('8', '40')];
    for (final (i, (reps, weight)) in plannedSets.indexed) {
      await tester.enterText(find.byKey(Key('plan_set_reps_$i')), reps);
      await tester.enterText(find.byKey(Key('plan_set_weight_$i')), weight);
    }
    await tester.tap(find.byKey(const Key('save_plan')));
    await settle(tester);
    expect(find.text('12 × 30 · 10 × 35 · 8 × 40 kg'), findsOneWidget);

    // 3. Iniciar treino e concluir as séries.
    await tester.tap(find.byKey(const Key('start_workout')));
    await settle(tester);
    expect(find.text('SUPINO RETO'), findsOneWidget);
    final completeButtons = keyPrefix('complete_set_');
    expect(completeButtons, findsNWidgets(3));
    for (var i = 0; i < 3; i++) {
      await tester.tap(completeButtons.at(i));
      await settle(tester, 4);
    }

    // O descanso de 90s (padrão) iniciou automaticamente.
    final timer = container.read(timerControllerProvider);
    expect(timer.snapshot.isRunning, isTrue);
    expect(timer.snapshot.duration, const Duration(seconds: 90));

    // O timer continua disponível e é controlável pelo botão global.
    await tester.tap(find.byKey(const Key('timer_button')));
    await settle(tester);
    expect(find.text('Descansando…'), findsOneWidget);
    await tester.tap(find.byKey(const Key('timer_toggle')));
    await settle(tester);
    expect(container.read(timerControllerProvider).snapshot.isPaused, isTrue);
    await tester.tapAt(const Offset(200, 40));
    await settle(tester);

    // 4. Finalizar treino → resumo → histórico.
    await tester.tap(find.byKey(const Key('finish_workout')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('confirm_finish')));
    await settle(tester);
    expect(find.text('TREINO CONCLUÍDO'), findsOneWidget);
    // Finalizar o treino encerra o descanso pendente.
    expect(container.read(timerControllerProvider).snapshot.isIdle, isTrue);
    expect(find.text('1.030 kg'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('summary_notes')),
      'Treino muito bom.',
    );
    await tester.tap(find.byKey(const Key('summary_done')));
    await settle(tester);
    expect(find.text('Série 3: 8 × 40 kg'), findsOneWidget);
    expect(find.text('Treino muito bom.'), findsOneWidget);

    // Dados persistidos no banco.
    final history = await tester.runAsync(
      () => WorkoutSessionRepository(db).watchHistory().first,
    );
    expect(history!.single.setCount, 3);
    expect(history.single.notes, 'Treino muito bom.');

    container.read(timerControllerProvider.notifier).reset();
    await tester.pumpWidget(const SizedBox.shrink());
    await settle(tester, 2);
  });
}
