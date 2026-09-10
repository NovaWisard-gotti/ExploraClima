import 'package:exploraclima/data/models/climate_period.dart';
import 'package:exploraclima/data/models/decision.dart';
import 'package:exploraclima/data/models/indicator.dart';
import 'package:exploraclima/data/scenarios/scenario_data.dart';
import 'package:exploraclima/domain/scenario_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Catálogo de escenarios', () {
    test('incluye cuatro escenarios con tres etapas y tres opciones', () {
      expect(ScenarioCatalog.all.length, 4);
      for (final scenario in ScenarioCatalog.all) {
        expect(scenario.stages.length, 3);
        for (final stage in scenario.stages) {
          expect(stage.options.length, 3);
        }
        expect(scenario.events, isNotEmpty);
        expect(scenario.baseline.length, kAllIndicators.length);
      }
    });

    test('las etapas siguen el orden de la línea temporal', () {
      for (final scenario in ScenarioCatalog.all) {
        expect(scenario.stages[0].period, ClimatePeriod.corto);
        expect(scenario.stages[1].period, ClimatePeriod.mediano);
        expect(scenario.stages[2].period, ClimatePeriod.largo);
      }
    });
  });

  group('Motor de proyección', () {
    final scenario = ScenarioCatalog.byId('continuidad');

    test('la trayectoria base sigue la tendencia del escenario', () {
      final actual = ScenarioEngine.project(scenario, ClimatePeriod.actual);
      final largo = ScenarioEngine.project(scenario, ClimatePeriod.largo);
      expect(
        largo.get(ClimateIndicator.emisiones),
        greaterThan(actual.get(ClimateIndicator.emisiones)),
      );
      expect(
        largo.get(ClimateIndicator.agua),
        lessThan(actual.get(ClimateIndicator.agua)),
      );
    });

    test('una medida de mitigación reduce las emisiones frente a la base', () {
      final choices = <int, String>{0: 'cont-s1-c'};
      final withChoice = ScenarioEngine.project(
        scenario,
        ClimatePeriod.largo,
        choices: choices,
      );
      final withoutChoice =
          ScenarioEngine.project(scenario, ClimatePeriod.largo);
      expect(
        withChoice.get(ClimateIndicator.emisiones),
        lessThan(withoutChoice.get(ClimateIndicator.emisiones)),
      );
    });

    test('los valores permanecen dentro del rango de cada indicador', () {
      for (final scenario in ScenarioCatalog.all) {
        for (final period in kAllPeriods) {
          final state = ScenarioEngine.project(scenario, period);
          for (final indicator in kAllIndicators) {
            final meta = metaOf(indicator);
            expect(state.get(indicator), greaterThanOrEqualTo(meta.min));
            expect(state.get(indicator), lessThanOrEqualTo(meta.max));
          }
        }
      }
    });
  });

  group('Evaluación del escenario', () {
    test('una estrategia integrada mejora el balance frente a la inacción', () {
      final scenario = ScenarioCatalog.byId('adaptacion');
      final integrada = ScenarioEngine.evaluate(scenario, <int, String>{
        0: 'ada-s1-a',
        1: 'ada-s2-b',
        2: 'ada-s3-c',
      });
      final pasiva = ScenarioEngine.evaluate(scenario, <int, String>{
        0: 'ada-s1-b',
        1: 'ada-s2-a',
        2: 'ada-s3-b',
      });
      expect(integrada.balance, greaterThan(pasiva.balance));
      expect(integrada.highlights, isNotEmpty);
    });

    test('la etiqueta de estrategia refleja las medidas elegidas', () {
      expect(
        ScenarioEngine.strategyLabel(<MeasureType>[
          MeasureType.mitigacion,
          MeasureType.mitigacion,
          MeasureType.ninguna,
        ]),
        'Estrategia centrada en mitigación',
      );
      expect(
        ScenarioEngine.strategyLabel(<MeasureType>[
          MeasureType.ninguna,
          MeasureType.ninguna,
        ]),
        'Baja intervención',
      );
    });
  });
}
