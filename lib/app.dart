import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/settings_controller.dart';
import 'features/timer/presentation/timer_controller.dart';
import 'features/timer/presentation/timer_overlay.dart';

class TrainUpApp extends ConsumerStatefulWidget {
  const TrainUpApp({super.key});

  @override
  ConsumerState<TrainUpApp> createState() => _TrainUpAppState();
}

class _TrainUpAppState extends ConsumerState<TrainUpApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Ao voltar do segundo plano, recalcula o timer a partir do relógio.
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.read(timerControllerProvider.notifier).refresh(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
