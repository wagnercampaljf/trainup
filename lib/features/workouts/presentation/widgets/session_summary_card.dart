import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/session_models.dart';

/// Item do histórico de treinos: data em destaque à esquerda, ficha e
/// números do treino à direita.
class SessionSummaryCard extends StatelessWidget {
  const SessionSummaryCard({required this.summary, this.onTap, super.key});

  final SessionSummary summary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final duration = summary.duration;
    final info = [
      if (duration != null) formatDuration(duration),
      '${summary.exerciseCount} '
          '${summary.exerciseCount == 1 ? 'exercício' : 'exercícios'}',
      '${summary.setCount} ${summary.setCount == 1 ? 'série' : 'séries'}',
    ].join(' · ');
    final date = summary.startedAt;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.md),
          child: Row(
            children: [
              Semantics(
                label: formatDate(date),
                excludeSemantics: true,
                child: Container(
                  width: 56,
                  padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: .6),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${date.day}',
                        style: context.text.headlineSmall?.copyWith(
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        DateFormat.MMM(appLocale)
                            .format(date)
                            .replaceAll('.', '')
                            .toUpperCase(),
                        style: context.text.labelSmall?.copyWith(
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(summary.planName, style: context.text.titleMedium),
                    Text(
                      '${DateFormat.EEEE(appLocale).format(date)}, '
                      '${formatDate(date)}',
                      style: context.text.bodySmall,
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Text(info, style: context.text.bodyMedium),
                    Text(
                      '${formatVolume(summary.volume)} de volume',
                      style: context.text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
