import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/routes.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../../../core/widgets/empty_state.dart';
import '../data/exercise_repository.dart';
import '../domain/muscle_group.dart';
import 'widgets/exercise_card.dart';

/// Catálogo de exercícios. Em [pickMode], tocar em um item o retorna
/// (`context.pop(exercise)`) para quem abriu a tela.
class ExercisesScreen extends ConsumerStatefulWidget {
  const ExercisesScreen({this.pickMode = false, super.key});

  final bool pickMode;

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends ConsumerState<ExercisesScreen> {
  final _search = TextEditingController();
  String _query = '';
  MuscleGroup? _group;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final id = await context.push<int>(Routes.newExercise);
    if (id == null || !widget.pickMode || !mounted) return;
    final exercise = await ref.read(exerciseRepositoryProvider).getById(id);
    if (mounted && exercise != null) context.pop(exercise);
  }

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(
      exerciseListProvider((query: _query, group: _group)),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pickMode ? 'Selecionar exercício' : 'Exercícios'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'new_exercise',
        onPressed: _create,
        icon: const Icon(Icons.add),
        label: const Text('Novo exercício'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              key: const Key('exercise_search'),
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Buscar exercício',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpar busca',
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() {
                          _search.clear();
                          _query = '';
                        }),
                      ),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                FilterChip(
                  label: const Text('Todos'),
                  selected: _group == null,
                  onSelected: (_) => setState(() => _group = null),
                ),
                for (final group in MuscleGroup.values)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(group.label),
                      selected: _group == group,
                      onSelected: (selected) =>
                          setState(() => _group = selected ? group : null),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: AsyncValueWidget(
              value: exercises,
              data: (list) {
                if (list.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off,
                    message: 'Nenhum exercício encontrado.',
                    actionLabel: 'Criar exercício',
                    onAction: _create,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 160),
                  itemCount: list.length + (widget.pickMode ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, position) {
                    if (widget.pickMode && position == 0) {
                      return Text(
                        'Toque no exercício para adicioná-lo. ⓘ mostra os '
                        'detalhes e a evolução.',
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                    }
                    final index = widget.pickMode ? position - 1 : position;
                    final exercise = list[index];
                    return ExerciseCard(
                      exercise: exercise,
                      trailing: widget.pickMode
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Detalhes de ${exercise.name}',
                                  icon: const Icon(Icons.info_outline),
                                  onPressed: () => context.push(
                                    Routes.exercise(exercise.id),
                                  ),
                                ),
                                Icon(
                                  Icons.add_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                  semanticLabel: 'Adicionar',
                                ),
                              ],
                            )
                          : null,
                      onTap: () => widget.pickMode
                          ? context.pop(exercise)
                          : context.push(Routes.exercise(exercise.id)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
