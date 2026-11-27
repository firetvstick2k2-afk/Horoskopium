import 'celestial_position.dart';

/// Result returned by a verified ephemeris implementation.
class ChartCalculationResult {
  ChartCalculationResult({
    required this.positions,
    required this.engineId,
    required this.engineVersion,
    required this.calculatedAtUtc,
    this.ascendantLongitudeDegrees,
    this.midheavenLongitudeDegrees,
  }) : positions = List.unmodifiable(positions);

  final List<CelestialPosition> positions;
  final String engineId;
  final String engineVersion;
  final DateTime calculatedAtUtc;

  /// Ecliptic longitude of the Ascendant, when calculated by the engine.
  final double? ascendantLongitudeDegrees;

  /// Ecliptic longitude of the Midheaven (MC), when calculated by the engine.
  final double? midheavenLongitudeDegrees;

  bool get isValid =>
      positions.every((position) => position.isValid) &&
      engineId.trim().isNotEmpty &&
      engineVersion.trim().isNotEmpty &&
      calculatedAtUtc.isUtc &&
      _isValidAngle(ascendantLongitudeDegrees) &&
      _isValidAngle(midheavenLongitudeDegrees);

  static bool _isValidAngle(double? value) =>
      value == null || (value.isFinite && value >= 0 && value < 360);
}
