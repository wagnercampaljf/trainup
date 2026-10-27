import 'package:material_ui/material_ui.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/chart_point.dart';
import '../../domain/progress_calculations.dart';

/// Destaque de uma série: valor atual, diferença e o período comparado.
///
/// - Um registro: só o valor, com a explicação de que a comparação começa
///   no segundo.
/// - Valor inicial zero: a porcentagem não existe e isso é dito.
/// - [judge] `false` (medidas corporais): a diferença fica neutra, sem
///   verde/vermelho, pois o app não sabe se o objetivo é subir ou descer.
class ProgressHighlight extends StatelessWidget {
  const ProgressHighlight({
    required this.points,
    required this.unit,
    this.judge = true,
    this.countLabel = ('registro', 'registros'),
    super.key,
  });

  /// Pontos em ordem cronológica.
  final List<ChartPoint> points;
  final String unit;
  final bool judge;

  /// Singular e plural do que cada ponto representa ("treino"/"treinos").
  final (String, String) countLabel;

  String _v(double value) => '${formatDecimal(value)} $unit';

  @override
  Widget build(BuildContext context) {
    final summary = ProgressSummary.fromValues([
      for (final p in points) p.value,
    ]);
    if (summary == null) return const SizedBox.shrink();
    final colors = context.colors;
    final count = points.length;
    final change = summary.absoluteChange;
    final percent = summary.percent;
    final changeColor = !judge || change <= 0
        ? colors.onSurface
        : colors.onTertiaryContainer;
    final badgeColor = !judge || change <= 0
        ? colors.surfaceContainerHigh
        : colors.tertiaryContainer;
    final (one, many) = countLabel;
    final period = count == 1
        ? 'em ${formatDate(points.first.date)}'
        : '${formatShortDate(points.first.date)} → '
              '${formatShortDate(points.last.date)} · $count $many';

    return Card(
      key: const Key('progress_highlight'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Atual',
              style: context.text.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            Text(_v(summary.current), style: context.text.headlineLarge),
            const SizedBox(height: AppSpace.sm),
            if (count == 1)
              Text(
                'Primeiro $one. A comparação aparece a partir do segundo.',
                style: context.text.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              )
            else
              Wrap(
                spacing: AppSpace.sm,
                runSpacing: AppSpace.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      '${formatSigned(change)} $unit',
                      style: context.text.titleMedium?.tabular.copyWith(
                        color: changeColor,
                      ),
                    ),
                  ),
                  Text(
                    percent == null
                        ? 'sem % (início em zero)'
                        : '${formatSigned(percent, maxDecimals: 1)}%',
                    style: context.text.titleSmall?.tabular,
                  ),
                  Text('desde o início', style: context.text.bodySmall),
                ],
              ),
            const SizedBox(height: AppSpace.md),
            const Divider(),
            const SizedBox(height: AppSpace.sm),
            Wrap(
              spacing: AppSpace.xl,
              runSpacing: AppSpace.sm,
              children: [
                _Mini(label: 'Inicial', value: _v(summary.initial)),
                _Mini(label: 'Período', value: period),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: context.text.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        Text(value, style: context.text.titleSmall?.tabular),
      ],
    );
  }
}
