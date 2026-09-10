import 'package:flutter/material.dart';

import 'decision.dart';
import 'indicator.dart';

/// Enfoque educativo dominante de un escenario.
enum ScenarioFocus { continuidad, mitigacion, usoSuelo, adaptacion }

extension ScenarioFocusX on ScenarioFocus {
  String get label {
    switch (this) {
      case ScenarioFocus.continuidad:
        return 'Continuidad actual';
      case ScenarioFocus.mitigacion:
        return 'Reducción de emisiones';
      case ScenarioFocus.usoSuelo:
        return 'Cambio de uso del suelo';
      case ScenarioFocus.adaptacion:
        return 'Adaptación territorial';
    }
  }

  IconData get icon {
    switch (this) {
      case ScenarioFocus.continuidad:
        return Icons.timeline;
      case ScenarioFocus.mitigacion:
        return Icons.trending_down;
      case ScenarioFocus.usoSuelo:
        return Icons.terrain_outlined;
      case ScenarioFocus.adaptacion:
        return Icons.shield_moon_outlined;
    }
  }
}

@immutable
class ClimateScenario {
  const ClimateScenario({
    required this.id,
    required this.name,
    required this.tagline,
    required this.focus,
    required this.territory,
    required this.briefing,
    required this.keyQuestion,
    required this.learningGoals,
    required this.baseline,
    required this.drift,
    required this.stages,
    required this.events,
    required this.highlightIndicators,
  });

  final String id;
  final String name;
  final String tagline;
  final ScenarioFocus focus;

  /// Territorio ficticio utilizado con fines educativos.
  final String territory;
  final String briefing;
  final String keyQuestion;
  final List<String> learningGoals;

  /// Situacion de partida (periodo "actualidad").
  final Map<ClimateIndicator, double> baseline;

  /// Tendencia por periodo si no se toma ninguna decision.
  final Map<ClimateIndicator, double> drift;

  final List<DecisionStage> stages;
  final List<ClimateEvent> events;

  /// Indicadores mas relevantes del caso (se muestran destacados).
  final List<ClimateIndicator> highlightIndicators;

  ClimateState get baselineState => ClimateState(baseline).clamped();

  List<ClimateEvent> eventsAfterStage(int stageIndex) =>
      events.where((e) => e.afterStage == stageIndex).toList();
}
