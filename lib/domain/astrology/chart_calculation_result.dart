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
    List<double> houseCuspsDegrees = const [],
    this.requestedHouseSystem,
    this.effectiveHouseSystem,
    this.usedPolarHouseFallback = false,
  })  : positions = List.unmodifiable(positions),
        houseCuspsDegrees = List.unmodifiable(houseCuspsDegrees);

  final List<CelestialPosition> positions;
  final String engineId;
  final String engineVersion;
  final DateTime calculatedAtUtc;
  final double? ascendantLongitudeDegrees;
  final double? midheavenLongitudeDegrees;
  final List<double> houseCuspsDegrees;
  final String? requestedHouseSystem;
  final String? effectiveHouseSystem;
  final bool usedPolarHouseFallback;

  bool get isValid =>
      positions.every((position) => position.isValid) &&
      engineId.trim().isNotEmpty &&
      engineVersion.trim().isNotEmpty &&
      calculatedAtUtc.isUtc &&
      _isValidAngle(ascendantLongitudeDegrees) &&
      _isValidAngle(midheavenLongitudeDegrees) &&
      (houseCuspsDegrees.isEmpty ||
          (houseCuspsDegrees.length == 12 &&
              houseCuspsDegrees.every(_isValidHouseCusp))) &&
      (houseCuspsDegrees.isEmpty ||
          (requestedHouseSystem?.trim().isNotEmpty == true &&
              effectiveHouseSystem?.trim().isNotEmpty == true));

  static bool _isValidAngle(double? value) =>
      value == null || (value.isFinite && value >= 0 && value < 360);

  static bool _isValidHouseCusp(double value) =>
      value.isFinite && value >= 0 && value < 360;
}
