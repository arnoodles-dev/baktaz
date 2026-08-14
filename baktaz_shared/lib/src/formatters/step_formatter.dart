import 'package:intl/intl.dart';

abstract class StepFormatter {
  static final NumberFormat _stepFormat = NumberFormat('#,##0');
  static final NumberFormat _distanceFormat = NumberFormat('#,##0.0');

  /// Formats step count (e.g. 10000 -> "10,000 steps" or "10,000")
  static String formatSteps(int steps, {bool includeUnit = true}) {
    final String formatted = _stepFormat.format(steps);
    return includeUnit ? '$formatted steps' : formatted;
  }

  /// Formats distance in km (e.g. 7.5 -> "7.5 km")
  static String formatDistanceKm(double kilometers) => '${_distanceFormat.format(kilometers)} km';

  /// Formats step goal progress percentage (e.g. 7500 / 10000 -> "75%")
  static String formatProgressPercent(int currentSteps, int targetSteps) {
    if (targetSteps <= 0) return '0%';
    final double percent = (currentSteps / targetSteps * 100).clamp(0, 100);
    return '${percent.toStringAsFixed(0)}%';
  }
}
