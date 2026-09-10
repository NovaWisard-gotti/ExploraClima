import 'package:flutter/material.dart';

/// Indicadores climaticos educativos utilizados por ExploraClima.
/// Todos son valores SIMULADOS con fines didacticos.
enum ClimateIndicator {
  emisiones,
  temperatura,
  agua,
  vegetacion,
  presion,
  energia,
  vulnerabilidad,
}

@immutable
class IndicatorMeta {
  const IndicatorMeta({
    required this.id,
    required this.label,
    required this.shortLabel,
    required this.unit,
    required this.icon,
    required this.lowerIsBetter,
    required this.min,
    required this.max,
    required this.decimals,
    required this.description,
    required this.signPrefix,
  });

  final ClimateIndicator id;
  final String label;
  final String shortLabel;
  final String unit;
  final IconData icon;

  /// true = un valor mas bajo representa una mejor situacion ambiental.
  final bool lowerIsBetter;
  final double min;
  final double max;
  final int decimals;
  final String description;

  /// Prefijo mostrado delante del valor (por ejemplo "+" en anomalia termica).
  final String signPrefix;

  String format(double value) {
    final text = value.toStringAsFixed(decimals);
    return '$signPrefix$text';
  }

  String formatWithUnit(double value) => '${format(value)} $unit';

  /// Posicion relativa (0..1) del valor dentro del rango del indicador.
  double normalize(double value) {
    if (max <= min) return 0;
    return ((value - min) / (max - min)).clamp(0.0, 1.0);
  }
}

const Map<ClimateIndicator, IndicatorMeta> kIndicatorMeta =
    <ClimateIndicator, IndicatorMeta>{
  ClimateIndicator.emisiones: IndicatorMeta(
    id: ClimateIndicator.emisiones,
    label: 'Emisiones relativas',
    shortLabel: 'Emisiones',
    unit: 'idx',
    icon: Icons.cloud_outlined,
    lowerIsBetter: true,
    min: 20,
    max: 180,
    decimals: 0,
    signPrefix: '',
    description:
        'Índice relativo de gases de efecto invernadero del caso. 100 equivale '
        'a la situación de partida.',
  ),
  ClimateIndicator.temperatura: IndicatorMeta(
    id: ClimateIndicator.temperatura,
    label: 'Temperatura simulada',
    shortLabel: 'Temperatura',
    unit: '°C',
    icon: Icons.thermostat_outlined,
    lowerIsBetter: true,
    min: 0.4,
    max: 4.5,
    decimals: 2,
    signPrefix: '+',
    description:
        'Anomalía térmica simulada respecto al periodo de referencia del caso.',
  ),
  ClimateIndicator.agua: IndicatorMeta(
    id: ClimateIndicator.agua,
    label: 'Disponibilidad hídrica',
    shortLabel: 'Agua',
    unit: 'idx',
    icon: Icons.water_drop_outlined,
    lowerIsBetter: false,
    min: 0,
    max: 100,
    decimals: 0,
    signPrefix: '',
    description:
        'Disponibilidad relativa de agua para la población y los ecosistemas '
        'del territorio analizado.',
  ),
  ClimateIndicator.vegetacion: IndicatorMeta(
    id: ClimateIndicator.vegetacion,
    label: 'Cobertura vegetal',
    shortLabel: 'Vegetación',
    unit: 'idx',
    icon: Icons.park_outlined,
    lowerIsBetter: false,
    min: 0,
    max: 100,
    decimals: 0,
    signPrefix: '',
    description:
        'Superficie con cobertura vegetal funcional: bosques, áreas verdes y '
        'suelos protegidos.',
  ),
  ClimateIndicator.presion: IndicatorMeta(
    id: ClimateIndicator.presion,
    label: 'Presión sobre ecosistemas',
    shortLabel: 'Presión',
    unit: 'idx',
    icon: Icons.compress,
    lowerIsBetter: true,
    min: 0,
    max: 100,
    decimals: 0,
    signPrefix: '',
    description:
        'Nivel de exigencia que las actividades humanas ejercen sobre los '
        'ecosistemas locales.',
  ),
  ClimateIndicator.energia: IndicatorMeta(
    id: ClimateIndicator.energia,
    label: 'Consumo energético',
    shortLabel: 'Energía',
    unit: 'idx',
    icon: Icons.bolt_outlined,
    lowerIsBetter: true,
    min: 20,
    max: 160,
    decimals: 0,
    signPrefix: '',
    description:
        'Demanda energética relativa del territorio, incluyendo transporte, '
        'industria y edificaciones.',
  ),
  ClimateIndicator.vulnerabilidad: IndicatorMeta(
    id: ClimateIndicator.vulnerabilidad,
    label: 'Vulnerabilidad territorial',
    shortLabel: 'Vulnerabilidad',
    unit: 'idx',
    icon: Icons.shield_outlined,
    lowerIsBetter: true,
    min: 0,
    max: 100,
    decimals: 0,
    signPrefix: '',
    description:
        'Grado de exposición y fragilidad del territorio frente a amenazas '
        'climáticas. Baja cuando aumenta la capacidad de adaptación.',
  ),
};

IndicatorMeta metaOf(ClimateIndicator id) => kIndicatorMeta[id]!;

const List<ClimateIndicator> kAllIndicators = ClimateIndicator.values;

ClimateIndicator indicatorFromName(String name) => kAllIndicators.firstWhere(
      (i) => i.name == name,
      orElse: () => ClimateIndicator.emisiones,
    );

/// Conjunto de valores de indicadores en un momento de la linea temporal.
@immutable
class ClimateState {
  const ClimateState(this.values);

  final Map<ClimateIndicator, double> values;

  double operator [](ClimateIndicator id) => values[id] ?? 0;

  double get(ClimateIndicator id) => values[id] ?? 0;

  ClimateState apply(Map<ClimateIndicator, double> deltas, {double factor = 1}) {
    final next = Map<ClimateIndicator, double>.from(values);
    deltas.forEach((key, value) {
      final meta = metaOf(key);
      final raw = (next[key] ?? 0) + value * factor;
      next[key] = raw.clamp(meta.min, meta.max).toDouble();
    });
    return ClimateState(next);
  }

  ClimateState clamped() {
    final next = <ClimateIndicator, double>{};
    values.forEach((key, value) {
      final meta = metaOf(key);
      next[key] = value.clamp(meta.min, meta.max).toDouble();
    });
    return ClimateState(next);
  }

  Map<String, double> toJson() =>
      values.map((key, value) => MapEntry(key.name, value));

  static ClimateState fromJson(Map<String, dynamic> json) {
    final values = <ClimateIndicator, double>{};
    json.forEach((key, value) {
      values[indicatorFromName(key)] = (value as num).toDouble();
    });
    return ClimateState(values);
  }
}
