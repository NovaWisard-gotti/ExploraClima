import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_palette.dart';
import '../../core/widgets/common.dart';
import '../../data/models/attempt.dart';
import '../../data/models/climate_period.dart';
import '../../domain/scenario_engine.dart';
import '../../state/providers.dart';
import '../../state/scenario_run_controller.dart';
import '../compare/attempts_compare_screen.dart';
import '../widgets/attempt_report.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key, required this.scenarioId});

  final String scenarioId;

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  AttemptRecord? _record;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepareRecord());
  }

  void _prepareRecord() {
    final run = ref.read(scenarioRunProvider(widget.scenarioId));
    if (!run.isComplete) return;

    if (run.saved) {
      final existing = ref
          .read(attemptsProvider)
          .where((a) => a.scenarioId == widget.scenarioId)
          .toList();
      if (existing.isNotEmpty) {
        setState(() => _record = existing.first);
        return;
      }
    }

    final record = _buildRecord();
    if (!run.saved) {
      ref.read(attemptsProvider.notifier).add(record);
      ref.read(scenarioRunProvider(widget.scenarioId).notifier).markSaved();
    }
    setState(() => _record = record);
  }

  AttemptRecord _buildRecord() {
    final run = ref.read(scenarioRunProvider(widget.scenarioId));
    final scenario = run.scenario;
    final choices = run.choices;
    final outcome = ScenarioEngine.evaluate(scenario, choices);

    final attemptChoices = <AttemptChoice>[];
    final events = <String>[];
    for (final resolution in run.resolutions) {
      final stage = scenario.stages[resolution.stageIndex];
      final option = stage.optionById(resolution.optionId);
      attemptChoices.add(
        AttemptChoice(
          stageIndex: resolution.stageIndex,
          stageTitle: stage.title,
          period: stage.period,
          optionId: option.id,
          optionTitle: option.title,
          realType: option.type,
          studentType: resolution.studentType,
        ),
      );
      for (final event in scenario.eventsAfterStage(resolution.stageIndex)) {
        final buffered =
            ScenarioEngine.isEventBuffered(scenario, event, choices);
        events.add(
          '${event.title} — ${buffered ? 'impacto amortiguado' : 'impacto completo'}',
        );
      }
    }

    return AttemptRecord(
      id: 'att-${DateTime.now().microsecondsSinceEpoch}',
      scenarioId: scenario.id,
      scenarioName: scenario.name,
      date: DateTime.now(),
      choices: attemptChoices,
      initial: ScenarioEngine.project(scenario, ClimatePeriod.actual),
      finalState: outcome.finalState,
      baselineFinal: outcome.baselineFinal,
      events: events,
      strategy: outcome.strategy,
      outcome: outcome.outcome,
      highlights: outcome.highlights,
    );
  }

  @override
  Widget build(BuildContext context) {
    final record = _record;
    final attempts = ref.watch(attemptsForScenarioProvider(widget.scenarioId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informe del escenario'),
      ),
      body: record == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
              children: <Widget>[
                Panel(
                  background:
                      withOpacityValue(context.palette.positive, 0.10),
                  borderColor: withOpacityValue(context.palette.positive, 0.45),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.save_outlined,
                          size: 18, color: context.palette.positive),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Resultado guardado en el historial del dispositivo.',
                          style:
                              context.texts.bodySmall?.copyWith(height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AttemptReportView(attempt: record),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      ref
                          .read(scenarioRunProvider(widget.scenarioId).notifier)
                          .restart();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.replay),
                    label: const Text('Repetir escenario con otras decisiones'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: attempts.length < 2
                        ? null
                        : () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => AttemptsCompareScreen(
                                  scenarioId: widget.scenarioId,
                                ),
                              ),
                            ),
                    icon: const Icon(Icons.compare_arrows),
                    label: Text(
                      attempts.length < 2
                          ? 'Comparación de intentos (requiere 2)'
                          : 'Comparar con otro intento',
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
