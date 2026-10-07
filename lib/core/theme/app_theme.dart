import 'package:material_ui/material_ui.dart';

import '../../features/settings/domain/app_preferences.dart';

/// Cores da marca, escolhidas a partir de pesquisa de psicologia das cores e
/// acessibilidade (detalhes em `README.md`, seção "Cores").
abstract final class AppColors {
  /// Azul elétrico: ações principais, foco e confiança (modo claro).
  static const brandBlue = Color(0xFF2563EB);

  /// Azul da marca suavizado para fundos escuros (evita "vibração" óptica e
  /// mantém contraste AA com o texto sobre ele).
  static const brandBlueOnDark = Color(0xFF8AB4FF);

  /// Verde de progresso: séries concluídas, descanso concluído e conquistas.
  static const progressGreen = Color(0xFF22C55E);
}

/// Tema Material 3 do aplicativo (claro e escuro).
abstract final class AppTheme {
  /// Altura mínima de botões principais (uso com uma mão, durante o treino).
  static const largeButtonHeight = 56.0;

  static final ThemeData _light = _build(Brightness.light);
  static final ThemeData _dark = _build(Brightness.dark);

  static ThemeData light() => _light;

  static ThemeData dark() => _dark;

  /// Esquema de cores do app.
  ///
  /// - Base (superfícies neutras frias, containers suaves, erro): Material 3
  ///   `tonalSpot` a partir do azul da marca.
  /// - Primária: azul vivo da marca (no escuro, a versão suavizada).
  /// - Terciária: verde de progresso em tons vivos (`fidelity`), com
  ///   containers suaves. Vermelho fica reservado para erros.
  static ColorScheme colorScheme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.brandBlue,
      brightness: brightness,
    );
    final blueVivid = ColorScheme.fromSeed(
      seedColor: AppColors.brandBlue,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );
    final greenVivid = ColorScheme.fromSeed(
      seedColor: AppColors.progressGreen,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );
    final greenSoft = ColorScheme.fromSeed(
      seedColor: AppColors.progressGreen,
      brightness: brightness,
    );
    final primary = dark ? AppColors.brandBlueOnDark : AppColors.brandBlue;
    return base.copyWith(
      primary: primary,
      onPrimary: blueVivid.onPrimary,
      surfaceTint: primary,
      tertiary: greenVivid.primary,
      onTertiary: greenVivid.onPrimary,
      tertiaryContainer: greenSoft.primaryContainer,
      onTertiaryContainer: greenSoft.onPrimaryContainer,
      tertiaryFixed: greenSoft.primaryFixed,
      tertiaryFixedDim: greenSoft.primaryFixedDim,
      onTertiaryFixed: greenSoft.onPrimaryFixed,
      onTertiaryFixedVariant: greenSoft.onPrimaryFixedVariant,
    );
  }

  static ThemeData _build(Brightness brightness) {
    final scheme = colorScheme(brightness);
    // Tipografia padrão da plataforma para derivar o estilo dos botões.
    final textTheme = ThemeData(
      colorScheme: scheme,
      brightness: brightness,
    ).textTheme;
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );
    return ThemeData(
      colorScheme: scheme,
      brightness: brightness,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        scrolledUnderElevation: 2,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .5)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: buttonShape,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: buttonShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: .4),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: scheme.primaryContainer,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      listTileTheme: const ListTileThemeData(minVerticalPadding: 10),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

extension ThemePreferenceMode on ThemePreference {
  ThemeMode get themeMode => switch (this) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };
}
