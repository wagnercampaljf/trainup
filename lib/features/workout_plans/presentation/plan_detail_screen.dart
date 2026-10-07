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
import '../../workouts/presentation/set_text.dart';
import '../../workouts/presentation/start_workout.dart';
import '../data/workout_plan_repository.dart';
import '../domain/plan_models.dart';

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

class _PlanDetailBody extends StatelessWidget {
  const _PlanDetailBody({required this.plan});

  final PlanDraft plan;

  @override
  Widget build(BuildContext context) {
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
                  if (exercise.restSeconds != null)
                    Text(
                      'Descanso: '
                      '${formatRest(Duration(seconds: exercise.restSeconds!))}',
                    ),
                  if (exercise.notes != null) Text(exercise.notes!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
