import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
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
          IconButton(
            tooltip: 'Excluir ficha',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      body: AsyncValueWidget(
        value: plan,
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
      bottomNavigationBar: (plan.value?.exercises.isNotEmpty ?? false)
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  height: AppTheme.largeButtonHeight,
                  child: FilledButton.icon(
                    key: const Key('start_workout'),
                    onPressed: () => startWorkout(context, ref, planId),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('INICIAR TREINO'),
                  ),
                ),
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
        actionLabel: 'Adicionar exercícios',
        onAction: () => context.push(Routes.editPlan(plan.id!)),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 160),
      children: [
        if (plan.description != null) ...[
          Text(plan.description!, style: context.text.bodyLarge),
          const SizedBox(height: 8),
        ],
        Text(
          '${plan.exercises.length} exercícios · ${plan.totalSets} séries',
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        for (final (index, exercise) in plan.exercises.indexed) ...[
          Card(
            child: ListTile(
              onTap: () => context.push(Routes.exercise(exercise.exerciseId)),
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(
                exercise.exerciseName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatSetsInline(
                      exercise.sets.map(
                        (s) =>
                            (weightKg: s.weightKg, repetitions: s.repetitions),
                      ),
                    ),
                  ),
                  Text(
                    'Descanso: '
                    '${formatRest(Duration(seconds: exercise.restSeconds ?? defaultRest))}'
                    '${exercise.restSeconds == null ? ' (padrão)' : ''}',
                  ),
                  if (exercise.notes != null) Text(exercise.notes!),
                ],
              ),
              trailing: IconButton(
                key: Key('plan_rest_${exercise.id}'),
                tooltip: 'Alterar descanso de ${exercise.exerciseName}',
                icon: const Icon(Icons.timer_outlined),
                onPressed: () =>
                    _changeRest(context, ref, exercise, defaultRest),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
