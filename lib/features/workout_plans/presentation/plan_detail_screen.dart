import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/action_bar.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../settings/presentation/settings_controller.dart';
import '../../timer/presentation/rest_picker.dart';
import '../../workouts/presentation/set_text.dart';
import '../../workouts/presentation/start_workout.dart';
import '../data/workout_plan_repository.dart';
import '../domain/plan_models.dart';
import 'plan_transfer_actions.dart';

/// Visualização da ficha (o planejamento). Daqui o usuário inicia o treino
/// (ação principal), edita o planejamento ou envia a ficha; excluir fica no
/// menu, longe das ações frequentes.
class PlanDetailScreen extends ConsumerWidget {
  const PlanDetailScreen({required this.planId, super.key});

  final int planId;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Excluir ficha?',
      message:
          'A ficha será removida. Os treinos já realizados continuam no '
          'histórico.',
    );
    if (!confirmed) return;
    await ref.read(workoutPlanRepositoryProvider).deletePlan(planId);
    if (context.mounted) {
      context
        ..showMessage('Ficha excluída')
        ..pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planDetailProvider(planId));
    final hasExercises = plan.value?.exercises.isNotEmpty ?? false;
    return Scaffold(
      appBar: AppBar(
        title: Text(plan.value?.name ?? 'Ficha'),
        actions: [
          IconButton(
            key: const Key('export_plan'),
            tooltip: 'Enviar ficha',
            icon: const Icon(Icons.ios_share),
            onPressed: () => exportPlans(context, ref, [planId]),
          ),
          IconButton(
            tooltip: 'Editar ficha',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(Routes.editPlan(planId)),
          ),
          PopupMenuButton<String>(
            key: const Key('plan_menu'),
            tooltip: 'Mais opções',
            onSelected: (_) => _delete(context, ref),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.delete_outline,
                    color: context.colors.error,
                  ),
                  title: Text(
                    'Excluir ficha',
                    style: TextStyle(color: context.colors.error),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: AsyncValueWidget(
        value: plan,
        onRetry: () => ref.invalidate(planDetailProvider(planId)),
        data: (draft) {
          if (draft == null) {
            return const EmptyState(
              icon: Icons.assignment_late_outlined,
              message: 'Ficha não encontrada.',
            );
          }
          return _PlanDetailBody(plan: draft);
        },
      ),
      bottomNavigationBar: hasExercises
          ? ActionBar(
              secondary: OutlinedButton.icon(
                key: const Key('edit_plan'),
                onPressed: () => context.push(Routes.editPlan(planId)),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar'),
              ),
              primary: FilledButton.icon(
                key: const Key('start_workout'),
                onPressed: () => startWorkout(context, ref, planId),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Iniciar treino'),
              ),
            )
          : null,
    );
  }
}

class _PlanDetailBody extends ConsumerWidget {
  const _PlanDetailBody({required this.plan});

  final PlanDraft plan;

  Future<void> _changeRest(
    BuildContext context,
    WidgetRef ref,
    PlanExerciseDraft exercise,
    int defaultRest,
  ) async {
    final choice = await showRestPicker(
      context,
      exerciseName: exercise.exerciseName,
      current: exercise.restSeconds,
      defaultSeconds: defaultRest,
    );
    if (choice == null || !context.mounted) return;
    try {
      await ref
          .read(workoutPlanRepositoryProvider)
          .updateExerciseRest(exercise.id!, choice.seconds);
    } on Object catch (e) {
      if (context.mounted) {
        context.showError('alterar o descanso', e);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultRest = ref.watch(
      settingsProvider.select((s) => s.defaultRestSeconds),
    );
    if (plan.exercises.isEmpty) {
      return EmptyState(
        icon: Icons.fitness_center,
        message: 'Esta ficha ainda não tem exercícios.',
        description: 'Adicione exercícios, séries e cargas para treinar.',
        actionLabel: 'Adicionar exercícios',
        onAction: () => context.push(Routes.editPlan(plan.id!)),
      );
    }
    final colors = context.colors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.page,
        AppSpace.sm,
        AppSpace.page,
        AppSpace.listBottom,
      ),
      children: [
        if (plan.description != null) ...[
          Text(plan.description!, style: context.text.bodyLarge),
          const SizedBox(height: AppSpace.xs),
        ],
        Text(
          '${plan.exercises.length} '
          '${plan.exercises.length == 1 ? 'exercício' : 'exercícios'} · '
          '${plan.totalSets} séries',
          style: context.text.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpace.md),
        Card(
          child: Column(
            children: [
              for (final (index, exercise) in plan.exercises.indexed) ...[
                if (index > 0) const Divider(indent: 64),
                InkWell(
                  onTap: () =>
                      context.push(Routes.exercise(exercise.exerciseId)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.lg,
                      AppSpace.md,
                      AppSpace.xs,
                      AppSpace.md,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpace.xs,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: context.text.titleMedium?.copyWith(
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpace.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.exerciseName,
                                style: context.text.titleMedium,
                              ),
                              Text(
                                exercise.muscleGroup.label,
                                style: context.text.bodySmall,
                              ),
                              const SizedBox(height: AppSpace.xs),
                              Text(
                                formatSetsInline(
                                  exercise.sets.map(
                                    (s) => (
                                      weightKg: s.weightKg,
                                      repetitions: s.repetitions,
                                    ),
                                  ),
                                ),
                                style: context.text.bodyMedium?.tabular,
                              ),
                              Text(
                                'Descanso: '
                                '${formatRest(Duration(seconds: exercise.restSeconds ?? defaultRest))}'
                                '${exercise.restSeconds == null ? ' (padrão)' : ''}',
                                style: context.text.bodySmall,
                              ),
                              if (exercise.notes != null)
                                Text(
                                  exercise.notes!,
                                  style: context.text.bodySmall?.copyWith(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          key: Key('plan_rest_${exercise.id}'),
                          tooltip:
                              'Alterar descanso de ${exercise.exerciseName}',
                          icon: const Icon(Icons.timer_outlined),
                          onPressed: () =>
                              _changeRest(context, ref, exercise, defaultRest),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpace.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 16, color: colors.onSurfaceVariant),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: Text(
                'Editar muda o planejamento dos próximos treinos. Treinos já '
                'feitos continuam iguais no histórico.',
                style: context.text.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
