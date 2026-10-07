import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/chart_point.dart';

/// Gráfico de linha de evolução (X = data, Y = valor). Série única: sem
/// legenda (o título da tela nomeia a métrica); toque mostra data e valor.
class ProgressChart extends StatelessWidget {
  const ProgressChart({
    required this.points,
    required this.unit,
    this.height = 240,
    super.key,
  });

  final List<ChartPoint> points;
  final String unit;
  final double height;

  static const _day = Duration.millisecondsPerDay;

  /// Acima disso os marcadores se sobrepõem e só custam desempenho; a linha
  /// e o toque (tooltip) continuam disponíveis.
  static const maxPointsWithDots = 60;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('Sem dados para exibir.')),
      );
    }
    final colors = context.colors;
    final first = points.first.date;
    double x(DateTime d) => d.difference(first).inMilliseconds / _day;

    final spots = [for (final p in points) FlSpot(x(p.date), p.value)];
    final values = points.map((p) => p.value);
    final minY = values.reduce(math.min);
    final maxY = values.reduce(math.max);
    final pad = maxY == minY ? math.max(1.0, maxY * .1) : (maxY - minY) * .15;
    final maxX = spots.last.x == 0 ? 1.0 : spots.last.x;
    final labelStyle = context.text.labelSmall?.copyWith(
      color: colors.onSurfaceVariant,
    );

    return Semantics(
      label:
          'Gráfico de ${points.length} registros, de '
          '${formatDecimal(points.first.value)} a '
          '${formatDecimal(points.last.value)} $unit',
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.only(right: 16, top: 8),
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: maxX,
              minY: math.max(0, minY - pad),
              maxY: maxY + pad,
              gridData: FlGridData(
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: colors.outlineVariant.withValues(alpha: .5),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text(
                        formatDecimal(value, maxDecimals: 1),
                        style: labelStyle,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: math.max(1, maxX / 4),
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text(
                        formatShortDate(
                          first.add(
                            Duration(milliseconds: (value * _day).round()),
                          ),
                        ),
                        style: labelStyle,
                      ),
                    ),
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => colors.inverseSurface,
                  getTooltipItems: (spots) => [
                    for (final spot in spots)
                      LineTooltipItem(
                        '${formatDate(points[spot.spotIndex].date)}\n'
                        '${formatDecimal(spot.y)} $unit',
                        TextStyle(
                          color: colors.onInverseSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  color: colors.primary,
                  barWidth: 2,
                  isCurved: false,
                  dotData: FlDotData(
                    show: points.length <= maxPointsWithDots,
                    getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                      radius: 4,
                      color: colors.primary,
                      strokeWidth: 2,
                      strokeColor: colors.surface,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: colors.primary.withValues(alpha: .08),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
