import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:trainup/core/theme/app_theme.dart';
import 'package:trainup/features/progress/domain/chart_point.dart';
import 'package:trainup/features/progress/presentation/widgets/progress_chart.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));
  for (final dark in [false, true]) {
    for (final count in [0, 1, 2, 1000]) {
      testWidgets(
        'gráfico $count registros em tema ${dark ? 'escuro' : 'claro'}',
        (tester) async {
          final points = [
            for (var i = 0; i < count; i++)
              ChartPoint(
                DateTime(2026, 1, 1).add(Duration(days: count == 2 ? 0 : i)),
                95.2 - i % 10,
              ),
          ];
          await tester.pumpWidget(
            MaterialApp(
              theme: dark ? AppTheme.dark() : AppTheme.light(),
              home: Scaffold(
                body: ProgressChart(points: points, unit: 'kg'),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          if (count == 0) {
            expect(find.text('Sem dados para exibir.'), findsOneWidget);
          }
        },
      );
    }
  }
}
