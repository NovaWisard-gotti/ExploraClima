import 'package:flutter/material.dart';

import '../models/carbon.dart';

/// Datos de referencia de la sección de huella de carbono.
///
/// Los valores son relativos y educativos: sirven para comparar el peso de
/// unas actividades frente a otras, no para calcular una huella certificada.
class CarbonData {
  const CarbonData._();

  static const List<CarbonCategory> categories = <CarbonCategory>[
    CarbonCategory(
      id: 'transporte',
      label: 'Transporte',
      icon: Icons.directions_bus_outlined,
      note:
          'Desplazamientos habituales de una semana típica del estudiante.',
      options: <CarbonOption>[
        CarbonOption(
          id: 'auto-solo',
          label: 'Automóvil particular todos los días',
          relativeValue: 62,
          detail: 'Un solo ocupante, recorrido urbano diario.',
        ),
        CarbonOption(
          id: 'auto-compartido',
          label: 'Automóvil compartido',
          relativeValue: 38,
          detail: 'El mismo recorrido dividido entre varias personas.',
        ),
        CarbonOption(
          id: 'publico',
          label: 'Transporte público',
          relativeValue: 16,
          detail: 'Alta ocupación por vehículo y menor emisión por pasajero.',
        ),
        CarbonOption(
          id: 'activo',
          label: 'Bicicleta o caminata',
          relativeValue: 4,
          detail: 'Movilidad activa, sin emisiones directas.',
        ),
      ],
    ),
    CarbonCategory(
      id: 'energia',
      label: 'Energía en el hogar',
      icon: Icons.bolt_outlined,
      note: 'Electricidad, climatización y agua caliente de la vivienda.',
      options: <CarbonOption>[
        CarbonOption(
          id: 'intensivo',
          label: 'Climatización intensiva con fuente fósil',
          relativeValue: 48,
          detail: 'Vivienda sin aislamiento y uso prolongado de equipos.',
        ),
        CarbonOption(
          id: 'medio',
          label: 'Consumo medio sin medidas de eficiencia',
          relativeValue: 30,
          detail: 'Equipos antiguos y sin control de consumo.',
        ),
        CarbonOption(
          id: 'eficiente',
          label: 'Vivienda eficiente',
          relativeValue: 16,
          detail: 'Aislamiento, iluminación eficiente y equipos de bajo consumo.',
        ),
        CarbonOption(
          id: 'renovable',
          label: 'Vivienda eficiente con generación renovable',
          relativeValue: 7,
          detail: 'Eficiencia más autogeneración solar para consumo propio.',
        ),
      ],
    ),
    CarbonCategory(
      id: 'consumo',
      label: 'Consumo y alimentación',
      icon: Icons.shopping_basket_outlined,
      note: 'Alimentos, bienes y su cadena de transporte asociada.',
      options: <CarbonOption>[
        CarbonOption(
          id: 'alto',
          label: 'Carne diaria y muchos productos importados',
          relativeValue: 55,
          detail: 'Cadena de suministro larga y alimentos de alta huella.',
        ),
        CarbonOption(
          id: 'mixto',
          label: 'Dieta mixta con consumo moderado',
          relativeValue: 34,
          detail: 'Equilibrio entre productos locales e importados.',
        ),
        CarbonOption(
          id: 'local',
          label: 'Mayoritariamente local y de temporada',
          relativeValue: 20,
          detail: 'Menor transporte y menos refrigeración prolongada.',
        ),
        CarbonOption(
          id: 'vegetal',
          label: 'Base vegetal y pocas compras nuevas',
          relativeValue: 12,
          detail: 'Alimentos de baja huella y reutilización de bienes.',
        ),
      ],
    ),
    CarbonCategory(
      id: 'suelo',
      label: 'Residuos y uso del suelo',
      icon: Icons.compost_outlined,
      note:
          'Gestión de residuos orgánicos y presencia de vegetación en el entorno.',
      options: <CarbonOption>[
        CarbonOption(
          id: 'sin-gestion',
          label: 'Sin separación ni áreas verdes',
          relativeValue: 22,
          detail: 'Orgánicos a relleno sanitario, generando metano.',
        ),
        CarbonOption(
          id: 'separacion',
          label: 'Separación de residuos',
          relativeValue: 15,
          detail: 'Reciclaje sin tratamiento de la fracción orgánica.',
        ),
        CarbonOption(
          id: 'compost',
          label: 'Compostaje doméstico',
          relativeValue: 8,
          detail: 'La fracción orgánica se trata y retorna al suelo.',
        ),
        CarbonOption(
          id: 'compost-verde',
          label: 'Compostaje y vegetación en el entorno',
          relativeValue: 3,
          detail: 'Compostaje más huerto o arborización que capturan carbono.',
        ),
      ],
    ),
  ];

  static CarbonCategory categoryById(String id) =>
      categories.firstWhere((c) => c.id == id, orElse: () => categories.first);

  /// Perfil inicial: nivel intermedio en cada categoría.
  static CarbonProfile get defaultProfile => const CarbonProfile(<String, String>{
        'transporte': 'auto-compartido',
        'energia': 'medio',
        'consumo': 'mixto',
        'suelo': 'separacion',
      });

  static double totalFor(CarbonProfile profile) {
    var total = 0.0;
    for (final category in categories) {
      final optionId = profile.selection[category.id];
      if (optionId == null) continue;
      total += category.optionById(optionId).relativeValue;
    }
    return total;
  }

  /// Huella mínima alcanzable eligiendo la mejor opción de cada categoría.
  static double get minimumTotal =>
      categories.fold(0.0, (acc, c) => acc + c.lowest.relativeValue);

  static double get maximumTotal => categories.fold(
        0.0,
        (acc, c) => acc + c.options.map((o) => o.relativeValue).reduce((a, b) => a > b ? a : b),
      );
}

/// Consulta rápida: definiciones breves y contextuales.
class GlossaryData {
  const GlossaryData._();

  static const List<GlossaryEntry> entries = <GlossaryEntry>[
    GlossaryEntry(
      group: 'Conceptos base',
      term: 'Cambio climático',
      definition:
          'Variación sostenida del clima atribuida directa o indirectamente a '
          'la actividad humana, que se suma a la variabilidad natural.',
      example:
          'En ExploraClima se observa como una tendencia sostenida de los '
          'indicadores a lo largo de la línea temporal.',
    ),
    GlossaryEntry(
      group: 'Conceptos base',
      term: 'Gases de efecto invernadero',
      definition:
          'Gases que retienen parte de la radiación infrarroja emitida por la '
          'superficie terrestre, como el CO₂, el metano y el óxido nitroso.',
      example:
          'El indicador de emisiones relativas representa su magnitud conjunta '
          'de forma simplificada.',
    ),
    GlossaryEntry(
      group: 'Conceptos base',
      term: 'Escenario climático',
      definition:
          'Descripción coherente de un futuro posible construida a partir de '
          'supuestos sobre decisiones y condiciones del territorio.',
      example:
          'Un escenario no es una predicción: sirve para comparar alternativas.',
    ),
    GlossaryEntry(
      group: 'Respuestas',
      term: 'Mitigación',
      definition:
          'Conjunto de acciones que reducen las emisiones de gases de efecto '
          'invernadero o aumentan su captura.',
      example:
          'Sustituir generación térmica por renovables, o conservar bosques '
          'que almacenan carbono.',
    ),
    GlossaryEntry(
      group: 'Respuestas',
      term: 'Adaptación',
      definition:
          'Ajustes en sistemas naturales o humanos que reducen el daño '
          'esperado frente a los impactos del clima.',
      example:
          'Drenaje urbano sostenible, alertas tempranas o reubicación de '
          'viviendas en zonas de riesgo.',
    ),
    GlossaryEntry(
      group: 'Respuestas',
      term: 'Mala adaptación',
      definition:
          'Medida que reduce un impacto inmediato pero incrementa el riesgo, '
          'las emisiones o la presión ambiental a futuro.',
      example:
          'Responder al calor extremo únicamente con más aire acondicionado '
          'alimentado por energía fósil.',
    ),
    GlossaryEntry(
      group: 'Respuestas',
      term: 'Solución basada en ecosistemas',
      definition:
          'Uso de la conservación o restauración de ecosistemas para reducir '
          'el riesgo climático y capturar carbono al mismo tiempo.',
      example:
          'Recuperar humedales costeros para amortiguar marejadas y almacenar '
          'carbono.',
    ),
    GlossaryEntry(
      group: 'Riesgo',
      term: 'Vulnerabilidad',
      definition:
          'Predisposición de un sistema o una población a sufrir daño ante una '
          'amenaza, según su exposición y su capacidad de respuesta.',
      example:
          'Un barrio en llanura de inundación sin drenaje presenta alta '
          'vulnerabilidad.',
    ),
    GlossaryEntry(
      group: 'Riesgo',
      term: 'Resiliencia',
      definition:
          'Capacidad de un territorio para absorber una perturbación, '
          'recuperarse y reorganizarse manteniendo sus funciones esenciales.',
      example:
          'Una ciudad resiliente restablece sus servicios con rapidez tras una '
          'inundación.',
    ),
    GlossaryEntry(
      group: 'Riesgo',
      term: 'Exposición',
      definition:
          'Presencia de personas, bienes o ecosistemas en lugares que pueden '
          'verse afectados por una amenaza climática.',
      example:
          'Ampliar el puerto sobre el frente costero incrementa la exposición.',
    ),
    GlossaryEntry(
      group: 'Medición',
      term: 'Huella de carbono',
      definition:
          'Cantidad total de gases de efecto invernadero asociada de forma '
          'directa o indirecta a una actividad, persona u organización.',
      example:
          'En la sección de huella se comparan actividades por su peso '
          'relativo, no por su valor absoluto.',
    ),
    GlossaryEntry(
      group: 'Medición',
      term: 'Indicador climático',
      definition:
          'Variable que resume el estado o la evolución de un componente del '
          'sistema climático o del territorio.',
      example:
          'Emisiones relativas, disponibilidad hídrica o cobertura vegetal.',
    ),
    GlossaryEntry(
      group: 'Energía',
      term: 'Transición energética',
      definition:
          'Proceso de cambio desde una matriz basada en combustibles fósiles '
          'hacia fuentes de baja emisión, acompañado de mayor eficiencia.',
      example:
          'Reemplazar centrales térmicas por generación renovable con '
          'almacenamiento.',
    ),
    GlossaryEntry(
      group: 'Energía',
      term: 'Eficiencia energética',
      definition:
          'Obtener el mismo servicio con menor consumo de energía mediante '
          'mejoras técnicas o de gestión.',
      example:
          'Aislar edificios reduce el consumo de climatización sin perder '
          'confort.',
    ),
    GlossaryEntry(
      group: 'Territorio',
      term: 'Uso del suelo',
      definition:
          'Forma en que se ocupa y aprovecha el territorio, con efectos '
          'directos sobre el carbono almacenado, el agua y el riesgo.',
      example:
          'Convertir bosque en cultivo libera carbono y reduce la regulación '
          'hídrica.',
    ),
    GlossaryEntry(
      group: 'Territorio',
      term: 'Servicio ecosistémico',
      definition:
          'Beneficio que las personas obtienen del funcionamiento de los '
          'ecosistemas, como regulación hídrica, sombra o control de erosión.',
      example:
          'El bosque de cabecera sostiene el caudal del río durante la '
          'temporada seca.',
    ),
  ];

  static List<String> get groups {
    final result = <String>[];
    for (final entry in entries) {
      if (!result.contains(entry.group)) result.add(entry.group);
    }
    return result;
  }
}
