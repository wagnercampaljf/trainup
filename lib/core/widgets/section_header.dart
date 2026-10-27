import 'package:material_ui/material_ui.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_theme.dart';

/// Título de seção com ação opcional à direita (ex.: "Ver todas").
class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    this.trailing,
    this.actionLabel,
    this.onAction,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.xl, bottom: AppSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: context.text.titleLarge?.copyWith(fontSize: 19),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ?trailing,
        ],
      ),
    );
  }
}
