import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_tile.dart';
import '../../body_measurements/data/body_measurement_repository.dart';
import '../data/profile_repository.dart';

/// Perfil: dados pessoais, corpo (medidas), treino e preferências do app,
/// cada grupo com seus acessos (sem atalhos repetidos).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latest = ref.watch(latestBodyMeasurementProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: AsyncValueWidget(
        value: ref.watch(profileProvider),
        onRetry: () => ref.invalidate(profileProvider),
        data: (profile) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.page,
            AppSpace.sm,
            AppSpace.page,
            AppSpace.listBottom,
          ),
          children: [
            if (profile != null) _ProfileHeader(profile: profile),
            SectionHeader(
              'Corpo',
              subtitle: latest == null
                  ? 'Nenhuma medição registrada'
                  : 'Última medição em ${formatDate(latest.date)}',
            ),
            StatGrid(
              children: [
                StatTile(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Peso atual',
                  value: latest == null ? '—' : formatWeight(latest.weightKg),
                ),
                StatTile(
                  icon: Icons.height,
                  label: 'Altura',
                  value: profile == null
                      ? '—'
                      : '${formatDecimal(profile.heightCm)} cm',
                ),
                StatTile(
                  icon: Icons.percent,
                  label: 'Gordura corporal',
                  value: latest?.bodyFatPercentage == null
                      ? '—'
                      : '${formatDecimal(latest!.bodyFatPercentage!)}%',
                ),
                StatTile(
                  icon: Icons.calculate_outlined,
                  label: 'IMC',
                  value: profile == null || latest == null
                      ? '—'
                      : formatDecimal(
                          latest.weightKg /
                              ((profile.heightCm / 100) *
                                  (profile.heightCm / 100)),
                          maxDecimals: 1,
                        ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.md),
            Wrap(
              spacing: AppSpace.sm,
              runSpacing: AppSpace.sm,
              children: [
                FilledButton.icon(
                  key: const Key('profile_new_measurement'),
                  onPressed: () => context.push(Routes.newMeasurement),
                  icon: const Icon(Icons.add_chart),
                  label: const Text('Registrar medição'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push(Routes.measurements),
                  icon: const Icon(Icons.straighten),
                  label: const Text('Histórico de medidas'),
                ),
              ],
            ),
            const SectionHeader('Treino'),
            _Group(
              children: [
                _NavTile(
                  icon: Icons.fitness_center,
                  title: 'Exercícios',
                  subtitle: 'Catálogo, exercícios próprios e evolução',
                  onTap: () => context.push(Routes.exercises),
                ),
              ],
            ),
            const SectionHeader('App'),
            _Group(
              children: [
                _NavTile(
                  icon: Icons.settings_outlined,
                  title: 'Configurações',
                  subtitle: 'Tema, descanso, som e meta semanal',
                  onTap: () => context.push(Routes.settings),
                ),
                _NavTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Política de privacidade',
                  onTap: () => context.push(Routes.privacy),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0) const Divider(indent: 56),
            child,
          ],
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserProfile profile;

  int? get _age {
    final birth = profile.birthDate;
    if (birth == null) return null;
    final now = DateTime.now();
    var age = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final details = [
      if (_age != null) '$_age anos',
      if (profile.sex != null) profile.sex!.label,
    ];
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: context.colors.primaryContainer,
          child: Text(
            profile.name.characters.first.toUpperCase(),
            style: context.text.headlineSmall?.copyWith(
              color: context.colors.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(profile.name, style: context.text.headlineSmall),
              if (details.isNotEmpty)
                Text(
                  details.join(' · '),
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        IconButton.outlined(
          key: const Key('profile_edit'),
          tooltip: 'Editar perfil',
          onPressed: () => context.push(Routes.editProfile),
          icon: const Icon(Icons.edit_outlined),
        ),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
