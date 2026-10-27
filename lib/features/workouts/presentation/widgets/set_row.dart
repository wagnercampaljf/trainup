import 'package:material_ui/material_ui.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import 'repetition_input.dart';
import 'weight_input.dart';

/// Linha de uma série durante o treino: Série | Peso | Reps | ✓.
///
/// Em telas estreitas ou com fonte ampliada ([isCompact]), vira duas linhas
/// (série e ✓ em cima; carga e repetições embaixo) em vez de encolher.
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

  /// Largura da coluna do número da série.
  static const labelWidth = 48.0;

  /// Largura mínima da linha única (número, carga −/+, reps e ✓), já
  /// considerando a escala de fonte dos campos.
  static double singleLineWidth(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    return labelWidth +
        WeightInput.widthFor(scale) +
        RepetitionInput.widthFor(scale) +
        56 +
        AppSpace.sm;
  }

  static bool isCompact(BuildContext context, double available) =>
      available < singleLineWidth(context);

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
    final next = widget.isNext && !completed;
    // Verde = concluída; azul (borda e faixa) = próxima. O estado também
    // aparece em texto ("Próxima") e no ícone do botão, não só na cor.
    final background = completed
        ? colors.tertiaryContainer.withValues(alpha: .45)
        : next
        ? colors.primaryContainer.withValues(alpha: .35)
        : null;

    final weight = WeightInput(
      fieldKey: Key('set_weight_${widget.set.id}'),
      value: _weight,
      increment: widget.weightIncrement,
      onChanged: (value) {
        setState(() => _weight = _pendingWeight = value);
        widget.onWeightChanged(value);
      },
    );
    final reps = RepetitionInput(
      fieldKey: Key('set_reps_${widget.set.id}'),
      value: _reps,
      minValue: widget.set.completed ? 1 : 0,
      onChanged: (value) {
        setState(() => _reps = _pendingReps = value);
        widget.onRepsChanged(value);
      },
    );
    final complete = _CompleteButton(
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
    );
    final label = _SetLabel(
      number: number,
      next: next,
      completed: completed,
      isRecord: widget.isRecord,
    );

    final row = AnimatedContainer(
      duration: AppMotion.of(context, AppMotion.medium),
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: next ? colors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (SetRow.isCompact(context, constraints.maxWidth)) {
            // Tela estreita ou fonte ampliada: duas linhas, sem encolher os
            // controles.
            return Padding(
              padding: const EdgeInsets.only(left: AppSpace.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _SetLabel(
                          number: number,
                          next: next,
                          completed: completed,
                          isRecord: widget.isRecord,
                          inline: true,
                        ),
                      ),
                      complete,
                    ],
                  ),
                  Wrap(
                    spacing: AppSpace.sm,
                    runSpacing: AppSpace.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _Captioned(caption: 'Carga (kg)', child: weight),
                      _Captioned(caption: 'Reps', child: reps),
                    ],
                  ),
                  const SizedBox(height: AppSpace.xs),
                ],
              ),
            );
          }
          return Row(
            children: [
              SizedBox(width: SetRow.labelWidth, child: label),
              Expanded(child: Center(child: weight)),
              const SizedBox(width: AppSpace.xs),
              reps,
              const SizedBox(width: AppSpace.xs),
              complete,
            ],
          );
        },
      ),
    );

    if (widget.onRemove == null) return row;
    return Dismissible(
      key: ValueKey('dismiss_${widget.set.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpace.lg),
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Remover',
              style: context.text.labelLarge?.copyWith(
                color: colors.onErrorContainer,
              ),
            ),
            const SizedBox(width: AppSpace.sm),
            Icon(Icons.delete_outline, color: colors.onErrorContainer),
          ],
        ),
      ),
      onDismissed: (_) => _remove(),
      child: row,
    );
  }
}

/// Número da série com o estado em texto ("Próxima", "Feita").
class _SetLabel extends StatelessWidget {
  const _SetLabel({
    required this.number,
    required this.next,
    required this.completed,
    required this.isRecord,
    this.inline = false,
  });

  /// Linha única ("Série 2 · Próxima"), usada no layout compacto.
  final bool inline;
  final int number;
  final bool next;
  final bool completed;
  final bool isRecord;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final status = next
        ? 'Próxima'
        : completed
        ? 'Feita'
        : null;
    return Semantics(
      label: status == null ? null : 'Série $number, ${status.toLowerCase()}',
      excludeSemantics: !isRecord,
      child: inline
          ? Wrap(
              spacing: AppSpace.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Série $number',
                  style: context.text.titleMedium?.copyWith(
                    color: next ? colors.primary : null,
                  ),
                ),
                if (status != null)
                  Text(
                    status,
                    style: context.text.labelLarge?.copyWith(
                      color: next ? colors.primary : colors.onSurfaceVariant,
                    ),
                  ),
                if (isRecord) const Text('🏆', semanticsLabel: 'Novo recorde'),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$number',
                  textAlign: TextAlign.center,
                  style: context.text.titleLarge?.copyWith(
                    color: next ? colors.primary : null,
                  ),
                ),
                if (status != null)
                  Text(
                    status,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: context.text.labelSmall?.copyWith(
                      color: next ? colors.primary : colors.onSurfaceVariant,
                    ),
                  ),
                if (isRecord) const Text('🏆', semanticsLabel: 'Novo recorde'),
              ],
            ),
    );
  }
}

class _Captioned extends StatelessWidget {
  const _Captioned({required this.caption, required this.child});

  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Text(
            caption,
            style: context.text.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        child,
      ],
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
