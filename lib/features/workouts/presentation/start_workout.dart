import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/routes.dart';
import '../data/workout_session_repository.dart';

/// Inicia um treino a partir da ficha e abre a tela de execução.
///
/// Se já houver um treino em andamento, oferece continuar o existente.
Future<void> startWorkout(
  BuildContext context,
  WidgetRef ref,
  int planId,
) async {
  final repo = ref.read(workoutSessionRepositoryProvider);
  try {
    final sessionId = await repo.startFromPlan(planId);
    if (context.mounted) await context.push(Routes.workout(sessionId));
  } on SessionAlreadyRunningException catch (e) {
    if (!context.mounted) return;
    final resume = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Treino em andamento'),
        content: const Text(
          'Você já possui um treino em andamento. Finalize-o antes de '
          'iniciar outro.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Fechar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continuar treino'),
          ),
        ],
      ),
    );
    if (resume == true && context.mounted) {
      await context.push(Routes.workout(e.sessionId));
    }
  } on Object catch (e) {
    if (context.mounted) context.showMessage('Não foi possível iniciar: $e');
  }
}
