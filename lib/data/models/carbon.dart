import 'package:flutter/material.dart';

/// Categoria de actividad para el analisis simplificado de huella de carbono.
@immutable
class CarbonCategory {
  const CarbonCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.note,
    required this.options,
  });

  final String id;
  final String label;
  final IconData icon;
  final String note;
  final List<CarbonOption> options;

  CarbonOption optionById(String id) =>
      options.firstWhere((o) => o.id == id, orElse: () => options.first);

  CarbonOption get lowest =>
      options.reduce((a, b) => a.relativeValue <= b.relativeValue ? a : b);
}

@immutable
class CarbonOption {
  const CarbonOption({
    required this.id,
    required this.label,
    required this.relativeValue,
    required this.detail,
  });

  final String id;
  final String label;

  /// Emisiones relativas educativas (unidades comparativas, no oficiales).
  final double relativeValue;
  final String detail;
}

/// Perfil elegido por el estudiante: categoria -> opcion seleccionada.
class CarbonProfile {
  const CarbonProfile(this.selection);

  final Map<String, String> selection;

  CarbonProfile withOption(String categoryId, String optionId) {
    final next = Map<String, String>.from(selection);
    next[categoryId] = optionId;
    return CarbonProfile(next);
  }

  Map<String, dynamic> toJson() => selection;

  static CarbonProfile fromJson(Map<String, dynamic> json) => CarbonProfile(
      json.map((key, value) => MapEntry(key, value as String)));
}

@immutable
class GlossaryEntry {
  const GlossaryEntry({
    required this.term,
    required this.definition,
    required this.example,
    required this.group,
  });

  final String term;
  final String definition;
  final String example;
  final String group;
}
