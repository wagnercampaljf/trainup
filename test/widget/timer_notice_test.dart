import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:trainup/core/utils/alert_feedback.dart';
import 'package:trainup/core/utils/clock.dart';
import 'package:trainup/features/timer/data/timer_repository.dart';
import 'package:trainup/features/timer/domain/timer_snapshot.dart';
import 'package:trainup/features/timer/presentation/timer_button.dart';
import 'package:trainup/features/profile/presentation/onboarding_status.dart';
import 'package:trainup/features/timer/presentation/timer_controller.dart';
import 'package:trainup/features/timer/presentation/timer_overlay.dart';

/// Repositório em memória (o aviso é só interface; não precisa de SQLite).
class _MemoryTimerRepository implements TimerRepository {
  TimerSnapshot saved = const TimerSnapshot.idle(Duration(seconds: 90));

  @override
  Future<TimerSnapshot> load() async => saved;

  @override
  Future<void> save(TimerSnapshot snapshot) async => saved = snapshot;
}

class _SilentFeedback extends AlertFeedback {
  @override
  Future<void> timerFinished({required bool vibrate, required bool sound}) =>
      Future.value();
}

void main() {
  late DateTime now;
  late int opened;
  late ProviderContainer container;

  Future<void> pumpButton(
    WidgetTester tester, {
    TimerSnapshot initial = const TimerSnapshot.idle(Duration(seconds: 90)),
  }) async {
    now = DateTime(2026, 10, 5, 18);
    opened = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          timerRepositoryProvider.overrideWithValue(_MemoryTimerRepository()),
          initialTimerSnapshotProvider.overrideWithValue(initial),
          clockProvider.overrideWithValue(() => now),
          alertFeedbackProvider.overrideWithValue(_SilentFeedback()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Center(child: TimerButton(onPressed: () => opened++)),
          ),
        ),
      ),
    );
    container = ProviderScope.containerOf(
      tester.element(find.byType(TimerButton)),
    );
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
  }

  /// Faz o descanso de 30 s terminar e deixa o ticker detectar o fim.
  Future<void> finishRest(WidgetTester tester) async {
    container
        .read(timerControllerProvider.notifier)
        .start(const Duration(seconds: 30));
    await tester.pump();
    now = now.add(const Duration(seconds: 31));
    await tester.pump(TimerController.tickInterval);
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('aviso aparece ao terminar e minimiza sozinho', (tester) async {
    await pumpButton(tester);
    await finishRest(tester);
    expect(container.read(timerControllerProvider).snapshot.isFinished, isTrue);
    expect(find.text('Descanso concluído'), findsOneWidget);
    expect(find.byKey(const Key('timer_notice_close')), findsOneWidget);

    await tester.pump(TimerButton.noticeDuration);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Descanso concluído'), findsNothing);
    expect(find.byIcon(Icons.alarm_on), findsOneWidget);
  });

  testWidgets('X minimiza; tocar no ícone reabre o aviso', (tester) async {
    await pumpButton(tester);
    await finishRest(tester);

    await tester.tap(find.byKey(const Key('timer_notice_close')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Descanso concluído'), findsNothing);
    expect(opened, 0, reason: 'o X não abre os controles');

    await tester.tap(find.byKey(const Key('timer_button')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Descanso concluído'), findsOneWidget);
    expect(opened, 0, reason: 'o ícone só reabre o aviso');

    // Com o aviso aberto, tocar na mensagem abre os controles.
    await tester.tap(find.byKey(const Key('timer_button')));
    expect(opened, 1);

    // Reaberto, ele também minimiza sozinho.
    await tester.pump(TimerButton.noticeDuration);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Descanso concluído'), findsNothing);
  });

  testWidgets('descanso concluído com o app fechado abre minimizado', (
    tester,
  ) async {
    await pumpButton(
      tester,
      initial: const TimerSnapshot.idle(Duration(seconds: 30)).finish(),
    );
    expect(find.text('Descanso concluído'), findsNothing);
    expect(find.byIcon(Icons.alarm_on), findsOneWidget);
  });

  testWidgets('resetar fecha o aviso e volta ao ícone de timer', (
    tester,
  ) async {
    await pumpButton(tester);
    await finishRest(tester);
    container.read(timerControllerProvider.notifier).reset();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Descanso concluído'), findsNothing);
    expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
  });

  testWidgets('botão preso à direita cresce para dentro da tela', (
    tester,
  ) async {
    now = DateTime(2026, 10, 5, 18);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          timerRepositoryProvider.overrideWithValue(_MemoryTimerRepository()),
          clockProvider.overrideWithValue(() => now),
          alertFeedbackProvider.overrideWithValue(_SilentFeedback()),
          onboardingStatusProvider.overrideWithValue(
            OnboardingStatus(completed: true),
          ),
        ],
        child: MaterialApp(
          builder: (context, child) => TimerOverlay(child: child!),
          home: const Scaffold(),
        ),
      ),
    );
    final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    final button = find.byKey(const Key('timer_button'));
    expect(tester.getRect(button).left, lessThan(width / 2));

    // Arrasta para a direita e solta: fica preso à borda direita.
    await tester.drag(button, Offset(width, 0));
    await tester.pumpAndSettle();
    expect(tester.getRect(button).right, closeTo(width - 8, 1));

    // Ao contar, a pílula cresce para a esquerda e continua inteira na tela.
    final c = ProviderScope.containerOf(tester.element(button));
    c.read(timerControllerProvider.notifier).start(const Duration(seconds: 90));
    // Um quadro para iniciar a animação de tamanho e outro após os 200 ms.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final rect = tester.getRect(button);
    expect(find.text('01:30'), findsOneWidget);
    expect(rect.right, lessThanOrEqualTo(width));
    expect(rect.left, greaterThanOrEqualTo(0));
    expect(rect.width, greaterThan(56));

    // Voltando para a esquerda, prende à esquerda de novo.
    await tester.drag(button, Offset(-width, 0));
    await tester.pumpAndSettle();
    expect(tester.getRect(button).left, closeTo(8, 1));
    c.read(timerControllerProvider.notifier).reset();
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
