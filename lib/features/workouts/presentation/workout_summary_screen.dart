import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/stat_tile.dart';
import '../data/workout_session_repository.dart';
import '../domain/session_models.dart';
import 'share/share_workout_sheet.dart';

/// Dados do resumo pós-treino.
typedef WorkoutSummaryData = ({
  SessionDetail detail,
  SessionComparison comparison,
  SessionRecords records,
});

final workoutSummaryProvider = FutureProvider.family<WorkoutSummaryData?, int>((
  ref,
  sessionId,
) async {
  final repo = ref.watch(workoutSessionRepositoryProvider);
  final detail = await repo.getSession(sessionId);
  if (detail == null) return null;
  return (
    detail: detail,
    comparison: await repo.compareWithPrevious(sessionId),
    records: await repo.recordsFor(sessionId),
  );
});

class WorkoutSummaryScreen extends ConsumerStatefulWidget {
  const WorkoutSummaryScreen({required this.sessionId, super.key});

  final int sessionId;

  @override
  ConsumerState<WorkoutSummaryScreen> createState() =>
      _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends ConsumerState<WorkoutSummaryScreen> {
  final _notes = TextEditingController();
  var _notesLoaded = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  var _saving = false;

  Future<void> _done() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(workoutSessionRepositoryProvider)
          .updateNotes(widget.sessionId, _notes.text);
      if (mounted) context.go(Routes.historyDetail(widget.sessionId));
    } on Object catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        context.showMessage('Não foi possível salvar a observação: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(workoutSummaryProvider(widget.sessionId));
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Resumo'),
      ),
      body: summary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (data) {
          if (data == null) {
            return const Center(child: Text('Treino não encontrado.'));
          }
          if (!_notesLoaded) {
            _notesLoaded = true;
            _notes.text = data.detail.session.notes ?? '';
          }
          return _SummaryBody(data: data, notes: _notes);
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('summary_share'),
                  onPressed: switch (summary.value) {
                    final data? => () => showShareWorkoutSheet(
                      context,
                      detail: data.detail,
                      records: data.records,
                    ),
                    null => null,
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('COMPARTILHAR'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  key: const Key('summary_done'),
                  onPressed: _saving ? null : _done,
                  child: const Text('CONCLUIR'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryBody extends StatelessWidget {
  const _SummaryBody({required this.data, required this.notes});

  final WorkoutSummaryData data;
  final TextEditingController notes;

  @override
  Widget build(BuildContext context) {
    final detail = data.detail;
    final comparison = data.comparison;
    final records = data.records;
    final previousVolume = comparison.previousVolume;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        Icon(
          Icons.emoji_events_outlined,
          size: 56,
          color: context.colors.tertiary,
        ),
        const SizedBox(height: 8),
        Text(
          'TREINO CONCLUÍDO',
          textAlign: TextAlign.center,
          style: context.text.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          detail.session.planNameSnapshot,
          textAlign: TextAlign.center,
          style: context.text.titleMedium,
        ),
        const SizedBox(height: 20),
        StatGrid(
          children: [
            StatTile(
              icon: Icons.schedule,
              label: 'Duração',
              value: formatDuration(detail.duration(DateTime.now())),
            ),
            StatTile(
              icon: Icons.fitness_center,
              label: 'Exercícios',
              value: '${detail.performedExerciseCount}',
            ),
            StatTile(
              icon: Icons.repeat,
              label: 'Séries',
              value: '${detail.completedSetCount}',
            ),
            StatTile(
              icon: Icons.stacked_bar_chart,
              label: 'Volume',
              value: formatVolume(detail.volume),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comparação com o último treino',
                  style: context.text.titleSmall,
                ),
                const SizedBox(height: 8),
                if (previousVolume == null)
                  const Text('Primeiro registro desta ficha.')
                else
                  Text(
                    '${formatSigned(detail.volume - previousVolume, maxDecimals: 0)} '
                    'kg de volume',
                    style: context.text.bodyLarge,
                  ),
                Text(
                  '${comparison.exercisesWithLoadIncrease} '
                  '${comparison.exercisesWithLoadIncrease == 1 ? 'exercício' : 'exercícios'} '
                  'com aumento de carga',
                  style: context.text.bodyLarge,
                ),
              ],
            ),
          ),
        ),
        if (!records.isEmpty) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🏆 Novo recorde', style: context.text.titleSmall),
                  const SizedBox(height: 6),
                  if (records.totalVolume)
                    const Text('Maior volume total em um treino'),
                  for (final name in records.maxWeightExercises)
                    Text('$name: maior carga'),
                  for (final name in records.volumeExercises)
                    Text('$name: maior volume'),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          key: const Key('summary_notes'),
          controller: notes,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Observação (opcional)',
            hintText: 'Ex.: Treino muito bom.',
          ),
        ),
      ],
    );
  }
}
