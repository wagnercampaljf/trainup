import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/routes.dart';
import '../../../timer/presentation/timer_controller.dart';
import '../../data/workout_session_repository.dart';

/// Marca se a pergunta de "treino em andamento" já foi feita nesta execução.
class _ResumePromptShown extends Notifier<bool> {
  @override
  bool build() => false;

  void markShown() => state = true;
}

final _resumePromptShownProvider = NotifierProvider<_ResumePromptShown, bool>(
  _ResumePromptShown.new,
);

/// Ao abrir o app com um treino em andamento, pergunta se deseja
/// continuar ou encerrar (os dados já registrados nunca são perdidos).
class RunningSessionGuard extends ConsumerStatefulWidget {
  const RunningSessionGuard({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<RunningSessionGuard> createState() =>
      _RunningSessionGuardState();
}

class _RunningSessionGuardState extends ConsumerState<RunningSessionGuard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  Future<void> _check() async {
    if (ref.read(_resumePromptShownProvider)) return;
    ref.read(_resumePromptShownProvider.notifier).markShown();
    final repo = ref.read(workoutSessionRepositoryProvider);
    final running = await repo.getRunningSession();
    if (running == null || !mounted) return;
    final resume = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Treino em andamento'),
        content: Text(
          'Você possui um treino em andamento '
          '(${running.planNameSnapshot}).',
        ),
        actions: [
          TextButton(
            key: const Key('end_running_workout'),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Encerrar treino'),
          ),
          FilledButton(
            key: const Key('resume_running_workout'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continuar treino'),
          ),
        ],
      ),
    );
    if (!mounted || resume == null) return;
    if (resume) {
      await context.push(Routes.workout(running.id));
    } else {
      await repo.finishSession(running.id);
      // Descanso pendente do treino encerrado não deve continuar contando.
      ref.read(timerControllerProvider.notifier).reset();
      if (mounted) await context.push(Routes.workoutSummary(running.id));
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
