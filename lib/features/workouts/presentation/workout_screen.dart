import 'dart:async';

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
import '../../../core/widgets/empty_state.dart';
import '../../settings/presentation/settings_controller.dart';
import '../../timer/presentation/timer_controller.dart';
import '../../workout_plans/data/workout_plan_repository.dart';
import '../data/workout_session_repository.dart';
import '../domain/session_models.dart';
import '../domain/session_status.dart';
import 'widgets/session_exercise_card.dart';

/// Execução do treino. Cada alteração é salva imediatamente no banco.
class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({required this.sessionId, super.key});

  final int sessionId;

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  final _rowKeys = <int, GlobalKey>{};

  GlobalKey _rowKey(int setId) => _rowKeys.putIfAbsent(setId, GlobalKey.new);

  WorkoutSessionRepository get _repo =>
      ref.read(workoutSessionRepositoryProvider);

  void _onSetCompleted(
    SessionDetail session,
    SessionExerciseDetail exercise,
    WorkoutSessionSet set,
  ) {
    final settings = ref.read(settingsProvider);
    if (settings.autoStartTimer) {
      final rest = exercise.exercise.restSeconds ?? settings.defaultRestSeconds;
      if (rest > 0) {
        ref
            .read(timerControllerProvider.notifier)
            .start(Duration(seconds: rest));
      }
    }
    // Move o foco visual para a próxima série pendente.
    final next = _nextPendingAfter(session, set.id);
    if (next == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _rowKeys[next.id]?.currentContext;
      if (context != null && context.mounted) {
        unawaited(
          Scrollable.ensureVisible(
            context,
            alignment: .35,
            duration: const Duration(milliseconds: 300),
          ),
        );
      }
    });
  }

  WorkoutSessionSet? _nextPendingAfter(SessionDetail session, int setId) {
    for (final e in session.exercises) {
      if (e.exercise.skipped) continue;
      for (final s in e.sets) {
        if (!s.completed && s.id != setId) return s;
      }
    }
    return null;
  }

  Future<void> _addExercise() async {
    final exercise = await context.push<Exercise>(Routes.pickExercise);
    if (exercise == null) return;
    await _repo.addExercise(widget.sessionId, exercise.id);
  }

  /// O descanso entre séries perde o sentido quando o treino termina.
  void _stopRestTimer() => ref.read(timerControllerProvider.notifier).reset();

  Future<void> _cancel() async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Cancelar treino?',
      message:
          'O treino será descartado e não aparecerá no histórico. '
          'Esta ação não pode ser desfeita.',
      confirmLabel: 'Cancelar treino',
      cancelLabel: 'Voltar',
    );
    if (!confirmed) return;
    await _repo.cancelSession(widget.sessionId);
    _stopRestTimer();
    if (mounted) context.pop();
  }

  Future<void> _finish(SessionDetail session) async {
    final planId = session.session.workoutPlanId;
    // Só oferece atualizar a ficha se ela ainda existir e estiver ativa.
    final plan = planId == null
        ? null
        : await ref.read(workoutPlanRepositoryProvider).watchPlan(planId).first;
    if (!mounted) return;
    final result = await showDialog<_FinishChoice>(
      context: context,
      builder: (_) =>
          _FinishDialog(session: session, canUpdatePlan: plan != null),
    );
    if (result == null) return;
    await _repo.finishSession(widget.sessionId);
    _stopRestTimer();
    if (result.updatePlan) {
      // O treino já está salvo: uma falha aqui não pode impedir o resumo.
      var updated = false;
      try {
        updated = await ref
            .read(workoutPlanRepositoryProvider)
            .updatePlanFromSession(widget.sessionId);
      } on Object {
        updated = false;
      }
      if (!updated && mounted) {
        context.showMessage(
          'Treino salvo, mas a ficha não pôde ser atualizada (foi excluída?).',
        );
      }
    }
    if (mounted) {
      context.pushReplacement(Routes.workoutSummary(widget.sessionId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(sessionDetailProvider(widget.sessionId));
    final increment = ref.watch(
      settingsProvider.select((s) => s.weightIncrementKg),
    );
    final session = detail.value;
    final running = session?.session.status == SessionStatus.running;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(session?.session.planNameSnapshot ?? 'Treino'),
            if (session != null && running)
              _ElapsedText(startedAt: session.session.startedAt),
          ],
        ),
        actions: [
          if (running) ...[
            IconButton(
              tooltip: 'Adicionar exercício',
              icon: const Icon(Icons.playlist_add),
              onPressed: _addExercise,
            ),
            PopupMenuButton<String>(
              tooltip: 'Mais opções',
              onSelected: (action) {
                if (action == 'cancel') _cancel();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'cancel', child: Text('Cancelar treino')),
              ],
            ),
          ],
        ],
      ),
      body: AsyncValueWidget(
        value: detail,
        data: (session) {
          if (session == null) {
            return const EmptyState(
              icon: Icons.error_outline,
              message: 'Treino não encontrado.',
            );
          }
          if (session.session.status != SessionStatus.running) {
            return EmptyState(
              icon: Icons.check_circle_outline,
              message: 'Este treino já foi encerrado.',
              actionLabel: 'Ver resumo',
              onAction: () => context.pushReplacement(
                Routes.workoutSummary(widget.sessionId),
              ),
            );
          }
          final nextSetId = session.nextPendingSet?.id;
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 120),
            children: [
              _ProgressHeader(session: session),
              const SizedBox(height: 8),
              for (final exercise in session.exercises) ...[
                SessionExerciseCard(
                  key: ValueKey(exercise.exercise.id),
                  detail: exercise,
                  sessionId: widget.sessionId,
                  nextSetId: nextSetId,
                  weightIncrement: increment,
                  rowKeyFor: _rowKey,
                  onSetCompleted: (e, s) => _onSetCompleted(session, e, s),
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton.icon(
                onPressed: _addExercise,
                icon: const Icon(Icons.add),
                label: const Text('ADICIONAR EXERCÍCIO'),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: running
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  height: AppTheme.largeButtonHeight,
                  child: FilledButton.icon(
                    key: const Key('finish_workout'),
                    onPressed: () => _finish(session!),
                    icon: const Icon(Icons.flag),
                    label: const Text('FINALIZAR TREINO'),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.session});

  final SessionDetail session;

  @override
  Widget build(BuildContext context) {
    final total = session.exercises.fold(
      0,
      (sum, e) =>
          sum + (e.exercise.skipped ? e.completedSets.length : e.sets.length),
    );
    final done = session.completedSetCount;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$done de $total séries · ${formatVolume(session.volume)}',
            style: context.text.bodyMedium,
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              minHeight: 6,
              color: context.colors.tertiary,
              backgroundColor: context.colors.surfaceContainerHighest,
              semanticsLabel: 'Progresso do treino: $done de $total séries',
            ),
          ),
        ],
      ),
    );
  }
}

/// Tempo decorrido do treino, atualizado a cada segundo.
class _ElapsedText extends StatefulWidget {
  const _ElapsedText({required this.startedAt});

  final DateTime startedAt;

  @override
  State<_ElapsedText> createState() => _ElapsedTextState();
}

class _ElapsedTextState extends State<_ElapsedText> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      formatClock(DateTime.now().difference(widget.startedAt)),
      style: context.text.bodySmall,
    );
  }
}

class _FinishChoice {
  const _FinishChoice({required this.updatePlan});

  final bool updatePlan;
}

class _FinishDialog extends StatefulWidget {
  const _FinishDialog({required this.session, required this.canUpdatePlan});

  final SessionDetail session;
  final bool canUpdatePlan;

  @override
  State<_FinishDialog> createState() => _FinishDialogState();
}

class _FinishDialogState extends State<_FinishDialog> {
  var _updatePlan = false;

  @override
  Widget build(BuildContext context) {
    final done = widget.session.completedSetCount;
    final pending = widget.session.exercises
        .where((e) => !e.exercise.skipped)
        .fold(0, (sum, e) => sum + e.sets.where((s) => !s.completed).length);
    return AlertDialog(
      title: const Text('Finalizar treino?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$done séries concluídas.'),
          if (pending > 0)
            Text(
              '$pending séries não marcadas não serão registradas.',
              style: TextStyle(color: context.colors.error),
            ),
          if (widget.canUpdatePlan) ...[
            const SizedBox(height: 12),
            CheckboxListTile(
              key: const Key('update_plan_checkbox'),
              contentPadding: EdgeInsets.zero,
              value: _updatePlan,
              onChanged: (v) => setState(() => _updatePlan = v ?? false),
              title: const Text('Atualizar a ficha'),
              subtitle: const Text(
                'As séries concluídas hoje (cargas e repetições) e o descanso '
                'passam a ser o planejamento. Séries não concluídas saem da '
                'ficha; exercícios sem séries concluídas não mudam.',
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Voltar'),
        ),
        FilledButton(
          key: const Key('confirm_finish'),
          onPressed: () =>
              Navigator.pop(context, _FinishChoice(updatePlan: _updatePlan)),
          child: const Text('Finalizar'),
        ),
      ],
    );
  }
}
