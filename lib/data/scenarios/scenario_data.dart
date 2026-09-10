import '../models/climate_period.dart';
import '../models/decision.dart';
import '../models/indicator.dart';
import '../models/scenario.dart';

/// Catálogo de escenarios climáticos educativos de ExploraClima.
///
/// Todos los territorios son ficticios y todos los valores son SIMULADOS con
/// fines didácticos. No constituyen proyecciones científicas oficiales.
class ScenarioCatalog {
  const ScenarioCatalog._();

  static const List<ClimateScenario> all = <ClimateScenario>[
    _continuidad,
    _mitigacion,
    _usoSuelo,
    _adaptacion,
  ];

  static ClimateScenario byId(String id) =>
      all.firstWhere((s) => s.id == id, orElse: () => all.first);

  // ---------------------------------------------------------------------------
  // ESCENARIO 1 — CONTINUIDAD ACTUAL
  // ---------------------------------------------------------------------------

  static const ClimateScenario _continuidad = ClimateScenario(
    id: 'continuidad',
    name: 'Continuidad actual',
    tagline: 'Valle de San Andrés · sin cambios de rumbo',
    focus: ScenarioFocus.continuidad,
    territory:
        'Valle agrícola con una ciudad intermedia de 180 000 habitantes, '
        'abastecida por un río de régimen estacional.',
    briefing:
        'El valle mantiene sus prácticas actuales: la demanda energética y el '
        'consumo de agua crecen cada año, mientras la superficie agrícola se '
        'expande sin planificación. Ninguna autoridad ha propuesto un cambio '
        'de modelo. Tu tarea es observar hacia dónde conduce esta trayectoria '
        'y qué ocurre cuando se interviene tarde.',
    keyQuestion:
        '¿Qué consecuencias acumula un territorio cuando las decisiones se '
        'postergan?',
    learningGoals: <String>[
      'Interpretar una tendencia climática sostenida en el tiempo.',
      'Reconocer que no decidir también produce consecuencias.',
      'Analizar el efecto de intervenir tarde frente a intervenir a tiempo.',
    ],
    highlightIndicators: <ClimateIndicator>[
      ClimateIndicator.emisiones,
      ClimateIndicator.agua,
      ClimateIndicator.temperatura,
    ],
    baseline: <ClimateIndicator, double>{
      ClimateIndicator.emisiones: 100,
      ClimateIndicator.temperatura: 1.20,
      ClimateIndicator.agua: 62,
      ClimateIndicator.vegetacion: 55,
      ClimateIndicator.presion: 48,
      ClimateIndicator.energia: 70,
      ClimateIndicator.vulnerabilidad: 45,
    },
    drift: <ClimateIndicator, double>{
      ClimateIndicator.emisiones: 10,
      ClimateIndicator.temperatura: 0.30,
      ClimateIndicator.agua: -6,
      ClimateIndicator.vegetacion: -5,
      ClimateIndicator.presion: 7,
      ClimateIndicator.energia: 8,
      ClimateIndicator.vulnerabilidad: 5,
    },
    stages: <DecisionStage>[
      DecisionStage(
        id: 'cont-s1',
        period: ClimatePeriod.corto,
        title: 'Crecimiento sin cambio de rumbo',
        context:
            'La demanda eléctrica del valle creció un 4 % anual durante la '
            'última década y la generación proviene principalmente de fuentes '
            'térmicas. El municipio debe responder al aumento previsto de '
            'consumo.',
        question: '¿Cómo responde el territorio al aumento de la demanda?',
        options: <DecisionOption>[
          DecisionOption(
            id: 'cont-s1-a',
            title: 'Mantener el plan vigente',
            action:
                'No modificar la planificación energética ni introducir metas '
                'de eficiencia.',
            cost: 1,
            benefit: 'Sin costo adicional ni conflicto con los sectores productivos.',
            scope: 'Todo el valle',
            type: MeasureType.ninguna,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.emisiones: 3,
              ClimateIndicator.presion: 2,
            },
            consequences: <String>[
              'La tendencia del escenario continúa sin variación.',
              'Las emisiones siguen la trayectoria previa y se suman al crecimiento propio del territorio.',
            ],
            feedback:
                'No intervenir no equivale a un efecto nulo: la tendencia base '
                'del escenario sigue operando y sus efectos se acumulan '
                'periodo tras periodo.',
          ),
          DecisionOption(
            id: 'cont-s1-b',
            title: 'Ampliar la generación térmica',
            action:
                'Instalar nueva capacidad térmica para cubrir el crecimiento '
                'de la demanda en el corto plazo.',
            cost: 2,
            benefit: 'Suministro asegurado durante los picos de consumo.',
            scope: 'Sistema eléctrico regional',
            type: MeasureType.ninguna,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.emisiones: 11,
              ClimateIndicator.energia: 6,
              ClimateIndicator.presion: 3,
              ClimateIndicator.temperatura: 0.05,
            },
            consequences: <String>[
              'Las emisiones relativas se aceleran por encima de la tendencia base.',
              'Aumenta la dependencia de combustibles fósiles para las décadas siguientes.',
            ],
            feedback:
                'La medida resuelve un problema operativo inmediato, pero '
                'incorpora infraestructura de larga vida que consolida '
                'emisiones futuras. No es mitigación ni adaptación.',
          ),
          DecisionOption(
            id: 'cont-s1-c',
            title: 'Programa voluntario de eficiencia',
            action:
                'Promover eficiencia energética en industria y edificaciones '
                'mediante incentivos, sin metas obligatorias.',
            cost: 1,
            benefit: 'Reducción moderada del consumo con baja resistencia social.',
            scope: 'Sector industrial y comercial',
            type: MeasureType.mitigacion,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.emisiones: -7,
              ClimateIndicator.energia: -8,
            },
            consequences: <String>[
              'El consumo energético crece más lentamente que la tendencia base.',
              'La reducción de emisiones es real pero insuficiente para revertir la trayectoria.',
            ],
            feedback:
                'Es mitigación: actúa sobre la causa reduciendo emisiones. Su '
                'alcance voluntario limita el efecto, que resulta menor que la '
                'tendencia de crecimiento del escenario.',
          ),
        ],
      ),
      DecisionStage(
        id: 'cont-s2',
        period: ClimatePeriod.mediano,
        title: 'Tensión sobre el agua',
        context:
            'Tras un periodo seco prolongado, el caudal del río disminuyó y la '
            'competencia entre uso agrícola y uso urbano se hizo evidente. La '
            'ciudad exige una respuesta.',
        question: '¿Qué medida se prioriza frente a la escasez hídrica?',
        options: <DecisionOption>[
          DecisionOption(
            id: 'cont-s2-a',
            title: 'Ampliar la captación superficial',
            action:
                'Aumentar la extracción del río y perforar nuevos pozos para '
                'sostener la demanda actual.',
            cost: 2,
            benefit: 'Disponibilidad inmediata de agua para ciudad y agricultura.',
            scope: 'Cuenca del valle',
            type: MeasureType.adaptacion,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.agua: 7,
              ClimateIndicator.presion: 9,
              ClimateIndicator.vulnerabilidad: -4,
              ClimateIndicator.emisiones: 2,
            },
            consequences: <String>[
              'La disponibilidad hídrica mejora en el corto plazo.',
              'La presión sobre los ecosistemas de la cuenca aumenta de forma sostenida.',
            ],
            feedback:
                'Reduce la exposición inmediata, por lo que su función es de '
                'adaptación, pero es un ejemplo de mala adaptación: resuelve '
                'el problema presente aumentando la presión ambiental y el '
                'riesgo futuro.',
          ),
          DecisionOption(
            id: 'cont-s2-b',
            title: 'Eficiencia hídrica y reúso',
            action:
                'Modernizar el riego, reducir pérdidas en la red y reutilizar '
                'agua tratada en usos no potables.',
            cost: 3,
            benefit: 'Menor demanda de agua con el mismo nivel de actividad.',
            scope: 'Ciudad y sector agrícola',
            type: MeasureType.adaptacion,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.agua: 10,
              ClimateIndicator.presion: -4,
              ClimateIndicator.vulnerabilidad: -8,
              ClimateIndicator.energia: 2,
            },
            consequences: <String>[
              'La disponibilidad hídrica mejora sin aumentar la extracción.',
              'El territorio resiste mejor los siguientes periodos secos.',
            ],
            feedback:
                'Es adaptación de calidad: reduce la vulnerabilidad frente a '
                'la escasez sin trasladar el problema al ecosistema. No reduce '
                'emisiones, por lo que no sustituye a la mitigación.',
          ),
          DecisionOption(
            id: 'cont-s2-c',
            title: 'Postergar la decisión',
            action:
                'Encargar un estudio y aplazar cualquier medida hasta el '
                'siguiente periodo de gobierno.',
            cost: 1,
            benefit: 'Se evita el conflicto político entre sectores.',
            scope: 'Sin alcance operativo',
            type: MeasureType.ninguna,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.vulnerabilidad: 4,
              ClimateIndicator.agua: -2,
            },
            consequences: <String>[
              'La vulnerabilidad del territorio continúa creciendo.',
              'El siguiente evento climático encontrará al valle sin preparación.',
            ],
            feedback:
                'Postergar mantiene intacta la tendencia negativa y reduce el '
                'margen de maniobra: las medidas aplicadas más tarde disponen '
                'de menos tiempo para madurar.',
          ),
        ],
      ),
      DecisionStage(
        id: 'cont-s3',
        period: ClimatePeriod.largo,
        title: 'Balance de la trayectoria',
        context:
            'Los indicadores acumulados muestran el resultado del modelo '
            'seguido hasta ahora. Existe una última oportunidad de modificar '
            'la trayectoria antes del cierre del horizonte analizado.',
        question: '¿Con qué estrategia se cierra el horizonte de análisis?',
        options: <DecisionOption>[
          DecisionOption(
            id: 'cont-s3-a',
            title: 'Continuar con el modelo actual',
            action: 'Mantener el patrón de crecimiento sin cambios estructurales.',
            cost: 1,
            benefit: 'Continuidad de la actividad económica en su forma actual.',
            scope: 'Todo el valle',
            type: MeasureType.ninguna,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.emisiones: 5,
              ClimateIndicator.presion: 4,
              ClimateIndicator.vulnerabilidad: 4,
            },
            consequences: <String>[
              'Los indicadores cierran el horizonte en su peor posición.',
              'La recuperación posterior exigiría un esfuerzo mucho mayor.',
            ],
            feedback:
                'La continuidad sostenida durante todos los periodos muestra '
                'el efecto acumulativo de la inacción: pequeñas diferencias '
                'por periodo producen una brecha final considerable.',
          ),
          DecisionOption(
            id: 'cont-s3-b',
            title: 'Transición energética tardía',
            action:
                'Iniciar el reemplazo de la generación térmica por fuentes '
                'renovables en el último tramo del horizonte.',
            cost: 3,
            benefit: 'Reducción significativa de emisiones a futuro.',
            scope: 'Sistema eléctrico regional',
            type: MeasureType.mitigacion,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.emisiones: -14,
              ClimateIndicator.energia: -9,
              ClimateIndicator.temperatura: -0.06,
            },
            consequences: <String>[
              'Las emisiones descienden, pero la medida dispone de poco tiempo para madurar.',
              'La temperatura simulada apenas se modifica dentro del horizonte analizado.',
            ],
            feedback:
                'Es mitigación correcta aplicada tarde. Compara su efecto con '
                'el de la misma familia de medidas tomada en el corto plazo: '
                'el momento de la decisión cambia el resultado.',
          ),
          DecisionOption(
            id: 'cont-s3-c',
            title: 'Programa de resiliencia territorial',
            action:
                'Proteger infraestructura crítica, ordenar el uso del suelo y '
                'preparar sistemas de alerta.',
            cost: 2,
            benefit: 'Menor daño esperado ante eventos extremos.',
            scope: 'Ciudad e infraestructura del valle',
            type: MeasureType.adaptacion,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.vulnerabilidad: -13,
              ClimateIndicator.agua: 4,
              ClimateIndicator.presion: -3,
            },
            consequences: <String>[
              'El territorio queda mejor preparado frente a impactos futuros.',
              'Las emisiones mantienen su trayectoria: la causa no fue atendida.',
            ],
            feedback:
                'Es adaptación: reduce el daño esperado sin actuar sobre las '
                'emisiones. Un territorio puede volverse más resiliente y '
                'seguir contribuyendo al problema global.',
          ),
        ],
      ),
    ],
    events: <ClimateEvent>[
      ClimateEvent(
        id: 'cont-ev1',
        afterStage: 0,
        title: 'Periodo seco prolongado',
        description:
            'Dos temporadas consecutivas con precipitación por debajo del '
            'promedio reducen el caudal disponible y tensionan el riego.',
        effects: <ClimateIndicator, double>{
          ClimateIndicator.agua: -9,
          ClimateIndicator.presion: 5,
          ClimateIndicator.vulnerabilidad: 5,
          ClimateIndicator.vegetacion: -3,
        },
        bufferIndicator: ClimateIndicator.vulnerabilidad,
        bufferThreshold: 46,
        bufferedNote:
            'El territorio llegó con vulnerabilidad contenida: el impacto del '
            'periodo seco se redujo a la mitad.',
        exposedNote:
            'El territorio llegó vulnerable al evento y recibió el impacto '
            'completo.',
      ),
      ClimateEvent(
        id: 'cont-ev2',
        afterStage: 1,
        title: 'Verano con demanda eléctrica récord',
        description:
            'Las altas temperaturas disparan el uso de refrigeración y el '
            'sistema eléctrico opera al límite durante varias semanas.',
        effects: <ClimateIndicator, double>{
          ClimateIndicator.energia: 8,
          ClimateIndicator.emisiones: 6,
          ClimateIndicator.temperatura: 0.04,
        },
        bufferIndicator: ClimateIndicator.energia,
        bufferThreshold: 84,
        bufferedNote:
            'El consumo previo era moderado: el sistema absorbió el pico sin '
            'un salto brusco de emisiones.',
        exposedNote:
            'El consumo ya era elevado y el pico se cubrió con generación de '
            'respaldo intensiva en emisiones.',
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // ESCENARIO 2 — REDUCCIÓN DE EMISIONES
  // ---------------------------------------------------------------------------

  static const ClimateScenario _mitigacion = ClimateScenario(
    id: 'mitigacion',
    name: 'Reducción de emisiones',
    tagline: 'Área metropolitana de Valdeluz · transición energética',
    focus: ScenarioFocus.mitigacion,
    territory:
        'Área metropolitana de 1,2 millones de habitantes con matriz eléctrica '
        'fósil, transporte privado dominante y actividad industrial relevante.',
    briefing:
        'Valdeluz aprobó una meta de reducción de emisiones para el horizonte '
        'analizado, pero no definió cómo alcanzarla. Deberás elegir en qué '
        'sector actuar primero y comprobar qué combinación de medidas modifica '
        'realmente la trayectoria de emisiones.',
    keyQuestion:
        '¿Qué decisiones reducen emisiones de forma significativa y cuáles '
        'solo lo aparentan?',
    learningGoals: <String>[
      'Distinguir medidas de mitigación según su magnitud real.',
      'Relacionar matriz energética, movilidad y consumo con las emisiones.',
      'Comprender que reducir emisiones no reduce automáticamente la vulnerabilidad.',
    ],
    highlightIndicators: <ClimateIndicator>[
      ClimateIndicator.emisiones,
      ClimateIndicator.energia,
      ClimateIndicator.temperatura,
    ],
    baseline: <ClimateIndicator, double>{
      ClimateIndicator.emisiones: 118,
      ClimateIndicator.temperatura: 1.35,
      ClimateIndicator.agua: 58,
      ClimateIndicator.vegetacion: 40,
      ClimateIndicator.presion: 60,
      ClimateIndicator.energia: 95,
      ClimateIndicator.vulnerabilidad: 48,
    },
    drift: <ClimateIndicator, double>{
      ClimateIndicator.emisiones: 9,
      ClimateIndicator.temperatura: 0.28,
      ClimateIndicator.agua: -4,
      ClimateIndicator.vegetacion: -3,
      ClimateIndicator.presion: 5,
      ClimateIndicator.energia: 7,
      ClimateIndicator.vulnerabilidad: 3,
    },
    stages: <DecisionStage>[
      DecisionStage(
        id: 'mit-s1',
        period: ClimatePeriod.corto,
        title: 'Matriz energética',
        context:
            'El 70 % de la electricidad metropolitana proviene de centrales '
            'térmicas próximas al final de su vida útil. Debe decidirse su '
            'reemplazo.',
        question: '¿Con qué se reemplaza la capacidad que sale de servicio?',
        options: <DecisionOption>[
          DecisionOption(
            id: 'mit-s1-a',
            title: 'Renovables con almacenamiento',
            action:
                'Instalar generación solar y eólica con baterías para cubrir '
                'las horas de mayor demanda.',
            cost: 3,
            benefit: 'Reducción estructural de emisiones del sistema eléctrico.',
            scope: 'Sistema eléctrico metropolitano',
            type: MeasureType.mitigacion,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.emisiones: -17,
              ClimateIndicator.energia: -4,
              ClimateIndicator.temperatura: -0.08,
              ClimateIndicator.presion: -2,
            },
            consequences: <String>[
              'Las emisiones se separan de forma clara de la trayectoria base.',
              'El efecto se amplía en los periodos siguientes al madurar la inversión.',
            ],
            feedback:
                'Mitigación de alto impacto: actúa sobre la fuente principal '
                'de emisiones. Su costo es elevado, pero decidida temprano '
                'dispone de tres periodos para madurar.',
          ),
          DecisionOption(
            id: 'mit-s1-b',
            title: 'Reemplazo por gas natural',
            action:
                'Sustituir las centrales antiguas por ciclos combinados de gas '
                'natural.',
            cost: 2,
            benefit: 'Menores emisiones por unidad generada que el carbón o el diésel.',
            scope: 'Sistema eléctrico metropolitano',
            type: MeasureType.mitigacion,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.emisiones: -8,
              ClimateIndicator.energia: -2,
            },
            consequences: <String>[
              'Las emisiones bajan respecto a la situación previa, pero siguen creciendo con el tiempo.',
              'La infraestructura fósil queda comprometida por varias décadas.',
            ],
            feedback:
                'Es mitigación parcial: reduce emisiones por unidad generada '
                'sin eliminar la dependencia fósil. Compárala con la opción '
                'renovable en el largo plazo.',
          ),
          DecisionOption(
            id: 'mit-s1-c',
            title: 'Compensar con arbolado urbano',
            action:
                'Mantener la matriz actual y financiar un plan intensivo de '
                'arbolado y áreas verdes urbanas.',
            cost: 1,
            benefit: 'Captura de carbono y reducción del efecto isla de calor.',
            scope: 'Espacio público urbano',
            type: MeasureType.ambas,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.emisiones: -4,
              ClimateIndicator.vegetacion: 9,
              ClimateIndicator.temperatura: -0.05,
              ClimateIndicator.vulnerabilidad: -5,
            },
            consequences: <String>[
              'Mejora la cobertura vegetal y la sensación térmica urbana.',
              'La fuente principal de emisiones permanece sin modificar.',
            ],
            feedback:
                'Cumple ambas funciones: captura carbono (mitigación) y reduce '
                'la exposición al calor (adaptación). Su magnitud, sin embargo, '
                'no compensa la generación fósil que se mantiene.',
          ),
        ],
      ),
      DecisionStage(
        id: 'mit-s2',
        period: ClimatePeriod.mediano,
        title: 'Movilidad urbana',
        context:
            'El transporte representa la segunda fuente de emisiones del área '
            'metropolitana. La congestión aumenta y el parque automotor privado '
            'crece cada año.',
        question: '¿Qué modelo de movilidad se impulsa?',
        options: <DecisionOption>[
          DecisionOption(
            id: 'mit-s2-a',
            title: 'Corredor de transporte público eléctrico',
            action:
                'Construir un corredor troncal eléctrico con red alimentadora '
                'e integración tarifaria.',
            cost: 3,
            benefit: 'Traslado masivo de viajes desde el vehículo privado.',
            scope: 'Área metropolitana',
            type: MeasureType.mitigacion,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.emisiones: -14,
              ClimateIndicator.energia: -10,
              ClimateIndicator.presion: -3,
            },
            consequences: <String>[
              'Baja el consumo energético del transporte y las emisiones asociadas.',
              'El efecto depende de que el sistema eléctrico también se descarbonice.',
            ],
            feedback:
                'Mitigación estructural: cambia el modo de transporte, no solo '
                'la tecnología del vehículo. Su efecto se combina con las '
                'decisiones tomadas sobre la matriz energética.',
          ),
          DecisionOption(
            id: 'mit-s2-b',
            title: 'Renovación de flota privada',
            action:
                'Incentivar el reemplazo de vehículos antiguos por modelos '
                'nuevos más eficientes.',
            cost: 2,
            benefit: 'Menor consumo por vehículo circulante.',
            scope: 'Parque automotor privado',
            type: MeasureType.mitigacion,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.emisiones: -6,
              ClimateIndicator.energia: -3,
            },
            consequences: <String>[
              'Reducción moderada de emisiones por vehículo.',
              'El número total de viajes en auto no disminuye.',
            ],
            feedback:
                'Es mitigación de alcance limitado: mejora la eficiencia '
                'unitaria mientras el volumen de viajes sigue creciendo.',
          ),
          DecisionOption(
            id: 'mit-s2-c',
            title: 'Ampliación de vías urbanas',
            action:
                'Ampliar avenidas y construir nuevos pasos a desnivel para '
                'reducir la congestión.',
            cost: 2,
            benefit: 'Menor tiempo de viaje en el corto plazo.',
            scope: 'Red vial metropolitana',
            type: MeasureType.ninguna,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.emisiones: 7,
              ClimateIndicator.energia: 6,
              ClimateIndicator.vegetacion: -5,
              ClimateIndicator.presion: 5,
            },
            consequences: <String>[
              'El tráfico vuelve a saturarse y las emisiones aumentan.',
              'Se pierde superficie verde en el proceso.',
            ],
            feedback:
                'No es mitigación ni adaptación: la mayor capacidad vial '
                'induce más viajes en vehículo privado, un efecto conocido '
                'como demanda inducida.',
          ),
        ],
      ),
      DecisionStage(
        id: 'mit-s3',
        period: ClimatePeriod.largo,
        title: 'Industria y edificaciones',
        context:
            'Queda por atender el consumo de la industria y de los edificios, '
            'responsable de una parte importante de la demanda energética '
            'metropolitana.',
        question: '¿Dónde se concentra el último tramo del esfuerzo?',
        options: <DecisionOption>[
          DecisionOption(
            id: 'mit-s3-a',
            title: 'Estándar de eficiencia en edificaciones',
            action:
                'Exigir aislamiento, ventilación y climatización pasiva en '
                'edificios nuevos y en rehabilitaciones.',
            cost: 2,
            benefit: 'Menor demanda energética y mejor confort térmico interior.',
            scope: 'Parque edificado',
            type: MeasureType.ambas,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.energia: -13,
              ClimateIndicator.emisiones: -9,
              ClimateIndicator.vulnerabilidad: -7,
              ClimateIndicator.temperatura: -0.04,
            },
            consequences: <String>[
              'Baja el consumo energético y las emisiones asociadas.',
              'Los edificios resisten mejor las olas de calor.',
            ],
            feedback:
                'Ejemplo claro de medida con doble función: reduce emisiones '
                'y a la vez disminuye la vulnerabilidad de la población frente '
                'al calor extremo.',
          ),
          DecisionOption(
            id: 'mit-s3-b',
            title: 'Eficiencia en procesos industriales',
            action:
                'Modernizar hornos, motores y sistemas de vapor de la industria '
                'metropolitana.',
            cost: 3,
            benefit: 'Reducción directa de emisiones del sector industrial.',
            scope: 'Sector industrial',
            type: MeasureType.mitigacion,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.emisiones: -15,
              ClimateIndicator.energia: -6,
              ClimateIndicator.presion: -2,
            },
            consequences: <String>[
              'Las emisiones industriales descienden de forma apreciable.',
              'La vulnerabilidad del territorio permanece sin cambios.',
            ],
            feedback:
                'Mitigación de alto impacto sectorial. Observa que un buen '
                'resultado en emisiones puede coexistir con un territorio '
                'igualmente expuesto a los impactos climáticos.',
          ),
          DecisionOption(
            id: 'mit-s3-c',
            title: 'Campaña de sensibilización',
            action:
                'Difundir buenas prácticas de consumo responsable sin metas '
                'obligatorias ni fiscalización.',
            cost: 1,
            benefit: 'Amplia aceptación social y bajo costo.',
            scope: 'Población general',
            type: MeasureType.ninguna,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.emisiones: -2,
              ClimateIndicator.energia: -2,
            },
            consequences: <String>[
              'El efecto sobre los indicadores es marginal.',
              'La trayectoria de emisiones se mantiene prácticamente igual.',
            ],
            feedback:
                'La sensibilización acompaña una política climática, pero por '
                'sí sola no produce un cambio medible: su efecto es demasiado '
                'pequeño frente a la tendencia del escenario.',
          ),
        ],
      ),
    ],
    events: <ClimateEvent>[
      ClimateEvent(
        id: 'mit-ev1',
        afterStage: 0,
        title: 'Ola de calor urbana',
        description:
            'Una semana de temperaturas extremas eleva el uso de refrigeración '
            'y agrava el efecto isla de calor en las zonas con menos vegetación.',
        effects: <ClimateIndicator, double>{
          ClimateIndicator.temperatura: 0.08,
          ClimateIndicator.energia: 9,
          ClimateIndicator.vulnerabilidad: 6,
          ClimateIndicator.agua: -3,
        },
        bufferIndicator: ClimateIndicator.vegetacion,
        bufferThreshold: 44,
        bufferedNote:
            'La cobertura vegetal urbana amortiguó el episodio y redujo la '
            'demanda de refrigeración.',
        exposedNote:
            'Con poca cobertura vegetal, la ciudad absorbió el impacto '
            'completo de la ola de calor.',
      ),
      ClimateEvent(
        id: 'mit-ev2',
        afterStage: 1,
        title: 'Crecimiento poblacional acelerado',
        description:
            'La migración hacia el área metropolitana incrementa la demanda de '
            'vivienda, transporte y servicios por encima de lo previsto.',
        effects: <ClimateIndicator, double>{
          ClimateIndicator.emisiones: 7,
          ClimateIndicator.energia: 8,
          ClimateIndicator.agua: -5,
          ClimateIndicator.presion: 5,
        },
        bufferIndicator: ClimateIndicator.energia,
        bufferThreshold: 88,
        bufferedNote:
            'El sistema partía de un consumo contenido y absorbió la nueva '
            'demanda con menor incremento de emisiones.',
        exposedNote:
            'La demanda adicional se sumó a un sistema ya exigido y amplificó '
            'las emisiones.',
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // ESCENARIO 3 — CAMBIO DE USO DEL SUELO
  // ---------------------------------------------------------------------------

  static const ClimateScenario _usoSuelo = ClimateScenario(
    id: 'uso-suelo',
    name: 'Cambio de uso del suelo',
    tagline: 'Cuenca del río Nayra · bosque, ciudad y suelo',
    focus: ScenarioFocus.usoSuelo,
    territory:
        'Cuenca de 4 200 km² con bosque en cabecera, frente agrícola en '
        'expansión y una ciudad que crece hacia la ribera del río.',
    briefing:
        'La cuenca del Nayra pierde cobertura vegetal cada año por el avance '
        'agrícola y urbano. Analizarás cómo el uso del suelo modifica '
        'simultáneamente las emisiones, el agua disponible y la exposición del '
        'territorio frente a lluvias intensas.',
    keyQuestion:
        '¿Cómo conecta el uso del suelo la dimensión climática con la '
        'disponibilidad de agua y el riesgo local?',
    learningGoals: <String>[
      'Relacionar cobertura vegetal con carbono, agua y erosión.',
      'Identificar el uso del suelo como decisión climática.',
      'Evaluar medidas de restauración según su calidad ecológica.',
    ],
    highlightIndicators: <ClimateIndicator>[
      ClimateIndicator.vegetacion,
      ClimateIndicator.agua,
      ClimateIndicator.presion,
    ],
    baseline: <ClimateIndicator, double>{
      ClimateIndicator.emisiones: 92,
      ClimateIndicator.temperatura: 1.15,
      ClimateIndicator.agua: 70,
      ClimateIndicator.vegetacion: 72,
      ClimateIndicator.presion: 40,
      ClimateIndicator.energia: 60,
      ClimateIndicator.vulnerabilidad: 42,
    },
    drift: <ClimateIndicator, double>{
      ClimateIndicator.emisiones: 7,
      ClimateIndicator.temperatura: 0.25,
      ClimateIndicator.agua: -7,
      ClimateIndicator.vegetacion: -9,
      ClimateIndicator.presion: 6,
      ClimateIndicator.energia: 5,
      ClimateIndicator.vulnerabilidad: 5,
    },
    stages: <DecisionStage>[
      DecisionStage(
        id: 'sue-s1',
        period: ClimatePeriod.corto,
        title: 'Frente de deforestación',
        context:
            'Una solicitud de habilitación agrícola propone incorporar 8 000 '
            'hectáreas de bosque de cabecera al cultivo intensivo.',
        question: '¿Qué decisión toma la autoridad sobre el uso del suelo?',
        options: <DecisionOption>[
          DecisionOption(
            id: 'sue-s1-a',
            title: 'Autorizar la expansión agrícola',
            action:
                'Habilitar la conversión del bosque de cabecera a superficie '
                'agrícola.',
            cost: 1,
            benefit: 'Aumento inmediato de la producción y del empleo rural.',
            scope: 'Cabecera de cuenca',
            type: MeasureType.ninguna,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.vegetacion: -15,
              ClimateIndicator.emisiones: 10,
              ClimateIndicator.agua: -7,
              ClimateIndicator.presion: 9,
              ClimateIndicator.vulnerabilidad: 6,
            },
            consequences: <String>[
              'Se libera carbono almacenado y se pierde regulación hídrica.',
              'La cuenca queda más expuesta a la erosión durante lluvias intensas.',
            ],
            feedback:
                'La deforestación actúa en sentido contrario a la mitigación: '
                'libera carbono, reduce la captura futura y aumenta la '
                'vulnerabilidad del territorio.',
          ),
          DecisionOption(
            id: 'sue-s1-b',
            title: 'Ordenamiento territorial con zonas protegidas',
            action:
                'Delimitar áreas de protección en cabecera y condicionar la '
                'expansión agrícola a zonas ya intervenidas.',
            cost: 3,
            benefit: 'Conservación del servicio hídrico y del carbono almacenado.',
            scope: 'Toda la cuenca',
            type: MeasureType.ambas,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.vegetacion: 7,
              ClimateIndicator.emisiones: -8,
              ClimateIndicator.agua: 6,
              ClimateIndicator.presion: -7,
              ClimateIndicator.vulnerabilidad: -6,
            },
            consequences: <String>[
              'Se conserva el bosque de cabecera y su función reguladora.',
              'La presión sobre los ecosistemas disminuye de forma sostenida.',
            ],
            feedback:
                'Cumple ambas funciones: evita emisiones por deforestación '
                '(mitigación) y conserva la regulación hídrica y del suelo que '
                'protege a la población (adaptación).',
          ),
          DecisionOption(
            id: 'sue-s1-c',
            title: 'Intensificar el área ya intervenida',
            action:
                'Mantener el límite del bosque y aumentar el rendimiento con '
                'más insumos en la superficie agrícola existente.',
            cost: 2,
            benefit: 'Más producción sin ampliar la frontera agrícola.',
            scope: 'Zona agrícola actual',
            type: MeasureType.ninguna,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.vegetacion: -2,
              ClimateIndicator.agua: -4,
              ClimateIndicator.presion: 3,
              ClimateIndicator.emisiones: 2,
            },
            consequences: <String>[
              'Se evita la pérdida masiva de bosque.',
              'El uso intensivo de insumos y riego aumenta la presión local.',
            ],
            feedback:
                'Evita un daño mayor, pero no reduce emisiones ni '
                'vulnerabilidad: no clasifica como mitigación ni como '
                'adaptación.',
          ),
        ],
      ),
      DecisionStage(
        id: 'sue-s2',
        period: ClimatePeriod.mediano,
        title: 'Expansión urbana hacia la ribera',
        context:
            'La ciudad crece y la presión inmobiliaria se dirige hacia la '
            'llanura de inundación del río Nayra.',
        question: '¿Cómo se ordena el crecimiento urbano?',
        options: <DecisionOption>[
          DecisionOption(
            id: 'sue-s2-a',
            title: 'Urbanización dispersa en la ribera',
            action:
                'Permitir el loteo de la llanura ribereña con baja densidad.',
            cost: 1,
            benefit: 'Suelo urbano barato y disponible de inmediato.',
            scope: 'Ribera del río',
            type: MeasureType.ninguna,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.vegetacion: -9,
              ClimateIndicator.vulnerabilidad: 11,
              ClimateIndicator.presion: 7,
              ClimateIndicator.agua: -4,
              ClimateIndicator.energia: 4,
            },
            consequences: <String>[
              'Se ocupa la zona con mayor probabilidad de inundación.',
              'La dispersión aumenta el consumo de energía en desplazamientos.',
            ],
            feedback:
                'Construir en la llanura de inundación instala vulnerabilidad '
                'permanente en el territorio: el riesgo no se elimina, se '
                'traslada a los habitantes.',
          ),
          DecisionOption(
            id: 'sue-s2-b',
            title: 'Crecimiento urbano compacto',
            action:
                'Densificar la ciudad existente e incorporar áreas verdes '
                'internas y drenaje permeable.',
            cost: 2,
            benefit: 'Menos superficie ocupada y menor demanda de transporte.',
            scope: 'Ciudad',
            type: MeasureType.ambas,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.vegetacion: 5,
              ClimateIndicator.vulnerabilidad: -7,
              ClimateIndicator.energia: -5,
              ClimateIndicator.emisiones: -5,
              ClimateIndicator.presion: -4,
            },
            consequences: <String>[
              'Se reduce la ocupación de suelo natural y el uso de transporte privado.',
              'La ciudad drena mejor las lluvias intensas.',
            ],
            feedback:
                'La forma urbana es una decisión climática: la compacidad '
                'reduce emisiones y el drenaje verde reduce la vulnerabilidad.',
          ),
          DecisionOption(
            id: 'sue-s2-c',
            title: 'Franja de amortiguamiento ribereña',
            action:
                'Declarar la ribera como área no edificable y recuperar su '
                'vegetación nativa.',
            cost: 2,
            benefit: 'Protección frente a crecidas y recuperación del cauce.',
            scope: 'Ribera del río',
            type: MeasureType.adaptacion,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.vulnerabilidad: -12,
              ClimateIndicator.agua: 5,
              ClimateIndicator.vegetacion: 6,
              ClimateIndicator.presion: -4,
            },
            consequences: <String>[
              'La ciudad reduce de forma marcada su exposición a crecidas.',
              'Las emisiones del territorio no se modifican de manera relevante.',
            ],
            feedback:
                'Adaptación basada en ecosistemas: su función principal es '
                'reducir el daño esperado. El pequeño aporte de captura no la '
                'convierte en una medida de mitigación.',
          ),
        ],
      ),
      DecisionStage(
        id: 'sue-s3',
        period: ClimatePeriod.largo,
        title: 'Recuperación de la cuenca',
        context:
            'Con la superficie ya transformada, se evalúa una estrategia de '
            'recuperación para el tramo final del horizonte.',
        question: '¿Qué tipo de recuperación se implementa?',
        options: <DecisionOption>[
          DecisionOption(
            id: 'sue-s3-a',
            title: 'Restauración ecológica en cabeceras',
            action:
                'Restaurar cobertura nativa en las cabeceras y estabilizar '
                'laderas degradadas.',
            cost: 3,
            benefit: 'Recuperación del agua, del suelo y del carbono almacenado.',
            scope: 'Cabecera de cuenca',
            type: MeasureType.ambas,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.vegetacion: 15,
              ClimateIndicator.agua: 10,
              ClimateIndicator.emisiones: -9,
              ClimateIndicator.presion: -6,
              ClimateIndicator.vulnerabilidad: -7,
              ClimateIndicator.temperatura: -0.05,
            },
            consequences: <String>[
              'Mejoran simultáneamente vegetación, agua y presión ambiental.',
              'La restauración necesita tiempo: su efecto pleno aparece después del horizonte analizado.',
            ],
            feedback:
                'La restauración captura carbono y recupera la regulación '
                'hídrica: mitigación y adaptación en una sola medida. Su '
                'limitación es temporal, no conceptual.',
          ),
          DecisionOption(
            id: 'sue-s3-b',
            title: 'Plantación forestal de una sola especie',
            action:
                'Plantar una especie de rápido crecimiento con fines '
                'comerciales en las áreas degradadas.',
            cost: 2,
            benefit: 'Aumento rápido de la cobertura y captura de carbono.',
            scope: 'Áreas degradadas',
            type: MeasureType.mitigacion,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.vegetacion: 10,
              ClimateIndicator.emisiones: -6,
              ClimateIndicator.agua: -4,
              ClimateIndicator.presion: 3,
            },
            consequences: <String>[
              'La cobertura vegetal aumenta con rapidez.',
              'El consumo hídrico de la plantación reduce el agua disponible aguas abajo.',
            ],
            feedback:
                'Es mitigación, pero no toda cobertura vegetal cumple la '
                'misma función: un monocultivo captura carbono sin recuperar '
                'la biodiversidad ni la regulación hídrica del bosque nativo.',
          ),
          DecisionOption(
            id: 'sue-s3-c',
            title: 'Mantener el uso actual del suelo',
            action: 'No intervenir y consolidar el uso del suelo existente.',
            cost: 1,
            benefit: 'Sin costo de recuperación ni conflicto por la tenencia.',
            scope: 'Toda la cuenca',
            type: MeasureType.ninguna,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.vegetacion: -4,
              ClimateIndicator.presion: 4,
              ClimateIndicator.agua: -3,
            },
            consequences: <String>[
              'La degradación continúa según la tendencia del escenario.',
              'La cuenca cierra el horizonte con su menor cobertura vegetal.',
            ],
            feedback:
                'En un escenario con tendencia negativa, mantener el uso '
                'actual equivale a aceptar la pérdida progresiva de servicios '
                'ecosistémicos.',
          ),
        ],
      ),
    ],
    events: <ClimateEvent>[
      ClimateEvent(
        id: 'sue-ev1',
        afterStage: 0,
        title: 'Lluvias intensas y pérdida de suelo',
        description:
            'Una temporada con precipitaciones concentradas provoca erosión en '
            'las laderas sin cobertura y arrastre de sedimentos al río.',
        effects: <ClimateIndicator, double>{
          ClimateIndicator.agua: -7,
          ClimateIndicator.vegetacion: -5,
          ClimateIndicator.vulnerabilidad: 8,
          ClimateIndicator.presion: 4,
        },
        bufferIndicator: ClimateIndicator.vegetacion,
        bufferThreshold: 64,
        bufferedNote:
            'La cobertura vegetal conservada retuvo el suelo y redujo el '
            'arrastre de sedimentos.',
        exposedNote:
            'Las laderas sin cobertura amplificaron la erosión y el daño en la '
            'cuenca.',
      ),
      ClimateEvent(
        id: 'sue-ev2',
        afterStage: 1,
        title: 'Nuevas solicitudes de concesión agrícola',
        description:
            'El alza del precio internacional de los cultivos genera presión '
            'para incorporar más superficie productiva en la cuenca.',
        effects: <ClimateIndicator, double>{
          ClimateIndicator.vegetacion: -6,
          ClimateIndicator.presion: 6,
          ClimateIndicator.emisiones: 5,
        },
        bufferIndicator: ClimateIndicator.presion,
        bufferThreshold: 46,
        bufferedNote:
            'El ordenamiento previo permitió canalizar la demanda sin ocupar '
            'nuevas áreas naturales.',
        exposedNote:
            'Sin reglas claras de uso del suelo, la presión productiva avanzó '
            'sobre áreas naturales.',
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // ESCENARIO 4 — ADAPTACIÓN TERRITORIAL
  // ---------------------------------------------------------------------------

  static const ClimateScenario _adaptacion = ClimateScenario(
    id: 'adaptacion',
    name: 'Adaptación territorial',
    tagline: 'Ciudad costera de Punta Serena · exposición y respuesta',
    focus: ScenarioFocus.adaptacion,
    territory:
        'Ciudad portuaria de 400 000 habitantes con barrios bajos junto al '
        'borde costero, humedales degradados y fuerte demanda eléctrica estival.',
    briefing:
        'Punta Serena convive con inundaciones costeras recurrentes y veranos '
        'cada vez más calurosos. Deberás distinguir qué medidas reducen las '
        'emisiones y cuáles reducen realmente el daño esperado sobre la '
        'población.',
    keyQuestion:
        '¿Por qué un territorio puede reducir sus emisiones y seguir siendo '
        'igual de vulnerable?',
    learningGoals: <String>[
      'Diferenciar con precisión mitigación y adaptación.',
      'Identificar medidas de mala adaptación.',
      'Reconocer soluciones basadas en ecosistemas con doble función.',
    ],
    highlightIndicators: <ClimateIndicator>[
      ClimateIndicator.vulnerabilidad,
      ClimateIndicator.temperatura,
      ClimateIndicator.energia,
    ],
    baseline: <ClimateIndicator, double>{
      ClimateIndicator.emisiones: 105,
      ClimateIndicator.temperatura: 1.40,
      ClimateIndicator.agua: 55,
      ClimateIndicator.vegetacion: 38,
      ClimateIndicator.presion: 58,
      ClimateIndicator.energia: 82,
      ClimateIndicator.vulnerabilidad: 66,
    },
    drift: <ClimateIndicator, double>{
      ClimateIndicator.emisiones: 8,
      ClimateIndicator.temperatura: 0.30,
      ClimateIndicator.agua: -5,
      ClimateIndicator.vegetacion: -3,
      ClimateIndicator.presion: 5,
      ClimateIndicator.energia: 6,
      ClimateIndicator.vulnerabilidad: 7,
    },
    stages: <DecisionStage>[
      DecisionStage(
        id: 'ada-s1',
        period: ClimatePeriod.corto,
        title: 'Inundaciones en el borde costero',
        context:
            'Tres barrios bajos se inundan varias veces al año. El municipio '
            'dispone de financiamiento para una sola intervención mayor.',
        question: '¿En qué se invierte el presupuesto disponible?',
        options: <DecisionOption>[
          DecisionOption(
            id: 'ada-s1-a',
            title: 'Drenaje sostenible y humedales',
            action:
                'Construir drenaje urbano sostenible y recuperar los humedales '
                'costeros degradados.',
            cost: 3,
            benefit: 'Retención de agua, amortiguación del oleaje y más área verde.',
            scope: 'Borde costero y barrios bajos',
            type: MeasureType.ambas,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.vulnerabilidad: -15,
              ClimateIndicator.agua: 6,
              ClimateIndicator.vegetacion: 8,
              ClimateIndicator.emisiones: -4,
              ClimateIndicator.presion: -5,
            },
            consequences: <String>[
              'Los barrios bajos reducen de forma marcada su exposición.',
              'El humedal recuperado captura carbono y mejora el entorno urbano.',
            ],
            feedback:
                'Solución basada en ecosistemas: protege a la población '
                '(adaptación) y captura carbono (mitigación). Suele ser más '
                'flexible y duradera que una obra rígida.',
          ),
          DecisionOption(
            id: 'ada-s1-b',
            title: 'Paneles solares en edificios públicos',
            action:
                'Instalar generación solar en escuelas, hospitales y oficinas '
                'municipales.',
            cost: 2,
            benefit: 'Menor consumo de electricidad de red y menos emisiones.',
            scope: 'Edificios públicos',
            type: MeasureType.mitigacion,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.emisiones: -10,
              ClimateIndicator.energia: -7,
            },
            consequences: <String>[
              'Las emisiones de la ciudad descienden.',
              'Los barrios inundables siguen exactamente igual de expuestos.',
            ],
            feedback:
                'Es una buena medida de mitigación, pero no responde al '
                'problema planteado: reducir emisiones no disminuye la '
                'vulnerabilidad frente a las inundaciones ya presentes.',
          ),
          DecisionOption(
            id: 'ada-s1-c',
            title: 'Muro de contención costero',
            action:
                'Construir un muro de defensa a lo largo del frente marítimo '
                'de los barrios afectados.',
            cost: 3,
            benefit: 'Protección física inmediata frente al oleaje.',
            scope: 'Frente marítimo urbano',
            type: MeasureType.adaptacion,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.vulnerabilidad: -12,
              ClimateIndicator.presion: 6,
              ClimateIndicator.emisiones: 4,
              ClimateIndicator.vegetacion: -3,
            },
            consequences: <String>[
              'La exposición directa al oleaje disminuye.',
              'La obra altera la dinámica costera y sus emisiones de construcción son elevadas.',
            ],
            feedback:
                'Adaptación estructural o "dura": eficaz mientras el muro '
                'resista, pero rígida, costosa de mantener y con efectos '
                'ambientales en el litoral.',
          ),
        ],
      ),
      DecisionStage(
        id: 'ada-s2',
        period: ClimatePeriod.mediano,
        title: 'Calor extremo y demanda eléctrica',
        context:
            'Las olas de calor se hicieron frecuentes. Los hogares sin '
            'ventilación adecuada concentran los casos de golpe de calor y la '
            'demanda eléctrica se dispara cada verano.',
        question: '¿Cómo responde la ciudad al calor extremo?',
        options: <DecisionOption>[
          DecisionOption(
            id: 'ada-s2-a',
            title: 'Subsidio masivo a aire acondicionado',
            action:
                'Financiar equipos de climatización para los hogares más '
                'afectados por el calor.',
            cost: 2,
            benefit: 'Alivio inmediato para la población expuesta.',
            scope: 'Hogares vulnerables',
            type: MeasureType.adaptacion,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.vulnerabilidad: -5,
              ClimateIndicator.energia: 13,
              ClimateIndicator.emisiones: 9,
              ClimateIndicator.temperatura: 0.03,
            },
            consequences: <String>[
              'Disminuye la exposición al calor dentro de las viviendas.',
              'El consumo eléctrico y las emisiones aumentan de forma notable.',
            ],
            feedback:
                'Ejemplo de mala adaptación: cumple su función de reducir el '
                'daño inmediato, pero agrava la causa del problema al '
                'aumentar emisiones y demanda energética.',
          ),
          DecisionOption(
            id: 'ada-s2-b',
            title: 'Corredores verdes y techos frescos',
            action:
                'Arborizar ejes urbanos, crear sombra continua y aplicar '
                'cubiertas reflectantes en edificios.',
            cost: 2,
            benefit: 'Menor temperatura urbana y menor demanda de refrigeración.',
            scope: 'Trama urbana',
            type: MeasureType.ambas,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.temperatura: -0.07,
              ClimateIndicator.vegetacion: 11,
              ClimateIndicator.vulnerabilidad: -10,
              ClimateIndicator.energia: -6,
              ClimateIndicator.emisiones: -4,
            },
            consequences: <String>[
              'Baja la temperatura percibida y la demanda eléctrica estival.',
              'La ciudad gana cobertura vegetal permanente.',
            ],
            feedback:
                'Doble función: reduce el daño por calor (adaptación) y '
                'disminuye consumo y emisiones (mitigación). Es la respuesta '
                'más coherente con ambos objetivos.',
          ),
          DecisionOption(
            id: 'ada-s2-c',
            title: 'Protocolo municipal de alerta por calor',
            action:
                'Implantar alertas tempranas, refugios climatizados y '
                'atención prioritaria a población de riesgo.',
            cost: 1,
            benefit: 'Reducción de la mortalidad asociada a olas de calor.',
            scope: 'Población de riesgo',
            type: MeasureType.adaptacion,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.vulnerabilidad: -8,
              ClimateIndicator.energia: 2,
            },
            consequences: <String>[
              'La población de riesgo queda mejor protegida durante los episodios.',
              'La causa del calentamiento no se modifica.',
            ],
            feedback:
                'Adaptación de bajo costo y alta efectividad social. No reduce '
                'emisiones: su valor está en disminuir el daño, no la causa.',
          ),
        ],
      ),
      DecisionStage(
        id: 'ada-s3',
        period: ClimatePeriod.largo,
        title: 'Futuro del borde costero',
        context:
            'El horizonte de largo plazo obliga a decidir qué hacer con las '
            'zonas de mayor riesgo y con el desarrollo portuario de la ciudad.',
        question: '¿Qué modelo territorial se adopta para el largo plazo?',
        options: <DecisionOption>[
          DecisionOption(
            id: 'ada-s3-a',
            title: 'Reubicación progresiva del área de riesgo',
            action:
                'Trasladar de forma planificada y consensuada las viviendas de '
                'la zona con mayor probabilidad de inundación.',
            cost: 3,
            benefit: 'Eliminación de la exposición en el sector más crítico.',
            scope: 'Barrios costeros de alto riesgo',
            type: MeasureType.adaptacion,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.vulnerabilidad: -16,
              ClimateIndicator.presion: -4,
              ClimateIndicator.energia: 3,
            },
            consequences: <String>[
              'La vulnerabilidad cae al nivel más bajo del escenario.',
              'El proceso exige acuerdos sociales complejos y tiempo prolongado.',
            ],
            feedback:
                'Adaptación transformacional: en lugar de resistir el impacto, '
                'se retira la exposición. Es eficaz y a la vez la decisión '
                'socialmente más exigente.',
          ),
          DecisionOption(
            id: 'ada-s3-b',
            title: 'Ampliación portuaria e industrial',
            action:
                'Expandir el puerto y habilitar suelo industrial sobre el '
                'frente costero.',
            cost: 3,
            benefit: 'Crecimiento económico y generación de empleo.',
            scope: 'Frente costero',
            type: MeasureType.ninguna,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.emisiones: 11,
              ClimateIndicator.energia: 9,
              ClimateIndicator.presion: 9,
              ClimateIndicator.vulnerabilidad: 7,
              ClimateIndicator.vegetacion: -4,
            },
            consequences: <String>[
              'Aumentan simultáneamente las emisiones y la exposición del litoral.',
              'Se instala nueva infraestructura crítica en zona de riesgo.',
            ],
            feedback:
                'Decisión que agrava ambas dimensiones: más emisiones y más '
                'activos expuestos. Ilustra que el desarrollo mal localizado '
                'genera riesgo climático futuro.',
          ),
          DecisionOption(
            id: 'ada-s3-c',
            title: 'Plan integrado costa-energía',
            action:
                'Combinar protección costera basada en ecosistemas con un plan '
                'de energía renovable municipal.',
            cost: 3,
            benefit: 'Reducción conjunta de emisiones y de daño esperado.',
            scope: 'Ciudad y borde costero',
            type: MeasureType.ambas,
            effects: <ClimateIndicator, double>{
              ClimateIndicator.emisiones: -12,
              ClimateIndicator.vulnerabilidad: -13,
              ClimateIndicator.vegetacion: 9,
              ClimateIndicator.energia: -7,
              ClimateIndicator.presion: -3,
            },
            consequences: <String>[
              'Emisiones y vulnerabilidad descienden al mismo tiempo.',
              'Requiere coordinación entre áreas municipales que suelen trabajar por separado.',
            ],
            feedback:
                'Estrategia integrada: mitigación y adaptación no compiten, se '
                'complementan cuando se planifican juntas.',
          ),
        ],
      ),
    ],
    events: <ClimateEvent>[
      ClimateEvent(
        id: 'ada-ev1',
        afterStage: 0,
        title: 'Marejada e inundación costera',
        description:
            'Una marejada coincide con marea alta e inunda los barrios bajos '
            'durante 48 horas.',
        effects: <ClimateIndicator, double>{
          ClimateIndicator.vulnerabilidad: 9,
          ClimateIndicator.agua: -5,
          ClimateIndicator.presion: 5,
          ClimateIndicator.energia: 3,
        },
        bufferIndicator: ClimateIndicator.vulnerabilidad,
        bufferThreshold: 58,
        bufferedNote:
            'Las medidas previas redujeron la exposición y el evento causó la '
            'mitad del daño esperado.',
        exposedNote:
            'Sin protección efectiva, la ciudad recibió el impacto completo de '
            'la marejada.',
      ),
      ClimateEvent(
        id: 'ada-ev2',
        afterStage: 1,
        title: 'Ola de calor prolongada',
        description:
            'Doce días consecutivos por encima del umbral de calor extremo '
            'ponen a prueba la red eléctrica y los servicios de salud.',
        effects: <ClimateIndicator, double>{
          ClimateIndicator.temperatura: 0.09,
          ClimateIndicator.energia: 10,
          ClimateIndicator.agua: -6,
          ClimateIndicator.vulnerabilidad: 6,
        },
        bufferIndicator: ClimateIndicator.vegetacion,
        bufferThreshold: 45,
        bufferedNote:
            'La sombra urbana y las cubiertas frescas contuvieron la demanda '
            'eléctrica y el impacto sanitario.',
        exposedNote:
            'Con escasa vegetación urbana, el calor se amplificó dentro de la '
            'ciudad.',
      ),
    ],
  );
}
