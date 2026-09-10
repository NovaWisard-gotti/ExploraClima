import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_palette.dart';
import '../../core/widgets/common.dart';
import '../../data/models/climate_period.dart';
import '../../data/models/decision.dart';
import '../../data/models/indicator.dart';
import '../../domain/scenario_engine.dart';
import '../../state/scenario_run_controller.dart';
import '../widgets/charts.dart';
import '../widgets/climate_timeline.dart';
import '../widgets/decision_widgets.dart';
import '../widgets/indicator_widgets.dart';
import '../widgets/scenario_visual.dart';
import 'decision_stage_screen.dart';
import 'report_screen.dart';

class ScenarioViewerScreen extends ConsumerWidget {
  const ScenarioViewerScreen({super.key, required this.scenarioId});

  final String scenarioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final run = ref.watch(scenarioRunProvider(scenarioId));
    final controller = ref.read(scenarioRunProvider(scenarioId).notifier);
    final scenario = run.scenario;
    final palette = context.palette;

    final current = ScenarioEngine.project(
      scenario,
      run.selectedPeriod,
      choices: run.choices,
    );
    final startState = ScenarioEngine.project(
      scenario,
      ClimatePeriod.actual,
      choices: run.choices,
    );
    final deltas = <ClimateIndicator, double>{
      for (final indicator in kAllIndicators)
        indicator: current.get(indicator) - startState.get(indicator),
    };

    final withDecisions =
        ScenarioEngine.series(scenario, run.focusIndicator, choices: run.choices);
    final withoutDecisions = ScenarioEngine.series(scenario, run.focusIndicator);

    final decisionPeriods = <ClimatePeriod>{
      for (final r in run.resolutions) scenario.stages[r.stageIndex].period,
    };
    final eventPeriods = <ClimatePeriod>{
      for (final r in run.resolutions)
        if (scenario.eventsAfterStage(r.stageIndex).isNotEmpty)
          scenario.stages[r.stageIndex].period,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(scenario.name),
        actions: <Widget>[
          IconButton(
            tooltip: 'Información del caso',
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showBriefing(context, ref, scenarioId),
          ),
          IconButton(
            tooltip: 'Reiniciar escenario',
            icon: const Icon(Icons.restart_alt),
            onPressed: run.resolvedCount == 0
                ? null
                : () => _confirmRestart(context, controller),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 30),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SectionHeader(
                    title: 'Línea temporal climática',
                    subtitle:
                        'Desplázate entre periodos para observar la evolución.',
                    icon: Icons.timeline,
                  ),
                  ClimateTimeline(
                    selected: run.selectedPeriod,
                    onSelected: controller.selectPeriod,
                    decisionPeriods: decisionPeriods,
                    eventPeriods: eventPeriods,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    run.selectedPeriod.horizonDescription,
                    style: context.texts.bodySmall?.copyWith(
                      color: palette.neutral,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ScenarioVisual(
                  state: current,
                  period: run.selectedPeriod,
                  territory: scenario.territory,
                ),
                const SizedBox(height: 10),
                ScenarioVisualLegend(state: current),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SectionHeader(
              title: 'Indicadores del escenario',
              subtitle: run.selectedPeriod == ClimatePeriod.actual
                  ? 'Situación de partida del territorio.'
                  : 'Variación respecto a la situación actual.',
              icon: Icons.speed_outlined,
            ),
          ),
          IndicatorStrip(
            indicators: kAllIndicators,
            values: current,
            deltas: run.selectedPeriod == ClimatePeriod.actual
                ? const <ClimateIndicator, double>{}
                : deltas,
            selected: run.focusIndicator,
            onSelected: controller.selectIndicator,
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SectionHeader(
                    title: metaOf(run.focusIndicator).label,
                    subtitle: metaOf(run.focusIndicator).description,
                    icon: metaOf(run.focusIndicator).icon,
                  ),
                  TrendChart(
                    indicator: run.focusIndicator,
                    xLabels: kAllPeriods.map((p) => p.shortLabel).toList(),
                    highlightIndex: run.selectedPeriod.index0,
                    series: <ChartSeries>[
                      ChartSeries(
                        label: 'Con tus decisiones',
                        values: withDecisions,
                        color: palette.seriesA,
                      ),
                      ChartSeries(
                        label: 'Sin intervención',
                        values: withoutDecisions,
                        color: palette.seriesB,
                        style: SeriesStyle.dashed,
                        marker: SeriesMarker.square,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ScenarioEngine.trendDescription(
                        withDecisions, run.focusIndicator),
                    style: context.texts.bodySmall?.copyWith(height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _DecisionsSection(scenarioId: scenarioId),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SimulatedDataNotice(),
          ),
        ],
      ),
    );
  }

  void _confirmRestart(BuildContext context, ScenarioRunController controller) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reiniciar escenario'),
        content: const Text(
          'Se descartarán las decisiones tomadas en este recorrido. Los '
          'intentos ya guardados en el historial se conservan.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              controller.restart();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
  }

  void _showBriefing(BuildContext context, WidgetRef ref, String scenarioId) {
    final scenario = ref.read(scenarioRunProvider(scenarioId)).scenario;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.palette.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
          children: <Widget>[
            Text(
              scenario.name,
              style: context.texts.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              scenario.tagline,
              style: context.texts.labelMedium
                  ?.copyWith(color: context.scheme.tertiary),
            ),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Territorio', icon: Icons.public),
            Text(scenario.territory,
                style: context.texts.bodySmall?.copyWith(height: 1.5)),
            const SizedBox(height: 16),
            const SectionHeader(
                title: 'Situación de partida', icon: Icons.article_outlined),
            Text(scenario.briefing,
                style: context.texts.bodySmall?.copyWith(height: 1.5)),
            const SizedBox(height: 16),
            const SectionHeader(
                title: 'Objetivos de aprendizaje', icon: Icons.school_outlined),
            for (final goal in scenario.learningGoals)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.check, size: 15, color: context.scheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(goal,
                          style:
                              context.texts.bodySmall?.copyWith(height: 1.45)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Panel(
              background: withOpacityValue(context.scheme.tertiary, 0.10),
              borderColor: withOpacityValue(context.scheme.tertiary, 0.4),
              child: Text(
                scenario.keyQuestion,
                style: context.texts.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecisionsSection extends ConsumerWidget {
  const _DecisionsSection({required this.scenarioId});

  final String scenarioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final run = ref.watch(scenarioRunProvider(scenarioId));
    final scenario = run.scenario;
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionHeader(
          title: 'Decisiones del escenario',
          subtitle: '${run.resolvedCount} de ${scenario.stages.length} '
              'momentos de decisión resueltos.',
          icon: Icons.alt_route,
        ),
        for (var i = 0; i < scenario.stages.length; i++)
          _StageTile(scenarioId: scenarioId, stageIndex: i),
        const SizedBox(height: 6),
        if (run.isComplete)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ReportScreen(scenarioId: scenarioId),
                ),
              ),
              icon: const Icon(Icons.assignment_outlined),
              label: const Text('Ver informe del escenario'),
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DecisionStageScreen(
                    scenarioId: scenarioId,
                    stageIndex: run.nextStageIndex,
                  ),
                ),
              ),
              icon: const Icon(Icons.play_arrow),
              label: Text(
                'Analizar decisión · '
                '${scenario.stages[run.nextStageIndex].period.label}',
              ),
            ),
          ),
        if (run.triggeredEvents.isNotEmpty) ...<Widget>[
          const SizedBox(height: 18),
          const SectionHeader(
            title: 'Eventos ocurridos',
            icon: Icons.bolt_outlined,
          ),
          for (final event in run.triggeredEvents)
            Panel(
              margin: const EdgeInsets.only(bottom: 10),
              borderColor: withOpacityValue(palette.negative, 0.45),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.bolt, size: 17, color: palette.negative),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.title,
                          style: context.texts.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: context.texts.bodySmall?.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ScenarioEngine.isEventBuffered(scenario, event, run.choices)
                        ? event.bufferedNote
                        : event.exposedNote,
                    style: context.texts.labelSmall?.copyWith(
                      color: palette.neutral,
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _StageTile extends ConsumerWidget {
  const _StageTile({required this.scenarioId, required this.stageIndex});

  final String scenarioId;
  final int stageIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final run = ref.watch(scenarioRunProvider(scenarioId));
    final stage = run.scenario.stages[stageIndex];
    final resolution = run.resolutionFor(stageIndex);
    final palette = context.palette;
    final scheme = context.scheme;
    final isNext = run.nextStageIndex == stageIndex;

    final option =
        resolution == null ? null : stage.optionById(resolution.optionId);
    final studentType = resolution?.studentType;

    return Panel(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      borderColor: isNext ? scheme.primary : null,
      onTap: resolution == null && !isNext
          ? null
          : () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DecisionStageScreen(
                    scenarioId: scenarioId,
                    stageIndex: stageIndex,
                  ),
                ),
              ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: resolution != null
                  ? withOpacityValue(palette.positive, 0.18)
                  : palette.surfaceSunken,
              border: Border.all(
                color: resolution != null ? palette.positive : scheme.outline,
              ),
            ),
            child: Icon(
              resolution != null ? Icons.check : Icons.more_horiz,
              size: 17,
              color: resolution != null ? palette.positive : palette.neutral,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${stage.period.label} · ${stage.title}',
                  style: context.texts.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  option?.title ?? 'Decisión pendiente',
                  style: context.texts.labelSmall?.copyWith(
                    color: palette.neutral,
                    height: 1.35,
                  ),
                ),
                if (option != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: <Widget>[
                      Tag(
                        label: option.type.label,
                        icon: option.type.icon,
                        color: palette.forMeasure(option.type, context),
                        filled: true,
                      ),
                      if (studentType != null)
                        Tag(
                          label: studentType == option.type
                              ? 'Clasificación correcta'
                              : 'Clasificación revisada',
                          icon: studentType == option.type
                              ? Icons.check_circle_outline
                              : Icons.change_circle_outlined,
                          color: studentType == option.type
                              ? palette.positive
                              : palette.negative,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
