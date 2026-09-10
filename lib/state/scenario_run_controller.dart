import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/climate_period.dart';
import '../data/models/decision.dart';
import '../data/models/indicator.dart';
import '../data/models/scenario.dart';
import '../data/scenarios/scenario_data.dart';

/// Decisión resuelta dentro de un recorrido.
class StageResolution {
  const StageResolution({
    required this.stageIndex,
    required this.optionId,
    this.studentType,
  });

  final int stageIndex;
  final String optionId;
  final MeasureType? studentType;

  StageResolution copyWith({MeasureType? studentType}) => StageResolution(
        stageIndex: stageIndex,
        optionId: optionId,
        studentType: studentType ?? this.studentType,
      );
}

/// Estado de la exploración de un escenario.
class ScenarioRunState {
  const ScenarioRunState({
    required this.scenario,
    required this.resolutions,
    required this.selectedPeriod,
    required this.focusIndicator,
    required this.startedAt,
    required this.saved,
  });

  final ClimateScenario scenario;
  final List<StageResolution> resolutions;
  final ClimatePeriod selectedPeriod;
  final ClimateIndicator focusIndicator;
  final DateTime startedAt;

  /// Indica si el resultado ya se guardó en el historial.
  final bool saved;

  Map<int, String> get choices => <int, String>{
        for (final r in resolutions) r.stageIndex: r.optionId,
      };

  int get resolvedCount => resolutions.length;

  bool get isComplete => resolutions.length >= scenario.stages.length;

  /// Índice de la siguiente etapa pendiente (o -1 si no quedan etapas).
  int get nextStageIndex => isComplete ? -1 : resolutions.length;

  StageResolution? resolutionFor(int stageIndex) {
    for (final r in resolutions) {
      if (r.stageIndex == stageIndex) return r;
    }
    return null;
  }

  /// Etapas ya resueltas cuyo evento asociado debe mostrarse.
  List<ClimateEvent> get triggeredEvents {
    final events = <ClimateEvent>[];
    for (final r in resolutions) {
      events.addAll(scenario.eventsAfterStage(r.stageIndex));
    }
    return events;
  }

  ScenarioRunState copyWith({
    List<StageResolution>? resolutions,
    ClimatePeriod? selectedPeriod,
    ClimateIndicator? focusIndicator,
    bool? saved,
  }) =>
      ScenarioRunState(
        scenario: scenario,
        resolutions: resolutions ?? this.resolutions,
        selectedPeriod: selectedPeriod ?? this.selectedPeriod,
        focusIndicator: focusIndicator ?? this.focusIndicator,
        startedAt: startedAt,
        saved: saved ?? this.saved,
      );
}

class ScenarioRunController extends StateNotifier<ScenarioRunState> {
  ScenarioRunController(ClimateScenario scenario)
      : super(ScenarioRunState(
          scenario: scenario,
          resolutions: const <StageResolution>[],
          selectedPeriod: ClimatePeriod.actual,
          focusIndicator: scenario.highlightIndicators.first,
          startedAt: DateTime.now(),
          saved: false,
        ));

  void selectPeriod(ClimatePeriod period) {
    state = state.copyWith(selectedPeriod: period);
  }

  void selectIndicator(ClimateIndicator indicator) {
    state = state.copyWith(focusIndicator: indicator);
  }

  void chooseOption(int stageIndex, String optionId) {
    final existing = state.resolutionFor(stageIndex);
    final updated = <StageResolution>[
      ...state.resolutions.where((r) => r.stageIndex != stageIndex),
      StageResolution(
        stageIndex: stageIndex,
        optionId: optionId,
        studentType: existing?.studentType,
      ),
    ]..sort((a, b) => a.stageIndex.compareTo(b.stageIndex));

    final stage = state.scenario.stages[stageIndex];
    state = state.copyWith(
      resolutions: updated,
      selectedPeriod: stage.period,
    );
  }

  void classify(int stageIndex, MeasureType type) {
    final updated = state.resolutions
        .map((r) => r.stageIndex == stageIndex ? r.copyWith(studentType: type) : r)
        .toList();
    state = state.copyWith(resolutions: updated);
  }

  void markSaved() {
    state = state.copyWith(saved: true);
  }

  void restart() {
    state = ScenarioRunState(
      scenario: state.scenario,
      resolutions: const <StageResolution>[],
      selectedPeriod: ClimatePeriod.actual,
      focusIndicator: state.scenario.highlightIndicators.first,
      startedAt: DateTime.now(),
      saved: false,
    );
  }
}

final scenarioRunProvider = StateNotifierProvider.family<ScenarioRunController,
    ScenarioRunState, String>((ref, scenarioId) {
  return ScenarioRunController(ScenarioCatalog.byId(scenarioId));
});
