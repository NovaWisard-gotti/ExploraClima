import '../../data/models/indicator.dart';

/// Utilidades de formato usadas en toda la aplicación.
class Formats {
  const Formats._();

  static const List<String> _months = <String>[
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  static String dateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _months[date.month - 1];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day $month ${date.year} · $hour:$minute';
  }

  static String shortDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _months[date.month - 1];
    return '$day $month ${date.year}';
  }

  /// Diferencia con signo explícito, respetando los decimales del indicador.
  static String signedDelta(ClimateIndicator indicator, double delta) {
    final meta = metaOf(indicator);
    final sign = delta > 0 ? '+' : (delta < 0 ? '−' : '±');
    return '$sign${delta.abs().toStringAsFixed(meta.decimals)}';
  }

  static String percent(double value) => '${(value * 100).round()} %';
}
