import 'package:material_ui/material_ui.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import 'repetition_input.dart';
import 'weight_input.dart';

/// Linha de uma série durante o treino: Série | Peso | Reps | ✓.
class SetRow extends StatefulWidget {
  const SetRow({
    required this.set,
    required this.index,
    required this.weightIncrement,
    required this.isNext,
    required this.onWeightChanged,
    required this.onRepsChanged,
    required this.onToggle,
    this.onRemove,
    this.isRecord = false,
    super.key,
  });

  final WorkoutSessionSet set;
  final int index;
  final double weightIncrement;
  final bool isNext;
  final bool isRecord;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<int> onRepsChanged;

  /// Conclui (ou desfaz) a série com os valores exibidos.
  final void Function(int repetitions, double weightKg) onToggle;

  /// Disponível apenas para séries ainda não executadas.
  ///
  /// Retorna `true` se a série foi removida; se `false`, a linha reaparece.
  final Future<bool> Function()? onRemove;

  @override
  State<SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<SetRow> {
  late double _weight = widget.set.weightKg;
  late int _reps = widget.set.repetitions;

  /// Remoção otimista: a linha sai da tela assim que é arrastada (o
  /// `Dismissible` não pode continuar na árvore) e volta se o banco recusar.
  var _removed = false;

  /// Última edição local ainda não refletida pelo banco. Enquanto existir,
  /// ecos atrasados do stream (valores intermediários da digitação) são
  /// ignorados, para que concluir a série use o valor que está na tela.
  double? _pendingWeight;
  int? _pendingReps;

  @override
  void didUpdateWidget(SetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final dbWeight = widget.set.weightKg;
    if (_pendingWeight == null) {
      _weight = dbWeight;
    } else if (dbWeight == _pendingWeight) {
      _pendingWeight = null;
    }
    final dbReps = widget.set.repetitions;
    if (_pendingReps == null) {
      _reps = dbReps;
    } else if (dbReps == _pendingReps) {
      _pendingReps = null;
    }
  }

  void _remove() {
    setState(() => _removed = true);
    widget.onRemove!().then((removed) {
      if (!removed && mounted) setState(() => _removed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_removed) return const SizedBox.shrink();
    final completed = widget.set.completed;
    final colors = context.colors;
    final number = widget.index + 1;
    // Verde = concluído; azul (borda) = próxima série a executar.
    final background = completed
        ? colors.tertiaryContainer.withValues(alpha: .45)
        : widget.isNext
        ? colors.surfaceContainerHighest.withValues(alpha: .6)
        : null;

    final row = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isNext ? colors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$number',
                  textAlign: TextAlign.center,
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: widget.isNext ? FontWeight.w800 : null,
                  ),
                ),
                if (widget.isRecord)
                  const Text('🏆', semanticsLabel: 'Novo recorde'),
              ],
            ),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: WeightInput(
                fieldKey: Key('set_weight_${widget.set.id}'),
                value: _weight,
                increment: widget.weightIncrement,
                onChanged: (value) {
                  setState(() => _weight = _pendingWeight = value);
                  widget.onWeightChanged(value);
                },
              ),
            ),
          ),
          const SizedBox(width: 4),
          RepetitionInput(
            fieldKey: Key('set_reps_${widget.set.id}'),
            value: _reps,
            minValue: widget.set.completed ? 1 : 0,
            onChanged: (value) {
              setState(() => _reps = _pendingReps = value);
              widget.onRepsChanged(value);
            },
          ),
          const SizedBox(width: 4),
          _CompleteButton(
            key: Key('complete_set_${widget.set.id}'),
            completed: completed,
            label: completed
                ? 'Série $number concluída: ${formatWeight(_weight)}, '
                      '$_reps repetições. Toque para desfazer'
                : 'Concluir série $number: ${formatWeight(_weight)}, '
                      '$_reps repetições',
            onPressed: () {
              FocusScope.of(context).unfocus();
              widget.onToggle(_reps, _weight);
            },
          ),
        ],
      ),
    );

    if (widget.onRemove == null) return row;
    return Dismissible(
      key: ValueKey('dismiss_${widget.set.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline, color: colors.onErrorContainer),
      ),
      onDismissed: (_) => _remove(),
      child: row,
    );
  }
}

class _CompleteButton extends StatelessWidget {
  const _CompleteButton({
    required this.completed,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final bool completed;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      checked: completed,
      label: label,
      excludeSemantics: true,
      child: SizedBox(
        width: 56,
        height: 56,
        child: IconButton(
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: completed ? colors.tertiary : null,
            side: completed ? null : BorderSide(color: colors.outline),
          ),
          icon: Icon(
            Icons.check,
            size: 28,
            color: completed ? colors.onTertiary : colors.outline,
          ),
        ),
      ),
    );
  }
}
