import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../data/settings_repository.dart';

/// Estado global das configurações, persistido a cada alteração.
class SettingsController extends Notifier<AppSettingsRow> {
  @override
  AppSettingsRow build() => ref.read(initialSettingsProvider);

  Future<void> update(AppSettingsRow Function(AppSettingsRow) change) async {
    final next = change(state);
    state = next;
    await ref.read(settingsRepositoryProvider).save(next);
  }
}

final settingsProvider = NotifierProvider<SettingsController, AppSettingsRow>(
  SettingsController.new,
);
