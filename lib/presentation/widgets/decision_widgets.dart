import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/widgets/common.dart';
import '../../data/models/decision.dart';
import '../../data/models/indicator.dart';

/// Tarjeta de decisión.
///
/// Muestra acción, costo relativo, beneficio esperado y alcance, sin revelar
/// la función real de la medida antes de decidir.
class DecisionOptionCard extends StatelessWidget {
  const DecisionOptionCard({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
    this.revealType = false,
  });

  final DecisionOption option;
  final bool selected;
  final VoidCallback? onTap;
  final bool revealType;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final palette = context.palette;

    return Panel(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      borderColor: selected ? scheme.primary : null,
      background: selected
          ? withOpacityValue(scheme.primary, context.isDark ? 0.16 : 0.07)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? scheme.primary : Colors.transparent,
                  border: Border.all(
                    color: selected ? scheme.primary : scheme.outline,
                    width: 2,
                  ),
                ),
                child: selected
                    ? Icon(Icons.check, size: 14, color: scheme.onPrimary)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  option.title,
                  style: context.texts.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            option.action,
            style: context.texts.bodySmall?.copyWith(height: 1.4),
          ),
          const SizedBox(height: 12),
          CostIndicator(cost: option.cost, label: option.costLabel),
          const SizedBox(height: 8),
          _MetaLine(
            icon: Icons.trending_up,
            label: 'Beneficio esperado',
            value: option.benefit,
          ),
          const SizedBox(height: 6),
          _MetaLine(
            icon: Icons.map_outlined,
            label: 'Alcance',
            value: option.scope,
          ),
          if (revealType) ...<Widget>[
            const SizedBox(height: 10),
            Tag(
              label: option.type.label,
              icon: option.type.icon,
              color: palette.forMeasure(option.type, context),
              filled: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 14, color: context.palette.neutral),
        const SizedBox(width: 7),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: context.texts.labelSmall?.copyWith(
                color: context.palette.neutral,
                height: 1.35,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(color: context.scheme.onSurface),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

extension MeasurePalette on AppPalette {
  Color forMeasure(MeasureType type, BuildContext context) {
    switch (type) {
      case MeasureType.mitigacion:
        return emisiones;
      case MeasureType.adaptacion:
        return vulnerabilidad;
      case MeasureType.ambas:
        return vegetacion;
      case MeasureType.ninguna:
        return neutral;
    }
  }
}

/// Selector de clasificación de la medida elegida.
class MeasureTypeSelector extends StatelessWidget {
  const MeasureTypeSelector({
    super.key,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
    this.correctType,
  });

  final MeasureType? selected;
  final ValueChanged<MeasureType> onSelected;
  final bool enabled;
  final MeasureType? correctType;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (final type in MeasureType.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _TypeOption(
              type: type,
              selected: selected == type,
              isCorrect: correctType == null ? null : correctType == type,
              onTap: enabled ? () => onSelected(type) : null,
            ),
          ),
      ],
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.type,
    required this.selected,
    required this.isCorrect,
    required this.onTap,
  });

  final MeasureType type;
  final bool selected;
  final bool? isCorrect;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scheme = context.scheme;

    Color border = scheme.outlineVariant;
    Color? background;
    IconData? statusIcon;
    Color statusColor = palette.neutral;

    if (isCorrect != null) {
      if (isCorrect!) {
        border = palette.positive;
        background = withOpacityValue(palette.positive, 0.12);
        statusIcon = Icons.check_circle_outline;
        statusColor = palette.positive;
      } else if (selected) {
        border = palette.negative;
        background = withOpacityValue(palette.negative, 0.12);
        statusIcon = Icons.cancel_outlined;
        statusColor = palette.negative;
      }
    } else if (selected) {
      border = scheme.primary;
      background = withOpacityValue(scheme.primary, context.isDark ? 0.18 : 0.08);
    }

    return Panel(
      onTap: onTap,
      borderColor: border,
      background: background,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(type.icon, size: 18, color: scheme.onSurface),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  type.label,
                  style: context.texts.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  type.definition,
                  style: context.texts.labelSmall
                      ?.copyWith(color: palette.neutral, height: 1.35),
                ),
              ],
            ),
          ),
          if (statusIcon != null) ...<Widget>[
            const SizedBox(width: 8),
            Icon(statusIcon, size: 20, color: statusColor),
          ],
        ],
      ),
    );
  }
}

/// Panel de consecuencias: variación de indicadores más efectos narrados.
class ConsequencePanel extends StatelessWidget {
  const ConsequencePanel({
    super.key,
    required this.title,
    required this.before,
    required this.after,
    required this.consequences,
    this.icon = Icons.insights_outlined,
    this.accent,
  });

  final String title;
  final ClimateState before;
  final ClimateState after;
  final List<String> consequences;
  final IconData icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final changed = <ClimateIndicator, double>{};
    for (final indicator in kAllIndicators) {
      final delta = after.get(indicator) - before.get(indicator);
      final threshold = metaOf(indicator).decimals > 0 ? 0.005 : 0.5;
      if (delta.abs() >= threshold) changed[indicator] = delta;
    }

    return Panel(
      borderColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 18, color: accent ?? context.scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: context.texts.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (changed.isEmpty)
            Text(
              'Los indicadores no registran variaciones apreciables.',
              style: context.texts.bodySmall?.copyWith(color: palette.neutral),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final entry in changed.entries)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        metaOf(entry.key).icon,
                        size: 14,
                        color: palette.forIndicator(entry.key),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        metaOf(entry.key).shortLabel,
                        style: context.texts.labelSmall?.copyWith(
                          color: context.scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 5),
                      DeltaChip(
                        indicator: entry.key,
                        delta: entry.value,
                        dense: true,
                      ),
                    ],
                  ),
              ],
            ),
          if (consequences.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            for (final line in consequences)
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 6, right: 8),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: palette.neutral,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        line,
                        style: context.texts.bodySmall?.copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
