import 'package:material_ui/material_ui.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_theme.dart';

/// Ações fixas no rodapé da tela: [primary] em destaque e, opcionalmente,
/// [secondary] ao lado.
///
/// Quando a largura (já descontada a escala de fonte) não comporta as duas
/// lado a lado ([minRowWidth]), elas são empilhadas, a principal embaixo,
/// perto do polegar. A altura cresce com o texto em vez de cortá-lo.
class ActionBar extends StatelessWidget {
  const ActionBar({
    required this.primary,
    this.secondary,
    this.note,
    this.minRowWidth = 320,
    super.key,
  });

  final Widget primary;
  final Widget? secondary;

  /// Explicação curta acima dos botões (ex.: o que a ação final faz).
  final String? note;

  /// Largura lógica (fonte em escala 1) necessária para a linha única.
  final double minRowWidth;

  static Widget _tall(Widget child) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: AppTheme.largeButtonHeight),
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.page,
          AppSpace.sm,
          AppSpace.page,
          AppSpace.md,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = MediaQuery.textScalerOf(context).scale(1);
            final secondary = this.secondary;
            final stacked =
                secondary != null && constraints.maxWidth / scale < minRowWidth;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (note != null) ...[
                  Text(
                    note!,
                    textAlign: TextAlign.center,
                    style: context.text.bodySmall,
                  ),
                  const SizedBox(height: AppSpace.sm),
                ],
                if (secondary == null)
                  _tall(primary)
                else if (stacked) ...[
                  _tall(secondary),
                  const SizedBox(height: AppSpace.sm),
                  _tall(primary),
                ] else
                  Row(
                    children: [
                      Flexible(child: _tall(secondary)),
                      const SizedBox(width: AppSpace.md),
                      Expanded(child: _tall(primary)),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
