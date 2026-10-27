import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/formatters.dart';

/// Campo de carga com botões −/+ (toque: incremento; toque longo: dobro) e
/// digitação manual. Valores sempre em kg.
class WeightInput extends StatefulWidget {
  const WeightInput({
    required this.value,
    required this.onChanged,
    required this.increment,
    this.enabled = true,
    this.fieldKey,
    super.key,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final double increment;
  final bool enabled;
  final Key? fieldKey;

  /// Botões −/+ (área de toque de 48 × 48).
  static const stepWidth = 48.0;

  /// O campo cresce com a fonte para "102,5" continuar inteiro.
  static double fieldWidthFor(double textScale) =>
      60 * textScale.clamp(1.0, 2.0);

  /// Largura total (−, campo, +).
  static double widthFor(double textScale) =>
      stepWidth * 2 + fieldWidthFor(textScale);

  @override
  State<WeightInput> createState() => _WeightInputState();
}

class _WeightInputState extends State<WeightInput> {
  late final _controller = TextEditingController(
    text: decimalToInput(widget.value),
  );
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (_focus.hasFocus) {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      } else {
        _commit();
      }
    });
  }

  @override
  void didUpdateWidget(WeightInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focus.hasFocus && parseDecimal(_controller.text) != widget.value) {
      _controller.text = decimalToInput(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _commit() {
    final parsed = parseDecimal(_controller.text);
    if (parsed == null || parsed < 0 || parsed > 1000) {
      _controller.text = decimalToInput(widget.value);
      return;
    }
    if (parsed != widget.value) widget.onChanged(parsed);
  }

  void _step(double delta) {
    final current = parseDecimal(_controller.text) ?? widget.value;
    final next = (current + delta).clamp(0.0, 1000.0);
    // Evita resíduos de ponto flutuante (ex.: 42.499999).
    final rounded = (next * 100).roundToDouble() / 100;
    _controller.text = decimalToInput(rounded);
    widget.onChanged(rounded);
  }

  @override
  Widget build(BuildContext context) {
    final inc = formatDecimal(widget.increment);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(
          icon: Icons.remove,
          label: 'Diminuir $inc kg',
          onTap: widget.enabled ? () => _step(-widget.increment) : null,
          onLongPress: widget.enabled
              ? () => _step(-widget.increment * 2)
              : null,
        ),
        SizedBox(
          width: WeightInput.fieldWidthFor(
            MediaQuery.textScalerOf(context).scale(1),
          ),
          child: TextField(
            key: widget.fieldKey,
            controller: _controller,
            focusNode: _focus,
            enabled: widget.enabled,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
              semanticCounterText: 'kg',
            ),
            onChanged: (value) {
              final parsed = parseDecimal(value);
              if (parsed != null && parsed >= 0 && parsed <= 1000) {
                widget.onChanged(parsed);
              }
            },
            onSubmitted: (_) => _commit(),
          ),
        ),
        _StepButton(
          icon: Icons.add,
          label: 'Aumentar $inc kg',
          onTap: widget.enabled ? () => _step(widget.increment) : null,
          onLongPress: widget.enabled
              ? () => _step(widget.increment * 2)
              : null,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.onLongPress,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        onLongPress: onLongPress,
        radius: 24,
        child: SizedBox(
          width: WeightInput.stepWidth,
          height: 48,
          child: Icon(
            icon,
            color: onTap == null
                ? Theme.of(context).disabledColor
                : Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
