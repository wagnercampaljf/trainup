import 'package:material_ui/material_ui.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/session_models.dart';

/// Item do histórico de treinos.
class SessionSummaryCard extends StatelessWidget {
  const SessionSummaryCard({required this.summary, this.onTap, super.key});

  final SessionSummary summary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final duration = summary.duration;
    final info = [
      if (duration != null) formatDuration(duration),
      '${summary.exerciseCount} '
          '${summary.exerciseCount == 1 ? 'exercício' : 'exercícios'}',
      '${summary.setCount} ${summary.setCount == 1 ? 'série' : 'séries'}',
    ].join(' · ');
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatDate(summary.startedAt),
                      style: context.text.labelLarge?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      summary.planName,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(info, style: context.text.bodyMedium),
                    Text(
                      '${formatVolume(summary.volume)} de volume',
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null) const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
