import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_tile.dart';
import '../../body_measurements/data/body_measurement_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../../progress/data/progress_repository.dart';
import '../../progress/presentation/widgets/frequency_card.dart';
import '../../workout_plans/data/workout_plan_repository.dart';
import '../../workout_plans/domain/plan_models.dart';
import '../../workout_plans/presentation/plan_transfer_actions.dart';
import '../../workouts/data/workout_session_repository.dart';
import '../../workouts/presentation/start_workout.dart';
import '../domain/next_plan.dart';

/// Início: a próxima ação (retomar ou iniciar um treino) no topo, depois a
/// semana, as demais fichas e os números do mês.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  /// Fichas listadas além da ficha em destaque (o resto fica em "Fichas").
  static const maxListedPlans = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final plansValue = ref.watch(activePlansProvider);
    final plans = plansValue.value;
    final running = ref.watch(runningSessionProvider).value;
    final firstName = profile?.name.split(' ').first ?? '';
    final now = ref.watch(clockProvider)();
    final next = plans == null ? null : suggestNextPlan(plans);
    final others = [
      for (final p in plans ?? const <PlanSummary>[])
        if (p.id != next?.plan.id) p,
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.page,
            AppSpace.lg,
            AppSpace.page,
            AppSpace.listBottom,
          ),
          children: [
            Text(
              DateFormat("EEEE, d 'de' MMMM", appLocale).format(now),
              style: context.text.labelLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpace.xs),
            Text('Olá, $firstName', style: context.text.headlineMedium),
            const SizedBox(height: AppSpace.lg),
            if (running != null)
              _ResumeCard(session: running)
            else if (plans == null)
              const SizedBox(height: 160)
            else if (plans.isEmpty)
              const _FirstPlanCard()
            else if (next != null)
              _NextPlanCard(next: next)
            else
              _NoExercisesCard(plan: plans.first),
            const SectionHeader('Esta semana'),
            const FrequencyCard(),
            if (others.isNotEmpty) ...[
              SectionHeader(
                next == null && running == null
                    ? 'Suas fichas'
                    : 'Outras fichas',
                actionLabel: others.length > maxListedPlans
                    ? 'Ver todas (${plans!.length})'
                    : null,
                onAction: () => context.go(Routes.plans),
              ),
              _PlanList(plans: others.take(maxListedPlans).toList()),
            ],
            if (plans?.isNotEmpty ?? false) const _MonthNumbers(),
          ],
        ),
      ),
    );
  }
}

/// Painel de destaque (azul da marca): a ação principal da tela.
class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.eyebrow,
    required this.title,
    required this.children,
    this.onTap,
    super.key,
  });

  final Widget eyebrow;
  final String title;
  final List<Widget> children;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.primary,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.lg + 4),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: colors.onPrimary),
            child: IconTheme.merge(
              data: IconThemeData(color: colors.onPrimary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DefaultTextStyle.merge(
                    style: context.text.labelLarge?.copyWith(
                      color: colors.onPrimary,
                    ),
                    child: eyebrow,
                  ),
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    title,
                    style: context.text.headlineLarge?.copyWith(
                      color: colors.onPrimary,
                    ),
                  ),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botão claro sobre o painel azul.
class _HeroButton extends StatelessWidget {
  const _HeroButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: AppTheme.largeButtonHeight,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: colors.onPrimary,
          foregroundColor: colors.primary,
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 28),
        label: Text(label),
      ),
    );
  }
}

class _ResumeCard extends ConsumerWidget {
  const _ResumeCard({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(sessionDetailProvider(session.id)).value;
    final colors = context.colors;
    final total = detail?.plannedSetCount ?? 0;
    final done = detail?.completedSetCount ?? 0;
    void open() => context.push(Routes.workout(session.id));
    return _HeroPanel(
      key: const Key('home_resume_workout'),
      onTap: open,
      eyebrow: Row(
        children: [
          Icon(Icons.fiber_manual_record, size: 12, color: colors.onPrimary),
          const SizedBox(width: AppSpace.xs + 2),
          Flexible(
            child: Text(
              'Treino em andamento · desde '
              '${DateFormat.Hm(appLocale).format(session.startedAt)}',
            ),
          ),
        ],
      ),
      title: session.planNameSnapshot,
      children: [
        if (detail != null) ...[
          const SizedBox(height: AppSpace.md),
          Text(
            '$done de $total séries · ${formatVolume(detail.volume)}',
            style: context.text.bodyLarge?.copyWith(color: colors.onPrimary),
          ),
          const SizedBox(height: AppSpace.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              color: colors.onPrimary,
              backgroundColor: colors.onPrimary.withValues(alpha: .25),
              semanticsLabel: 'Progresso do treino: $done de $total séries',
            ),
          ),
        ],
        const SizedBox(height: AppSpace.lg),
        _HeroButton(
          key: const Key('resume_workout'),
          label: 'Retomar treino',
          icon: Icons.play_arrow_rounded,
          onPressed: open,
        ),
      ],
    );
  }
}

class _NextPlanCard extends ConsumerWidget {
  const _NextPlanCard({required this.next});

  final NextPlan next;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = next.plan;
    final colors = context.colors;
    final last = plan.lastPerformedAt;
    return _HeroPanel(
      key: const Key('home_next_plan'),
      onTap: () => context.push(Routes.plan(plan.id)),
      eyebrow: Text(
        [
          next.reason,
          if (last != null) 'último em ${formatShortDate(last)}',
        ].join(' · '),
      ),
      title: plan.name,
      children: [
        const SizedBox(height: AppSpace.xs),
        Text(
          [
            ?plan.description,
            '${plan.exerciseCount} '
                '${plan.exerciseCount == 1 ? 'exercício' : 'exercícios'}',
          ].join(' · '),
          style: context.text.bodyLarge?.copyWith(color: colors.onPrimary),
        ),
        const SizedBox(height: AppSpace.lg),
        _HeroButton(
          key: const Key('home_start_workout'),
          label: 'Iniciar treino',
          icon: Icons.play_arrow_rounded,
          onPressed: () => startWorkout(context, ref, plan.id),
        ),
      ],
    );
  }
}

/// Primeiro uso: criar uma ficha ou importar a recebida de um personal.
class _FirstPlanCard extends ConsumerWidget {
  const _FirstPlanCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return Card(
      key: const Key('home_first_plan'),
      color: colors.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.lg + 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.assignment_add,
              size: 32,
              color: colors.onPrimaryContainer,
            ),
            const SizedBox(height: AppSpace.sm),
            Text(
              'Comece pela sua ficha',
              style: context.text.headlineSmall?.copyWith(
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: AppSpace.xs),
            Text(
              'Monte a ficha com exercícios, séries e cargas, ou importe o '
              'arquivo que seu personal enviou.',
              style: context.text.bodyLarge?.copyWith(
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: AppSpace.lg),
            FilledButton.icon(
              key: const Key('home_create_plan'),
              onPressed: () => context.push(Routes.newPlan),
              icon: const Icon(Icons.add),
              label: const Text('Criar ficha'),
            ),
            const SizedBox(height: AppSpace.sm),
            OutlinedButton.icon(
              key: const Key('home_import_plan'),
              onPressed: () => importPlansFromFile(context, ref),
              icon: const Icon(Icons.file_download_outlined),
              label: const Text('Importar ficha recebida'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Há fichas, mas nenhuma com exercícios.
class _NoExercisesCard extends StatelessWidget {
  const _NoExercisesCard({required this.plan});

  final PlanSummary plan;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.playlist_add),
        title: Text('Adicione exercícios em ${plan.name}'),
        subtitle: const Text('Depois é só iniciar o treino por aqui.'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(Routes.editPlan(plan.id)),
      ),
    );
  }
}

/// Lista compacta de fichas: tocar abre a ficha; o botão inicia o treino.
class _PlanList extends ConsumerWidget {
  const _PlanList({required this.plans});

  final List<PlanSummary> plans;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        children: [
          for (final (index, plan) in plans.indexed) ...[
            if (index > 0) const Divider(indent: AppSpace.lg),
            ListTile(
              contentPadding: const EdgeInsets.only(
                left: AppSpace.lg,
                right: AppSpace.sm,
              ),
              title: Text(
                plan.name,
                style: context.text.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                [
                  ?plan.description,
                  if (plan.lastPerformedAt != null)
                    'último: ${formatShortDate(plan.lastPerformedAt!)}'
                  else
                    'ainda não treinada',
                ].join(' · '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => context.push(Routes.plan(plan.id)),
              trailing: plan.exerciseCount == 0
                  ? const Icon(Icons.chevron_right)
                  : IconButton.filledTonal(
                      tooltip: 'Iniciar treino ${plan.name}',
                      onPressed: () => startWorkout(context, ref, plan.id),
                      icon: const Icon(Icons.play_arrow_rounded),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Números do mês (sem repetir a contagem de treinos, que está na semana).
class _MonthNumbers extends ConsumerWidget {
  const _MonthNumbers();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider).value;
    final weight = ref.watch(latestBodyMeasurementProvider);
    final last = ref.watch(historyProvider).value?.firstOrNull;
    // "…" enquanto carrega: carregamento não se passa por zero.
    const loading = '…';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader('Seus números'),
        StatGrid(
          children: [
            StatTile(
              icon: Icons.stacked_bar_chart,
              label: 'Volume no mês',
              value: stats == null
                  ? loading
                  : formatVolume(stats.volumeThisMonth),
            ),
            StatTile(
              icon: Icons.trending_up,
              label: 'Exercícios com evolução',
              value: stats == null ? loading : '${stats.exercisesImproved}',
            ),
            StatTile(
              icon: Icons.monitor_weight_outlined,
              label: 'Peso corporal',
              value: switch (weight) {
                AsyncData(:final value?) => formatWeight(value.weightKg),
                AsyncData() => '—',
                _ => loading,
              },
              caption: switch (weight) {
                AsyncData(:final value?) => formatShortDate(value.date),
                _ => null,
              },
            ),
            StatTile(
              icon: Icons.event_available,
              label: 'Último treino',
              value: last == null ? '—' : formatShortDate(last.startedAt),
              caption: last?.planName,
            ),
          ],
        ),
        if (last != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              key: const Key('home_last_workout'),
              onPressed: () => context.push(Routes.historyDetail(last.id)),
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('Ver último treino'),
            ),
          ),
      ],
    );
  }
}
