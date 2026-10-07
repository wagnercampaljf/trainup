import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/routes.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../../../core/widgets/empty_state.dart';
import '../data/body_measurement_repository.dart';
import 'widgets/body_measurement_card.dart';

/// Histórico de medições corporais.
class MeasurementsScreen extends ConsumerWidget {
  const MeasurementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medidas corporais')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.newMeasurement),
        icon: const Icon(Icons.add),
        label: const Text('Nova medição'),
      ),
      body: AsyncValueWidget(
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
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: measurements.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final m = measurements[index];
              return BodyMeasurementCard(
                measurement: m,
                onTap: () => context.push(Routes.editMeasurement(m.id)),
              );
            },
          );
        },
      ),
    );
  }
}
