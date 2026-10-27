import 'package:material_ui/material_ui.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_theme.dart';

enum EmptyStateTone { neutral, error }

/// Estado vazio (ou de erro) com ícone, mensagem, ação principal e,
/// opcionalmente, uma alternativa secundária.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.message,
    this.description,
    this.actionLabel,
    this.actionIcon = Icons.add,
    this.onAction,
    this.secondaryLabel,
    this.secondaryIcon,
    this.onSecondary,
    this.tone = EmptyStateTone.neutral,
    this.actionKey,
    this.secondaryKey,
    super.key,
  });

  final IconData icon;
  final String message;
  final String? description;
  final String? actionLabel;
  final IconData actionIcon;
  final VoidCallback? onAction;
  final String? secondaryLabel;
  final IconData? secondaryIcon;
  final VoidCallback? onSecondary;
  final EmptyStateTone tone;
  final Key? actionKey;
  final Key? secondaryKey;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (Color badge, Color onBadge) = tone == EmptyStateTone.error
        ? (colors.errorContainer, colors.onErrorContainer)
        : (colors.primaryContainer, colors.onPrimaryContainer);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.xl,
          AppSpace.xl,
          AppSpace.xl,
          AppSpace.listBottom,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: badge,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Icon(icon, size: 36, color: onBadge),
                ),
              ),
              const SizedBox(height: AppSpace.lg),
              Text(
                message,
                textAlign: TextAlign.center,
                style: context.text.headlineSmall,
              ),
              if (description != null) ...[
                const SizedBox(height: AppSpace.sm),
                Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: context.text.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpace.xl),
                FilledButton.icon(
                  key: actionKey,
                  onPressed: onAction,
                  icon: Icon(actionIcon),
                  label: Text(actionLabel!),
                ),
              ],
              if (secondaryLabel != null && onSecondary != null) ...[
                const SizedBox(height: AppSpace.md),
                OutlinedButton.icon(
                  key: secondaryKey,
                  onPressed: onSecondary,
                  icon: Icon(secondaryIcon ?? Icons.arrow_forward),
                  label: Text(secondaryLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
