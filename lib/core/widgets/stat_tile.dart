import 'package:material_ui/material_ui.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_theme.dart';

/// Indicador numérico (rótulo + valor), sem caixa própria: agrupe vários em
/// um [StatGrid], que os coloca em um único painel.
class StatTile extends StatelessWidget {
  const StatTile({
    required this.label,
    required this.value,
    this.icon,
    this.caption,
    this.valueColor,
    super.key,
  });

  final String label;
  final String value;
  final IconData? icon;
  final String? caption;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: colors.onSurfaceVariant),
                const SizedBox(width: AppSpace.xs + 2),
              ],
              Expanded(
                child: Text(
                  label,
                  style: context.text.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            value,
            style: context.text.headlineSmall?.copyWith(
              color: valueColor ?? colors.onSurface,
            ),
          ),
          if (caption != null)
            Text(
              caption!,
              style: context.text.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

/// Painel de [StatTile]s: um só cartão, 2 colunas no celular (4 em telas
/// largas) e divisórias entre as linhas.
class StatGrid extends StatelessWidget {
  const StatGrid({required this.children, this.columns, super.key});

  final List<Widget> children;

  /// Força o número de colunas (padrão: 2, ou 4 acima de 600 de largura).
  final int? columns;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final count = columns ?? (constraints.maxWidth > 600 ? 4 : 2);
          final rows = <List<Widget>>[
            for (var i = 0; i < children.length; i += count)
              children.sublist(i, (i + count).clamp(0, children.length)),
          ];
          return Column(
            children: [
              for (final (index, row) in rows.indexed) ...[
                if (index > 0)
                  const Divider(indent: AppSpace.lg, endIndent: AppSpace.lg),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < count; i++) ...[
                        if (i > 0)
                          const VerticalDivider(
                            width: 1,
                            indent: AppSpace.md,
                            endIndent: AppSpace.md,
                          ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpace.lg),
                            child: i < row.length
                                ? row[i]
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
