import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/stat_tile.dart';
import '../data/workout_session_repository.dart';
import '../domain/session_models.dart';
import 'set_text.dart';

/// Tudo o que foi realizado em um treino.
class SessionDetailScreen extends ConsumerWidget {
  const SessionDetailScreen({required this.sessionId, super.key});

  final int sessionId;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Excluir treino?',
      message:
          'Este treino será removido do histórico e das estatísticas. '
          'Esta ação não pode ser desfeita.',
    );
    if (!confirmed) return;
    await ref.read(workoutSessionRepositoryProvider).deleteSession(sessionId);
    if (context.mounted) {
      context
        ..showMessage('Treino excluído')
        ..pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treino'),
        actions: [
          IconButton(
            tooltip: 'Excluir treino',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      body: AsyncValueWidget(
        value: ref.watch(sessionDetailProvider(sessionId)),
        data: (detail) {
          if (detail == null) {
            return const EmptyState(
              icon: Icons.error_outline,
              message: 'Treino não encontrado.',
            );
          }
          return _SessionDetailBody(detail: detail);
        },
      ),
    );
  }
}

class _SessionDetailBody extends StatelessWidget {
  const _SessionDetailBody({required this.detail});

  final SessionDetail detail;

  @override
  Widget build(BuildContext context) {
    final session = detail.session;
    final performed = detail.exercises.where((e) => e.hasCompletedSets);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 160),
      children: [
        Text(
          formatDateTime(session.startedAt),
          style: context.text.labelLarge?.copyWith(
            color: context.colors.primary,
          ),
        ),
        Text(
          session.planNameSnapshot,
          style: context.text.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        StatGrid(
          children: [
            StatTile(
              label: 'Duração',
              value: formatDuration(detail.duration(DateTime.now())),
            ),
            StatTile(label: 'Volume', value: formatVolume(detail.volume)),
            StatTile(
              label: 'Exercícios',
              value: '${detail.performedExerciseCount}',
            ),
            StatTile(label: 'Séries', value: '${detail.completedSetCount}'),
          ],
        ),
        if (session.notes != null) ...[
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notes),
              title: Text(session.notes!),
            ),
          ),
        ],
        const SizedBox(height: 16),
        for (final exercise in performed) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => context.push(
                      Routes.exercise(exercise.exercise.exerciseId),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            exercise.exercise.exerciseNameSnapshot,
                            style: context.text.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          formatVolume(exercise.volume),
                          style: context.text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final (index, set) in exercise.completedSets.indexed)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        'Série ${index + 1}: '
                        '${formatSet(set.repetitions, set.weightKg)}',
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (performed.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Nenhuma série foi registrada neste treino.'),
          ),
      ],
    );
  }
}
