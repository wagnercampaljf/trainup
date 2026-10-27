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

/// Espaçamentos (múltiplos de 4). Use estes valores em vez de números soltos.
abstract final class AppSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// Margem lateral das telas.
  static const page = 16.0;

  /// Espaço livre no fim das listas: o conteúdo pode rolar para fora de
  /// baixo do temporizador flutuante e das ações fixas.
  static const listBottom = 120.0;
}

/// Raios de canto.
abstract final class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
}

/// Durações de animação. [of] respeita "remover animações" do sistema.
abstract final class AppMotion {
  static const fast = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 250);

  static Duration of(BuildContext context, Duration duration) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false
      ? Duration.zero
      : duration;
}

/// Família tipográfica de títulos e números (Roboto Condensed Bold, licença
/// Apache 2.0, incluída em `assets/fonts`). O corpo usa a fonte do sistema.
const displayFontFamily = 'RobotoCondensed';

extension NumericText on TextStyle {
  /// Algarismos de largura fixa: números alinham e não "pulam" ao mudar.
  TextStyle get tabular =>
      copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
}

/// Tema Material 3 do aplicativo (claro e escuro).
abstract final class AppTheme {
  /// Altura mínima de botões principais (uso com uma mão, durante o treino).
  static const largeButtonHeight = 56.0;

  static final ThemeData _light = _build(Brightness.light);
  static final ThemeData _dark = _build(Brightness.dark);

  static ThemeData light() => _light;

  static ThemeData dark() => _dark;

  /// Fundo dos cartões (um nível acima do fundo da tela).
  static Color cardColor(ColorScheme scheme) =>
      scheme.brightness == Brightness.light
      ? scheme.surfaceContainerLowest
      : scheme.surfaceContainerLow;

  /// Esquema de cores do app.
  ///
  /// - Neutros próprios, levemente frios (cinza-grafite), sem o tom lilás
  ///   do `fromSeed`: fundo da tela < cartão < campos/trilhas.
  /// - Containers e erro: Material 3 `tonalSpot` a partir do azul da marca.
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
    final neutrals = dark ? _darkNeutrals : _lightNeutrals;
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
      surface: neutrals[0],
      surfaceContainerLowest: neutrals[1],
      surfaceContainerLow: neutrals[2],
      surfaceContainer: neutrals[3],
      surfaceContainerHigh: neutrals[4],
      surfaceContainerHighest: neutrals[5],
      onSurface: neutrals[6],
      onSurfaceVariant: neutrals[7],
      outline: neutrals[8],
      outlineVariant: neutrals[9],
    );
  }

  // surface, lowest, low, container, high, highest, onSurface,
  // onSurfaceVariant, outline, outlineVariant.
  static const _lightNeutrals = [
    Color(0xFFF4F6F8),
    Color(0xFFFFFFFF),
    Color(0xFFEEF1F4),
    Color(0xFFE8EBEF),
    Color(0xFFE2E6EB),
    Color(0xFFDADFE5),
    Color(0xFF13171C),
    Color(0xFF4A525E),
    Color(0xFF6C7480),
    Color(0xFFD3D8DF),
  ];
  static const _darkNeutrals = [
    Color(0xFF0E1115),
    Color(0xFF0A0C0F),
    Color(0xFF171B20),
    Color(0xFF1C2127),
    Color(0xFF242A31),
    Color(0xFF2D343C),
    Color(0xFFE7EAEE),
    Color(0xFFA9B2BD),
    Color(0xFF7F8995),
    Color(0xFF353D46),
  ];

  /// Escala tipográfica: títulos e números em Roboto Condensed Bold;
  /// textos corridos na fonte do sistema, em dois pesos (400 e 600).
  static TextTheme _textTheme(TextTheme base, ColorScheme scheme) {
    TextStyle display(TextStyle? s, double size, {double height = 1.1}) =>
        (s ?? const TextStyle()).copyWith(
          fontFamily: displayFontFamily,
          fontSize: size,
          height: height,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          fontFeatures: const [FontFeature.tabularFigures()],
        );
    TextStyle strong(TextStyle? s, double size, {double? letterSpacing}) =>
        (s ?? const TextStyle()).copyWith(
          fontSize: size,
          fontWeight: FontWeight.w600,
          letterSpacing: letterSpacing,
        );
    return base.copyWith(
      displayLarge: display(base.displayLarge, 56),
      displayMedium: display(base.displayMedium, 44),
      displaySmall: display(base.displaySmall, 36),
      headlineLarge: display(base.headlineLarge, 32, height: 1.15),
      headlineMedium: display(base.headlineMedium, 28, height: 1.15),
      headlineSmall: display(base.headlineSmall, 24, height: 1.2),
      titleLarge: display(base.titleLarge, 21, height: 1.2),
      titleMedium: strong(base.titleMedium, 16, letterSpacing: 0),
      titleSmall: strong(base.titleSmall, 14, letterSpacing: 0),
      labelLarge: strong(base.labelLarge, 14, letterSpacing: .1),
      labelMedium: strong(base.labelMedium, 12, letterSpacing: .2),
      labelSmall: strong(base.labelSmall, 11, letterSpacing: .3),
      bodySmall: base.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
    );
  }

  static ThemeData _build(Brightness brightness) {
    final scheme = colorScheme(brightness);
    final textTheme = _textTheme(
      ThemeData(colorScheme: scheme, brightness: brightness).textTheme,
      scheme,
    );
    final card = cardColor(scheme);
    final dark = brightness == Brightness.dark;
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md + 2),
    );
    final buttonText = textTheme.labelLarge?.copyWith(fontSize: 16);
    return ThemeData(
      colorScheme: scheme,
      brightness: brightness,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withValues(alpha: dark ? .6 : .18),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontSize: 22,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: card,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: dark ? .7 : 1),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: buttonShape,
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.outline),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        extendedTextStyle: buttonText,
        shape: buttonShape,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: textTheme.titleSmall,
        unselectedLabelStyle: textTheme.titleSmall,
        dividerColor: scheme.outlineVariant,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm + 2),
        ),
        side: BorderSide(color: scheme.outlineVariant),
        labelStyle: textTheme.labelLarge,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          minimumSize: const Size(48, 48),
          selectedBackgroundColor: scheme.primaryContainer,
          selectedForegroundColor: scheme.onPrimaryContainer,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      listTileTheme: ListTileThemeData(
        minVerticalPadding: 10,
        iconColor: scheme.onSurfaceVariant,
        titleTextStyle: textTheme.bodyLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        linearTrackColor: scheme.surfaceContainerHighest,
        linearMinHeight: 6,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: scheme.onSurface,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}

/// Estilos de botão com papel fixo.
abstract final class AppButtons {
  /// Ação destrutiva confirmada (excluir, descartar).
  static ButtonStyle destructive(ColorScheme scheme) => FilledButton.styleFrom(
    backgroundColor: scheme.error,
    foregroundColor: scheme.onError,
  );

  /// Ação destrutiva em menus/listas: texto vermelho, sem preenchimento.
  static ButtonStyle destructiveText(ColorScheme scheme) =>
      TextButton.styleFrom(foregroundColor: scheme.error);
}

extension ThemePreferenceMode on ThemePreference {
  ThemeMode get themeMode => switch (this) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };
}
