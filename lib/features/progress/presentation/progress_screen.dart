import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../../../core/widgets/empty_state.dart';
import '../data/progress_repository.dart';
import '../domain/exercise_progress.dart';
import 'widgets/body_progress_view.dart';
import 'widgets/sparkline.dart';

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
              Tab(text: 'Cargas'),
              Tab(text: 'Corporal'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_LoadEvolutionList(), BodyProgressView()],
        ),
      ),
    );
  }
}

/// Evolução da carga de cada exercício: primeira → última maior carga,
/// diferença e minigráfico.
class _LoadEvolutionList extends ConsumerWidget {
  const _LoadEvolutionList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueWidget(
      value: ref.watch(loadEvolutionProvider),
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
        final improved = exercises.where((e) => e.change > 0).length;
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 160),
          itemCount: exercises.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                child: Text(
                  '$improved de ${exercises.length} '
                  '${exercises.length == 1 ? 'exercício' : 'exercícios'} '
                  'com aumento de carga desde o primeiro treino. Toque para '
                  'ver o gráfico.',
                  key: const Key('load_evolution_summary'),
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              );
            }
            return _LoadEvolutionCard(evolution: exercises[index - 1]);
          },
        );
      },
    );
  }
}

class _LoadEvolutionCard extends StatelessWidget {
  const _LoadEvolutionCard({required this.evolution});

  final ExerciseLoadEvolution evolution;

  @override
  Widget build(BuildContext context) {
    final e = evolution;
    final colors = context.colors;
    // Verde só para evolução; queda fica neutra (vermelho é para erros).
    final changeColor = e.change > 0
        ? colors.tertiary
        : colors.onSurfaceVariant;
    final percent = e.percent;
    return Card(
      key: Key('load_evolution_${e.exerciseId}'),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(Routes.exercise(e.exerciseId)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.name,
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      e.sessionCount == 1
                          ? '${formatWeight(e.lastWeight)} · 1 treino'
                          : '${formatWeight(e.firstWeight)} → '
                                '${formatWeight(e.lastWeight)} · '
                                '${e.sessionCount} treinos',
                      style: context.text.bodyMedium,
                    ),
                    Text(
                      'Maior carga: ${formatWeight(e.bestWeight)} · '
                      'último em ${formatShortDate(e.lastDate)}',
                      style: context.text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (e.sessionCount > 1) ...[
                Sparkline(values: e.maxWeights, color: colors.primary),
                const SizedBox(width: 12),
              ],
              SizedBox(
                width: 64,
                child: e.sessionCount == 1
                    ? Text(
                        'novo',
                        textAlign: TextAlign.end,
                        style: context.text.labelMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${formatSigned(e.change)} kg',
                            style: context.text.titleSmall?.copyWith(
                              color: changeColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (percent != null)
                            Text(
                              '${formatSigned(percent, maxDecimals: 0)}%',
                              style: context.text.labelMedium?.copyWith(
                                color: changeColor,
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
