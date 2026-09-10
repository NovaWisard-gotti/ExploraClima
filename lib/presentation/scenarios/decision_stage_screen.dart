import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_palette.dart';
import '../../core/widgets/common.dart';
import '../../data/models/decision.dart';
import '../../data/models/indicator.dart';
import '../../domain/scenario_engine.dart';
import '../../state/scenario_run_controller.dart';
import '../widgets/decision_widgets.dart';

/// Flujo de una etapa de decisión: contexto, opciones, consecuencias,
/// clasificación de la medida, retroalimentación y evento asociado.
class DecisionStageScreen extends ConsumerStatefulWidget {
  const DecisionStageScreen({
    super.key,
    required this.scenarioId,
    required this.stageIndex,
  });

  final String scenarioId;
  final int stageIndex;

  @override
  ConsumerState<DecisionStageScreen> createState() =>
      _DecisionStageScreenState();
}

class _DecisionStageScreenState extends ConsumerState<DecisionStageScreen> {
  String? _selectedOptionId;
  int _step = 0;
  bool _reviewMode = false;

  @override
  void initState() {
    super.initState();
    final run = ref.read(scenarioRunProvider(widget.scenarioId));
    final resolution = run.resolutionFor(widget.stageIndex);
    if (resolution != null) {
      _selectedOptionId = resolution.optionId;
      _reviewMode = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final run = ref.watch(scenarioRunProvider(widget.scenarioId));
    final controller = ref.read(scenarioRunProvider(widget.scenarioId).notifier);
    final scenario = run.scenario;
    final stage = scenario.stages[widget.stageIndex];

    final priorChoices = <int, String>{
      for (final entry in run.choices.entries)
        if (entry.key < widget.stageIndex) entry.key: entry.value,
    };
    final beforeDecision = ScenarioEngine.project(
      scenario,
      stage.period,
      choices: priorChoices,
    );

    final option =
        _selectedOptionId == null ? null : stage.optionById(_selectedOptionId!);
    final afterDecision = option == null
        ? beforeDecision
        : beforeDecision.apply(option.effects, factor: 0.6);

    final events = scenario.eventsAfterStage(widget.stageIndex);
    final resolution = run.resolutionFor(widget.stageIndex);

    return Scaffold(
      appBar: AppBar(
        title: Text(stage.period.label),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: _reviewMode ? 1 : (_step + 1) / 4,
            minHeight: 4,
            backgroundColor: context.palette.surfaceSunken,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
        children: <Widget>[
          _ContextPanel(
            title: stage.title,
            context_: stage.context,
            question: stage.question,
            period: '${stage.period.label} · ${stage.period.referenceYear}',
          ),
          const SizedBox(height: 18),
          if (_reviewMode)
            ..._buildReview(
              stage: stage,
              option: option!,
              resolution: resolution,
              beforeDecision: beforeDecision,
              afterDecision: afterDecision,
              events: events,
              run: run,
            )
          else
            ..._buildFlow(
              stage: stage,
              option: option,
              controller: controller,
              beforeDecision: beforeDecision,
              afterDecision: afterDecision,
              events: events,
              run: run,
              resolution: resolution,
            ),
        ],
      ),
    );
  }

  List<Widget> _buildFlow({
    required DecisionStage stage,
    required DecisionOption? option,
    required ScenarioRunController controller,
    required ClimateState beforeDecision,
    required ClimateState afterDecision,
    required List<ClimateEvent> events,
    required ScenarioRunState run,
    required StageResolution? resolution,
  }) {
    switch (_step) {
      case 0:
        return <Widget>[
          const SectionHeader(
            title: 'Tarjetas de decisión',
            subtitle:
                'Compara acción, costo relativo, beneficio esperado y alcance '
                'antes de elegir.',
            icon: Icons.style_outlined,
          ),
          for (final o in stage.options)
            DecisionOptionCard(
              option: o,
              selected: _selectedOptionId == o.id,
              onTap: () => setState(() => _selectedOptionId = o.id),
            ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _selectedOptionId == null
                  ? null
                  : () {
                      controller.chooseOption(
                          widget.stageIndex, _selectedOptionId!);
                      setState(() => _step = 1);
                    },
              icon: const Icon(Icons.check),
              label: const Text('Confirmar decisión'),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'La función de cada medida se analiza después de decidir.',
            textAlign: TextAlign.center,
            style: context.texts.labelSmall
                ?.copyWith(color: context.palette.neutral),
          ),
        ];
      case 1:
        return <Widget>[
          SectionHeader(
            title: 'Consecuencias en ${stage.period.label.toLowerCase()}',
            subtitle:
                'Efecto de la decisión sobre los indicadores del escenario.',
            icon: Icons.insights_outlined,
          ),
          ConsequencePanel(
            title: option!.title,
            before: beforeDecision,
            after: afterDecision,
            consequences: option.consequences,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => setState(() => _step = 2),
              child: const Text('Analizar la medida'),
            ),
          ),
        ];
      case 2:
        final studentType = resolution?.studentType;
        return <Widget>[
          const SectionHeader(
            title: '¿Qué función cumple esta medida?',
            subtitle:
                'Clasifica la decisión que acabas de tomar dentro del caso.',
            icon: Icons.help_outline,
          ),
          Panel(
            padding: const EdgeInsets.all(14),
            child: Text(
              option!.action,
              style: context.texts.bodySmall?.copyWith(height: 1.45),
            ),
          ),
          const SizedBox(height: 14),
          MeasureTypeSelector(
            selected: studentType,
            enabled: studentType == null,
            correctType: studentType == null ? null : option.type,
            onSelected: (type) =>
                controller.classify(widget.stageIndex, type),
          ),
          if (studentType != null) ...<Widget>[
            const SizedBox(height: 6),
            _FeedbackPanel(
              correct: studentType == option.type,
              realType: option.type,
              feedback: option.feedback,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => setState(() => _step = 3),
                child: Text(
                  events.isEmpty ? 'Continuar' : 'Ver evento del periodo',
                ),
              ),
            ),
          ],
        ];
      default:
        return _buildClosing(
          events: events,
          afterDecision: afterDecision,
          run: run,
        );
    }
  }

  List<Widget> _buildClosing({
    required List<ClimateEvent> events,
    required ClimateState afterDecision,
    required ScenarioRunState run,
  }) {
    final widgets = <Widget>[];
    var state = afterDecision;

    for (final event in events) {
      final buffered = ScenarioEngine.isEventBuffered(
        run.scenario,
        event,
        run.choices,
      );
      final after = state.apply(event.effects, factor: buffered ? 0.5 : 1.0);
      widgets.addAll(<Widget>[
        const SectionHeader(
          title: 'Evento del periodo',
          subtitle: 'Un hecho externo obliga a reconsiderar la estrategia.',
          icon: Icons.bolt_outlined,
        ),
        Panel(
          borderColor: withOpacityValue(context.palette.negative, 0.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.bolt, color: context.palette.negative, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.title,
                      style: context.texts.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                event.description,
                style: context.texts.bodySmall?.copyWith(height: 1.45),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: withOpacityValue(
                    buffered
                        ? context.palette.positive
                        : context.palette.negative,
                    0.12,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      buffered ? Icons.verified_outlined : Icons.warning_amber,
                      size: 16,
                      color: buffered
                          ? context.palette.positive
                          : context.palette.negative,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        buffered ? event.bufferedNote : event.exposedNote,
                        style: context.texts.labelSmall?.copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ConsequencePanel(
          title: 'Impacto del evento',
          before: state,
          after: after,
          consequences: const <String>[],
          icon: Icons.trending_down,
          accent: context.palette.negative,
        ),
        const SizedBox(height: 16),
      ]);
      state = after;
    }

    widgets.addAll(<Widget>[
      Panel(
        background: withOpacityValue(context.scheme.primary, 0.08),
        borderColor: withOpacityValue(context.scheme.primary, 0.4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              run.isComplete
                  ? 'Escenario completado'
                  : 'Siguiente momento de decisión disponible',
              style: context.texts.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              run.isComplete
                  ? 'Regresa al visor para revisar la línea temporal completa '
                      'y abrir el informe del escenario.'
                  : 'Vuelve al visor para observar cómo cambió la trayectoria '
                      'antes de tomar la siguiente decisión.',
              style: context.texts.bodySmall?.copyWith(height: 1.45),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Volver al escenario'),
        ),
      ),
    ]);

    return widgets;
  }

  List<Widget> _buildReview({
    required DecisionStage stage,
    required DecisionOption option,
    required StageResolution? resolution,
    required ClimateState beforeDecision,
    required ClimateState afterDecision,
    required List<ClimateEvent> events,
    required ScenarioRunState run,
  }) {
    final studentType = resolution?.studentType;
    return <Widget>[
      const SectionHeader(
        title: 'Decisión tomada',
        subtitle: 'Este momento ya fue resuelto en el recorrido actual.',
        icon: Icons.history_toggle_off,
      ),
      DecisionOptionCard(
        option: option,
        selected: true,
        onTap: null,
        revealType: true,
      ),
      const SizedBox(height: 8),
      ConsequencePanel(
        title: 'Consecuencias registradas',
        before: beforeDecision,
        after: afterDecision,
        consequences: option.consequences,
      ),
      const SizedBox(height: 16),
      if (studentType != null)
        _FeedbackPanel(
          correct: studentType == option.type,
          realType: option.type,
          feedback: option.feedback,
        )
      else
        Panel(
          child: Text(
            option.feedback,
            style: context.texts.bodySmall?.copyWith(height: 1.45),
          ),
        ),
      const SizedBox(height: 16),
      ..._buildClosing(
        events: events,
        afterDecision: afterDecision,
        run: run,
      ),
    ];
  }
}

class _ContextPanel extends StatelessWidget {
  const _ContextPanel({
    required this.title,
    required this.context_,
    required this.question,
    required this.period,
  });

  final String title;
  final String context_;
  final String question;
  final String period;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Tag(label: period, icon: Icons.schedule, color: context.scheme.tertiary),
          const SizedBox(height: 10),
          Text(
            title,
            style: context.texts.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800, height: 1.25),
          ),
          const SizedBox(height: 8),
          Text(
            context_,
            style: context.texts.bodySmall?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: context.palette.surfaceSunken,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: context.scheme.outlineVariant),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.help_outline,
                    size: 16, color: context.scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    question,
                    style: context.texts.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  const _FeedbackPanel({
    required this.correct,
    required this.realType,
    required this.feedback,
  });

  final bool correct;
  final MeasureType realType;
  final String feedback;

  @override
  Widget build(BuildContext context) {
    final color = correct ? context.palette.positive : context.palette.negative;
    return Panel(
      borderColor: withOpacityValue(color, 0.5),
      background: withOpacityValue(color, 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                correct ? Icons.check_circle_outline : Icons.info_outline,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  correct
                      ? 'Clasificación correcta: ${realType.label}'
                      : 'La medida corresponde a: ${realType.label}',
                  style: context.texts.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            feedback,
            style: context.texts.bodySmall?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
