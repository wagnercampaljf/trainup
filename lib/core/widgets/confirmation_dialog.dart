import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Diálogo de confirmação. Retorna `true` se confirmado.
///
/// Com [destructive], a confirmação fica vermelha e o ícone de alerta
/// reforça que a ação não tem volta; "Cancelar" continua sendo a saída mais
/// fácil.
Future<bool> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Excluir',
  String cancelLabel = 'Cancelar',
  bool destructive = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final colors = Theme.of(context).colorScheme;
      return AlertDialog(
        icon: destructive
            ? Icon(Icons.warning_amber_rounded, color: colors.error)
            : null,
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            style: destructive ? AppButtons.destructive(colors) : null,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
