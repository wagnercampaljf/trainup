import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../../../core/widgets/section_header.dart';
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
        context.showError('salvar a observação', e);
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
        loading: () => const LoadingState(),
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () =>
              ref.invalidate(workoutSummaryProvider(widget.sessionId)),
        ),
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
          padding: const EdgeInsets.fromLTRB(
            AppSpace.page,
            AppSpace.sm,
            AppSpace.page,
            AppSpace.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Concluir guarda a observação e abre o treino no histórico.',
                textAlign: TextAlign.center,
                style: context.text.bodySmall,
              ),
              const SizedBox(height: AppSpace.sm),
              Row(
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
                      label: const Text('Compartilhar'),
                    ),
                  ),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: FilledButton.icon(
                      key: const Key('summary_done'),
                      onPressed: _saving ? null : _done,
                      icon: const Icon(Icons.check),
                      label: const Text('Concluir'),
                    ),
                  ),
                ],
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
    final colors = context.colors;
    final recordLines = [
      if (records.totalVolume) 'Maior volume total em um treino',
      for (final name in records.maxWeightExercises) '$name: maior carga',
      for (final name in records.volumeExercises) '$name: maior volume',
    ];
    final volumeDiff = previousVolume == null
        ? null
        : detail.volume - previousVolume;
    final increases = comparison.exercisesWithLoadIncrease;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.page,
        AppSpace.sm,
        AppSpace.page,
        AppSpace.xl,
      ),
      children: [
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors.tertiaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 40,
              color: colors.onTertiaryContainer,
            ),
          ),
        ),
        const SizedBox(height: AppSpace.md),
        Semantics(
          header: true,
          child: Text(
            'Treino concluído',
            textAlign: TextAlign.center,
            style: context.text.headlineMedium,
          ),
        ),
        Text(
          '${detail.session.planNameSnapshot} · '
          '${formatDate(detail.session.startedAt)}',
          textAlign: TextAlign.center,
          style: context.text.titleMedium,
        ),
        const SizedBox(height: AppSpace.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_done_outlined, size: 16, color: colors.tertiary),
            const SizedBox(width: AppSpace.xs),
            Flexible(
              child: Text(
                'Já salvo no histórico',
                style: context.text.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.xl),
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
        if (recordLines.isNotEmpty) ...[
          const SizedBox(height: AppSpace.md),
          Card(
            key: const Key('summary_records'),
            color: colors.tertiaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpace.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🏆 Novo recorde',
                    style: context.text.titleLarge?.copyWith(
                      color: colors.onTertiaryContainer,
                    ),
                  ),
                  const SizedBox(height: AppSpace.sm),
                  for (final line in recordLines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpace.xs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.emoji_events_outlined,
                            size: 18,
                            color: colors.onTertiaryContainer,
                          ),
                          const SizedBox(width: AppSpace.sm),
                          Expanded(
                            child: Text(
                              line,
                              style: context.text.bodyMedium?.copyWith(
                                color: colors.onTertiaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        const SectionHeader('Comparado ao último treino desta ficha'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.lg),
            child: volumeDiff == null
                ? Text(
                    'Primeiro registro desta ficha. A comparação aparece no '
                    'próximo treino.',
                    style: context.text.bodyMedium,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${formatSigned(volumeDiff, maxDecimals: 0)} '
                        'kg de volume',
                        style: context.text.titleLarge?.copyWith(
                          color: volumeDiff > 0 ? colors.tertiary : null,
                        ),
                      ),
                      Text(
                        '$increases '
                        '${increases == 1 ? 'exercício' : 'exercícios'} '
                        'com aumento de carga',
                        style: context.text.bodyLarge,
                      ),
                    ],
                  ),
          ),
        ),
        const SectionHeader('Observação'),
        TextField(
          key: const Key('summary_notes'),
          controller: notes,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Como foi o treino? (opcional)',
            hintText: 'Ex.: Treino muito bom.',
          ),
        ),
      ],
    );
  }
}
