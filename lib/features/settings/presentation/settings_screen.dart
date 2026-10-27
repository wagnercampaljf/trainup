import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/alert_feedback.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/section_header.dart';
import '../../timer/domain/rest_options.dart';
import '../../timer/presentation/rest_alarm_permission_notice.dart';
import '../domain/app_preferences.dart';
import 'settings_controller.dart';

/// Preferências em grupos: aparência, descanso, treino e privacidade.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const incrementOptions = [0.5, 1.0, 1.25, 2.0, 2.5, 5.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.page,
          0,
          AppSpace.page,
          AppSpace.listBottom,
        ),
        children: [
          const SectionHeader('Aparência'),
          _Group(
            children: [
              Text('Tema', style: context.text.titleSmall),
              const SizedBox(height: AppSpace.sm),
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
            ],
          ),
          const SectionHeader('Descanso'),
          _Group(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Iniciar timer ao concluir série'),
                subtitle: const Text('Usa o descanso configurado no exercício'),
                value: settings.autoStartTimer,
                onChanged: (v) =>
                    controller.update((s) => s.copyWith(autoStartTimer: v)),
              ),
              const SizedBox(height: AppSpace.sm),
              DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue:
                    restOptionsSeconds.contains(settings.defaultRestSeconds)
                    ? settings.defaultRestSeconds
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Descanso padrão',
                  helperText: 'Para exercícios sem descanso próprio',
                ),
                items: [
                  for (final seconds in restOptionsSeconds)
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
              const Divider(height: AppSpace.xl),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Som ao terminar'),
                value: settings.timerSound,
                onChanged: (v) =>
                    controller.update((s) => s.copyWith(timerSound: v)),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const Key('test_timer_sound'),
                  onPressed: () => ref.read(alertFeedbackProvider).playSound(),
                  icon: const Icon(Icons.volume_up_outlined),
                  label: const Text('Testar som'),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Vibração ao terminar'),
                value: settings.timerVibration,
                onChanged: (v) =>
                    controller.update((s) => s.copyWith(timerVibration: v)),
              ),
              const RestAlarmPermissionNotice(),
            ],
          ),
          const SectionHeader('Treino'),
          _Group(
            children: [
              DropdownButtonFormField<int>(
                key: const Key('weekly_goal'),
                isExpanded: true,
                initialValue: settings.weeklyGoal,
                decoration: const InputDecoration(
                  labelText: 'Meta de treinos por semana',
                  helperText: 'Usada no acompanhamento da semana, no Início',
                ),
                items: [
                  for (var goal = 1; goal <= 7; goal++)
                    DropdownMenuItem(
                      value: goal,
                      child: Text(goal == 1 ? '1 treino' : '$goal treinos'),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    controller.update((s) => s.copyWith(weeklyGoal: v));
                  }
                },
              ),
              const SizedBox(height: AppSpace.lg),
              DropdownButtonFormField<double>(
                isExpanded: true,
                initialValue:
                    incrementOptions.contains(settings.weightIncrementKg)
                    ? settings.weightIncrementKg
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Incremento rápido de carga',
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
              const SizedBox(height: AppSpace.lg),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Unidade de peso',
                  helperText: 'Outras unidades estarão disponíveis futuramente',
                ),
                child: Text(settings.weightUnit.symbol),
              ),
            ],
          ),
          const SectionHeader('Privacidade'),
          _Group(
            children: [
              Text(
                'Seus dados ficam neste aparelho e não são enviados ao '
                'desenvolvedor. Se o backup do aparelho (Google ou iCloud) '
                'estiver ativado, ele pode incluí-los.',
                style: context.text.bodyMedium?.copyWith(
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
        ],
      ),
    );
  }
}

/// Grupo de preferências em um cartão.
class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.lg,
          AppSpace.md,
          AppSpace.lg,
          AppSpace.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}
