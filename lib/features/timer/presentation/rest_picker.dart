import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/formatters.dart';
import '../domain/rest_options.dart';

/// Escolha feita no [showRestPicker].
class RestChoice {
  const RestChoice({required this.seconds, this.applyToPlan = false});

  /// `null` = usar o descanso padrão das configurações.
  final int? seconds;

  /// Também gravar na ficha (quando oferecido).
  final bool applyToPlan;
}

/// Seletor do descanso de um exercício.
///
/// Com [offerApplyToPlan], mostra a opção de gravar o valor também na ficha
/// (usado durante o treino, cuja sessão é uma cópia da ficha).
Future<RestChoice?> showRestPicker(
  BuildContext context, {
  required String exerciseName,
  required int? current,
  required int defaultSeconds,
  bool offerApplyToPlan = false,
}) => showDialog<RestChoice>(
  context: context,
  builder: (_) => _RestPickerDialog(
    exerciseName: exerciseName,
    current: current,
    defaultSeconds: defaultSeconds,
    offerApplyToPlan: offerApplyToPlan,
  ),
);

class _RestPickerDialog extends StatefulWidget {
  const _RestPickerDialog({
    required this.exerciseName,
    required this.current,
    required this.defaultSeconds,
    required this.offerApplyToPlan,
  });

  final String exerciseName;
  final int? current;
  final int defaultSeconds;
  final bool offerApplyToPlan;

  @override
  State<_RestPickerDialog> createState() => _RestPickerDialogState();
}

class _RestPickerDialogState extends State<_RestPickerDialog> {
  late int? _selected = widget.current;
  var _applyToPlan = true;

  String _label(int seconds) => formatRest(Duration(seconds: seconds));

  @override
  Widget build(BuildContext context) {
    final options = {...restOptionsSeconds, ?widget.current}.toList()..sort();
    return AlertDialog(
      title: const Text('Descanso'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.exerciseName, style: context.text.bodyMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  key: const Key('rest_option_default'),
                  label: Text('Padrão (${_label(widget.defaultSeconds)})'),
                  selected: _selected == null,
                  onSelected: (_) => setState(() => _selected = null),
                ),
                for (final seconds in options)
                  ChoiceChip(
                    key: Key('rest_option_$seconds'),
                    label: Text(_label(seconds)),
                    selected: _selected == seconds,
                    onSelected: (_) => setState(() => _selected = seconds),
                  ),
              ],
            ),
            if (widget.offerApplyToPlan) ...[
              const SizedBox(height: 8),
              CheckboxListTile(
                key: const Key('rest_apply_to_plan'),
                contentPadding: EdgeInsets.zero,
                value: _applyToPlan,
                onChanged: (v) => setState(() => _applyToPlan = v ?? false),
                title: const Text('Salvar também na ficha'),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const Key('rest_save'),
          onPressed: () => Navigator.pop(
            context,
            RestChoice(
              seconds: _selected,
              applyToPlan: widget.offerApplyToPlan && _applyToPlan,
            ),
          ),
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
