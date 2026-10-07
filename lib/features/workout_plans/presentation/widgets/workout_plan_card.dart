import 'package:material_ui/material_ui.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/plan_models.dart';

/// Cartão de ficha com ação opcional de iniciar treino.
class WorkoutPlanCard extends StatelessWidget {
  const WorkoutPlanCard({
    required this.plan,
    required this.onTap,
    this.onStart,
    super.key,
  });

  final PlanSummary plan;
  final VoidCallback onTap;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      '${plan.exerciseCount} '
          '${plan.exerciseCount == 1 ? 'exercício' : 'exercícios'}',
      if (plan.lastPerformedAt != null)
        'último: ${formatShortDate(plan.lastPerformedAt!)}',
    ].join(' · ');
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (plan.description != null)
                      Text(
                        plan.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyMedium,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onStart != null)
                IconButton.filled(
                  tooltip: 'Iniciar treino ${plan.name}',
                  iconSize: 28,
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow),
                )
              else
                const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
