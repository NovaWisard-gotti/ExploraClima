import 'climate_period.dart';
import 'decision.dart';
import 'indicator.dart';

/// Decision registrada dentro de un intento.
class AttemptChoice {
  const AttemptChoice({
    required this.stageIndex,
    required this.stageTitle,
    required this.period,
    required this.optionId,
    required this.optionTitle,
    required this.realType,
    required this.studentType,
  });

  final int stageIndex;
  final String stageTitle;
  final ClimatePeriod period;
  final String optionId;
  final String optionTitle;
  final MeasureType realType;

  /// Clasificacion elegida por el estudiante (mitigacion / adaptacion / ...).
  final MeasureType? studentType;

  bool get classifiedCorrectly => studentType != null && studentType == realType;

  Map<String, dynamic> toJson() => {
        'stageIndex': stageIndex,
        'stageTitle': stageTitle,
        'period': period.name,
        'optionId': optionId,
        'optionTitle': optionTitle,
        'realType': realType.name,
        'studentType': studentType?.name,
      };

  static AttemptChoice fromJson(Map<String, dynamic> json) => AttemptChoice(
        stageIndex: json['stageIndex'] as int,
        stageTitle: json['stageTitle'] as String,
        period: periodFromName(json['period'] as String),
        optionId: json['optionId'] as String,
        optionTitle: json['optionTitle'] as String,
        realType: measureTypeFromName(json['realType'] as String),
        studentType: json['studentType'] == null
            ? null
            : measureTypeFromName(json['studentType'] as String),
      );
}

/// Resultado completo de un escenario finalizado.
class AttemptRecord {
  const AttemptRecord({
    required this.id,
    required this.scenarioId,
    required this.scenarioName,
    required this.date,
    required this.choices,
    required this.initial,
    required this.finalState,
    required this.baselineFinal,
    required this.events,
    required this.strategy,
    required this.outcome,
    required this.highlights,
  });

  final String id;
  final String scenarioId;
  final String scenarioName;
  final DateTime date;
  final List<AttemptChoice> choices;

  /// Indicadores en la actualidad.
  final ClimateState initial;

  /// Indicadores al largo plazo con las decisiones tomadas.
  final ClimateState finalState;

  /// Indicadores al largo plazo si no se hubiese intervenido.
  final ClimateState baselineFinal;

  final List<String> events;
  final String strategy;
  final String outcome;
  final List<String> highlights;

  int get mitigationCount => choices
      .where((c) =>
          c.realType == MeasureType.mitigacion || c.realType == MeasureType.ambas)
      .length;

  int get adaptationCount => choices
      .where((c) =>
          c.realType == MeasureType.adaptacion || c.realType == MeasureType.ambas)
      .length;

  int get classificationHits => choices.where((c) => c.classifiedCorrectly).length;

  int get classificationTotal =>
      choices.where((c) => c.studentType != null).length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'scenarioId': scenarioId,
        'scenarioName': scenarioName,
        'date': date.toIso8601String(),
        'choices': choices.map((c) => c.toJson()).toList(),
        'initial': initial.toJson(),
        'final': finalState.toJson(),
        'baselineFinal': baselineFinal.toJson(),
        'events': events,
        'strategy': strategy,
        'outcome': outcome,
        'highlights': highlights,
      };

  static AttemptRecord fromJson(Map<String, dynamic> json) => AttemptRecord(
        id: json['id'] as String,
        scenarioId: json['scenarioId'] as String,
        scenarioName: json['scenarioName'] as String,
        date: DateTime.parse(json['date'] as String),
        choices: (json['choices'] as List<dynamic>)
            .map((e) => AttemptChoice.fromJson(e as Map<String, dynamic>))
            .toList(),
        initial: ClimateState.fromJson(
            Map<String, dynamic>.from(json['initial'] as Map)),
        finalState: ClimateState.fromJson(
            Map<String, dynamic>.from(json['final'] as Map)),
        baselineFinal: ClimateState.fromJson(
            Map<String, dynamic>.from(json['baselineFinal'] as Map)),
        events: (json['events'] as List<dynamic>).map((e) => e as String).toList(),
        strategy: json['strategy'] as String,
        outcome: json['outcome'] as String,
        highlights:
            (json['highlights'] as List<dynamic>).map((e) => e as String).toList(),
      );
}

/// Contadores de actividad que no derivan de los intentos guardados.
class ActivityCounters {
  const ActivityCounters({
    this.comparisons = 0,
    this.attemptComparisons = 0,
    this.carbonAnalyses = 0,
    this.energyExplorations = 0,
    this.glossaryConsults = 0,
  });

  final int comparisons;
  final int attemptComparisons;
  final int carbonAnalyses;
  final int energyExplorations;
  final int glossaryConsults;

  ActivityCounters copyWith({
    int? comparisons,
    int? attemptComparisons,
    int? carbonAnalyses,
    int? energyExplorations,
    int? glossaryConsults,
  }) =>
      ActivityCounters(
        comparisons: comparisons ?? this.comparisons,
        attemptComparisons: attemptComparisons ?? this.attemptComparisons,
        carbonAnalyses: carbonAnalyses ?? this.carbonAnalyses,
        energyExplorations: energyExplorations ?? this.energyExplorations,
        glossaryConsults: glossaryConsults ?? this.glossaryConsults,
      );

  Map<String, dynamic> toJson() => {
        'comparisons': comparisons,
        'attemptComparisons': attemptComparisons,
        'carbonAnalyses': carbonAnalyses,
        'energyExplorations': energyExplorations,
        'glossaryConsults': glossaryConsults,
      };

  static ActivityCounters fromJson(Map<String, dynamic> json) => ActivityCounters(
        comparisons: (json['comparisons'] as num?)?.toInt() ?? 0,
        attemptComparisons: (json['attemptComparisons'] as num?)?.toInt() ?? 0,
        carbonAnalyses: (json['carbonAnalyses'] as num?)?.toInt() ?? 0,
        energyExplorations: (json['energyExplorations'] as num?)?.toInt() ?? 0,
        glossaryConsults: (json['glossaryConsults'] as num?)?.toInt() ?? 0,
      );
}
