import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/async_value_widget.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../body_measurements/data/body_measurement_repository.dart';
import '../../../body_measurements/domain/body_metric.dart';
import '../../domain/chart_point.dart';
import '../../domain/progress_calculations.dart';
import 'progress_chart.dart';
import 'progress_summary.dart';

/// Evolução corporal: seleção do indicador, gráfico e resumo.
class BodyProgressView extends ConsumerStatefulWidget {
  const BodyProgressView({super.key});

  @override
  ConsumerState<BodyProgressView> createState() => _BodyProgressViewState();
}

class _BodyProgressViewState extends ConsumerState<BodyProgressView> {
  var _metric = BodyMetric.weight;

  @override
  Widget build(BuildContext context) {
    return AsyncValueWidget(
      value: ref.watch(bodyMeasurementsProvider),
      data: (measurements) {
        if (measurements.isEmpty) {
          return EmptyState(
            icon: Icons.monitor_weight_outlined,
            message: 'Nenhuma medição registrada.',
            actionLabel: 'Registrar medição',
            onAction: () => context.push(Routes.newMeasurement),
          );
        }
        final available = [
          for (final metric in BodyMetric.values)
            if (measurements.any((m) => metric.valueOf(m) != null)) metric,
        ];
        final metric = available.contains(_metric) ? _metric : available.first;
        // Lista vem do mais recente ao mais antigo; o gráfico é cronológico.
        final points = [
          for (final m in measurements.reversed)
            if (metric.valueOf(m) case final value?) ChartPoint(m.date, value),
        ];
        final summary = ProgressSummary.fromValues([
          for (final p in points) p.value,
        ]);
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 160),
          children: [
            DropdownButtonFormField<BodyMetric>(
              isExpanded: true,
              key: ValueKey(metric),
              initialValue: metric,
              decoration: const InputDecoration(labelText: 'Indicador'),
              items: [
                for (final m in available)
                  DropdownMenuItem(value: m, child: Text(m.label)),
              ],
              onChanged: (m) => setState(() => _metric = m ?? _metric),
            ),
            const SizedBox(height: 16),
            ProgressChart(points: points, unit: metric.unit),
            const SizedBox(height: 12),
            if (summary != null)
              ProgressSummaryTiles(summary: summary, unit: metric.unit),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(Routes.measurements),
                    icon: const Icon(Icons.list),
                    label: const Text('Histórico'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => context.push(Routes.newMeasurement),
                    icon: const Icon(Icons.add),
                    label: const Text('Nova medição'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
