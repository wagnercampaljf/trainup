import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../settings/presentation/settings_controller.dart';
import '../../../timer/presentation/rest_picker.dart';
import '../../../workout_plans/data/workout_plan_repository.dart';
import '../../data/workout_session_repository.dart';
import '../../domain/session_models.dart';
import '../set_text.dart';
import 'repetition_input.dart';
import 'set_row.dart';

/// Exercício durante o treino: último treino, séries e ações rápidas.
///
/// O exercício da próxima série ("Em execução") ganha borda azul; os
/// concluídos e pulados ficam mais discretos. Todos continuam editáveis, em
/// qualquer ordem.
class SessionExerciseCard extends ConsumerWidget {
  const SessionExerciseCard({
    required this.detail,
    required this.sessionId,
    required this.nextSetId,
    required this.weightIncrement,
    required this.rowKeyFor,
    required this.onSetCompleted,
    this.position,
    super.key,
  });

  final SessionExerciseDetail detail;
  final int sessionId;
  final int? nextSetId;
  final double weightIncrement;
  final GlobalKey Function(int setId) rowKeyFor;

  /// "1 de 4", exibido acima do nome.
  final String? position;

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
    final colors = context.colors;
    final current =
        nextSetId != null && detail.sets.any((s) => s.id == nextSetId);
    final done = detail.sets.where((s) => s.completed).length;

    final (
      String statusText,
      IconData statusIcon,
      Color statusBg,
      Color statusFg,
    ) = exercise.skipped
        ? (
            'Pulado',
            Icons.redo,
            colors.surfaceContainerHigh,
            colors.onSurfaceVariant,
          )
        : detail.isDone
        ? (
            'Concluído',
            Icons.check_circle,
            colors.tertiaryContainer,
            colors.onTertiaryContainer,
          )
        : current
        ? (
            'Em execução',
            Icons.play_arrow_rounded,
            colors.primaryContainer,
            colors.onPrimaryContainer,
          )
        : (
            '$done/${detail.sets.length} séries',
            Icons.radio_button_unchecked,
            colors.surfaceContainerHigh,
            colors.onSurfaceVariant,
          );

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: current
            ? BorderSide(color: colors.primary, width: 2)
            : BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.md,
          AppSpace.sm,
          AppSpace.xs,
          AppSpace.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpace.xs),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: AppSpace.sm,
                          runSpacing: AppSpace.xs,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _StatusChip(
                              text: statusText,
                              icon: statusIcon,
                              background: statusBg,
                              foreground: statusFg,
                            ),
                            if (position != null)
                              Text(
                                position!,
                                style: context.text.labelMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            if (isRecord)
                              _StatusChip(
                                text: '🏆 Novo recorde',
                                background: colors.tertiaryContainer,
                                foreground: colors.onTertiaryContainer,
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpace.xs + 2),
                        Text(
                          exercise.exerciseNameSnapshot,
                          style: context.text.titleLarge?.copyWith(
                            color: exercise.skipped
                                ? colors.onSurfaceVariant
                                : null,
                            decoration: exercise.skipped
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        Text(
                          '${exercise.muscleGroupSnapshot.label} · '
                          'descanso ${formatRest(Duration(seconds: rest))}',
                          style: context.text.bodySmall,
                        ),
                      ],
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
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.timer_outlined),
                        title: Text('Alterar descanso'),
                      ),
                    ),
                    if (last.isNotEmpty && !exercise.skipped)
                      const PopupMenuItem(
                        value: 'last',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.history),
                          title: Text('Usar cargas do último treino'),
                        ),
                      ),
                    PopupMenuItem(
                      value: 'skip',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          exercise.skipped ? Icons.undo : Icons.redo,
                        ),
                        title: Text(
                          exercise.skipped
                              ? 'Retomar exercício'
                              : 'Pular exercício',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (exercise.notes != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpace.xs),
                child: Text(exercise.notes!, style: context.text.bodySmall),
              ),
            if (!exercise.skipped) ...[
              if (last.isNotEmpty) _LastPerformance(sets: last),
              const SizedBox(height: AppSpace.sm),
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
                                context.showError('remover a série', e);
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
                          context.showError('salvar a série', e);
                        }
                      }
                    },
                  ),
                ),
              Wrap(
                spacing: AppSpace.xs,
                children: [
                  TextButton.icon(
                    key: Key('session_add_set_${exercise.id}'),
                    onPressed: () =>
                        _guard(context, () => repo.addSet(exercise.id)),
                    icon: const Icon(Icons.add),
                    label: const Text('Nova série'),
                  ),
                  TextButton.icon(
                    key: Key('session_rest_${exercise.id}'),
                    onPressed: () =>
                        _changeRest(context, ref, exercise, defaultRest),
                    icon: const Icon(Icons.timer_outlined),
                    label: Text(
                      'Descanso ${formatRest(Duration(seconds: rest))}',
                      semanticsLabel:
                          'Alterar descanso de '
                          '${exercise.exerciseNameSnapshot}',
                    ),
                  ),
                ],
              ),
            ],
            if (exercise.skipped && detail.hasCompletedSets)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.sm),
                child: Text(
                  formatSetsInline(detail.completedSets.values),
                  style: context.text.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.text,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String text;
  final IconData? icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: AppSpace.xs),
          ],
          Text(
            text,
            style: context.text.labelMedium?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

/// Referência do último treino: uma "etiqueta" por série, com unidade.
class _LastPerformance extends StatelessWidget {
  const _LastPerformance({required this.sets});

  final List<WorkoutSessionSet> sets;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = sets
        .map((s) => '${formatWeight(s.weightKg)} × ${s.repetitions}')
        .join(', ');
    return Semantics(
      label: 'Último treino: $text',
      excludeSemantics: true,
      child: Container(
        margin: const EdgeInsets.only(top: AppSpace.sm, right: AppSpace.sm),
        padding: const EdgeInsets.all(AppSpace.sm),
        decoration: BoxDecoration(
          color: colors.brightness == Brightness.light
              ? colors.surfaceContainerLow
              : colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, size: 16, color: colors.onSurfaceVariant),
                const SizedBox(width: AppSpace.xs),
                Flexible(
                  child: Text(
                    'Último treino',
                    style: context.text.labelMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.xs),
            Wrap(
              spacing: AppSpace.xs + 2,
              runSpacing: AppSpace.xs,
              children: [
                for (final s in sets)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor(colors),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: formatDecimal(s.weightKg),
                            style: context.text.titleSmall?.tabular,
                          ),
                          TextSpan(
                            text: ' kg × ',
                            style: context.text.bodySmall,
                          ),
                          TextSpan(
                            text: '${s.repetitions}',
                            style: context.text.titleSmall?.tabular,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
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
      context.showError('alterar o descanso', e);
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
          context.showError('salvar', error);
        }
      },
    ),
  );
}

/// Rótulos das colunas, alinhados com [SetRow] (só no layout de uma linha).
class _SetHeader extends StatelessWidget {
  const _SetHeader();

  @override
  Widget build(BuildContext context) {
    final style = context.text.labelSmall?.copyWith(
      color: context.colors.onSurfaceVariant,
    );
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mesma largura disponível da linha (sem a borda de 2 px).
        if (SetRow.isCompact(context, constraints.maxWidth - 4)) {
          return const SizedBox.shrink();
        }
        return ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              children: [
                SizedBox(
                  width: SetRow.labelWidth,
                  child: Text(
                    'Série',
                    style: style,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Carga (kg)',
                    style: style,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: AppSpace.xs),
                SizedBox(
                  width: RepetitionInput.widthFor(scale),
                  child: Text(
                    'Reps',
                    style: style,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: AppSpace.xs + 56),
              ],
            ),
          ),
        );
      },
    );
  }
}
