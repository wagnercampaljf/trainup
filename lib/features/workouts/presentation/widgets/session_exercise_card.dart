import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../settings/presentation/settings_controller.dart';
import '../../../timer/presentation/rest_picker.dart';
import '../../../workout_plans/data/workout_plan_repository.dart';
import '../../data/workout_session_repository.dart';
import '../../domain/session_models.dart';
import '../set_text.dart';
import 'set_row.dart';

/// Exercício durante o treino: último treino, séries e ações rápidas.
class SessionExerciseCard extends ConsumerWidget {
  const SessionExerciseCard({
    required this.detail,
    required this.sessionId,
    required this.nextSetId,
    required this.weightIncrement,
    required this.rowKeyFor,
    required this.onSetCompleted,
    super.key,
  });

  final SessionExerciseDetail detail;
  final int sessionId;
  final int? nextSetId;
  final double weightIncrement;
  final GlobalKey Function(int setId) rowKeyFor;

  /// Chamado após concluir uma série (inicia descanso, move o foco).
  final void Function(SessionExerciseDetail exercise, WorkoutSessionSet set)
  onSetCompleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercise = detail.exercise;
    final repo = ref.read(workoutSessionRepositoryProvider);
    final args = (exerciseId: exercise.exerciseId, sessionId: sessionId);
    final last = ref.watch(lastPerformanceProvider(args)).value ?? const [];
    final previousBest = ref.watch(previousBestWeightProvider(args)).value;
    final currentMax = detail.maxWeight;
    final isRecord =
        previousBest != null && currentMax != null && currentMax > previousBest;
    final defaultRest = ref.watch(
      settingsProvider.select((s) => s.defaultRestSeconds),
    );
    final rest = exercise.restSeconds ?? defaultRest;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.exerciseNameSnapshot.toUpperCase(),
                        style: context.text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          decoration: exercise.skipped
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      Text(
                        [
                          exercise.muscleGroupSnapshot.label,
                          'descanso ${formatRest(Duration(seconds: rest))}',
                          if (exercise.skipped) 'pulado',
                          if (detail.isDone) 'concluído ✓',
                        ].join(' · '),
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (isRecord)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Chip(
                      label: const Text('🏆 Novo recorde'),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: context.colors.tertiaryContainer,
                      side: BorderSide.none,
                      labelStyle: context.text.labelSmall?.copyWith(
                        color: context.colors.onTertiaryContainer,
                      ),
                    ),
                  ),
                PopupMenuButton<String>(
                  tooltip: 'Opções de ${exercise.exerciseNameSnapshot}',
                  onSelected: (action) => action == 'rest'
                      ? _changeRest(context, ref, exercise, defaultRest)
                      : _guard(
                          context,
                          () => switch (action) {
                            'skip' => repo.setSkipped(
                              exercise.id,
                              skipped: !exercise.skipped,
                            ),
                            _ => repo.applyValuesToPendingSets(
                              exercise.id,
                              last.values.toList(),
                            ),
                          },
                        ),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'rest',
                      child: Text('Alterar descanso'),
                    ),
                    PopupMenuItem(
                      value: 'skip',
                      child: Text(
                        exercise.skipped
                            ? 'Retomar exercício'
                            : 'Pular exercício',
                      ),
                    ),
                    if (last.isNotEmpty && !exercise.skipped)
                      const PopupMenuItem(
                        value: 'last',
                        child: Text('Usar cargas do último treino'),
                      ),
                  ],
                ),
              ],
            ),
            if (exercise.notes != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(exercise.notes!, style: context.text.bodySmall),
              ),
            if (!exercise.skipped) ...[
              if (last.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8, right: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerHighest.withValues(
                      alpha: .5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.history,
                        size: 18,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Último treino: ${last.map((s) => '${formatDecimal(s.weightKg)} × ${s.repetitions}').join(' · ')}',
                          style: context.text.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              const _SetHeader(),
              for (final (index, set) in detail.sets.indexed)
                KeyedSubtree(
                  key: rowKeyFor(set.id),
                  child: SetRow(
                    key: ValueKey(set.id),
                    set: set,
                    index: index,
                    weightIncrement: weightIncrement,
                    isNext: set.id == nextSetId,
                    isRecord:
                        set.completed &&
                        previousBest != null &&
                        set.weightKg > previousBest,
                    onWeightChanged: (w) => _guard(
                      context,
                      () => repo.updateSet(set.id, weightKg: w),
                    ),
                    onRepsChanged: (r) => _guard(
                      context,
                      () => repo.updateSet(set.id, repetitions: r),
                    ),
                    onRemove: set.completed
                        ? null
                        : () async {
                            try {
                              final removed = await repo.removePendingSet(
                                set.id,
                              );
                              if (!removed && context.mounted) {
                                context.showMessage(
                                  'A série não pôde ser removida '
                                  '(já foi concluída?).',
                                );
                              }
                              return removed;
                            } on Object catch (e) {
                              if (context.mounted) {
                                context.showMessage(
                                  'Não foi possível remover a série: $e',
                                );
                              }
                              return false;
                            }
                          },
                    onToggle: (reps, weight) async {
                      if (set.completed) {
                        _guard(context, () => repo.uncompleteSet(set.id));
                        return;
                      }
                      if (reps <= 0) {
                        context.showMessage('Informe ao menos uma repetição');
                        return;
                      }
                      try {
                        await repo.completeSet(
                          set.id,
                          repetitions: reps,
                          weightKg: weight,
                        );
                        onSetCompleted(detail, set);
                      } on Object catch (e) {
                        if (context.mounted) {
                          context.showMessage(
                            'Não foi possível salvar a série: $e',
                          );
                        }
                      }
                    },
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: Key('session_add_set_${exercise.id}'),
                  onPressed: () =>
                      _guard(context, () => repo.addSet(exercise.id)),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar série'),
                ),
              ),
            ],
            if (exercise.skipped && detail.hasCompletedSets)
              Text(
                formatSetsInline(detail.completedSets.values),
                style: context.text.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}

/// Altera o descanso de um exercício do treino e, se pedido, na ficha.
Future<void> _changeRest(
  BuildContext context,
  WidgetRef ref,
  WorkoutSessionExercise exercise,
  int defaultRest,
) async {
  final planExerciseId = exercise.planExerciseId;
  final choice = await showRestPicker(
    context,
    exerciseName: exercise.exerciseNameSnapshot,
    current: exercise.restSeconds,
    defaultSeconds: defaultRest,
    offerApplyToPlan: planExerciseId != null,
  );
  if (choice == null || !context.mounted) return;
  try {
    await ref
        .read(workoutSessionRepositoryProvider)
        .updateRest(exercise.id, choice.seconds);
    if (choice.applyToPlan && planExerciseId != null) {
      final saved = await ref
          .read(workoutPlanRepositoryProvider)
          .updateExerciseRest(planExerciseId, choice.seconds);
      if (!saved && context.mounted) {
        context.showMessage(
          'Descanso alterado neste treino. A ficha não existe mais.',
        );
      }
    }
  } on Object catch (e) {
    if (context.mounted) {
      context.showMessage('Não foi possível alterar o descanso: $e');
    }
  }
}

/// Executa uma gravação disparada pela UI sem deixar erros sem tratamento
/// (ex.: treino encerrado em outra tela, valor rejeitado pelo repositório).
void _guard(BuildContext context, Future<Object?> Function() action) {
  unawaited(
    Future.sync(action).then<void>(
      (_) {},
      onError: (Object error) {
        if (context.mounted) {
          context.showMessage('Não foi possível salvar: $error');
        }
      },
    ),
  );
}

class _SetHeader extends StatelessWidget {
  const _SetHeader();

  @override
  Widget build(BuildContext context) {
    final style = context.text.labelSmall?.copyWith(
      color: context.colors.onSurfaceVariant,
    );
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Text('SÉRIE', style: style, textAlign: TextAlign.center),
            ),
            Expanded(
              child: Text(
                'PESO (kg)',
                style: style,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 60,
              child: Text('REPS', style: style, textAlign: TextAlign.center),
            ),
            const SizedBox(width: 56),
          ],
        ),
      ),
    );
  }
}
