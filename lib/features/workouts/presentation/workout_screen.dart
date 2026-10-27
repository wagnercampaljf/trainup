import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../settings/presentation/settings_controller.dart';
import '../../timer/presentation/timer_bottom_sheet.dart';
import '../../timer/presentation/timer_button.dart';
import '../../timer/presentation/timer_controller.dart';
import '../../workout_plans/data/workout_plan_repository.dart';
import '../data/workout_session_repository.dart';
import '../domain/session_models.dart';
import '../domain/session_status.dart';
import 'widgets/session_exercise_card.dart';

/// Execução do treino. Cada alteração é salva imediatamente no banco.
///
/// O temporizador de descanso fica encaixado na barra inferior (o botão
/// flutuante global some enquanto esta tela está visível). "Finalizar" fica
/// no topo durante o treino e ganha destaque quando não há séries pendentes.
class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({required this.sessionId, super.key});

  final int sessionId;

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> with RouteAware {
  final _rowKeys = <int, GlobalKey>{};

  /// Outra tela (ex.: escolher exercício) está por cima desta.
  var _covered = false;
  bool? _dockedApplied;
  late final TimerDocked _docked;
  PageRoute<dynamic>? _route;

  @override
  void initState() {
    super.initState();
    _docked = ref.read(timerDockedProvider.notifier);
  }

  GlobalKey _rowKey(int setId) => _rowKeys.putIfAbsent(setId, GlobalKey.new);

  WorkoutSessionRepository get _repo =>
      ref.read(workoutSessionRepositoryProvider);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute && route != _route) {
      if (_route != null) appRouteObserver.unsubscribe(this);
      _route = route;
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didPushNext() => setState(() => _covered = true);

  @override
  void didPopNext() => setState(() => _covered = false);

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    // Fora da fase de build: o provider não pode mudar durante a montagem.
    final docked = _docked;
    if (_dockedApplied ?? false) {
      Future.microtask(() => docked.set(docked: false));
    }
    super.dispose();
  }

  /// O timer fica encaixado enquanto o treino está em andamento e visível.
  void _syncDocked({required bool running}) {
    final docked = running && !_covered;
    if (_dockedApplied == docked) return;
    _dockedApplied = docked;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _docked.set(docked: docked);
    });
  }

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
            duration: AppMotion.of(context, const Duration(milliseconds: 300)),
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
    _syncDocked(running: running);
    final compactBar =
        MediaQuery.sizeOf(context).width < 360 ||
        MediaQuery.textScalerOf(context).scale(1) > 1.15;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session?.session.planNameSnapshot ?? 'Treino',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (session != null && running)
              _ElapsedText(startedAt: session.session.startedAt),
          ],
        ),
        actions: [
          if (running) ...[
            // Em telas estreitas/fonte grande, o atalho vai para o menu para
            // o nome da ficha não ser espremido.
            if (!compactBar)
              IconButton(
                tooltip: 'Adicionar exercício',
                icon: const Icon(Icons.playlist_add),
                onPressed: _addExercise,
              ),
            TextButton(
              key: const Key('finish_workout'),
              onPressed: () => _finish(session!),
              child: const Text('Finalizar'),
            ),
            PopupMenuButton<String>(
              tooltip: 'Mais opções',
              onSelected: (action) {
                if (action == 'cancel') _cancel();
                if (action == 'add') _addExercise();
              },
              itemBuilder: (context) => [
                if (compactBar)
                  const PopupMenuItem(
                    value: 'add',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.playlist_add),
                      title: Text('Adicionar exercício'),
                    ),
                  ),
                PopupMenuItem(
                  value: 'cancel',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.delete_outline,
                      color: context.colors.error,
                    ),
                    title: Text(
                      'Cancelar treino',
                      style: TextStyle(color: context.colors.error),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: AsyncValueWidget(
        value: detail,
        onRetry: () => ref.invalidate(sessionDetailProvider(widget.sessionId)),
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
              actionIcon: Icons.receipt_long_outlined,
              onAction: () => context.pushReplacement(
                Routes.workoutSummary(widget.sessionId),
              ),
            );
          }
          final nextSetId = session.nextPendingSet?.id;
          final count = session.exercises.length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.sm + 2,
              AppSpace.sm,
              AppSpace.sm + 2,
              AppSpace.xl,
            ),
            children: [
              _ProgressHeader(session: session),
              const SizedBox(height: AppSpace.md),
              for (final (index, exercise) in session.exercises.indexed) ...[
                SessionExerciseCard(
                  key: ValueKey(exercise.exercise.id),
                  detail: exercise,
                  sessionId: widget.sessionId,
                  nextSetId: nextSetId,
                  weightIncrement: increment,
                  position: 'Exercício ${index + 1} de $count',
                  rowKeyFor: _rowKey,
                  onSetCompleted: (e, s) => _onSetCompleted(session, e, s),
                ),
                const SizedBox(height: AppSpace.md),
              ],
              OutlinedButton.icon(
                onPressed: _addExercise,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar exercício'),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: running
          ? _RestDock(session: session!, onFinish: () => _finish(session))
          : null,
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.session});

  final SessionDetail session;

  @override
  Widget build(BuildContext context) {
    final total = session.plannedSetCount;
    final done = session.completedSetCount;
    final current = session.currentExercise;
    final position = current == null
        ? null
        : session.exercises.indexOf(current) + 1;
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpace.sm,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Text(
                '$done de $total séries · ${formatVolume(session.volume)}',
                style: context.text.titleMedium?.tabular,
              ),
              if (position != null)
                Text(
                  'exercício $position de ${session.exercises.length}',
                  style: context.text.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpace.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              color: colors.tertiary,
              semanticsLabel: 'Progresso do treino: $done de $total séries',
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          Row(
            children: [
              Icon(
                Icons.cloud_done_outlined,
                size: 16,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpace.xs + 2),
              Expanded(
                child: Text(
                  'Salvo automaticamente a cada série marcada.',
                  style: context.text.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Barra inferior do treino: o descanso (mesmo controle global, encaixado)
/// com atalhos, e "Finalizar treino" em destaque quando tudo foi marcado.
class _RestDock extends ConsumerWidget {
  const _RestDock({required this.session, required this.onFinish});

  final SessionDetail session;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(
      timerControllerProvider.select((s) => s.snapshot),
    );
    final controller = ref.read(timerControllerProvider.notifier);
    final colors = context.colors;
    final allDone = session.pendingSetCount == 0;
    final current = session.currentExercise;
    final next = session.nextPendingSet;
    final active = snapshot.isRunning || snapshot.isPaused;

    return Material(
      color: AppTheme.cardColor(colors),
      child: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colors.outlineVariant)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.md,
              AppSpace.sm,
              AppSpace.md,
              AppSpace.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (allDone) ...[
                  SizedBox(
                    height: AppTheme.largeButtonHeight,
                    child: FilledButton.icon(
                      key: const Key('finish_workout_done'),
                      onPressed: onFinish,
                      icon: const Icon(Icons.flag),
                      label: const Text('Finalizar treino'),
                    ),
                  ),
                  const SizedBox(height: AppSpace.sm),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: TimerButton(
                        docked: true,
                        onPressed: () => showTimerBottomSheet(context),
                      ),
                    ),
                    if (active) ...[
                      const SizedBox(width: AppSpace.sm),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton.outlined(
                            key: const Key('dock_timer_toggle'),
                            tooltip: snapshot.isRunning
                                ? 'Pausar descanso'
                                : 'Continuar descanso',
                            onPressed: controller.toggle,
                            icon: Icon(
                              snapshot.isRunning
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                          ),
                          const SizedBox(width: AppSpace.xs),
                          Tooltip(
                            message: 'Adicionar 15 segundos',
                            child: OutlinedButton(
                              key: const Key('dock_timer_plus'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(56, 48),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpace.md,
                                ),
                              ),
                              onPressed: () => controller.adjust(
                                const Duration(seconds: 15),
                              ),
                              child: const Text('+15s'),
                            ),
                          ),
                        ],
                      ),
                    ] else if (current != null &&
                        next != null &&
                        !snapshot.isFinished) ...[
                      const SizedBox(width: AppSpace.md),
                      Expanded(
                        child: Text(
                          'A seguir: ${current.exercise.exerciseNameSnapshot}'
                          ' · série ${current.sets.indexOf(next) + 1}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: context.text.bodySmall,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
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
    final elapsed = formatClock(DateTime.now().difference(widget.startedAt));
    return Text(
      elapsed,
      semanticsLabel: 'Tempo de treino $elapsed',
      style: context.text.bodySmall?.tabular,
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
    final pending = widget.session.pendingSetCount;
    final colors = context.colors;
    return AlertDialog(
      title: const Text('Finalizar treino?'),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Line(
            icon: Icons.check_circle,
            color: colors.tertiary,
            text:
                '${done == 1 ? '1 série concluída' : '$done séries concluídas'}'
                ', já salvas.',
          ),
          if (pending > 0)
            _Line(
              icon: Icons.warning_amber_rounded,
              color: colors.error,
              text: pending == 1
                  ? '1 série não marcada não será registrada.'
                  : '$pending séries não marcadas não serão registradas.',
            ),
          if (widget.canUpdatePlan) ...[
            const SizedBox(height: AppSpace.md),
            CheckboxListTile(
              key: const Key('update_plan_checkbox'),
              contentPadding: EdgeInsets.zero,
              value: _updatePlan,
              onChanged: (v) => setState(() => _updatePlan = v ?? false),
              title: const Text('Atualizar também a ficha'),
              subtitle: const Text(
                'Muda o planejamento dos próximos treinos: as cargas, '
                'repetições e o descanso de hoje passam a ser os da ficha. '
                'Séries não concluídas saem da ficha; exercícios sem séries '
                'concluídas não mudam. O histórico não é alterado.',
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

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: AppSpace.sm),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
