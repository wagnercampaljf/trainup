import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
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
      onRetry: () => ref.invalidate(loadEvolutionProvider),
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
          padding: const EdgeInsets.fromLTRB(
            AppSpace.page,
            AppSpace.md,
            AppSpace.page,
            AppSpace.listBottom,
          ),
          itemCount: exercises.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpace.sm),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, AppSpace.xs),
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

/// Uma linha por exercício: nome, primeira → última maior carga, período,
/// minigráfico e a diferença (verde só quando subiu; queda fica neutra,
/// pois vermelho é reservado para erros).
class _LoadEvolutionCard extends StatelessWidget {
  const _LoadEvolutionCard({required this.evolution});

  final ExerciseLoadEvolution evolution;

  @override
  Widget build(BuildContext context) {
    final e = evolution;
    final colors = context.colors;
    final up = e.change > 0;
    final percent = e.percent;
    final single = e.sessionCount == 1;
    return Card(
      key: Key('load_evolution_${e.exerciseId}'),
      child: InkWell(
        onTap: () => context.push(Routes.exercise(e.exerciseId)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.lg,
            AppSpace.md,
            AppSpace.md,
            AppSpace.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.name, style: context.text.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      single
                          ? '${formatWeight(e.lastWeight)} · 1 treino'
                          : '${formatWeight(e.firstWeight)} → '
                                '${formatWeight(e.lastWeight)} · '
                                '${e.sessionCount} treinos',
                      style: context.text.bodyMedium?.tabular,
                    ),
                    Text(
                      single
                          ? 'em ${formatShortDate(e.lastDate)} · sem '
                                'comparação ainda'
                          : 'de ${formatShortDate(e.firstDate)} a '
                                '${formatShortDate(e.lastDate)}'
                                '${e.bestWeight > e.lastWeight ? ' · maior ${formatWeight(e.bestWeight)}' : ''}',
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
              if (!single) ...[
                Sparkline(
                  values: e.maxWeights,
                  color: up ? colors.tertiary : colors.primary,
                ),
                const SizedBox(width: AppSpace.md),
              ],
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 64),
                child: single
                    ? _Pill(
                        text: '1º registro',
                        background: colors.surfaceContainerHigh,
                        foreground: colors.onSurfaceVariant,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _Pill(
                            text: '${formatSigned(e.change)} kg',
                            background: up
                                ? colors.tertiaryContainer
                                : colors.surfaceContainerHigh,
                            foreground: up
                                ? colors.onTertiaryContainer
                                : colors.onSurface,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            percent == null
                                ? 'sem %'
                                : '${formatSigned(percent, maxDecimals: 0)}%',
                            style: context.text.labelMedium?.tabular.copyWith(
                              color: colors.onSurfaceVariant,
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

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    required this.background,
    required this.foreground,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        text,
        style: context.text.titleSmall?.tabular.copyWith(color: foreground),
      ),
    );
  }
}
