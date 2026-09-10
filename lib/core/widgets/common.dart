import 'package:flutter/material.dart';

import '../../data/models/indicator.dart';
import '../theme/app_palette.dart';
import '../utils/format.dart';

/// Panel base de ExploraClima. Sustituye a `Card` para controlar el color en
/// ambos temas sin depender de valores fijos.
class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.borderColor,
    this.background,
    this.radius = 18,
    this.elevated = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? background;
  final double radius;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scheme = context.scheme;
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background ??
            (elevated ? palette.surfaceElevated : palette.surfaceSunken),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? scheme.outlineVariant),
      ),
      child: child,
    );

    return Padding(
      padding: margin,
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(radius),
                child: content,
              ),
            ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 20, color: scheme.primary),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: context.texts.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: context.texts.bodySmall
                          ?.copyWith(color: context.palette.neutral),
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Etiqueta compacta con icono y texto.
class Tag extends StatelessWidget {
  const Tag({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.filled = false,
  });

  final String label;
  final IconData? icon;
  final Color? color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final base = color ?? context.scheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? withOpacityValue(base, 0.16) : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: withOpacityValue(base, 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 14, color: base),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: context.texts.labelSmall?.copyWith(
              color: base,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip de variación de un indicador: color + icono + signo + valor.
class DeltaChip extends StatelessWidget {
  const DeltaChip({
    super.key,
    required this.indicator,
    required this.delta,
    this.showUnit = false,
    this.dense = false,
  });

  final ClimateIndicator indicator;
  final double delta;
  final bool showUnit;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final meta = metaOf(indicator);
    final threshold = meta.decimals > 0 ? 0.005 : 0.5;
    final neutral = delta.abs() < threshold;
    final favourable = meta.lowerIsBetter ? delta < 0 : delta > 0;
    final color = neutral
        ? palette.neutral
        : (favourable ? palette.positive : palette.negative);
    final icon = neutral
        ? Icons.horizontal_rule
        : (delta > 0 ? Icons.north_east : Icons.south_east);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 6 : 8,
        vertical: dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: withOpacityValue(color, 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: withOpacityValue(color, 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: dense ? 12 : 14, color: color),
          const SizedBox(width: 4),
          Text(
            showUnit
                ? '${Formats.signedDelta(indicator, delta)} ${meta.unit}'
                : Formats.signedDelta(indicator, delta),
            style: (dense ? context.texts.labelSmall : context.texts.labelMedium)
                ?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: palette.surfaceSunken,
                shape: BoxShape.circle,
                border: Border.all(color: context.scheme.outlineVariant),
              ),
              child: Icon(icon, color: palette.neutral, size: 30),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.texts.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.texts.bodyMedium?.copyWith(color: palette.neutral),
            ),
            if (action != null) ...<Widget>[
              const SizedBox(height: 18),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Aviso permanente que recuerda el carácter educativo de los datos.
class SimulatedDataNotice extends StatelessWidget {
  const SimulatedDataNotice({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: compact ? 8 : 10),
      decoration: BoxDecoration(
        color: withOpacityValue(context.scheme.tertiary, 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: withOpacityValue(context.scheme.tertiary, 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline, size: 16, color: context.scheme.tertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Datos educativos simulados. No son proyecciones científicas '
              'oficiales.',
              style: context.texts.labelSmall?.copyWith(
                color: palette.neutral,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Indicador de costo o dificultad relativa (accesible: puntos + texto).
class CostIndicator extends StatelessWidget {
  const CostIndicator({super.key, required this.cost, required this.label});

  final int cost;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (var i = 1; i <= 3; i++)
          Padding(
            padding: const EdgeInsets.only(right: 3),
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i <= cost ? scheme.tertiary : Colors.transparent,
                border: Border.all(color: scheme.outline),
              ),
            ),
          ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: context.texts.labelSmall
                ?.copyWith(color: context.palette.neutral),
          ),
        ),
      ],
    );
  }
}
