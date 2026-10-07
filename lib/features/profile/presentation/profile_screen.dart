import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../../../core/widgets/stat_tile.dart';
import '../../body_measurements/data/body_measurement_repository.dart';
import '../data/profile_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latest = ref.watch(latestBodyMeasurementProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            tooltip: 'Configurações',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: AsyncValueWidget(
        value: ref.watch(profileProvider),
        data: (profile) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            if (profile != null) _ProfileHeader(profile: profile),
            const SizedBox(height: 16),
            StatGrid(
              children: [
                StatTile(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Peso atual',
                  value: latest == null ? '—' : formatWeight(latest.weightKg),
                  caption: latest == null ? null : formatDate(latest.date),
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
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  _NavTile(
                    icon: Icons.edit_outlined,
                    title: 'Editar perfil',
                    onTap: () => context.push(Routes.editProfile),
                  ),
                  _NavTile(
                    icon: Icons.add_chart,
                    title: 'Registrar peso e medidas',
                    onTap: () => context.push(Routes.newMeasurement),
                  ),
                  _NavTile(
                    icon: Icons.straighten,
                    title: 'Histórico de medidas',
                    onTap: () => context.push(Routes.measurements),
                  ),
                  _NavTile(
                    icon: Icons.fitness_center,
                    title: 'Exercícios',
                    onTap: () => context.push(Routes.exercises),
                  ),
                  _NavTile(
                    icon: Icons.settings_outlined,
                    title: 'Configurações',
                    onTap: () => context.push(Routes.settings),
                  ),
                  _NavTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Política de privacidade',
                    onTap: () => context.push(Routes.privacy),
                  ),
                ],
              ),
            ),
          ],
        ),
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
              Text(
                profile.name,
                style: context.text.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                details.join(' · '),
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
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
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
