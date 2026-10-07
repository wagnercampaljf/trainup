import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/body_metric.dart';

/// Controladores dos campos de medição (um por [BodyMetric]).
class MeasurementControllers {
  MeasurementControllers([BodyMeasurement? initial])
    : controllers = {
        for (final metric in BodyMetric.values)
          metric: TextEditingController(
            text: initial == null
                ? ''
                : decimalToInput(metric.valueOf(initial)),
          ),
      };

  final Map<BodyMetric, TextEditingController> controllers;

  TextEditingController operator [](BodyMetric metric) => controllers[metric]!;

  Map<BodyMetric, double?> get values => {
    for (final entry in controllers.entries)
      entry.key: parseDecimal(entry.value.text),
  };

  bool get hasAnyCircumference =>
      BodyMetric.circumferences.any((m) => this[m].text.trim().isNotEmpty);

  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
  }
}

final _decimalInput = FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'));

/// Campo numérico de uma métrica corporal com unidade e validação.
class MetricField extends StatelessWidget {
  const MetricField({
    required this.metric,
    required this.controller,
    this.required = false,
    super.key,
  });

  final BodyMetric metric;
  final TextEditingController controller;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: Key('metric_${metric.name}'),
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [_decimalInput],
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: required ? '${metric.label} *' : metric.label,
        suffixText: metric.unit,
      ),
      validator: (value) => Validators.decimalRange(
        value,
        min: metric.min,
        max: metric.max,
        optional: !required,
        unit: metric.unit,
      ),
    );
  }
}

/// Peso, gordura e medidas opcionais (agrupadas em seção expansível).
class MeasurementFields extends StatelessWidget {
  const MeasurementFields({required this.controllers, super.key});

  final MeasurementControllers controllers;

  @override
  Widget build(BuildContext context) {
    final metrics = BodyMetric.circumferences;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MetricField(
          metric: BodyMetric.weight,
          controller: controllers[BodyMetric.weight],
          required: true,
        ),
        const SizedBox(height: 16),
        MetricField(
          metric: BodyMetric.bodyFat,
          controller: controllers[BodyMetric.bodyFat],
        ),
        const SizedBox(height: 8),
        Card(
          child: ExpansionTile(
            initiallyExpanded: controllers.hasAnyCircumference,
            leading: const Icon(Icons.straighten),
            title: const Text('Medidas corporais (opcional)'),
            subtitle: const Text('Em centímetros'),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              for (var i = 0; i < metrics.length; i += 2)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: MetricField(
                          metric: metrics[i],
                          controller: controllers[metrics[i]],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: i + 1 < metrics.length
                            ? MetricField(
                                metric: metrics[i + 1],
                                controller: controllers[metrics[i + 1]],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
