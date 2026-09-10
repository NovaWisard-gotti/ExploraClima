# ExploraClima

**Explorador educativo de futuros climáticos** para estudiantes universitarios de Ingeniería Ambiental.

ExploraClima forma parte del proyecto *Educational Mobile Apps Factory*. No es una app de estadísticas ni un simulador científico: es un espacio para **explorar escenarios, comparar trayectorias, interpretar tendencias, decidir y observar consecuencias**.

> Todos los datos de la aplicación son **educativos y simulados**. No constituyen proyecciones científicas oficiales.

---

## 1. Qué resuelve

El cambio climático suele estudiarse con conceptos, gráficos y estadísticas. Los estudiantes tienen dificultad para:

- relacionar causas y consecuencias,
- comparar escenarios futuros,
- interpretar tendencias,
- distinguir mitigación de adaptación,
- entender cómo las decisiones actuales condicionan escenarios posteriores.

ExploraClima convierte ese contenido en un recorrido analítico:

```
SITUACIÓN ACTUAL → ESCENARIO FUTURO → COMPARACIÓN → INTERPRETACIÓN → DECISIÓN → CONSECUENCIAS
```

---

## 2. Funcionalidades del MVP

| Módulo | Descripción |
| --- | --- |
| Línea temporal climática | Cuatro periodos (actualidad, corto, mediano y largo plazo) recorribles, con marcas de decisiones y eventos. |
| Visor de escenarios | Representación gráfica del territorio enlazada a los indicadores (cielo, bruma, vegetación, agua, zona urbana, marcas de riesgo). |
| Cuatro escenarios | Continuidad actual, reducción de emisiones, cambio de uso del suelo y adaptación territorial. |
| Indicadores | Emisiones, temperatura simulada, agua, cobertura vegetal, presión sobre ecosistemas, consumo energético y vulnerabilidad. |
| Tarjetas de decisión | Acción, costo relativo, beneficio esperado y alcance; la función de la medida no se revela antes de decidir. |
| Consecuencias | Variación de indicadores más efectos narrados y retroalimentación explicativa. |
| Mitigación y adaptación | Clasificación contextual de cada medida tomada, con corrección y explicación. |
| Eventos educativos | Hechos del periodo (sequía, ola de calor, marejada, lluvias intensas…) amortiguados si el territorio llegó preparado. |
| Comparador climático | Dos escenarios enfrentados indicador por indicador en el periodo elegido. |
| Comparación de intentos | Dos recorridos del mismo escenario, con las decisiones que cambiaron y sus efectos. |
| Huella de carbono | Análisis simplificado por categorías con peso relativo y potencial de reducción. |
| Energía y decisiones | Efecto combinado de renovables, eficiencia y reducción de consumo sobre emisiones y demanda. |
| Informe de escenario | Indicadores finales frente a la trayectoria sin intervención, decisiones, eventos y retroalimentación. |
| Historial y progreso | Persistencia local de intentos y registro de actividad analítica (sin XP, monedas, insignias ni rankings). |
| Consulta rápida | Definiciones breves y contextuales de dieciséis conceptos clave. |
| Temas | Modo claro y modo oscuro diseñados por separado, con `ThemeMode.system`. |

Todo el MVP funciona **sin conexión** y **sin cuentas de usuario**. No se integra ninguna API de inteligencia artificial.

---

## 3. Requisitos

- Flutter **3.22 o superior** (canal stable), Dart 3.4+
- JDK 17 para la compilación de Android
- Android SDK con `compileSdk 35` (mínimo soportado: Android 5.0 / API 21)

## 4. Ejecución

```bash
flutter pub get
flutter run
```

## 5. Generación del APK

```bash
flutter build apk --release
# resultado: build/app/outputs/flutter-apk/app-release.apk
```

El APK se instala mostrando exactamente el nombre **ExploraClima** bajo el icono
(`android:label="ExploraClima"` en `android/app/src/main/AndroidManifest.xml`).

El proyecto no incluye el binario `gradle-wrapper.jar`: la herramienta de Flutter
lo inyecta automáticamente en la primera compilación.

### Icono

El launcher icon es exclusivo de ExploraClima (horizonte planetario en azul noche
con línea de tendencia coral). Está incluido ya generado en `android/app/src/main/res/mipmap-*`
en variantes cuadrada, redonda y adaptativa. Para regenerarlo:

```bash
python3 tool/generate_icon.py     # regenera los PNG desde el diseño vectorial
dart run flutter_launcher_icons   # alternativa usando el paquete
```

## 6. Pruebas y análisis

```bash
flutter analyze
flutter test
```

La integración continua (`.github/workflows/ci.yml`) ejecuta análisis estático,
pruebas y compilación del APK, publicándolo como artefacto.

---

## 7. Arquitectura

Flutter + Dart, gestión de estado con **Riverpod** y organización **MVVM**:

```
lib/
├── main.dart                  Punto de entrada
├── app.dart                   MaterialApp, temas y ThemeMode.system
├── core/
│   ├── theme/                 ColorScheme claro y oscuro + paleta semántica
│   ├── utils/                 Formato de fechas y valores
│   └── widgets/               Componentes base (Panel, Tag, DeltaChip…)
├── data/
│   ├── models/                Periodo, indicadores, decisiones, escenario, intento
│   ├── scenarios/             Contenido educativo (escenarios, huella, glosario)
│   └── local/                 Persistencia con SharedPreferences
├── domain/
│   └── scenario_engine.dart   Motor de proyección determinista
├── state/                     Providers y controladores (ViewModels)
└── presentation/              Pantallas y widgets de cada módulo
```

**Motor de proyección**: cada valor mostrado se obtiene de `valor base + tendencia del escenario × periodos + efecto de las decisiones × maduración + efecto de los eventos`. Es determinista y explicable: no hay aleatoriedad ni simulación científica.

**Persistencia local**: intentos, contadores de actividad, perfil de huella, medidas energéticas y preferencia de tema.

---

## 8. Identidad visual

| Rol | Claro | Oscuro |
| --- | --- | --- |
| Superficie | Marfil `#F7F2E8` | Azul noche `#101A2E` |
| Primario | Índigo `#2F3E9E` | Índigo claro `#9FB0FF` |
| Acento | Coral `#E2694C` | Coral suave `#FF9B84` |
| Texto | `#1A2233` | `#E7EAF4` |

Ambos modos se definen de forma independiente (no hay inversión de colores). Los gráficos combinan **color + tipo de línea + marcador + etiqueta + valor numérico**, de modo que ninguna diferencia depende únicamente del color.

---

## 9. Fuera del alcance del MVP

Modelos climáticos científicos, predicción meteorológica, APIs climáticas, GIS profesional, mapas 3D, realidad aumentada o virtual, backend, cuentas de usuario, funciones sociales e integración obligatoria de IA.

La IA queda evaluada como evolución futura (explicación de tendencias, comentario de decisiones, generación de variantes de escenario y retroalimentación personalizada).

---

## 10. Documentación

- `docs/01_analisis_educativo.md` — problema, usuario, competencias, experiencia, diferenciación y MVP.
- `docs/02_arquitectura.md` — arquitectura técnica, motor de proyección y decisiones de diseño.
- `docs/03_escenarios.md` — contenido de los cuatro escenarios y guía docente.

## 11. Licencia

MIT. Ver `LICENSE`.
