import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_palette.dart';
import '../../core/widgets/common.dart';
import '../../data/models/attempt.dart';
import '../../data/models/climate_period.dart';
import '../../data/models/indicator.dart';
import '../../data/models/scenario.dart';
import '../../domain/scenario_engine.dart';
import '../../state/providers.dart';
import '../widgets/charts.dart';
import '../widgets/climate_timeline.dart';

enum CompareSource { baseline, lastAttempt }

class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({super.key});

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  String? _scenarioA;
  String? _scenarioB;
  CompareSource _sourceA = CompareSource.baseline;
  CompareSource _sourceB = CompareSource.baseline;
  ClimatePeriod _period = ClimatePeriod.largo;
  bool _analysed = false;

  @override
  Widget build(BuildContext context) {
    final scenarios = ref.watch(scenariosProvider);
    final attempts = ref.watch(attemptsProvider);
    final palette = context.palette;

    final idA = _scenarioA ?? scenarios.first.id;
    final idB = _scenarioB ?? scenarios[1].id;
    final scenarioA = scenarios.firstWhere((s) => s.id == idA);
    final scenarioB = scenarios.firstWhere((s) => s.id == idB);

    final choicesA = _choicesFor(idA, _sourceA, attempts);
    final choicesB = _choicesFor(idB, _sourceB, attempts);

    final stateA = ScenarioEngine.project(scenarioA, _period, choices: choicesA);
    final stateB = ScenarioEngine.project(scenarioB, _period, choices: choicesB);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: <Widget>[
        Text(
          'Comparador climático',
          style: context.texts.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Enfrenta dos escenarios en el mismo periodo y observa en qué '
          'indicadores se separan.',
          style: context.texts.bodySmall
              ?.copyWith(color: palette.neutral, height: 1.45),
        ),
        const SizedBox(height: 16),
        _SideSelector(
          label: 'Escenario A',
          badge: 'A',
          badgeColor: palette.seriesA,
          scenarios: scenarios,
          selectedId: idA,
          source: _sourceA,
          hasAttempt: attempts.any((a) => a.scenarioId == idA),
          onScenarioChanged: (value) => setState(() {
            _scenarioA = value;
            _sourceA = CompareSource.baseline;
            _analysed = false;
          }),
          onSourceChanged: (value) => setState(() {
            _sourceA = value;
            _analysed = false;
          }),
        ),
        const SizedBox(height: 10),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: palette.surfaceSunken,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.scheme.outlineVariant),
            ),
            child: Text(
              'frente a',
              style: context.texts.labelSmall?.copyWith(
                color: palette.neutral,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _SideSelector(
          label: 'Escenario B',
          badge: 'B',
          badgeColor: palette.seriesB,
          scenarios: scenarios,
          selectedId: idB,
          source: _sourceB,
          hasAttempt: attempts.any((a) => a.scenarioId == idB),
          onScenarioChanged: (value) => setState(() {
            _scenarioB = value;
            _sourceB = CompareSource.baseline;
            _analysed = false;
          }),
          onSourceChanged: (value) => setState(() {
            _sourceB = value;
            _analysed = false;
          }),
        ),
        const SizedBox(height: 18),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SectionHeader(
                title: 'Periodo comparado',
                icon: Icons.timeline,
              ),
              ClimateTimeline(
                selected: _period,
                onSelected: (value) => setState(() {
                  _period = value;
                  _analysed = false;
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SectionHeader(
          title: 'Indicadores comparados',
          subtitle:
              'Barra sólida: escenario A. Barra con trama: escenario B.',
          icon: Icons.bar_chart,
        ),
        Panel(
          child: Column(
            children: <Widget>[
              for (final indicator in kAllIndicators)
                _ComparisonRow(
                  indicator: indicator,
                  valueA: stateA.get(indicator),
                  valueB: stateB.get(indicator),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (idA == idB && _sourceA == _sourceB)
          Panel(
            background: withOpacityValue(context.scheme.tertiary, 0.10),
            borderColor: withOpacityValue(context.scheme.tertiary, 0.4),
            child: Text(
              'Ambos lados muestran exactamente la misma trayectoria. Cambia '
              'el escenario o la fuente para observar diferencias.',
              style: context.texts.bodySmall?.copyWith(height: 1.45),
            ),
          )
        else if (!_analysed)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                setState(() => _analysed = true);
                ref.read(countersProvider.notifier).registerComparison();
              },
              icon: const Icon(Icons.query_stats),
              label: const Text('Analizar comparación'),
            ),
          )
        else
          _AnalysisPanel(
            scenarioA: scenarioA,
            scenarioB: scenarioB,
            stateA: stateA,
            stateB: stateB,
            period: _period,
          ),
        const SizedBox(height: 16),
        const SimulatedDataNotice(),
      ],
    );
  }

  Map<int, String> _choicesFor(
    String scenarioId,
    CompareSource source,
    List<AttemptRecord> attempts,
  ) {
    if (source == CompareSource.baseline) return const <int, String>{};
    final matching =
        attempts.where((a) => a.scenarioId == scenarioId).toList();
    if (matching.isEmpty) return const <int, String>{};
    return <int, String>{
      for (final choice in matching.first.choices)
        choice.stageIndex: choice.optionId,
    };
  }
}

class _SideSelector extends StatelessWidget {
  const _SideSelector({
    required this.label,
    required this.badge,
    required this.badgeColor,
    required this.scenarios,
    required this.selectedId,
    required this.source,
    required this.hasAttempt,
    required this.onScenarioChanged,
    required this.onSourceChanged,
  });

  final String label;
  final String badge;
  final Color badgeColor;
  final List<ClimateScenario> scenarios;
  final String selectedId;
  final CompareSource source;
  final bool hasAttempt;
  final ValueChanged<String> onScenarioChanged;
  final ValueChanged<CompareSource> onSourceChanged;

  @override
  Widget build(BuildContext context) {
    return Panel(
      borderColor: withOpacityValue(badgeColor, 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    badge,
                    style: context.texts.labelMedium?.copyWith(
                      color: context.isDark ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: context.texts.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: context.palette.surfaceSunken,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.scheme.outlineVariant),
            ),
            child: DropdownButton<String>(
              value: selectedId,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              borderRadius: BorderRadius.circular(12),
              dropdownColor: context.palette.surfaceElevated,
              iconEnabledColor: context.scheme.onSurface,
              items: <DropdownMenuItem<String>>[
                for (final scenario in scenarios)
                  DropdownMenuItem<String>(
                    value: scenario.id,
                    child: Text(
                      scenario.name,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.bodyMedium,
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value != null) onScenarioChanged(value);
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: _SourceChip(
                  label: 'Trayectoria base',
                  selected: source == CompareSource.baseline,
                  onTap: () => onSourceChanged(CompareSource.baseline),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SourceChip(
                  label: 'Mi último intento',
                  selected: source == CompareSource.lastAttempt,
                  onTap: hasAttempt
                      ? () => onSourceChanged(CompareSource.lastAttempt)
                      : null,
                ),
              ),
            ],
          ),
          if (!hasAttempt)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Completa el escenario para poder comparar tus decisiones.',
                style: context.texts.labelSmall
                    ?.copyWith(color: context.palette.neutral),
              ),
            ),
        ],
      ),
    );
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? withOpacityValue(scheme.primary, context.isDark ? 0.24 : 0.12)
              : context.palette.surfaceSunken,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 15,
              color: enabled
                  ? (selected ? scheme.primary : context.palette.neutral)
                  : withOpacityValue(context.palette.neutral, 0.5),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: context.texts.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: enabled
                      ? scheme.onSurface
                      : withOpacityValue(context.palette.neutral, 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.indicator,
    required this.valueA,
    required this.valueB,
  });

  final ClimateIndicator indicator;
  final double valueA;
  final double valueB;

  @override
  Widget build(BuildContext context) {
    final meta = metaOf(indicator);
    final palette = context.palette;
    final difference = valueA - valueB;
    final threshold = meta.decimals > 0 ? 0.005 : 0.5;

    String verdict;
    Color verdictColor;
    if (difference.abs() < threshold) {
      verdict = 'Sin diferencia relevante';
      verdictColor = palette.neutral;
    } else {
      final aBetter = meta.lowerIsBetter ? valueA < valueB : valueA > valueB;
      verdict = aBetter ? 'Mejor en A' : 'Mejor en B';
      verdictColor = aBetter ? palette.seriesA : palette.seriesB;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(meta.icon,
                  size: 16, color: palette.forIndicator(indicator)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  meta.label,
                  style: context.texts.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                verdict,
                style: context.texts.labelSmall?.copyWith(
                  color: verdictColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _BarLine(
            tag: 'A',
            value: valueA,
            fraction: meta.normalize(valueA),
            color: palette.seriesA,
            striped: false,
            meta: meta,
          ),
          const SizedBox(height: 6),
          _BarLine(
            tag: 'B',
            value: valueB,
            fraction: meta.normalize(valueB),
            color: palette.seriesB,
            striped: true,
            meta: meta,
          ),
        ],
      ),
    );
  }
}

class _BarLine extends StatelessWidget {
  const _BarLine({
    required this.tag,
    required this.value,
    required this.fraction,
    required this.color,
    required this.striped,
    required this.meta,
  });

  final String tag;
  final double value;
  final double fraction;
  final Color color;
  final bool striped;
  final IndicatorMeta meta;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 16,
          child: Text(
            tag,
            style: context.texts.labelSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
        Expanded(
          child: ComparisonBar(
            fraction: fraction,
            color: color,
            striped: striped,
          ),
        ),
        SizedBox(
          width: 62,
          child: Text(
            meta.formatWithUnit(value),
            textAlign: TextAlign.right,
            style: context.texts.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _AnalysisPanel extends StatelessWidget {
  const _AnalysisPanel({
    required this.scenarioA,
    required this.scenarioB,
    required this.stateA,
    required this.stateB,
    required this.period,
  });

  final ClimateScenario scenarioA;
  final ClimateScenario scenarioB;
  final ClimateState stateA;
  final ClimateState stateB;
  final ClimatePeriod period;

  @override
  Widget build(BuildContext context) {
    final differences = <MapEntry<ClimateIndicator, double>>[];
    for (final indicator in kAllIndicators) {
      final improvement = ScenarioEngine.improvement(
        indicator,
        stateA.get(indicator),
        stateB.get(indicator),
      );
      differences.add(MapEntry(indicator, improvement));
    }
    differences.sort((a, b) => b.value.abs().compareTo(a.value.abs()));
    final top = differences.take(3).toList();

    return Panel(
      borderColor: withOpacityValue(context.scheme.primary, 0.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionHeader(
            title: 'Lectura de la comparación',
            icon: Icons.query_stats,
          ),
          Text(
            'Periodo analizado: ${period.label} (${period.referenceYear}).',
            style: context.texts.bodySmall?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 10),
          for (final entry in top)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    metaOf(entry.key).icon,
                    size: 15,
                    color: context.palette.forIndicator(entry.key),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _describe(entry.key, entry.value),
                      style: context.texts.bodySmall?.copyWith(height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Text(
            'La comparación quedó registrada en tu progreso.',
            style: context.texts.labelSmall
                ?.copyWith(color: context.palette.neutral),
          ),
        ],
      ),
    );
  }

  String _describe(ClimateIndicator indicator, double improvement) {
    final meta = metaOf(indicator);
    if (improvement.abs() < 0.01) {
      return '${meta.label}: ambos escenarios llegan a valores muy similares.';
    }
    final better = improvement > 0 ? scenarioA.name : scenarioB.name;
    final worse = improvement > 0 ? scenarioB.name : scenarioA.name;
    return '${meta.label}: "$better" alcanza una situación más favorable que '
        '"$worse" en este periodo.';
  }
}
