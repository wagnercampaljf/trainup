import 'package:material_ui/material_ui.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/plan_models.dart';

/// Cartão de ficha: tocar abre a ficha; o botão ▶ inicia o treino direto.
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
    final colors = context.colors;
    final subtitle = [
      '${plan.exerciseCount} '
          '${plan.exerciseCount == 1 ? 'exercício' : 'exercícios'}',
      if (plan.lastPerformedAt != null)
        'último: ${formatShortDate(plan.lastPerformedAt!)}'
      else
        'ainda não treinada',
    ].join(' · ');
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.lg,
            AppSpace.md + 2,
            AppSpace.sm,
            AppSpace.md + 2,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.name, style: context.text.titleLarge),
                    if (plan.description != null)
                      Text(
                        plan.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyMedium,
                      ),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      subtitle,
                      style: context.text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onStart != null)
                IconButton.filled(
                  tooltip: 'Iniciar treino ${plan.name}',
                  iconSize: 28,
                  style: IconButton.styleFrom(minimumSize: const Size(52, 52)),
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow_rounded),
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
