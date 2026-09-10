import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../../data/models/attempt.dart';
import '../../data/models/climate_period.dart';
import '../../data/models/decision.dart';
import '../../data/models/indicator.dart';
import '../../data/scenarios/scenario_data.dart';
import '../../domain/scenario_engine.dart';
import 'charts.dart';
import 'decision_widgets.dart';
import 'indicator_widgets.dart';

/// Informe educativo de un escenario completado.
class AttemptReportView extends StatelessWidget {
  const AttemptReportView({super.key, required this.attempt});

  final AttemptRecord attempt;

  @override
  Widget build(BuildContext context) {
    final scenario = ScenarioCatalog.byId(attempt.scenarioId);
    final palette = context.palette;
    final choices = <int, String>{
      for (final choice in attempt.choices) choice.stageIndex: choice.optionId,
    };
    final keyIndicator = scenario.highlightIndicators.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                attempt.scenarioName,
                style: context.texts.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                Formats.dateTime(attempt.date),
                style:
                    context.texts.labelSmall?.copyWith(color: palette.neutral),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  Tag(
                    label: attempt.strategy,
                    icon: Icons.route_outlined,
                    color: context.scheme.primary,
                    filled: true,
                  ),
                  Tag(
                    label: attempt.outcome,
                    icon: Icons.flag_outlined,
                    color: context.scheme.tertiary,
                    filled: true,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _SummaryStat(
                      value: '${attempt.mitigationCount}',
                      label: 'Medidas de mitigación',
                      color: palette.emisiones,
                    ),
                  ),
                  Expanded(
                    child: _SummaryStat(
                      value: '${attempt.adaptationCount}',
                      label: 'Medidas de adaptación',
                      color: palette.vulnerabilidad,
                    ),
                  ),
                  Expanded(
                    child: _SummaryStat(
                      value:
                          '${attempt.classificationHits}/${attempt.classificationTotal}',
                      label: 'Clasificaciones correctas',
                      color: palette.positive,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SectionHeader(
          title: 'Indicadores al final del horizonte',
          subtitle:
              'Valor alcanzado frente a la trayectoria sin intervención.',
          icon: Icons.speed_outlined,
        ),
        Panel(
          child: Column(
            children: <Widget>[
              for (final indicator in kAllIndicators)
                IndicatorRow(
                  indicator: indicator,
                  value: attempt.finalState.get(indicator),
                  delta: attempt.finalState.get(indicator) -
                      attempt.initial.get(indicator),
                  reference: attempt.baselineFinal.get(indicator),
                  referenceLabel: 'Sin intervención',
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SectionHeader(
          title: 'Evolución observada',
          subtitle: metaOf(keyIndicator).label,
          icon: Icons.show_chart,
        ),
        Panel(
          child: TrendChart(
            indicator: keyIndicator,
            xLabels: kAllPeriods.map((p) => p.shortLabel).toList(),
            series: <ChartSeries>[
              ChartSeries(
                label: 'Con tus decisiones',
                values: ScenarioEngine.series(
                  scenario,
                  keyIndicator,
                  choices: choices,
                ),
                color: palette.seriesA,
              ),
              ChartSeries(
                label: 'Sin intervención',
                values: ScenarioEngine.series(scenario, keyIndicator),
                color: palette.seriesB,
                style: SeriesStyle.dashed,
                marker: SeriesMarker.square,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SectionHeader(
          title: 'Decisiones tomadas',
          subtitle: 'Función real de cada medida y clasificación realizada.',
          icon: Icons.alt_route,
        ),
        for (final choice in attempt.choices)
          _ChoiceSummary(
            choice: choice,
            option: scenario.stages[choice.stageIndex]
                .optionById(choice.optionId),
          ),
        if (attempt.events.isNotEmpty) ...<Widget>[
          const SizedBox(height: 6),
          const SectionHeader(
            title: 'Eventos del recorrido',
            icon: Icons.bolt_outlined,
          ),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (final event in attempt.events)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.bolt, size: 15, color: palette.negative),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event,
                            style: context.texts.bodySmall
                                ?.copyWith(height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        const SectionHeader(
          title: 'Retroalimentación',
          subtitle: 'Por qué la estrategia produjo estos efectos.',
          icon: Icons.psychology_outlined,
        ),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (final line in attempt.highlights)
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
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
                          style: context.texts.bodySmall?.copyWith(height: 1.45),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                _strategyExplanation(attempt),
                style: context.texts.bodySmall?.copyWith(
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SimulatedDataNotice(),
      ],
    );
  }

  String _strategyExplanation(AttemptRecord attempt) {
    final mitigation = attempt.mitigationCount;
    final adaptation = attempt.adaptationCount;
    if (mitigation == 0 && adaptation == 0) {
      return 'No se aplicaron medidas de mitigación ni de adaptación: el '
          'escenario evolucionó según su propia tendencia.';
    }
    if (mitigation > 0 && adaptation == 0) {
      return 'La estrategia actuó sobre las causas del problema. Las emisiones '
          'mejoraron respecto a la trayectoria base, pero el territorio '
          'mantiene su nivel de exposición frente a los impactos.';
    }
    if (adaptation > 0 && mitigation == 0) {
      return 'La estrategia redujo el daño esperado sobre el territorio, pero '
          'no modificó las causas: las emisiones siguieron su tendencia.';
    }
    return 'La estrategia combinó medidas sobre las causas y sobre las '
        'consecuencias. Mitigación y adaptación cumplen funciones distintas y '
        'sus efectos aparecen en indicadores diferentes.';
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: context.texts.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800, color: color),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: context.texts.labelSmall
              ?.copyWith(color: context.palette.neutral, height: 1.3),
        ),
      ],
    );
  }
}

class _ChoiceSummary extends StatelessWidget {
  const _ChoiceSummary({required this.choice, required this.option});

  final AttemptChoice choice;
  final DecisionOption option;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final studentType = choice.studentType;

    return Panel(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${choice.period.label} · ${choice.stageTitle}',
            style: context.texts.labelSmall?.copyWith(
              color: palette.neutral,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            choice.optionTitle,
            style:
                context.texts.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              Tag(
                label: choice.realType.label,
                icon: choice.realType.icon,
                color: palette.forMeasure(choice.realType, context),
                filled: true,
              ),
              if (studentType != null)
                Tag(
                  label: studentType == choice.realType
                      ? 'Clasificaste correctamente'
                      : 'Clasificaste como ${studentType.shortLabel}',
                  icon: studentType == choice.realType
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  color: studentType == choice.realType
                      ? palette.positive
                      : palette.negative,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            option.feedback,
            style: context.texts.bodySmall
                ?.copyWith(height: 1.45, color: palette.neutral),
          ),
        ],
      ),
    );
  }
}
