import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/settings_controller.dart';
import 'features/timer/data/rest_alarm.dart';
import 'features/timer/presentation/timer_controller.dart';
import 'features/timer/presentation/timer_overlay.dart';

class TrainUpApp extends ConsumerStatefulWidget {
  const TrainUpApp({super.key});

  @override
  ConsumerState<TrainUpApp> createState() => _TrainUpAppState();
}

class _TrainUpAppState extends ConsumerState<TrainUpApp> {
  late final AppLifecycleListener _lifecycle;

  /// Há um aviso de fim de descanso agendado no sistema.
  var _alarmScheduled = false;

  /// A permissão de notificações já foi pedida nesta execução.
  var _askedNotifications = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onHide: _scheduleRestAlarm,
      onShow: _cancelRestAlarm,
      onResume: _onResume,
    );
  }

  /// Ao voltar do segundo plano, recalcula o timer a partir do relógio. Se o
  /// aviso do sistema estava agendado, ele já vibrou: o app não repete.
  void _onResume() {
    final systemAlarm = _alarmScheduled;
    _alarmScheduled = false;
    ref.read(timerControllerProvider.notifier).refresh(feedback: !systemAlarm);
  }

  /// Com o app fora da tela (ex.: celular bloqueado), só o sistema consegue
  /// vibrar/tocar no fim do descanso.
  void _scheduleRestAlarm() {
    final snapshot = ref.read(timerControllerProvider).snapshot;
    final endsAt = snapshot.endsAt;
    if (!snapshot.isRunning || endsAt == null) return;
    final settings = ref.read(settingsProvider);
    _alarmScheduled = true;
    unawaited(
      ref
          .read(restAlarmProvider)
          .schedule(
            endsAt,
            vibrate: settings.timerVibration,
            sound: settings.timerSound,
          )
          .catchError((Object _) {}),
    );
  }

  void _cancelRestAlarm() {
    if (!_alarmScheduled) return;
    unawaited(ref.read(restAlarmProvider).cancel().catchError((Object _) {}));
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No primeiro descanso, pede a permissão usada pelo aviso com a tela
    // bloqueada (Android 13+ e iOS).
    ref.listen(timerControllerProvider.select((s) => s.snapshot.isRunning), (
      _,
      running,
    ) {
      if (!running || _askedNotifications) return;
      _askedNotifications = true;
      unawaited(
        ref
            .read(restAlarmProvider)
            .requestNotifications()
            .catchError((Object _) {}),
      );
    });
    final router = ref.watch(appRouterProvider);
    final themePreference = ref.watch(
      settingsProvider.select((s) => s.themePreference),
    );
    return MaterialApp.router(
      title: 'TrainUp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themePreference.themeMode,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: router,
      builder: (context, child) =>
          TimerOverlay(child: child ?? const SizedBox.shrink()),
    );
  }
}
