import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_tile.dart';
import '../../exercises/data/exercise_repository.dart';
import '../data/progress_repository.dart';
import '../domain/exercise_progress.dart';
import '../domain/progress_calculations.dart';
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
        data: (entries) {
          final stats = ExerciseStats.from(entries);
          final series = _metric.series(entries);
          final summary = ProgressSummary.fromValues([
            for (final p in series) p.value,
          ]);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 160),
            children: [
              if (exercise != null)
                Text(
                  [
                    exercise.muscleGroup.label,
                    if (!exercise.isActive) 'inativo',
                  ].join(' · '),
                  style: context.text.bodyMedium,
                ),
              if (exercise?.description != null)
                Text(exercise!.description!, style: context.text.bodyMedium),
              const SizedBox(height: 12),
              StatGrid(
                children: [
                  StatTile(
                    label: 'Maior carga',
                    value: stats.maxWeight == null
                        ? '—'
                        : formatWeight(stats.maxWeight!),
                  ),
                  StatTile(
                    label: 'Última carga',
                    value: stats.lastWeight == null
                        ? '—'
                        : formatWeight(stats.lastWeight!),
                  ),
                  StatTile(label: 'Treinos', value: '${stats.sessionCount}'),
                  StatTile(
                    label: 'Maior volume',
                    value: stats.maxVolume == null
                        ? '—'
                        : formatVolume(stats.maxVolume!),
                  ),
                ],
              ),
              if (entries.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'Este exercício ainda não foi executado em nenhum treino.',
                    textAlign: TextAlign.center,
                  ),
                )
              else ...[
                const SectionHeader('Evolução'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final metric in ExerciseMetric.values)
                      ChoiceChip(
                        label: Text(metric.label),
                        selected: _metric == metric,
                        onSelected: (_) => setState(() => _metric = metric),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ProgressChart(points: series, unit: _metric.unit),
                const SizedBox(height: 12),
                if (summary != null)
                  ProgressSummaryTiles(
                    summary: summary,
                    unit: _metric.unit,
                    showMax: true,
                  ),
                const SectionHeader('Histórico'),
                for (final entry in entries) _HistoryEntry(entry: entry),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.push(Routes.historyDetail(entry.sessionId)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 64,
                child: Text(
                  formatShortDate(entry.date),
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final set in entry.sets)
                      Text(
                        '${formatDecimal(set.weightKg)} kg × ${set.repetitions}',
                      ),
                  ],
                ),
              ),
              Text(formatVolume(entry.volume), style: context.text.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
