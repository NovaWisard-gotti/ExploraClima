import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/attempt.dart';
import '../models/carbon.dart';

/// Persistencia local de ExploraClima.
///
/// La aplicacion funciona completamente offline: no existe backend ni cuentas
/// de usuario. Todo el progreso se guarda en el dispositivo.
class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  static const String _kThemeMode = 'exploraclima.theme_mode';
  static const String _kAttempts = 'exploraclima.attempts';
  static const String _kCounters = 'exploraclima.counters';
  static const String _kCarbon = 'exploraclima.carbon_profile';
  static const String _kEnergy = 'exploraclima.energy_measures';

  // --- Tema -----------------------------------------------------------------

  ThemeMode loadThemeMode() {
    final raw = _prefs.getString(_kThemeMode);
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs.setString(_kThemeMode, mode.name);
  }

  // --- Intentos -------------------------------------------------------------

  List<AttemptRecord> loadAttempts() {
    final raw = _prefs.getString(_kAttempts);
    if (raw == null || raw.isEmpty) return <AttemptRecord>[];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => AttemptRecord.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return <AttemptRecord>[];
    }
  }

  Future<void> saveAttempts(List<AttemptRecord> attempts) async {
    final encoded = jsonEncode(attempts.map((a) => a.toJson()).toList());
    await _prefs.setString(_kAttempts, encoded);
  }

  // --- Contadores de actividad ---------------------------------------------

  ActivityCounters loadCounters() {
    final raw = _prefs.getString(_kCounters);
    if (raw == null || raw.isEmpty) return const ActivityCounters();
    try {
      return ActivityCounters.fromJson(
          Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (_) {
      return const ActivityCounters();
    }
  }

  Future<void> saveCounters(ActivityCounters counters) async {
    await _prefs.setString(_kCounters, jsonEncode(counters.toJson()));
  }

  // --- Huella de carbono ----------------------------------------------------

  CarbonProfile? loadCarbonProfile() {
    final raw = _prefs.getString(_kCarbon);
    if (raw == null || raw.isEmpty) return null;
    try {
      return CarbonProfile.fromJson(
          Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCarbonProfile(CarbonProfile profile) async {
    await _prefs.setString(_kCarbon, jsonEncode(profile.toJson()));
  }

  // --- Decisiones energeticas ----------------------------------------------

  Set<String> loadEnergyMeasures() {
    final raw = _prefs.getStringList(_kEnergy);
    if (raw == null) return <String>{};
    return raw.toSet();
  }

  Future<void> saveEnergyMeasures(Set<String> measures) async {
    await _prefs.setStringList(_kEnergy, measures.toList());
  }

  // --- Mantenimiento --------------------------------------------------------

  Future<void> clearLearningData() async {
    await _prefs.remove(_kAttempts);
    await _prefs.remove(_kCounters);
    await _prefs.remove(_kCarbon);
    await _prefs.remove(_kEnergy);
  }
}
