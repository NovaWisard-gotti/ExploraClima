import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local/preferences_service.dart';
import '../data/models/attempt.dart';
import '../data/models/carbon.dart';
import '../data/models/scenario.dart';
import '../data/scenarios/reference_data.dart';
import '../data/scenarios/scenario_data.dart';

/// Se sobrescribe en `main()` con la instancia ya inicializada.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider debe sobrescribirse');
});

final preferencesServiceProvider = Provider<PreferencesService>(
  (ref) => PreferencesService(ref.watch(sharedPreferencesProvider)),
);

final scenariosProvider = Provider<List<ClimateScenario>>(
  (ref) => ScenarioCatalog.all,
);

// ---------------------------------------------------------------------------
// Tema
// ---------------------------------------------------------------------------

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController(this._prefs) : super(_prefs.loadThemeMode());

  final PreferencesService _prefs;

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await _prefs.saveThemeMode(mode);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
  return ThemeModeController(ref.watch(preferencesServiceProvider));
});

// ---------------------------------------------------------------------------
// Intentos guardados
// ---------------------------------------------------------------------------

class AttemptsController extends StateNotifier<List<AttemptRecord>> {
  AttemptsController(this._prefs) : super(_prefs.loadAttempts());

  final PreferencesService _prefs;

  Future<void> add(AttemptRecord record) async {
    state = <AttemptRecord>[record, ...state];
    await _prefs.saveAttempts(state);
  }

  Future<void> remove(String id) async {
    state = state.where((a) => a.id != id).toList();
    await _prefs.saveAttempts(state);
  }

  Future<void> clear() async {
    state = <AttemptRecord>[];
    await _prefs.saveAttempts(state);
  }

  List<AttemptRecord> forScenario(String scenarioId) =>
      state.where((a) => a.scenarioId == scenarioId).toList();
}

final attemptsProvider =
    StateNotifierProvider<AttemptsController, List<AttemptRecord>>((ref) {
  return AttemptsController(ref.watch(preferencesServiceProvider));
});

final attemptsForScenarioProvider =
    Provider.family<List<AttemptRecord>, String>((ref, scenarioId) {
  final attempts = ref.watch(attemptsProvider);
  return attempts.where((a) => a.scenarioId == scenarioId).toList();
});

// ---------------------------------------------------------------------------
// Contadores de actividad
// ---------------------------------------------------------------------------

class CountersController extends StateNotifier<ActivityCounters> {
  CountersController(this._prefs) : super(_prefs.loadCounters());

  final PreferencesService _prefs;

  Future<void> _save() async => _prefs.saveCounters(state);

  Future<void> registerComparison() async {
    state = state.copyWith(comparisons: state.comparisons + 1);
    await _save();
  }

  Future<void> registerAttemptComparison() async {
    state = state.copyWith(attemptComparisons: state.attemptComparisons + 1);
    await _save();
  }

  Future<void> registerCarbonAnalysis() async {
    state = state.copyWith(carbonAnalyses: state.carbonAnalyses + 1);
    await _save();
  }

  Future<void> registerEnergyExploration() async {
    state = state.copyWith(energyExplorations: state.energyExplorations + 1);
    await _save();
  }

  Future<void> registerGlossaryConsult() async {
    state = state.copyWith(glossaryConsults: state.glossaryConsults + 1);
    await _save();
  }

  Future<void> reset() async {
    state = const ActivityCounters();
    await _save();
  }
}

final countersProvider =
    StateNotifierProvider<CountersController, ActivityCounters>((ref) {
  return CountersController(ref.watch(preferencesServiceProvider));
});

// ---------------------------------------------------------------------------
// Huella de carbono
// ---------------------------------------------------------------------------

class CarbonController extends StateNotifier<CarbonProfile> {
  CarbonController(this._prefs)
      : super(_prefs.loadCarbonProfile() ?? CarbonData.defaultProfile);

  final PreferencesService _prefs;

  Future<void> select(String categoryId, String optionId) async {
    state = state.withOption(categoryId, optionId);
    await _prefs.saveCarbonProfile(state);
  }

  Future<void> resetProfile() async {
    state = CarbonData.defaultProfile;
    await _prefs.saveCarbonProfile(state);
  }
}

final carbonProfileProvider =
    StateNotifierProvider<CarbonController, CarbonProfile>((ref) {
  return CarbonController(ref.watch(preferencesServiceProvider));
});

// ---------------------------------------------------------------------------
// Decisiones energéticas
// ---------------------------------------------------------------------------

class EnergyController extends StateNotifier<Set<String>> {
  EnergyController(this._prefs) : super(_prefs.loadEnergyMeasures());

  final PreferencesService _prefs;

  Future<void> toggle(String id) async {
    final next = Set<String>.from(state);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = next;
    await _prefs.saveEnergyMeasures(state);
  }

  Future<void> clear() async {
    state = <String>{};
    await _prefs.saveEnergyMeasures(state);
  }
}

final energyMeasuresProvider =
    StateNotifierProvider<EnergyController, Set<String>>((ref) {
  return EnergyController(ref.watch(preferencesServiceProvider));
});

// ---------------------------------------------------------------------------
// Resumen de progreso (derivado)
// ---------------------------------------------------------------------------

class ProgressSummary {
  const ProgressSummary({
    required this.exploredScenarios,
    required this.totalScenarios,
    required this.attempts,
    required this.decisions,
    required this.mitigationMeasures,
    required this.adaptationMeasures,
    required this.classificationHits,
    required this.classificationTotal,
    required this.counters,
  });

  final Set<String> exploredScenarios;
  final int totalScenarios;
  final int attempts;
  final int decisions;
  final int mitigationMeasures;
  final int adaptationMeasures;
  final int classificationHits;
  final int classificationTotal;
  final ActivityCounters counters;

  double get scenarioCoverage =>
      totalScenarios == 0 ? 0 : exploredScenarios.length / totalScenarios;

  int get classificationPercent => classificationTotal == 0
      ? 0
      : ((classificationHits / classificationTotal) * 100).round();
}

final progressProvider = Provider<ProgressSummary>((ref) {
  final attempts = ref.watch(attemptsProvider);
  final counters = ref.watch(countersProvider);
  final scenarios = ref.watch(scenariosProvider);

  final explored = <String>{};
  var decisions = 0;
  var mitigation = 0;
  var adaptation = 0;
  var hits = 0;
  var classified = 0;

  for (final attempt in attempts) {
    explored.add(attempt.scenarioId);
    decisions += attempt.choices.length;
    mitigation += attempt.mitigationCount;
    adaptation += attempt.adaptationCount;
    hits += attempt.classificationHits;
    classified += attempt.classificationTotal;
  }

  return ProgressSummary(
    exploredScenarios: explored,
    totalScenarios: scenarios.length,
    attempts: attempts.length,
    decisions: decisions,
    mitigationMeasures: mitigation,
    adaptationMeasures: adaptation,
    classificationHits: hits,
    classificationTotal: classified,
    counters: counters,
  );
});
