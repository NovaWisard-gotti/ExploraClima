import '../data/models/climate_period.dart';
import '../data/models/decision.dart';
import '../data/models/indicator.dart';
import '../data/models/scenario.dart';

/// Resultado educativo de un escenario completado.
class ScenarioOutcome {
  const ScenarioOutcome({
    required this.strategy,
    required this.outcome,
    required this.highlights,
    required this.finalState,
    required this.baselineFinal,
    required this.balance,
  });

  final String strategy;
  final String outcome;
  final List<String> highlights;
  final ClimateState finalState;
  final ClimateState baselineFinal;

  /// Balance global respecto a la trayectoria sin intervención (-1 .. 1).
  final double balance;
}

/// Motor de proyeccion educativo de ExploraClima.
///
/// Es determinista y explicable: cada variacion mostrada al estudiante puede
/// rastrearse hasta la tendencia del escenario, una decision o un evento.
/// NO es un modelo climatico cientifico.
class ScenarioEngine {
  const ScenarioEngine._();

  /// Maduracion de una medida segun los periodos transcurridos desde que se
  /// tomo la decision.
  static double maturityFactor(int periodsElapsed) {
    if (periodsElapsed <= 0) return 0.6;
    if (periodsElapsed == 1) return 1.0;
    return 1.25;
  }

  /// Proyecta el estado del escenario en un periodo dado.
  static ClimateState project(
    ClimateScenario scenario,
    ClimatePeriod period, {
    Map<int, String> choices = const <int, String>{},
    bool includeEvents = true,
  }) {
    final target = period.index0;
    final values = <ClimateIndicator, double>{};
    scenario.baseline.forEach((key, value) {
      values[key] = value + (scenario.drift[key] ?? 0) * target;
    });
    var state = ClimateState(values).clamped();

    for (var stageIndex = 0; stageIndex < scenario.stages.length; stageIndex++) {
      final stage = scenario.stages[stageIndex];
      final stagePeriod = stage.period.index0;
      if (stagePeriod > target) break;
      final optionId = choices[stageIndex];
      if (optionId == null) continue;

      final option = stage.optionById(optionId);
      state = state.apply(
        option.effects,
        factor: maturityFactor(target - stagePeriod),
      );

      if (includeEvents) {
        for (final event in scenario.eventsAfterStage(stageIndex)) {
          final buffered = isEventBuffered(scenario, event, choices);
          final decay = (target - stagePeriod) >= 1 ? 0.85 : 1.0;
          state = state.apply(
            event.effects,
            factor: (buffered ? 0.5 : 1.0) * decay,
          );
        }
      }
    }
    return state;
  }

  /// Un evento se amortigua cuando el territorio llego suficientemente
  /// preparado (por ejemplo, con baja vulnerabilidad).
  static bool isEventBuffered(
    ClimateScenario scenario,
    ClimateEvent event,
    Map<int, String> choices,
  ) {
    final stage = scenario.stages[event.afterStage];
    final limited = <int, String>{};
    choices.forEach((key, value) {
      if (key <= event.afterStage) limited[key] = value;
    });
    final state = project(
      scenario,
      stage.period,
      choices: limited,
      includeEvents: false,
    );
    final meta = metaOf(event.bufferIndicator);
    final value = state.get(event.bufferIndicator);
    return meta.lowerIsBetter
        ? value <= event.bufferThreshold
        : value >= event.bufferThreshold;
  }

  /// Serie completa de un indicador a lo largo de la linea temporal.
  static List<double> series(
    ClimateScenario scenario,
    ClimateIndicator indicator, {
    Map<int, String> choices = const <int, String>{},
    bool includeEvents = true,
  }) {
    return kAllPeriods
        .map((p) => project(
              scenario,
              p,
              choices: choices,
              includeEvents: includeEvents,
            ).get(indicator))
        .toList();
  }

  /// Diferencia normalizada (-1 .. 1) donde un valor positivo significa
  /// "mejor situacion ambiental" que la referencia.
  static double improvement(
    ClimateIndicator indicator,
    double value,
    double reference,
  ) {
    final meta = metaOf(indicator);
    final range = meta.max - meta.min;
    if (range <= 0) return 0;
    final raw = (reference - value) / range;
    final oriented = meta.lowerIsBetter ? raw : -raw;
    return oriented.clamp(-1.0, 1.0).toDouble();
  }

  static String strategyLabel(List<MeasureType> types) {
    final mit = types
        .where((t) => t == MeasureType.mitigacion || t == MeasureType.ambas)
        .length;
    final adap = types
        .where((t) => t == MeasureType.adaptacion || t == MeasureType.ambas)
        .length;
    if (mit == 0 && adap == 0) return 'Baja intervención';
    if (mit >= 2 && adap >= 2) return 'Estrategia integrada';
    if (mit > adap) return 'Estrategia centrada en mitigación';
    if (adap > mit) return 'Estrategia centrada en adaptación';
    return 'Estrategia mixta';
  }

  /// Evalua el resultado final del escenario comparandolo con la trayectoria
  /// sin intervención.
  static ScenarioOutcome evaluate(
    ClimateScenario scenario,
    Map<int, String> choices,
  ) {
    final finalState = project(
      scenario,
      ClimatePeriod.largo,
      choices: choices,
    );
    final baselineFinal = project(scenario, ClimatePeriod.largo);

    var sum = 0.0;
    final highlights = <String>[];
    for (final indicator in kAllIndicators) {
      final meta = metaOf(indicator);
      final value = finalState.get(indicator);
      final reference = baselineFinal.get(indicator);
      final imp = improvement(indicator, value, reference);
      sum += imp;
      if (imp.abs() >= 0.03) {
        final better = imp > 0;
        final diff = (value - reference).abs();
        highlights.add(
          '${meta.label}: ${meta.format(value)} ${meta.unit} frente a '
          '${meta.format(reference)} ${meta.unit} sin intervención '
          '(${better ? 'mejora' : 'deterioro'} de ${diff.toStringAsFixed(meta.decimals)} ${meta.unit}).',
        );
      }
    }
    final balance = sum / kAllIndicators.length;

    final types = <MeasureType>[];
    choices.forEach((stageIndex, optionId) {
      types.add(scenario.stages[stageIndex].optionById(optionId).type);
    });

    String outcome;
    if (balance >= 0.06) {
      outcome = 'Trayectoria favorable';
    } else if (balance >= 0.02) {
      outcome = 'Mejora parcial';
    } else if (balance > -0.02) {
      outcome = 'Cambios poco significativos';
    } else {
      outcome = 'Trayectoria desfavorable';
    }

    if (highlights.isEmpty) {
      highlights.add(
        'Las decisiones tomadas no modificaron de forma apreciable la '
        'trayectoria del escenario.',
      );
    }

    return ScenarioOutcome(
      strategy: strategyLabel(types),
      outcome: outcome,
      highlights: highlights,
      finalState: finalState,
      baselineFinal: baselineFinal,
      balance: balance,
    );
  }

  /// Explicacion breve del comportamiento de un indicador en el tiempo.
  static String trendDescription(List<double> values, ClimateIndicator indicator) {
    if (values.length < 2) return 'Sin variación registrada.';
    final meta = metaOf(indicator);
    final diff = values.last - values.first;
    final range = meta.max - meta.min;
    final relative = range == 0 ? 0.0 : diff.abs() / range;
    if (relative < 0.02) {
      return 'Se mantiene prácticamente estable a lo largo del periodo analizado.';
    }
    final rising = diff > 0;
    final favourable = meta.lowerIsBetter ? !rising : rising;
    final intensity = relative > 0.18
        ? 'marcada'
        : relative > 0.08
            ? 'moderada'
            : 'leve';
    return 'Tendencia ${rising ? 'creciente' : 'decreciente'} $intensity '
        '(${favourable ? 'favorable' : 'desfavorable'} para el territorio).';
  }
}
