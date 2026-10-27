import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:trainup/core/theme/app_theme.dart';
import 'package:trainup/core/utils/formatters.dart';
import 'package:trainup/features/progress/domain/chart_point.dart';
import 'package:trainup/features/progress/presentation/widgets/progress_summary.dart';

void main() {
  setUpAll(() => initializeDateFormatting(appLocale));

  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );

  final d1 = DateTime(2026, 9, 1);
  final d2 = DateTime(2026, 10, 1);

  testWidgets('um registro: valor atual e explicação, sem diferença', (
    tester,
  ) async {
    await pump(
      tester,
      ProgressHighlight(
        points: [ChartPoint(d1, 40)],
        unit: 'kg',
        countLabel: const ('treino', 'treinos'),
      ),
    );
    expect(find.text('40 kg'), findsWidgets);
    expect(find.textContaining('Primeiro treino'), findsOneWidget);
    expect(find.textContaining('+'), findsNothing);
  });

  testWidgets('início em zero: diferença sem porcentagem', (tester) async {
    await pump(
      tester,
      ProgressHighlight(
        points: [ChartPoint(d1, 0), ChartPoint(d2, 10)],
        unit: 'kg',
      ),
    );
    expect(find.text('+10 kg'), findsOneWidget);
    expect(find.text('sem % (início em zero)'), findsOneWidget);
    expect(find.text('01/09 → 01/10 · 2 registros'), findsOneWidget);
  });

  testWidgets('medida corporal: queda e alta ficam neutras', (tester) async {
    for (final values in [
      [95.0, 93.0],
      [93.0, 95.0],
    ]) {
      await pump(
        tester,
        ProgressHighlight(
          points: [ChartPoint(d1, values[0]), ChartPoint(d2, values[1])],
          unit: 'kg',
          judge: false,
        ),
      );
      final scheme = AppTheme.colorScheme(Brightness.light);
      final badge = tester.widget<Text>(find.textContaining(' kg').at(1));
      expect(badge.style?.color, scheme.onSurface);
    }
  });
}
