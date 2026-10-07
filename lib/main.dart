import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'core/database/database_provider.dart';
import 'core/utils/formatters.dart';
import 'features/profile/data/profile_repository.dart';
import 'features/profile/presentation/onboarding_status.dart';
import 'features/settings/data/settings_repository.dart';
import 'features/timer/data/timer_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = appLocale;
  await initializeDateFormatting(appLocale);

  final db = AppDatabase.open();
  // Carrega o estado essencial antes da primeira tela (sem "piscar").
  final hasProfile = await ProfileRepository(db).hasProfile();
  final settings = await SettingsRepository(db).load();
  final timer = await TimerRepository(db).load();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        onboardingStatusProvider.overrideWithValue(
          OnboardingStatus(completed: hasProfile),
        ),
        initialSettingsProvider.overrideWithValue(settings),
        initialTimerSnapshotProvider.overrideWithValue(timer),
      ],
      child: const TrainUpApp(),
    ),
  );
}
