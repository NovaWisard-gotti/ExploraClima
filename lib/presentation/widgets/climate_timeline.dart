import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../data/models/climate_period.dart';

/// Línea temporal climática interactiva.
///
/// Es uno de los elementos característicos de ExploraClima: permite recorrer
/// los periodos del escenario y muestra en qué momentos se tomaron decisiones
/// o se produjeron eventos.
class ClimateTimeline extends StatelessWidget {
  const ClimateTimeline({
    super.key,
    required this.selected,
    required this.onSelected,
    this.decisionPeriods = const <ClimatePeriod>{},
    this.eventPeriods = const <ClimatePeriod>{},
    this.enabled = true,
    this.showYears = true,
  });

  final ClimatePeriod selected;
  final ValueChanged<ClimatePeriod> onSelected;
  final Set<ClimatePeriod> decisionPeriods;
  final Set<ClimatePeriod> eventPeriods;
  final bool enabled;
  final bool showYears;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scheme = context.scheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var i = 0; i < kAllPeriods.length; i++)
          Expanded(
            child: _TimelineNode(
              period: kAllPeriods[i],
              isSelected: kAllPeriods[i] == selected,
              isPast: kAllPeriods[i].index0 < selected.index0,
              hasDecision: decisionPeriods.contains(kAllPeriods[i]),
              hasEvent: eventPeriods.contains(kAllPeriods[i]),
              showLeftTrack: i > 0,
              showRightTrack: i < kAllPeriods.length - 1,
              trackColor: palette.timelineTrack,
              activeColor: palette.timelineActive,
              onTap: enabled ? () => onSelected(kAllPeriods[i]) : null,
              showYear: showYears,
              scheme: scheme,
            ),
          ),
      ],
    );
  }
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({
    required this.period,
    required this.isSelected,
    required this.isPast,
    required this.hasDecision,
    required this.hasEvent,
    required this.showLeftTrack,
    required this.showRightTrack,
    required this.trackColor,
    required this.activeColor,
    required this.onTap,
    required this.showYear,
    required this.scheme,
  });

  final ClimatePeriod period;
  final bool isSelected;
  final bool isPast;
  final bool hasDecision;
  final bool hasEvent;
  final bool showLeftTrack;
  final bool showRightTrack;
  final Color trackColor;
  final Color activeColor;
  final VoidCallback? onTap;
  final bool showYear;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final nodeColor = isSelected
        ? activeColor
        : (isPast ? withOpacityValue(activeColor, 0.55) : palette.surfaceElevated);
    final borderColor = isSelected ? activeColor : scheme.outline;

    return Semantics(
      button: onTap != null,
      selected: isSelected,
      label: '${period.label} ${period.referenceYear}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 30,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        height: 2,
                        color: showLeftTrack ? trackColor : Colors.transparent,
                      ),
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: <Widget>[
                        Container(
                          width: isSelected ? 24 : 18,
                          height: isSelected ? 24 : 18,
                          decoration: BoxDecoration(
                            color: nodeColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.circle,
                                  size: 7,
                                  color: scheme.onPrimary,
                                )
                              : null,
                        ),
                        if (hasDecision)
                          Positioned(
                            top: -4,
                            right: -6,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: scheme.tertiary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: palette.surfaceElevated, width: 1.5),
                              ),
                            ),
                          ),
                        if (hasEvent)
                          Positioned(
                            bottom: -6,
                            child: Icon(
                              Icons.bolt,
                              size: 12,
                              color: palette.negative,
                            ),
                          ),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: showRightTrack ? trackColor : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                period.shortLabel,
                textAlign: TextAlign.center,
                style: context.texts.labelSmall?.copyWith(
                  color: isSelected ? activeColor : scheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
              if (showYear)
                Text(
                  period.referenceYear,
                  textAlign: TextAlign.center,
                  style: context.texts.labelSmall?.copyWith(
                    color: palette.neutral,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
