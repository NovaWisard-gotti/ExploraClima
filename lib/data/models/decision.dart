import 'package:flutter/material.dart';

import 'climate_period.dart';
import 'indicator.dart';

/// Funcion principal de una medida frente al cambio climatico.
enum MeasureType { mitigacion, adaptacion, ambas, ninguna }

extension MeasureTypeX on MeasureType {
  String get label {
    switch (this) {
      case MeasureType.mitigacion:
        return 'Mitigación';
      case MeasureType.adaptacion:
        return 'Adaptación';
      case MeasureType.ambas:
        return 'Mitigación y adaptación';
      case MeasureType.ninguna:
        return 'Ninguna de las dos';
    }
  }

  String get shortLabel {
    switch (this) {
      case MeasureType.mitigacion:
        return 'Mitigación';
      case MeasureType.adaptacion:
        return 'Adaptación';
      case MeasureType.ambas:
        return 'Ambas';
      case MeasureType.ninguna:
        return 'Ninguna';
    }
  }

  IconData get icon {
    switch (this) {
      case MeasureType.mitigacion:
        return Icons.trending_down;
      case MeasureType.adaptacion:
        return Icons.security_outlined;
      case MeasureType.ambas:
        return Icons.hub_outlined;
      case MeasureType.ninguna:
        return Icons.remove_circle_outline;
    }
  }

  String get definition {
    switch (this) {
      case MeasureType.mitigacion:
        return 'Actúa sobre las causas: reduce emisiones o aumenta la captura '
            'de carbono.';
      case MeasureType.adaptacion:
        return 'Actúa sobre las consecuencias: reduce la vulnerabilidad del '
            'territorio frente a los impactos.';
      case MeasureType.ambas:
        return 'Reduce emisiones y al mismo tiempo disminuye la '
            'vulnerabilidad del territorio.';
      case MeasureType.ninguna:
        return 'No modifica de forma significativa ni las emisiones ni la '
            'vulnerabilidad.';
    }
  }
}

MeasureType measureTypeFromName(String name) => MeasureType.values.firstWhere(
      (m) => m.name == name,
      orElse: () => MeasureType.ninguna,
    );

/// Una opcion concreta dentro de una tarjeta de decision.
@immutable
class DecisionOption {
  const DecisionOption({
    required this.id,
    required this.title,
    required this.action,
    required this.cost,
    required this.benefit,
    required this.scope,
    required this.effects,
    required this.type,
    required this.consequences,
    required this.feedback,
  });

  final String id;
  final String title;

  /// Accion propuesta, redactada como decision profesional.
  final String action;

  /// Costo o dificultad relativa (1 = baja, 3 = alta).
  final int cost;

  /// Beneficio esperado declarado ANTES de decidir (sin revelar la respuesta).
  final String benefit;

  /// Alcance de la medida (local, sectorial, regional...).
  final String scope;

  /// Efecto sobre los indicadores, aplicado desde el periodo de la decision.
  final Map<ClimateIndicator, double> effects;

  final MeasureType type;

  /// Consecuencias observables mostradas despues de decidir.
  final List<String> consequences;

  /// Explicacion educativa de por que la decision produce esos efectos.
  final String feedback;

  String get costLabel {
    switch (cost) {
      case 1:
        return 'Costo o dificultad baja';
      case 2:
        return 'Costo o dificultad media';
      default:
        return 'Costo o dificultad alta';
    }
  }
}

/// Etapa de decision asociada a un periodo de la linea temporal.
@immutable
class DecisionStage {
  const DecisionStage({
    required this.id,
    required this.period,
    required this.title,
    required this.context,
    required this.question,
    required this.options,
  });

  final String id;
  final ClimatePeriod period;
  final String title;
  final String context;
  final String question;
  final List<DecisionOption> options;

  DecisionOption optionById(String id) =>
      options.firstWhere((o) => o.id == id, orElse: () => options.first);
}

/// Evento climatico educativo que ocurre despues de una etapa.
@immutable
class ClimateEvent {
  const ClimateEvent({
    required this.id,
    required this.afterStage,
    required this.title,
    required this.description,
    required this.effects,
    required this.bufferIndicator,
    required this.bufferThreshold,
    required this.bufferedNote,
    required this.exposedNote,
  });

  final String id;

  /// Indice de la etapa despues de la cual ocurre el evento.
  final int afterStage;
  final String title;
  final String description;

  /// Impacto base del evento sobre los indicadores.
  final Map<ClimateIndicator, double> effects;

  /// Indicador que amortigua el evento (normalmente vulnerabilidad).
  final ClimateIndicator bufferIndicator;

  /// Si el indicador amortiguador esta por debajo del umbral, el impacto se
  /// reduce a la mitad.
  final double bufferThreshold;
  final String bufferedNote;
  final String exposedNote;
}
