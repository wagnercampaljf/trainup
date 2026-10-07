import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Campo compacto de repetições (inteiro ≥ 0).
class RepetitionInput extends StatefulWidget {
  const RepetitionInput({
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.minValue = 0,
    this.fieldKey,
    super.key,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final bool enabled;

  /// Menor valor aceito (1 para séries já concluídas). Valores abaixo não
  /// são enviados e o campo volta ao último valor válido ao perder o foco.
  final int minValue;
  final Key? fieldKey;

  @override
  State<RepetitionInput> createState() => _RepetitionInputState();
}

class _RepetitionInputState extends State<RepetitionInput> {
  late final _controller = TextEditingController(text: '${widget.value}');
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
  void didUpdateWidget(RepetitionInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focus.hasFocus && int.tryParse(_controller.text) != widget.value) {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _commit() {
    final parsed = int.tryParse(_controller.text.trim());
    if (parsed == null || parsed < widget.minValue || parsed > 1000) {
      _controller.text = '${widget.value}';
      return;
    }
    if (parsed != widget.value) widget.onChanged(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      child: TextField(
        key: widget.fieldKey,
        controller: _controller,
        focusNode: _focus,
        enabled: widget.enabled,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
          semanticCounterText: 'repetições',
        ),
        onChanged: (value) {
          final parsed = int.tryParse(value);
          if (parsed != null && parsed >= widget.minValue && parsed <= 1000) {
            widget.onChanged(parsed);
          }
        },
        onSubmitted: (_) => _commit(),
      ),
    );
  }
}
