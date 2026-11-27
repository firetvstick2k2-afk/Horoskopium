import 'celestial_position.dart';

/// Result returned by a verified ephemeris implementation.
class ChartCalculationResult {
  ChartCalculationResult({
    required this.positions,
    required this.engineId,
    required this.engineVersion,
    required this.calculatedAtUtc,
  }) : positions = List.unmodifiable(positions);

  final List<CelestialPosition> positions;
  final String engineId;
  final String engineVersion;
  final DateTime calculatedAtUtc;

  bool get isValid =>
      positions.every((position) => position.isValid) &&
      engineId.trim().isNotEmpty &&
      engineVersion.trim().isNotEmpty &&
      calculatedAtUtc.isUtc;
}
