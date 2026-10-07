import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/formatters.dart';
import '../domain/app_preferences.dart';
import 'settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const restOptions = [30, 45, 60, 90, 120, 150, 180, 240, 300];
  static const incrementOptions = [0.5, 1.0, 1.25, 2.0, 2.5, 5.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          Text('Tema', style: context.text.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<ThemePreference>(
            segments: [
              for (final p in ThemePreference.values)
                ButtonSegment(value: p, label: Text(p.label)),
            ],
            selected: {settings.themePreference},
            onSelectionChanged: (value) => controller.update(
              (s) => s.copyWith(themePreference: value.first),
            ),
          ),
          const SizedBox(height: 24),
          Text('Temporizador', style: context.text.titleSmall),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Iniciar timer ao concluir série'),
            subtitle: const Text('Usa o descanso configurado no exercício'),
            value: settings.autoStartTimer,
            onChanged: (v) =>
                controller.update((s) => s.copyWith(autoStartTimer: v)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Som ao terminar'),
            value: settings.timerSound,
            onChanged: (v) =>
                controller.update((s) => s.copyWith(timerSound: v)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Vibração ao terminar'),
            value: settings.timerVibration,
            onChanged: (v) =>
                controller.update((s) => s.copyWith(timerVibration: v)),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            isExpanded: true,
            initialValue: restOptions.contains(settings.defaultRestSeconds)
                ? settings.defaultRestSeconds
                : null,
            decoration: const InputDecoration(labelText: 'Descanso padrão'),
            items: [
              for (final seconds in restOptions)
                DropdownMenuItem(
                  value: seconds,
                  child: Text(formatRest(Duration(seconds: seconds))),
                ),
            ],
            onChanged: (v) {
              if (v != null) {
                controller.update((s) => s.copyWith(defaultRestSeconds: v));
              }
            },
          ),
          const SizedBox(height: 24),
          Text('Treino', style: context.text.titleSmall),
          const SizedBox(height: 8),
          DropdownButtonFormField<double>(
            isExpanded: true,
            initialValue: incrementOptions.contains(settings.weightIncrementKg)
                ? settings.weightIncrementKg
                : null,
            decoration: const InputDecoration(
              labelText: 'Incremento rápido de peso',
              helperText: 'Toque longo em −/+ aplica o dobro',
            ),
            items: [
              for (final value in incrementOptions)
                DropdownMenuItem(
                  value: value,
                  child: Text(formatWeight(value)),
                ),
            ],
            onChanged: (v) {
              if (v != null) {
                controller.update((s) => s.copyWith(weightIncrementKg: v));
              }
            },
          ),
          const SizedBox(height: 16),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Unidade de peso',
              helperText: 'Outras unidades estarão disponíveis futuramente',
            ),
            child: Text(settings.weightUnit.symbol),
          ),
          const SizedBox(height: 32),
          Text(
            'Seus dados ficam neste aparelho e não são enviados ao '
            'desenvolvedor. Se o backup do aparelho (Google ou iCloud) estiver '
            'ativado, ele pode incluí-los.',
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => context.push(Routes.privacy),
              icon: const Icon(Icons.privacy_tip_outlined),
              label: const Text('Política de privacidade'),
            ),
          ),
        ],
      ),
    );
  }
}
