import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_palette.dart';
import '../../core/widgets/common.dart';
import '../../data/models/climate_period.dart';
import '../../data/models/indicator.dart';
import '../../state/providers.dart';
import '../widgets/charts.dart';

class _EnergyMeasure {
  const _EnergyMeasure({
    required this.id,
    required this.title,
    required this.description,
    required this.emissionEffect,
    required this.energyEffect,
    required this.note,
  });

  final String id;
  final String title;
  final String description;
  final double emissionEffect;
  final double energyEffect;
  final String note;
}

const List<_EnergyMeasure> _measures = <_EnergyMeasure>[
  _EnergyMeasure(
    id: 'renovables',
    title: 'Introducir energías renovables',
    description:
        'Sustituir progresivamente generación fósil por solar y eólica.',
    emissionEffect: -17,
    energyEffect: -3,
    note:
        'Actúa sobre la fuente de las emisiones. No reduce por sí sola la '
        'cantidad de energía que el territorio consume.',
  ),
  _EnergyMeasure(
    id: 'eficiencia',
    title: 'Mejorar la eficiencia',
    description:
        'Equipos, procesos y edificaciones que entregan el mismo servicio con '
        'menos energía.',
    emissionEffect: -8,
    energyEffect: -11,
    note:
        'Reduce a la vez consumo y emisiones, y disminuye la capacidad de '
        'generación que hay que construir.',
  ),
  _EnergyMeasure(
    id: 'demanda',
    title: 'Reducir el consumo',
    description:
        'Gestión de la demanda: menos viajes motorizados, menos climatización '
        'innecesaria, mejor programación industrial.',
    emissionEffect: -6,
    energyEffect: -13,
    note:
        'La energía que no se consume es la de menor costo y menor impacto.',
  ),
];

/// Módulo de decisiones energéticas.
///
/// Permite observar cómo cambia la trayectoria de emisiones y consumo al
/// combinar medidas sobre la matriz energética. No es un juego de recursos.
class EnergyScreen extends ConsumerStatefulWidget {
  const EnergyScreen({super.key});

  @override
  ConsumerState<EnergyScreen> createState() => _EnergyScreenState();
}

class _EnergyScreenState extends ConsumerState<EnergyScreen> {
  bool _registered = false;

  static const double _baseEmissions = 108;
  static const double _baseEnergy = 92;
  static const double _emissionDrift = 9;
  static const double _energyDrift = 7;

  double _maturity(int periodsElapsed) {
    if (periodsElapsed <= 0) return 0;
    if (periodsElapsed == 1) return 0.7;
    if (periodsElapsed == 2) return 1.0;
    return 1.25;
  }

  List<double> _series(Set<String> active, bool emissions) {
    return kAllPeriods.map((period) {
      final index = period.index0;
      var value = (emissions ? _baseEmissions : _baseEnergy) +
          (emissions ? _emissionDrift : _energyDrift) * index;
      for (final measure in _measures) {
        if (!active.contains(measure.id)) continue;
        final effect = emissions ? measure.emissionEffect : measure.energyEffect;
        value += effect * _maturity(index);
      }
      final meta = metaOf(
          emissions ? ClimateIndicator.emisiones : ClimateIndicator.energia);
      return value.clamp(meta.min, meta.max).toDouble();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(energyMeasuresProvider);
    final palette = context.palette;

    final emissionsWith = _series(active, true);
    final emissionsWithout = _series(const <String>{}, true);
    final energyWith = _series(active, false);
    final energyWithout = _series(const <String>{}, false);

    final emissionGap = emissionsWithout.last - emissionsWith.last;
    final energyGap = energyWithout.last - energyWith.last;

    return Scaffold(
      appBar: AppBar(title: const Text('Energía y decisiones')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: <Widget>[
          Text(
            'Matriz energética y emisiones',
            style:
                context.texts.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Parte de una matriz convencional y combina medidas para observar '
            'cómo se separa la trayectoria.',
            style: context.texts.bodySmall
                ?.copyWith(color: palette.neutral, height: 1.45),
          ),
          const SizedBox(height: 16),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SectionHeader(
                  title: 'Emisiones relativas',
                  icon: Icons.cloud_outlined,
                ),
                TrendChart(
                  indicator: ClimateIndicator.emisiones,
                  xLabels: kAllPeriods.map((p) => p.shortLabel).toList(),
                  series: <ChartSeries>[
                    ChartSeries(
                      label: 'Con las medidas activas',
                      values: emissionsWith,
                      color: palette.seriesA,
                    ),
                    ChartSeries(
                      label: 'Matriz convencional',
                      values: emissionsWithout,
                      color: palette.seriesB,
                      style: SeriesStyle.dashed,
                      marker: SeriesMarker.square,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SectionHeader(
                  title: 'Consumo energético',
                  icon: Icons.bolt_outlined,
                ),
                TrendChart(
                  indicator: ClimateIndicator.energia,
                  xLabels: kAllPeriods.map((p) => p.shortLabel).toList(),
                  series: <ChartSeries>[
                    ChartSeries(
                      label: 'Con las medidas activas',
                      values: energyWith,
                      color: palette.seriesA,
                    ),
                    ChartSeries(
                      label: 'Matriz convencional',
                      values: energyWithout,
                      color: palette.seriesB,
                      style: SeriesStyle.dashed,
                      marker: SeriesMarker.square,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Panel(
            background: withOpacityValue(context.scheme.primary, 0.07),
            borderColor: withOpacityValue(context.scheme.primary, 0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  active.isEmpty
                      ? 'Sin medidas activas: la matriz convencional mantiene '
                          'la trayectoria de crecimiento.'
                      : 'Al largo plazo, las medidas activas dejan las '
                          'emisiones ${emissionGap.toStringAsFixed(0)} puntos '
                          'por debajo y el consumo '
                          '${energyGap.toStringAsFixed(0)} puntos por debajo de '
                          'la matriz convencional.',
                  style: context.texts.bodySmall?.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SectionHeader(
            title: 'Decisiones disponibles',
            subtitle: 'Puedes combinarlas: sus efectos se suman.',
            icon: Icons.tune,
          ),
          for (final measure in _measures)
            _MeasureTile(
              title: measure.title,
              description: measure.description,
              note: measure.note,
              active: active.contains(measure.id),
              onChanged: () {
                ref.read(energyMeasuresProvider.notifier).toggle(measure.id);
                if (!_registered) {
                  _registered = true;
                  ref
                      .read(countersProvider.notifier)
                      .registerEnergyExploration();
                }
              },
            ),
          const SizedBox(height: 6),
          Panel(
            child: Text(
              'Todas estas decisiones son medidas de mitigación: actúan sobre '
              'las causas del cambio climático. No reducen por sí solas la '
              'vulnerabilidad del territorio frente a los impactos, que se '
              'trabaja con medidas de adaptación.',
              style: context.texts.bodySmall?.copyWith(height: 1.5),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: active.isEmpty
                  ? null
                  : () => ref.read(energyMeasuresProvider.notifier).clear(),
              icon: const Icon(Icons.restart_alt),
              label: const Text('Volver a la matriz convencional'),
            ),
          ),
          const SizedBox(height: 16),
          const SimulatedDataNotice(),
        ],
      ),
    );
  }
}

class _MeasureTile extends StatelessWidget {
  const _MeasureTile({
    required this.title,
    required this.description,
    required this.note,
    required this.active,
    required this.onChanged,
  });

  final String title;
  final String description;
  final String note;
  final bool active;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Panel(
      margin: const EdgeInsets.only(bottom: 10),
      onTap: onChanged,
      borderColor: active ? scheme.primary : null,
      background: active
          ? withOpacityValue(scheme.primary, context.isDark ? 0.16 : 0.07)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: context.texts.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Switch(
                value: active,
                onChanged: (_) => onChanged(),
              ),
            ],
          ),
          Text(
            description,
            style: context.texts.bodySmall?.copyWith(height: 1.4),
          ),
          if (active) ...<Widget>[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.lightbulb_outline,
                    size: 15, color: context.scheme.tertiary),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    note,
                    style: context.texts.labelSmall?.copyWith(
                      color: context.palette.neutral,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
