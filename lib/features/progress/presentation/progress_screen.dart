import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../../../core/widgets/empty_state.dart';
import '../data/progress_repository.dart';
import 'widgets/body_progress_view.dart';

/// "Minha evolução": cargas por exercício e evolução corporal.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Minha evolução'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Treinos'),
              Tab(text: 'Corporal'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_ExerciseProgressList(), BodyProgressView()],
        ),
      ),
    );
  }
}

class _ExerciseProgressList extends ConsumerWidget {
  const _ExerciseProgressList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueWidget(
      value: ref.watch(exercisesWithHistoryProvider),
      data: (exercises) {
        if (exercises.isEmpty) {
          return EmptyState(
            icon: Icons.show_chart,
            message: 'Ainda não há treinos registrados.',
            description:
                'A evolução das cargas aparece após o primeiro treino.',
            actionLabel: 'Ver fichas',
            onAction: () => context.go(Routes.plans),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 160),
          itemCount: exercises.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final e = exercises[index];
            return Card(
              child: ListTile(
                title: Text(e.name),
                subtitle: Text(
                  '${e.sessionCount} '
                  '${e.sessionCount == 1 ? 'treino' : 'treinos'} · '
                  'último em ${formatDate(e.lastDate)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.exercise(e.exerciseId)),
              ),
            );
          },
        );
      },
    );
  }
}
