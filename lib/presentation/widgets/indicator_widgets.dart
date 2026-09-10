import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/widgets/common.dart';
import '../../data/models/indicator.dart';

/// Medidor compacto de un indicador (icono, valor, barra y variación).
class IndicatorGauge extends StatelessWidget {
  const IndicatorGauge({
    super.key,
    required this.indicator,
    required this.value,
    this.delta,
    this.width = 152,
    this.selected = false,
    this.onTap,
  });

  final ClimateIndicator indicator;
  final double value;
  final double? delta;
  final double width;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final meta = metaOf(indicator);
    final color = context.palette.forIndicator(indicator);
    final fraction = meta.normalize(value);

    return SizedBox(
      width: width,
      child: Panel(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        borderColor: selected ? color : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(meta.icon, size: 16, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    meta.shortLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Text(
                  meta.format(value),
                  style: context.texts.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.scheme.onSurface,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  meta.unit,
                  style: context.texts.labelSmall
                      ?.copyWith(color: context.palette.neutral),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _IndicatorBar(fraction: fraction, color: color),
            if (delta != null) ...<Widget>[
              const SizedBox(height: 8),
              DeltaChip(indicator: indicator, delta: delta!, dense: true),
            ],
          ],
        ),
      ),
    );
  }
}

class _IndicatorBar extends StatelessWidget {
  const _IndicatorBar({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: fraction.clamp(0.0, 1.0),
        minHeight: 7,
        backgroundColor: context.palette.surfaceSunken,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

/// Fila detallada de un indicador, con descripción opcional.
class IndicatorRow extends StatelessWidget {
  const IndicatorRow({
    super.key,
    required this.indicator,
    required this.value,
    this.delta,
    this.reference,
    this.referenceLabel,
  });

  final ClimateIndicator indicator;
  final double value;
  final double? delta;
  final double? reference;
  final String? referenceLabel;

  @override
  Widget build(BuildContext context) {
    final meta = metaOf(indicator);
    final color = context.palette.forIndicator(indicator);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(meta.icon, size: 17, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  meta.label,
                  style: context.texts.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                meta.formatWithUnit(value),
                style: context.texts.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: context.scheme.onSurface,
                ),
              ),
              if (delta != null) ...<Widget>[
                const SizedBox(width: 8),
                DeltaChip(indicator: indicator, delta: delta!, dense: true),
              ],
            ],
          ),
          const SizedBox(height: 7),
          _IndicatorBar(fraction: meta.normalize(value), color: color),
          if (reference != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '${referenceLabel ?? 'Referencia'}: '
                '${meta.formatWithUnit(reference!)}',
                style: context.texts.labelSmall
                    ?.copyWith(color: context.palette.neutral),
              ),
            ),
        ],
      ),
    );
  }
}

/// Tira horizontal de indicadores utilizada en el visor de escenarios.
class IndicatorStrip extends StatelessWidget {
  const IndicatorStrip({
    super.key,
    required this.indicators,
    required this.values,
    required this.deltas,
    required this.selected,
    required this.onSelected,
  });

  final List<ClimateIndicator> indicators;
  final ClimateState values;
  final Map<ClimateIndicator, double> deltas;
  final ClimateIndicator selected;
  final ValueChanged<ClimateIndicator> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: indicators.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final indicator = indicators[index];
          return IndicatorGauge(
            indicator: indicator,
            value: values.get(indicator),
            delta: deltas[indicator],
            selected: indicator == selected,
            onTap: () => onSelected(indicator),
          );
        },
      ),
    );
  }
}
