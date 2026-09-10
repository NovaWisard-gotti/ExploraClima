import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Identidad visual de ExploraClima: azul noche, indigo, coral suave,
/// marfil / arena clara y gris frio.
///
/// Los dos modos se disenan de forma independiente. El modo oscuro no se
/// obtiene invirtiendo el modo claro.
class AppTheme {
  const AppTheme._();

  static const Color nightBlue = Color(0xFF101C33);
  static const Color nightBlueDeep = Color(0xFF0A1424);
  static const Color indigo = Color(0xFF2F3E9E);
  static const Color indigoLight = Color(0xFF9FB0FF);
  static const Color coral = Color(0xFFE2694C);
  static const Color coralSoft = Color(0xFFFF9B84);
  static const Color ivory = Color(0xFFF7F2E8);
  static const Color sand = Color(0xFFEDE5D6);
  static const Color coolGrey = Color(0xFF6B7488);

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: indigo,
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFDDE1FA),
    onPrimaryContainer: Color(0xFF131D5A),
    secondary: Color(0xFF3F5170),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFDCE3F0),
    onSecondaryContainer: Color(0xFF1B2740),
    tertiary: coral,
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFBDDD3),
    onTertiaryContainer: Color(0xFF5A2313),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFF9DEDC),
    onErrorContainer: Color(0xFF410E0B),
    surface: ivory,
    onSurface: Color(0xFF1A2233),
    outline: Color(0xFF747C90),
    outlineVariant: Color(0xFFC9C2B4),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: nightBlue,
    onInverseSurface: Color(0xFFF1F3FA),
    inversePrimary: indigoLight,
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: indigoLight,
    onPrimary: Color(0xFF10193A),
    primaryContainer: Color(0xFF283563),
    onPrimaryContainer: Color(0xFFDDE2FF),
    secondary: Color(0xFFB9C6E4),
    onSecondary: Color(0xFF15203A),
    secondaryContainer: Color(0xFF243354),
    onSecondaryContainer: Color(0xFFDCE5F8),
    tertiary: coralSoft,
    onTertiary: Color(0xFF4A1B0D),
    tertiaryContainer: Color(0xFF6B3323),
    onTertiaryContainer: Color(0xFFFFDBD1),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF101A2E),
    onSurface: Color(0xFFE7EAF4),
    outline: Color(0xFF8791A8),
    outlineVariant: Color(0xFF3A4661),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE7EAF4),
    onInverseSurface: Color(0xFF16203A),
    inversePrimary: indigo,
  );

  static ThemeData light() => _build(_lightScheme, AppPalette.light);

  static ThemeData dark() => _build(_darkScheme, AppPalette.dark);

  static ThemeData _build(ColorScheme scheme, AppPalette palette) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: scheme.brightness,
    );

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      extensions: <ThemeExtension<dynamic>>[palette],
      textTheme: base.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      iconTheme: IconThemeData(color: scheme.onSurface),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        elevation: 3,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => base.textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurface,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurface,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.outline),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surfaceSunken,
        selectedColor: scheme.primaryContainer,
        side: BorderSide(color: scheme.outlineVariant),
        labelStyle: base.textTheme.labelLarge?.copyWith(color: scheme.onSurface),
        secondaryLabelStyle:
            base.textTheme.labelLarge?.copyWith(color: scheme.onPrimaryContainer),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurface,
        textColor: scheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        actionTextColor: scheme.inversePrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceElevated,
        hintStyle: TextStyle(color: palette.neutral),
        prefixIconColor: scheme.onSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: palette.timelineTrack,
        thumbColor: scheme.primary,
        overlayColor: withOpacityValue(scheme.primary, 0.12),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: palette.timelineTrack,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? scheme.onPrimary
                : scheme.outline),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? scheme.primary
                : palette.surfaceSunken),
      ),
    );
  }
}
