import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_tile.dart';
import '../../body_measurements/data/body_measurement_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../../progress/data/progress_repository.dart';
import '../../workout_plans/data/workout_plan_repository.dart';
import '../../workout_plans/presentation/widgets/workout_plan_card.dart';
import '../../workouts/data/workout_session_repository.dart';
import '../../workouts/presentation/start_workout.dart';
import '../../workouts/presentation/widgets/session_summary_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final plans = ref.watch(activePlansProvider).value ?? const [];
    final running = ref.watch(runningSessionProvider).value;
    final lastWorkout = ref.watch(historyProvider).value?.firstOrNull;
    final stats = ref.watch(dashboardStatsProvider).value;
    final weight = ref.watch(latestBodyMeasurementProvider).value;
    final firstName = profile?.name.split(' ').first ?? '';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
          children: [
            Text(
              'Olá, $firstName',
              style: context.text.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            if (running != null) ...[
              Card(
                color: context.colors.primaryContainer,
                child: ListTile(
                  leading: const Icon(Icons.play_circle_fill, size: 36),
                  title: const Text('Treino em andamento'),
                  subtitle: Text(running.planNameSnapshot),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(Routes.workout(running.id)),
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SectionHeader('Treinar hoje'),
            if (plans.isEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.add_circle_outline),
                  title: const Text('Crie sua primeira ficha'),
                  onTap: () => context.push(Routes.newPlan),
                ),
              )
            else
              for (final plan in plans) ...[
                WorkoutPlanCard(
                  plan: plan,
                  onTap: () => context.push(Routes.plan(plan.id)),
                  onStart: () => startWorkout(context, ref, plan.id),
                ),
                const SizedBox(height: 8),
              ],
            if (lastWorkout != null) ...[
              const SectionHeader('Último treino'),
              SessionSummaryCard(
                summary: lastWorkout,
                onTap: () => context.push(Routes.historyDetail(lastWorkout.id)),
              ),
            ],
            const SectionHeader('Indicadores'),
            StatGrid(
              children: [
                StatTile(
                  icon: Icons.calendar_month,
                  label: 'Treinos este mês',
                  value: '${stats?.workoutsThisMonth ?? 0}',
                ),
                StatTile(
                  icon: Icons.stacked_bar_chart,
                  label: 'Volume no mês',
                  value: formatVolume(stats?.volumeThisMonth ?? 0),
                ),
                StatTile(
                  icon: Icons.trending_up,
                  label: 'Exercícios com evolução',
                  value: '${stats?.exercisesImproved ?? 0}',
                ),
                StatTile(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Peso corporal',
                  value: weight == null ? '—' : formatWeight(weight.weightKg),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
