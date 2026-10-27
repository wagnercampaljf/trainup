import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_tile.dart';
import '../../exercises/data/exercise_repository.dart';
import '../data/progress_repository.dart';
import '../domain/exercise_progress.dart';
import 'widgets/progress_chart.dart';
import 'widgets/progress_summary.dart';

/// Indicadores, gráfico de carga e histórico de execução de um exercício.
class ExerciseDetailScreen extends ConsumerStatefulWidget {
  const ExerciseDetailScreen({required this.exerciseId, super.key});

  final int exerciseId;

  @override
  ConsumerState<ExerciseDetailScreen> createState() =>
      _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen> {
  var _metric = ExerciseMetric.maxWeight;

  Future<void> _delete(Exercise exercise) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Excluir exercício?',
      message:
          '${exercise.name} sairá do catálogo. Se já foi usado, o histórico '
          'é preservado.',
    );
    if (!confirmed) return;
    await ref.read(exerciseRepositoryProvider).delete(exercise.id);
    if (mounted) {
      context
        ..showMessage('Exercício excluído')
        ..pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = ref.watch(exerciseProvider(widget.exerciseId)).value;
    final history = ref.watch(exerciseHistoryProvider(widget.exerciseId));
    return Scaffold(
      appBar: AppBar(
        title: Text(exercise?.name ?? 'Exercício'),
        actions: [
          if (exercise != null && exercise.isActive) ...[
            IconButton(
              tooltip: 'Editar exercício',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push(Routes.editExercise(exercise.id)),
            ),
            IconButton(
              tooltip: 'Excluir exercício',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(exercise),
            ),
          ],
        ],
      ),
      body: AsyncValueWidget(
        value: history,
        onRetry: () =>
            ref.invalidate(exerciseHistoryProvider(widget.exerciseId)),
        data: (entries) {
          final stats = ExerciseStats.from(entries);
          final series = _metric.series(entries);
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.page,
              AppSpace.sm,
              AppSpace.page,
              AppSpace.listBottom,
            ),
            children: [
              if (exercise != null)
                Text(
                  [
                    exercise.muscleGroup.label,
                    if (!exercise.isActive) 'inativo',
                  ].join(' · '),
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              if (exercise?.description != null)
                Text(exercise!.description!, style: context.text.bodyMedium),
              if (entries.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpace.xxl),
                  child: Text(
                    'Este exercício ainda não foi executado em nenhum treino. '
                    'A evolução aparece depois do primeiro treino com ele.',
                    textAlign: TextAlign.center,
                  ),
                )
              else ...[
                const SizedBox(height: AppSpace.md),
                Wrap(
                  spacing: AppSpace.sm,
                  runSpacing: AppSpace.sm,
                  children: [
                    for (final metric in ExerciseMetric.values)
                      ChoiceChip(
                        label: Text(metric.label),
                        selected: _metric == metric,
                        onSelected: (_) => setState(() => _metric = metric),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpace.md),
                // Destaque, gráfico e período usam a mesma métrica.
                ProgressHighlight(
                  points: series,
                  unit: _metric.unit,
                  countLabel: const ('treino', 'treinos'),
                ),
                const SizedBox(height: AppSpace.md),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.sm,
                      AppSpace.lg,
                      AppSpace.lg,
                      AppSpace.sm,
                    ),
                    child: ProgressChart(points: series, unit: _metric.unit),
                  ),
                ),
                const SectionHeader('Recordes'),
                StatGrid(
                  children: [
                    StatTile(
                      icon: Icons.emoji_events_outlined,
                      label: 'Maior carga',
                      value: formatWeight(stats.maxWeight!),
                    ),
                    StatTile(
                      icon: Icons.stacked_bar_chart,
                      label: 'Maior volume',
                      value: formatVolume(stats.maxVolume!),
                    ),
                  ],
                ),
                SectionHeader(
                  'Histórico',
                  subtitle:
                      '${stats.sessionCount} '
                      '${stats.sessionCount == 1 ? 'treino' : 'treinos'}, '
                      'do mais recente ao mais antigo',
                ),
                Card(
                  child: Column(
                    children: [
                      for (final (index, entry) in entries.indexed) ...[
                        if (index > 0) const Divider(indent: AppSpace.lg),
                        _HistoryEntry(entry: entry),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _HistoryEntry extends StatelessWidget {
  const _HistoryEntry({required this.entry});

  final ExerciseSessionEntry entry;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(Routes.historyDetail(entry.sessionId)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.md + 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 64,
              child: Text(
                formatShortDate(entry.date),
                style: context.text.titleMedium?.tabular,
              ),
            ),
            Expanded(
              child: Wrap(
                spacing: AppSpace.md,
                runSpacing: 2,
                children: [
                  for (final set in entry.sets)
                    Text(
                      '${formatDecimal(set.weightKg)} kg × ${set.repetitions}',
                      style: context.text.bodyMedium?.tabular,
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.sm),
            Text(formatVolume(entry.volume), style: context.text.bodySmall),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: context.colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
