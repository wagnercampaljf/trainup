import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainup/core/database/app_database.dart';
import 'package:trainup/core/database/database_provider.dart';
import 'package:trainup/core/utils/alert_feedback.dart';
import 'package:trainup/core/utils/clock.dart';
import 'package:trainup/features/timer/data/timer_repository.dart';
import 'package:trainup/features/timer/presentation/timer_controller.dart';

import '../helpers/test_database.dart';

class _FakeFeedback extends AlertFeedback {
  int calls = 0;

  @override
  Future<void> timerFinished({
    required bool vibrate,
    required bool sound,
  }) async => calls++;
}

void main() {
  late AppDatabase db;
  late DateTime now;
  late _FakeFeedback feedback;

  setUp(() {
    db = createTestDatabase();
    now = DateTime(2026, 10, 4, 10);
    feedback = _FakeFeedback();
  });
  tearDown(() => db.close());

  Future<ProviderContainer> container() async {
    final saved = await TimerRepository(db).load();
    final c = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
        alertFeedbackProvider.overrideWithValue(feedback),
        initialTimerSnapshotProvider.overrideWithValue(saved),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('estado é único e global; conclui e vibra ao chegar a zero', () async {
    final c = await container();
    final controller = c.read(timerControllerProvider.notifier)
      ..start(const Duration(seconds: 90));
    now = now.add(const Duration(seconds: 30));
    controller.refresh();
    expect(c.read(timerControllerProvider).remaining.inSeconds, 60);

    now = now.add(const Duration(seconds: 61));
    controller.refresh();
    expect(c.read(timerControllerProvider).snapshot.isFinished, isTrue);
    expect(feedback.calls, 1);
  });

  test('restaura após o app ser fechado e reaberto', () async {
    final first = await container();
    first
        .read(timerControllerProvider.notifier)
        .start(const Duration(seconds: 90));
    await Future<void>.delayed(Duration.zero);
    first.dispose();

    now = now.add(const Duration(seconds: 40));
    final second = await container();
    final state = second.read(timerControllerProvider);
    expect(state.snapshot.isRunning, isTrue);
    expect(state.remaining.inSeconds, 50);
  });

  test('se acabou enquanto fechado, abre como concluído', () async {
    final first = await container();
    first
        .read(timerControllerProvider.notifier)
        .start(const Duration(seconds: 60));
    await Future<void>.delayed(Duration.zero);
    first.dispose();

    now = now.add(const Duration(minutes: 10));
    final second = await container();
    expect(second.read(timerControllerProvider).snapshot.isFinished, isTrue);
  });

  test('pausar, continuar e resetar', () async {
    final c = await container();
    final controller = c.read(timerControllerProvider.notifier)
      ..start(const Duration(seconds: 60));
    now = now.add(const Duration(seconds: 10));
    controller.pause();
    now = now.add(const Duration(minutes: 5));
    controller.refresh();
    expect(c.read(timerControllerProvider).remaining.inSeconds, 50);
    controller.resume();
    now = now.add(const Duration(seconds: 5));
    controller.refresh();
    expect(c.read(timerControllerProvider).remaining.inSeconds, 45);
    controller.reset();
    expect(c.read(timerControllerProvider).snapshot.isIdle, isTrue);
  });
}
