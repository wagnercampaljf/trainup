import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:trainup/core/theme/app_theme.dart';

/// Razão de contraste WCAG 2.x entre duas cores.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final (hi, lo) = la > lb ? (la, lb) : (lb, la);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  for (final brightness in Brightness.values) {
    group('tema ${brightness.name}', () {
      final s = AppTheme.colorScheme(brightness);
      final card = s.surfaceContainerLow;
      // Linha de série concluída: verde translúcido sobre o card.
      final completedRow = Color.alphaBlend(
        s.tertiaryContainer.withValues(alpha: .45),
        card,
      );

      // Texto: WCAG AA 4,5:1. Componentes/gráficos: 3:1 (critério 1.4.11).
      final text = <String, (Color, Color)>{
        'texto sobre botão primário': (s.onPrimary, s.primary),
        'link/botão de texto primário': (s.primary, s.surface),
        'texto em container primário': (
          s.onPrimaryContainer,
          s.primaryContainer,
        ),
        'texto sobre verde (descanso concluído)': (s.onTertiary, s.tertiary),
        'texto em container verde (recorde)': (
          s.onTertiaryContainer,
          s.tertiaryContainer,
        ),
        'texto em série concluída': (s.onSurface, completedRow),
        'texto principal': (s.onSurface, s.surface),
        'texto secundário em card': (s.onSurfaceVariant, card),
        'erro sobre fundo': (s.error, s.surface),
        'texto sobre erro (excluir)': (s.onError, s.error),
        'chips/indicador': (s.onSecondaryContainer, s.secondaryContainer),
      };
      final components = <String, (Color, Color)>{
        'linha do gráfico / borda da próxima série': (s.primary, card),
        'botão de série concluída / barra de progresso': (s.tertiary, card),
        'contorno do botão de série pendente': (s.outline, card),
      };

      for (final entry in text.entries) {
        test('${entry.key} ≥ 4,5:1', () {
          final (fg, bg) = entry.value;
          expect(contrast(fg, bg), greaterThanOrEqualTo(4.5));
        });
      }
      for (final entry in components.entries) {
        test('${entry.key} ≥ 3:1', () {
          final (fg, bg) = entry.value;
          expect(contrast(fg, bg), greaterThanOrEqualTo(3));
        });
      }
    });
  }

  test('papéis com significado fixo', () {
    expect(AppTheme.colorScheme(Brightness.light).primary, AppColors.brandBlue);
    expect(
      AppTheme.colorScheme(Brightness.dark).primary,
      AppColors.brandBlueOnDark,
    );
    // Fundo escuro "quase preto", nunca preto puro.
    final darkSurface = AppTheme.colorScheme(Brightness.dark).surface;
    expect(darkSurface, isNot(const Color(0xFF000000)));
    expect(darkSurface.computeLuminance(), lessThan(0.02));
  });
}
