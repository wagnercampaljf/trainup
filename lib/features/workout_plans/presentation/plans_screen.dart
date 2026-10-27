import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
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
        onRetry: () => ref.invalidate(activePlansProvider),
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.assignment_outlined,
              message: 'Você ainda não possui nenhuma ficha.',
              description:
                  'Monte sua ficha com exercícios, séries e cargas, ou '
                  'importe o arquivo que seu personal enviou.',
              actionLabel: 'Criar primeira ficha',
              onAction: () => context.push(Routes.newPlan),
              secondaryLabel: 'Importar ficha recebida',
              secondaryIcon: Icons.file_download_outlined,
              secondaryKey: const Key('plans_empty_import'),
              onSecondary: () => importPlansFromFile(context, ref),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.page,
              AppSpace.sm,
              AppSpace.page,
              AppSpace.listBottom + 40,
            ),
            itemCount: list.length + 2,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpace.md),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Text(
                  '${list.length} ${list.length == 1 ? 'ficha' : 'fichas'} · '
                  'toque para ver, ▶ para treinar',
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                );
              }
              if (index == list.length + 1) {
                return _ImportTile(
                  onTap: () => importPlansFromFile(context, ref),
                );
              }
              final plan = list[index - 1];
              return WorkoutPlanCard(
                plan: plan,
                onTap: () => context.push(Routes.plan(plan.id)),
                onStart: plan.exerciseCount == 0
                    ? null
                    : () => startWorkout(context, ref, plan.id),
              );
            },
          );
        },
      ),
    );
  }
}

/// Atalho para quem recebeu uma ficha (ex.: do personal).
class _ImportTile extends StatelessWidget {
  const _ImportTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: ListTile(
        key: const Key('plans_import_tile'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        leading: Icon(Icons.file_download_outlined, color: colors.primary),
        title: const Text('Recebeu uma ficha?'),
        subtitle: const Text('Importe o arquivo .json enviado pelo personal'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
