import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../data/models/indicator.dart';

enum SeriesStyle { solid, dashed }

enum SeriesMarker { circle, square, triangle }

/// Serie de datos de un gráfico de tendencia.
class ChartSeries {
  const ChartSeries({
    required this.label,
    required this.values,
    required this.color,
    this.style = SeriesStyle.solid,
    this.marker = SeriesMarker.circle,
  });

  final String label;
  final List<double> values;
  final Color color;
  final SeriesStyle style;
  final SeriesMarker marker;
}

/// Gráfico de tendencia a lo largo de la línea temporal.
///
/// Accesibilidad: cada serie combina color, tipo de línea y marcador, y los
/// valores se muestran en texto, de modo que la lectura no depende del color.
class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.series,
    required this.xLabels,
    required this.indicator,
    this.height = 190,
    this.highlightIndex,
  });

  final List<ChartSeries> series;
  final List<String> xLabels;
  final ClimateIndicator indicator;
  final double height;
  final int? highlightIndex;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scheme = context.scheme;
    final meta = metaOf(indicator);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _TrendPainter(
              series: series,
              xLabels: xLabels,
              meta: meta,
              gridColor: palette.gridLine,
              textColor: scheme.onSurface,
              mutedColor: palette.neutral,
              highlightColor: withOpacityValue(scheme.primary, 0.14),
              highlightIndex: highlightIndex,
              textDirection: Directionality.of(context),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ChartLegend(series: series),
      ],
    );
  }
}

class ChartLegend extends StatelessWidget {
  const ChartLegend({super.key, required this.series});

  final List<ChartSeries> series;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: <Widget>[
        for (final s in series)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: 26,
                height: 12,
                child: CustomPaint(
                  painter: _LegendPainter(series: s),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                s.label,
                style: context.texts.labelSmall?.copyWith(
                  color: context.scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _LegendPainter extends CustomPainter {
  _LegendPainter({required this.series});

  final ChartSeries series;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = series.color
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    if (series.style == SeriesStyle.dashed) {
      var x = 0.0;
      while (x < size.width) {
        canvas.drawLine(Offset(x, y), Offset(math.min(x + 5, size.width), y), paint);
        x += 9;
      }
    } else {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    _paintMarker(canvas, Offset(size.width / 2, y), series.marker,
        Paint()..color = series.color, 3.6);
  }

  @override
  bool shouldRepaint(covariant _LegendPainter oldDelegate) =>
      oldDelegate.series != series;
}

void _paintMarker(
    Canvas canvas, Offset center, SeriesMarker marker, Paint paint, double r) {
  switch (marker) {
    case SeriesMarker.circle:
      canvas.drawCircle(center, r, paint);
      break;
    case SeriesMarker.square:
      canvas.drawRect(
        Rect.fromCenter(center: center, width: r * 2, height: r * 2),
        paint,
      );
      break;
    case SeriesMarker.triangle:
      final path = Path()
        ..moveTo(center.dx, center.dy - r)
        ..lineTo(center.dx + r, center.dy + r)
        ..lineTo(center.dx - r, center.dy + r)
        ..close();
      canvas.drawPath(path, paint);
      break;
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.series,
    required this.xLabels,
    required this.meta,
    required this.gridColor,
    required this.textColor,
    required this.mutedColor,
    required this.highlightColor,
    required this.highlightIndex,
    required this.textDirection,
  });

  final List<ChartSeries> series;
  final List<String> xLabels;
  final IndicatorMeta meta;
  final Color gridColor;
  final Color textColor;
  final Color mutedColor;
  final Color highlightColor;
  final int? highlightIndex;
  final TextDirection textDirection;

  static const double _left = 46;
  static const double _right = 14;
  static const double _top = 16;
  static const double _bottom = 28;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty || xLabels.isEmpty) return;

    final chartWidth = size.width - _left - _right;
    final chartHeight = size.height - _top - _bottom;
    if (chartWidth <= 0 || chartHeight <= 0) return;

    var minValue = double.infinity;
    var maxValue = -double.infinity;
    for (final s in series) {
      for (final v in s.values) {
        minValue = math.min(minValue, v);
        maxValue = math.max(maxValue, v);
      }
    }
    if (!minValue.isFinite || !maxValue.isFinite) return;
    if ((maxValue - minValue).abs() < 0.0001) {
      minValue -= 1;
      maxValue += 1;
    }
    final span = maxValue - minValue;
    minValue -= span * 0.14;
    maxValue += span * 0.14;

    double dx(int index) => _left +
        (xLabels.length == 1
            ? chartWidth / 2
            : chartWidth * index / (xLabels.length - 1));

    double dy(double value) =>
        _top + chartHeight * (1 - (value - minValue) / (maxValue - minValue));

    // Franja del periodo destacado.
    if (highlightIndex != null &&
        highlightIndex! >= 0 &&
        highlightIndex! < xLabels.length) {
      final step = xLabels.length > 1 ? chartWidth / (xLabels.length - 1) : chartWidth;
      final center = dx(highlightIndex!);
      final rect = Rect.fromLTRB(
        math.max(_left, center - step * 0.42),
        _top - 6,
        math.min(size.width - _right, center + step * 0.42),
        _top + chartHeight + 6,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(10)),
        Paint()..color = highlightColor,
      );
    }

    // Rejilla horizontal y etiquetas del eje vertical.
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final value = maxValue - (maxValue - minValue) * i / 3;
      final y = dy(value);
      canvas.drawLine(Offset(_left, y), Offset(size.width - _right, y), gridPaint);
      _text(
        canvas,
        meta.format(value),
        Offset(_left - 6, y),
        color: mutedColor,
        fontSize: 10,
        alignRight: true,
        centerVertically: true,
      );
    }

    // Etiquetas del eje horizontal.
    for (var i = 0; i < xLabels.length; i++) {
      _text(
        canvas,
        xLabels[i],
        Offset(dx(i), _top + chartHeight + 8),
        color: mutedColor,
        fontSize: 10,
        centerHorizontally: true,
      );
    }

    // Series.
    for (final s in series) {
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = 2.6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final points = <Offset>[];
      for (var i = 0; i < s.values.length && i < xLabels.length; i++) {
        points.add(Offset(dx(i), dy(s.values[i])));
      }
      if (points.length < 2) continue;

      if (s.style == SeriesStyle.dashed) {
        for (var i = 0; i < points.length - 1; i++) {
          _dashedLine(canvas, points[i], points[i + 1], paint);
        }
      } else {
        final path = Path()..moveTo(points.first.dx, points.first.dy);
        for (var i = 1; i < points.length; i++) {
          path.lineTo(points[i].dx, points[i].dy);
        }
        canvas.drawPath(path, paint);
      }

      final markerPaint = Paint()..color = s.color;
      for (final p in points) {
        _paintMarker(canvas, p, s.marker, markerPaint, 4);
      }

      // Valor final de la serie.
      _text(
        canvas,
        meta.format(s.values.last),
        Offset(points.last.dx - 2, points.last.dy - 16),
        color: textColor,
        fontSize: 11,
        bold: true,
        alignRight: true,
      );
    }
  }

  void _dashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 6.0;
    const gap = 4.0;
    final total = (b - a).distance;
    if (total == 0) return;
    final direction = (b - a) / total;
    var travelled = 0.0;
    while (travelled < total) {
      final end = math.min(travelled + dash, total);
      canvas.drawLine(
        a + direction * travelled,
        a + direction * end,
        paint,
      );
      travelled = end + gap;
    }
  }

  void _text(
    Canvas canvas,
    String value,
    Offset position, {
    required Color color,
    required double fontSize,
    bool bold = false,
    bool alignRight = false,
    bool centerHorizontally = false,
    bool centerVertically = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      textDirection: textDirection,
    )..layout();
    var dx = position.dx;
    var dy = position.dy;
    if (alignRight) dx -= painter.width;
    if (centerHorizontally) dx -= painter.width / 2;
    if (centerVertically) dy -= painter.height / 2;
    painter.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) => true;
}

/// Miniatura de tendencia usada en las tarjetas de escenario.
class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.values,
    required this.color,
    this.height = 38,
  });

  final List<double> values;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(
          values: values,
          color: color,
          fill: withOpacityValue(color, 0.16),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.color,
    required this.fill,
  });

  final List<double> values;
  final Color color;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    var minValue = values.reduce(math.min);
    var maxValue = values.reduce(math.max);
    if ((maxValue - minValue).abs() < 0.0001) {
      minValue -= 1;
      maxValue += 1;
    }
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height *
          (1 - (values[i] - minValue) / (maxValue - minValue)) *
          0.86 +
          size.height * 0.07;
      points.add(Offset(x, y));
    }

    final area = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      area.lineTo(p.dx, p.dy);
    }
    area.lineTo(points.last.dx, size.height);
    area.close();
    canvas.drawPath(area, Paint()..color = fill);

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      line.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(points.last, 3, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

/// Barra comparativa individual. La serie B se dibuja con trama para que la
/// diferencia no dependa únicamente del color.
class ComparisonBar extends StatelessWidget {
  const ComparisonBar({
    super.key,
    required this.fraction,
    required this.color,
    required this.striped,
    this.height = 14,
  });

  final double fraction;
  final Color color;
  final bool striped;
  final double height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth * fraction.clamp(0.02, 1.0);
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: context.palette.surfaceSunken,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: context.scheme.outlineVariant),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: width,
              height: height,
              child: CustomPaint(
                painter: _BarPainter(
                  color: color,
                  striped: striped,
                  stripeColor: withOpacityValue(
                      context.isDark ? Colors.black : Colors.white, 0.45),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.color,
    required this.striped,
    required this.stripeColor,
  });

  final Color color;
  final bool striped;
  final Color stripeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(7),
    );
    canvas.drawRRect(rrect, Paint()..color = color);
    if (!striped) return;
    canvas.save();
    canvas.clipRRect(rrect);
    final paint = Paint()
      ..color = stripeColor
      ..strokeWidth = 2.2;
    for (var x = -size.height; x < size.width + size.height; x += 7) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BarPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.striped != striped;
}
