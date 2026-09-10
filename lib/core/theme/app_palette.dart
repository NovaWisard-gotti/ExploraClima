import 'package:flutter/material.dart';

import '../../data/models/indicator.dart';

/// Paleta semantica de ExploraClima.
///
/// Se define de forma independiente para modo claro y modo oscuro: el modo
/// oscuro NO es una inversion del modo claro.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.emisiones,
    required this.temperatura,
    required this.agua,
    required this.vegetacion,
    required this.presion,
    required this.energia,
    required this.vulnerabilidad,
    required this.positive,
    required this.negative,
    required this.neutral,
    required this.gridLine,
    required this.surfaceElevated,
    required this.surfaceSunken,
    required this.timelineTrack,
    required this.timelineActive,
    required this.skyCalm,
    required this.skyHot,
    required this.land,
    required this.landDry,
    required this.water,
    required this.city,
    required this.haze,
    required this.seriesA,
    required this.seriesB,
  });

  final Color emisiones;
  final Color temperatura;
  final Color agua;
  final Color vegetacion;
  final Color presion;
  final Color energia;
  final Color vulnerabilidad;

  final Color positive;
  final Color negative;
  final Color neutral;

  final Color gridLine;
  final Color surfaceElevated;
  final Color surfaceSunken;
  final Color timelineTrack;
  final Color timelineActive;

  final Color skyCalm;
  final Color skyHot;
  final Color land;
  final Color landDry;
  final Color water;
  final Color city;
  final Color haze;

  final Color seriesA;
  final Color seriesB;

  Color forIndicator(ClimateIndicator id) {
    switch (id) {
      case ClimateIndicator.emisiones:
        return emisiones;
      case ClimateIndicator.temperatura:
        return temperatura;
      case ClimateIndicator.agua:
        return agua;
      case ClimateIndicator.vegetacion:
        return vegetacion;
      case ClimateIndicator.presion:
        return presion;
      case ClimateIndicator.energia:
        return energia;
      case ClimateIndicator.vulnerabilidad:
        return vulnerabilidad;
    }
  }

  static const AppPalette light = AppPalette(
    emisiones: Color(0xFF4B44B5),
    temperatura: Color(0xFFC24A30),
    agua: Color(0xFF1C6B87),
    vegetacion: Color(0xFF35714A),
    presion: Color(0xFF7A4A92),
    energia: Color(0xFF9A6A05),
    vulnerabilidad: Color(0xFF4A5568),
    positive: Color(0xFF2C7A57),
    negative: Color(0xFFB3452C),
    neutral: Color(0xFF5B6478),
    gridLine: Color(0xFFD9D2C3),
    surfaceElevated: Color(0xFFFFFDF8),
    surfaceSunken: Color(0xFFEFE9DC),
    timelineTrack: Color(0xFFCFC8B8),
    timelineActive: Color(0xFF2F3E9E),
    skyCalm: Color(0xFFC3D4E8),
    skyHot: Color(0xFFE9BCA8),
    land: Color(0xFF6E8F5F),
    landDry: Color(0xFFB79E72),
    water: Color(0xFF2E7C9E),
    city: Color(0xFF5E6880),
    haze: Color(0xFFB9B2A4),
    seriesA: Color(0xFF2F3E9E),
    seriesB: Color(0xFFC85A3D),
  );

  static const AppPalette dark = AppPalette(
    emisiones: Color(0xFF9FA6FF),
    temperatura: Color(0xFFFF9B84),
    agua: Color(0xFF6FC4E0),
    vegetacion: Color(0xFF7FD394),
    presion: Color(0xFFC79BE0),
    energia: Color(0xFFF0C05A),
    vulnerabilidad: Color(0xFFAEB8CC),
    positive: Color(0xFF7FD3A8),
    negative: Color(0xFFFF9478),
    neutral: Color(0xFF98A2B8),
    gridLine: Color(0xFF27334D),
    surfaceElevated: Color(0xFF17233C),
    surfaceSunken: Color(0xFF0C1526),
    timelineTrack: Color(0xFF31405F),
    timelineActive: Color(0xFF9FB0FF),
    skyCalm: Color(0xFF1D2C4C),
    skyHot: Color(0xFF4B3049),
    land: Color(0xFF3A6047),
    landDry: Color(0xFF6A5B3E),
    water: Color(0xFF2A6A8C),
    city: Color(0xFF46536E),
    haze: Color(0xFF3A4257),
    seriesA: Color(0xFF9FB0FF),
    seriesB: Color(0xFFFF9B84),
  );

  @override
  AppPalette copyWith({
    Color? emisiones,
    Color? temperatura,
    Color? agua,
    Color? vegetacion,
    Color? presion,
    Color? energia,
    Color? vulnerabilidad,
    Color? positive,
    Color? negative,
    Color? neutral,
    Color? gridLine,
    Color? surfaceElevated,
    Color? surfaceSunken,
    Color? timelineTrack,
    Color? timelineActive,
    Color? skyCalm,
    Color? skyHot,
    Color? land,
    Color? landDry,
    Color? water,
    Color? city,
    Color? haze,
    Color? seriesA,
    Color? seriesB,
  }) {
    return AppPalette(
      emisiones: emisiones ?? this.emisiones,
      temperatura: temperatura ?? this.temperatura,
      agua: agua ?? this.agua,
      vegetacion: vegetacion ?? this.vegetacion,
      presion: presion ?? this.presion,
      energia: energia ?? this.energia,
      vulnerabilidad: vulnerabilidad ?? this.vulnerabilidad,
      positive: positive ?? this.positive,
      negative: negative ?? this.negative,
      neutral: neutral ?? this.neutral,
      gridLine: gridLine ?? this.gridLine,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      timelineTrack: timelineTrack ?? this.timelineTrack,
      timelineActive: timelineActive ?? this.timelineActive,
      skyCalm: skyCalm ?? this.skyCalm,
      skyHot: skyHot ?? this.skyHot,
      land: land ?? this.land,
      landDry: landDry ?? this.landDry,
      water: water ?? this.water,
      city: city ?? this.city,
      haze: haze ?? this.haze,
      seriesA: seriesA ?? this.seriesA,
      seriesB: seriesB ?? this.seriesB,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t) ?? a;
    return AppPalette(
      emisiones: mix(emisiones, other.emisiones),
      temperatura: mix(temperatura, other.temperatura),
      agua: mix(agua, other.agua),
      vegetacion: mix(vegetacion, other.vegetacion),
      presion: mix(presion, other.presion),
      energia: mix(energia, other.energia),
      vulnerabilidad: mix(vulnerabilidad, other.vulnerabilidad),
      positive: mix(positive, other.positive),
      negative: mix(negative, other.negative),
      neutral: mix(neutral, other.neutral),
      gridLine: mix(gridLine, other.gridLine),
      surfaceElevated: mix(surfaceElevated, other.surfaceElevated),
      surfaceSunken: mix(surfaceSunken, other.surfaceSunken),
      timelineTrack: mix(timelineTrack, other.timelineTrack),
      timelineActive: mix(timelineActive, other.timelineActive),
      skyCalm: mix(skyCalm, other.skyCalm),
      skyHot: mix(skyHot, other.skyHot),
      land: mix(land, other.land),
      landDry: mix(landDry, other.landDry),
      water: mix(water, other.water),
      city: mix(city, other.city),
      haze: mix(haze, other.haze),
      seriesA: mix(seriesA, other.seriesA),
      seriesB: mix(seriesB, other.seriesB),
    );
  }
}

/// Acceso comodo a la paleta y a valores de color derivados.
extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;

  ColorScheme get scheme => Theme.of(this).colorScheme;

  TextTheme get texts => Theme.of(this).textTheme;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

/// Aplica opacidad sin usar APIs marcadas como obsoletas.
Color withOpacityValue(Color color, double opacity) =>
    color.withAlpha((opacity.clamp(0.0, 1.0) * 255).round());
