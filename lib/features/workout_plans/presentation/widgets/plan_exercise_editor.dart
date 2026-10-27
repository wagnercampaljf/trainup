import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../timer/domain/rest_options.dart';
import '../../domain/plan_models.dart';

/// Editor de um exercício da ficha: descanso, observação e séries.
class PlanExerciseEditor extends StatelessWidget {
  const PlanExerciseEditor({
    required this.exercise,
    required this.index,
    required this.onChanged,
    required this.onRemove,
    this.onMove,
    this.isLast = false,
    super.key,
  });

  final PlanExerciseDraft exercise;
  final int index;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  /// Move o exercício (−1 sobe, +1 desce): alternativa acessível ao arraste.
  final ValueChanged<int>? onMove;
  final bool isLast;

  void _addSet() {
    final last = exercise.sets.lastOrNull;
    exercise.sets.add(
      last?.copy() ?? PlanSetDraft(repetitions: 10, weightKg: 0),
    );
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: Tooltip(
                    message: 'Arraste para reordenar',
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.drag_indicator,
                        color: context.colors.onSurfaceVariant,
                        semanticLabel: 'Arrastar para reordenar',
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}. ${exercise.exerciseName}',
                        style: context.text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        exercise.muscleGroup.label,
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  key: Key('plan_exercise_menu_$index'),
                  tooltip: 'Opções de ${exercise.exerciseName}',
                  onSelected: (action) => switch (action) {
                    'up' => onMove?.call(-1),
                    'down' => onMove?.call(1),
                    _ => onRemove(),
                  },
                  itemBuilder: (context) => [
                    if (onMove != null && index > 0)
                      const PopupMenuItem(
                        value: 'up',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.arrow_upward),
                          title: Text('Mover para cima'),
                        ),
                      ),
                    if (onMove != null && !isLast)
                      const PopupMenuItem(
                        value: 'down',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.arrow_downward),
                          title: Text('Mover para baixo'),
                        ),
                      ),
                    PopupMenuItem(
                      value: 'remove',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.delete_outline,
                          color: context.colors.error,
                        ),
                        title: Text(
                          'Remover da ficha',
                          style: TextStyle(color: context.colors.error),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int?>(
              isExpanded: true,
              initialValue: exercise.restSeconds,
              decoration: const InputDecoration(
                labelText: 'Descanso',
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(child: Text('Padrão das configurações')),
                for (final s in {...restOptionsSeconds, ?exercise.restSeconds})
                  DropdownMenuItem(
                    value: s,
                    child: Text(formatRest(Duration(seconds: s))),
                  ),
              ],
              onChanged: (value) {
                exercise.restSeconds = value;
                onChanged();
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: exercise.notes,
              decoration: const InputDecoration(
                labelText: 'Observação (opcional)',
                isDense: true,
              ),
              onChanged: (value) {
                exercise.notes = value;
                onChanged();
              },
            ),
            const SizedBox(height: 12),
            for (final (setIndex, set) in exercise.sets.indexed)
              _PlanSetRow(
                key: ObjectKey(set),
                index: setIndex,
                set: set,
                onDuplicate: () {
                  exercise.sets.insert(setIndex + 1, set.copy());
                  onChanged();
                },
                onRemove: () {
                  exercise.sets.removeAt(setIndex);
                  onChanged();
                },
                onChanged: onChanged,
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: Key('add_set_${exercise.exerciseId}'),
                onPressed: _addSet,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar série'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _intInput = FilteringTextInputFormatter.digitsOnly;
final _decimalInput = FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'));

class _PlanSetRow extends StatelessWidget {
  const _PlanSetRow({
    required this.index,
    required this.set,
    required this.onDuplicate,
    required this.onRemove,
    required this.onChanged,
    super.key,
  });

  final int index;
  final PlanSetDraft set;
  final VoidCallback onDuplicate;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            height: 48,
            child: Center(
              child: Text(
                'Série ${index + 1}',
                style: context.text.labelMedium,
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              key: Key('plan_set_reps_$index'),
              initialValue: '${set.repetitions}',
              keyboardType: TextInputType.number,
              inputFormatters: [_intInput],
              decoration: const InputDecoration(
                labelText: 'Reps',
                isDense: true,
              ),
              validator: Validators.repetitions,
              onChanged: (value) {
                final reps = int.tryParse(value);
                if (reps != null && reps >= 0) set.repetitions = reps;
                onChanged();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              key: Key('plan_set_weight_$index'),
              initialValue: decimalToInput(set.weightKg),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [_decimalInput],
              decoration: const InputDecoration(
                labelText: 'Carga',
                suffixText: 'kg',
                isDense: true,
              ),
              validator: Validators.liftWeight,
              onChanged: (value) {
                final weight = parseDecimal(value);
                if (weight != null && weight >= 0) set.weightKg = weight;
                onChanged();
              },
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Opções da série ${index + 1}',
            onSelected: (action) =>
                action == 'duplicate' ? onDuplicate() : onRemove(),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'duplicate',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.content_copy),
                  title: Text('Duplicar série'),
                ),
              ),
              PopupMenuItem(
                value: 'remove',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.delete_outline,
                    color: context.colors.error,
                  ),
                  title: Text(
                    'Remover série',
                    style: TextStyle(color: context.colors.error),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
