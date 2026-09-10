/// Periodos de la linea temporal climatica educativa de ExploraClima.
///
/// Los anios son referencias didacticas: NO corresponden a proyecciones
/// cientificas oficiales.
enum ClimatePeriod { actual, corto, mediano, largo }

extension ClimatePeriodX on ClimatePeriod {
  int get index0 {
    switch (this) {
      case ClimatePeriod.actual:
        return 0;
      case ClimatePeriod.corto:
        return 1;
      case ClimatePeriod.mediano:
        return 2;
      case ClimatePeriod.largo:
        return 3;
    }
  }

  String get label {
    switch (this) {
      case ClimatePeriod.actual:
        return 'Actualidad';
      case ClimatePeriod.corto:
        return 'Corto plazo';
      case ClimatePeriod.mediano:
        return 'Mediano plazo';
      case ClimatePeriod.largo:
        return 'Largo plazo';
    }
  }

  String get shortLabel {
    switch (this) {
      case ClimatePeriod.actual:
        return 'Hoy';
      case ClimatePeriod.corto:
        return 'Corto';
      case ClimatePeriod.mediano:
        return 'Mediano';
      case ClimatePeriod.largo:
        return 'Largo';
    }
  }

  /// Anio educativo de referencia (dato simulado con fines didacticos).
  String get referenceYear {
    switch (this) {
      case ClimatePeriod.actual:
        return '2025';
      case ClimatePeriod.corto:
        return '2035';
      case ClimatePeriod.mediano:
        return '2050';
      case ClimatePeriod.largo:
        return '2080';
    }
  }

  String get horizonDescription {
    switch (this) {
      case ClimatePeriod.actual:
        return 'Situación de partida observada en el caso.';
      case ClimatePeriod.corto:
        return 'Primeras consecuencias de las decisiones recientes.';
      case ClimatePeriod.mediano:
        return 'Las tendencias se consolidan y aparecen efectos acumulados.';
      case ClimatePeriod.largo:
        return 'Se observa el efecto sostenido de la estrategia elegida.';
    }
  }
}

const List<ClimatePeriod> kAllPeriods = ClimatePeriod.values;

ClimatePeriod periodFromIndex(int index) =>
    kAllPeriods[index.clamp(0, kAllPeriods.length - 1)];

ClimatePeriod periodFromName(String name) => kAllPeriods.firstWhere(
      (p) => p.name == name,
      orElse: () => ClimatePeriod.actual,
    );
