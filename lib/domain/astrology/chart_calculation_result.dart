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

  /// Ecliptic longitude of the Ascendant, when calculated by the engine.
  final double? ascendantLongitudeDegrees;

  /// Ecliptic longitude of the Midheaven (MC), when calculated by the engine.
  final double? midheavenLongitudeDegrees;

  /// Ecliptic longitudes of house cusps 1–12, when available.
  final List<double> houseCuspsDegrees;

  /// User-requested house system (for example, "Placidus").
  final String? requestedHouseSystem;

  /// Actually calculated house system (may differ after a polar fallback).
  final String? effectiveHouseSystem;

  /// True when Placidus was undefined and Whole Sign was used instead.
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
