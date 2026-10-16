import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/routes.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../../../core/widgets/empty_state.dart';
import '../../workouts/presentation/start_workout.dart';
import '../data/workout_plan_repository.dart';
import 'plan_transfer_actions.dart';
import 'widgets/workout_plan_card.dart';

class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(activePlansProvider);
    final hasPlans = plans.value?.isNotEmpty ?? false;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fichas'),
        actions: [
          IconButton(
            tooltip: 'Catálogo de exercícios',
            icon: const Icon(Icons.fitness_center),
            onPressed: () => context.push(Routes.exercises),
          ),
          PopupMenuButton<String>(
            key: const Key('plans_menu'),
            tooltip: 'Mais opções',
            onSelected: (action) => action == 'import'
                ? importPlansFromFile(context, ref)
                : chooseAndExportPlans(context, ref, plans.value ?? const []),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'import',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.file_download_outlined),
                  title: Text('Importar fichas'),
                ),
              ),
              PopupMenuItem(
                value: 'export',
                enabled: hasPlans,
                child: const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.ios_share),
                  title: Text('Exportar fichas'),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: hasPlans
          ? FloatingActionButton.extended(
              heroTag: 'new_plan',
              onPressed: () => context.push(Routes.newPlan),
              icon: const Icon(Icons.add),
              label: const Text('Nova ficha'),
            )
          : null,
      body: AsyncValueWidget(
        value: plans,
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.assignment_outlined,
              message: 'Você ainda não possui nenhuma ficha.',
              description: 'Monte sua ficha com exercícios, séries e cargas.',
              actionLabel: 'Criar primeira ficha',
              onAction: () => context.push(Routes.newPlan),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 160),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final plan = list[index];
              return WorkoutPlanCard(
                plan: plan,
                onTap: () => context.push(Routes.plan(plan.id)),
                onStart: () => startWorkout(context, ref, plan.id),
              );
            },
          );
        },
      ),
    );
  }
}
