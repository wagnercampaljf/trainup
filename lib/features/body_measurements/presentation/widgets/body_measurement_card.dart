import 'package:material_ui/material_ui.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/body_metric.dart';

/// Cartão resumido de uma medição corporal.
class BodyMeasurementCard extends StatelessWidget {
  const BodyMeasurementCard({required this.measurement, this.onTap, super.key});

  final BodyMeasurement measurement;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final extras = [
      for (final metric in BodyMetric.values.skip(1))
        if (metric.valueOf(measurement) case final value?)
          '${metric.label}: ${formatDecimal(value)} ${metric.unit}',
    ];
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatDate(measurement.date),
                      style: context.text.titleSmall,
                    ),
                  ),
                  Text(
                    formatWeight(measurement.weightKg),
                    style: context.text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (extras.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  extras.join(' · '),
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
              if (measurement.notes != null) ...[
                const SizedBox(height: 6),
                Text(measurement.notes!, style: context.text.bodyMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
