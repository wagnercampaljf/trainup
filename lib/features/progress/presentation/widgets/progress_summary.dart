import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../domain/progress_calculations.dart';

/// Inicial / atual / diferença / evolução % de uma série.
class ProgressSummaryTiles extends StatelessWidget {
  const ProgressSummaryTiles({
    required this.summary,
    required this.unit,
    this.showMax = false,
    super.key,
  });

  final ProgressSummary summary;
  final String unit;
  final bool showMax;

  String _v(double value) => '${formatDecimal(value)} $unit';

  @override
  Widget build(BuildContext context) {
    final percent = summary.percent;
    return StatGrid(
      children: [
        StatTile(label: 'Inicial', value: _v(summary.initial)),
        StatTile(label: 'Atual', value: _v(summary.current)),
        if (showMax) StatTile(label: 'Maior', value: _v(summary.max)),
        StatTile(
          label: 'Diferença',
          value: '${formatSigned(summary.absoluteChange)} $unit',
        ),
        StatTile(
          label: 'Evolução',
          value: percent == null
              ? '—'
              : '${formatSigned(percent, maxDecimals: 1)}%',
        ),
      ],
    );
  }
}
