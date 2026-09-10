import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../data/models/climate_period.dart';
import '../../data/models/indicator.dart';

/// Visor gráfico del escenario.
///
/// No es un adorno: cada elemento del paisaje está enlazado a un indicador
/// (cielo y bruma con temperatura y emisiones, franja de agua con la
/// disponibilidad hídrica, vegetación con la cobertura vegetal y marcas de
/// riesgo con la vulnerabilidad). El texto acompaña siempre al gráfico.
class ScenarioVisual extends StatelessWidget {
  const ScenarioVisual({
    super.key,
    required this.state,
    required this.period,
    required this.territory,
    this.height = 186,
  });

  final ClimateState state;
  final ClimatePeriod period;
  final String territory;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scheme = context.scheme;

    final temperature = metaOf(ClimateIndicator.temperatura)
        .normalize(state.get(ClimateIndicator.temperatura));
    final emissions = metaOf(ClimateIndicator.emisiones)
        .normalize(state.get(ClimateIndicator.emisiones));
    final water = metaOf(ClimateIndicator.agua)
        .normalize(state.get(ClimateIndicator.agua));
    final vegetation = metaOf(ClimateIndicator.vegetacion)
        .normalize(state.get(ClimateIndicator.vegetacion));
    final vulnerability = metaOf(ClimateIndicator.vulnerabilidad)
        .normalize(state.get(ClimateIndicator.vulnerabilidad));

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CustomPaint(
              painter: _TerritoryPainter(
                temperature: temperature,
                emissions: emissions,
                water: water,
                vegetation: vegetation,
                vulnerability: vulnerability,
                palette: palette,
              ),
            ),
            Positioned(
              left: 12,
              top: 10,
              child: _GlassLabel(
                child: Text(
                  '${period.label} · ${period.referenceYear}',
                  style: context.texts.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 12,
              top: 10,
              child: _GlassLabel(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.thermostat_outlined,
                        size: 13, color: palette.temperatura),
                    const SizedBox(width: 4),
                    Text(
                      metaOf(ClimateIndicator.temperatura)
                          .formatWithUnit(state.get(ClimateIndicator.temperatura)),
                      style: context.texts.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: _GlassLabel(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        territory,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.labelSmall?.copyWith(
                          color: scheme.onSurface,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassLabel extends StatelessWidget {
  const _GlassLabel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: withOpacityValue(context.palette.surfaceElevated, 0.88),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.scheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class _TerritoryPainter extends CustomPainter {
  _TerritoryPainter({
    required this.temperature,
    required this.emissions,
    required this.water,
    required this.vegetation,
    required this.vulnerability,
    required this.palette,
  });

  final double temperature;
  final double emissions;
  final double water;
  final double vegetation;
  final double vulnerability;
  final AppPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final skyColor =
        Color.lerp(palette.skyCalm, palette.skyHot, temperature.clamp(0.0, 1.0))!;
    final skyRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      skyRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            skyColor,
            Color.lerp(skyColor, palette.surfaceElevated, 0.35)!,
          ],
        ).createShader(skyRect),
    );

    // Sol / disco solar.
    final sunCenter = Offset(size.width * 0.80, size.height * 0.26);
    canvas.drawCircle(
      sunCenter,
      16 + 6 * temperature,
      Paint()..color = withOpacityValue(palette.skyHot, 0.85),
    );
    canvas.drawCircle(
      sunCenter,
      26 + 8 * temperature,
      Paint()..color = withOpacityValue(palette.skyHot, 0.25),
    );

    // Bruma asociada a las emisiones.
    final hazePaint = Paint()
      ..color = withOpacityValue(palette.haze, 0.15 + 0.45 * emissions);
    for (var i = 0; i < 3; i++) {
      final y = size.height * (0.18 + i * 0.09);
      final rect = Rect.fromLTWH(
        -20 + i * 26,
        y,
        size.width * (0.55 + 0.12 * i),
        10.0 + 4 * emissions,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(9)),
        hazePaint,
      );
    }

    final groundTop = size.height * 0.56;
    final landColor =
        Color.lerp(palette.landDry, palette.land, vegetation.clamp(0.0, 1.0))!;

    // Colinas de fondo.
    final backHill = Path()
      ..moveTo(0, groundTop + 12)
      ..quadraticBezierTo(size.width * 0.22, groundTop - 26, size.width * 0.46,
          groundTop + 6)
      ..quadraticBezierTo(
          size.width * 0.72, groundTop - 30, size.width, groundTop + 4)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      backHill,
      Paint()..color = Color.lerp(landColor, palette.skyCalm, 0.35)!,
    );

    // Terreno principal.
    final ground = Path()
      ..moveTo(0, groundTop + 26)
      ..quadraticBezierTo(size.width * 0.35, groundTop + 6, size.width * 0.66,
          groundTop + 24)
      ..quadraticBezierTo(
          size.width * 0.86, groundTop + 34, size.width, groundTop + 18)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(ground, Paint()..color = landColor);

    // Vegetación: número de árboles proporcional a la cobertura.
    final treeCount = (vegetation * 7).round();
    final treePaint = Paint()
      ..color = Color.lerp(palette.land, Colors.black, 0.22)!;
    for (var i = 0; i < treeCount; i++) {
      final x = size.width * (0.08 + 0.115 * i);
      final baseY = groundTop + 34 + (i.isEven ? 4 : 10);
      canvas.drawRect(
        Rect.fromLTWH(x - 1.4, baseY - 8, 2.8, 9),
        treePaint,
      );
      canvas.drawCircle(Offset(x, baseY - 12), 6.5, treePaint);
    }

    // Franja de agua: su altura representa la disponibilidad hídrica.
    final waterHeight = 10 + 26 * water;
    final waterRect = Rect.fromLTWH(
      0,
      size.height - waterHeight,
      size.width,
      waterHeight,
    );
    canvas.drawRect(waterRect, Paint()..color = palette.water);
    final wavePaint = Paint()
      ..color = withOpacityValue(Colors.white, 0.22)
      ..strokeWidth = 1.6;
    for (var i = 0; i < 3; i++) {
      final y = size.height - waterHeight + 5 + i * 7;
      if (y > size.height - 2) break;
      canvas.drawLine(
        Offset(size.width * (0.08 + i * 0.2), y),
        Offset(size.width * (0.30 + i * 0.2), y),
        wavePaint,
      );
    }

    // Núcleo urbano.
    final cityPaint = Paint()..color = palette.city;
    final buildings = <List<double>>[
      <double>[0.60, 34],
      <double>[0.665, 48],
      <double>[0.73, 28],
      <double>[0.785, 40],
      <double>[0.85, 24],
    ];
    for (final b in buildings) {
      final x = size.width * b[0];
      final h = b[1];
      canvas.drawRect(
        Rect.fromLTWH(x, size.height - waterHeight - h, 26, h),
        cityPaint,
      );
    }

    // Marcas de vulnerabilidad sobre la zona urbana.
    final riskCount = (vulnerability * 4).round();
    final riskPaint = Paint()..color = palette.negative;
    for (var i = 0; i < riskCount; i++) {
      final x = size.width * (0.615 + i * 0.062);
      final y = size.height - waterHeight - 58;
      final path = Path()
        ..moveTo(x, y - 7)
        ..lineTo(x + 6, y + 5)
        ..lineTo(x - 6, y + 5)
        ..close();
      canvas.drawPath(path, riskPaint);
    }

    // Línea de horizonte para separar cielo y territorio.
    canvas.drawLine(
      Offset(0, groundTop + 26),
      Offset(size.width, groundTop + 18),
      Paint()
        ..color = withOpacityValue(Colors.black, 0.10)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _TerritoryPainter oldDelegate) {
    return oldDelegate.temperature != temperature ||
        oldDelegate.emissions != emissions ||
        oldDelegate.water != water ||
        oldDelegate.vegetation != vegetation ||
        oldDelegate.vulnerability != vulnerability ||
        oldDelegate.palette != palette;
  }
}

/// Leyenda textual del visor: garantiza que la información no dependa solo
/// de la representación gráfica.
class ScenarioVisualLegend extends StatelessWidget {
  const ScenarioVisualLegend({super.key, required this.state});

  final ClimateState state;

  @override
  Widget build(BuildContext context) {
    final items = <ClimateIndicator>[
      ClimateIndicator.emisiones,
      ClimateIndicator.agua,
      ClimateIndicator.vegetacion,
      ClimateIndicator.vulnerabilidad,
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: <Widget>[
        for (final indicator in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                metaOf(indicator).icon,
                size: 13,
                color: context.palette.forIndicator(indicator),
              ),
              const SizedBox(width: 4),
              Text(
                '${metaOf(indicator).shortLabel} '
                '${metaOf(indicator).format(state.get(indicator))}',
                style: context.texts.labelSmall?.copyWith(
                  color: context.palette.neutral,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// Pequeño círculo de progreso textual usado en resúmenes.
class RatioBadge extends StatelessWidget {
  const RatioBadge({
    super.key,
    required this.value,
    required this.label,
    this.color,
  });

  final double value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final base = color ?? context.scheme.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 52,
          height: 52,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SizedBox(
                width: 52,
                height: 52,
                child: CircularProgressIndicator(
                  value: value.clamp(0.0, 1.0),
                  strokeWidth: 5,
                  backgroundColor: context.palette.surfaceSunken,
                  valueColor: AlwaysStoppedAnimation<Color>(base),
                ),
              ),
              Text(
                '${(math.min(value, 1) * 100).round()}%',
                style: context.texts.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: context.scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 86,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.texts.labelSmall
                ?.copyWith(color: context.palette.neutral),
          ),
        ),
      ],
    );
  }
}
