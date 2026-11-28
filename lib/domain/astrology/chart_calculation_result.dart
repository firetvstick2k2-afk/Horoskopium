import 'aspect_calculator.dart';
import 'celestial_position.dart';

/// Result returned by a verified ephemeris implementation and enriched by
/// the application layer with derived chart data.
class ChartCalculationResult {
  ChartCalculationResult({
    required List<CelestialPosition> positions,
    required this.engineId,
    required this.engineVersion,
    required this.calculatedAtUtc,
    this.ascendantLongitudeDegrees,
    this.midheavenLongitudeDegrees,
    List<double> houseCuspsDegrees = const [],
    this.requestedHouseSystem,
    this.effectiveHouseSystem,
    this.usedPolarHouseFallback = false,
    List<CalculatedAspect> aspects = const [],
  })  : positions = List.unmodifiable(positions),
        houseCuspsDegrees = List.unmodifiable(houseCuspsDegrees),
        aspects = List.unmodifiable(aspects);

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

  /// Major aspects derived from [positions] by the application layer.
  final List<CalculatedAspect> aspects;

  /// Returns an equivalent result enriched with application-derived aspects.
  ChartCalculationResult withAspects(List<CalculatedAspect> calculatedAspects) {
    return ChartCalculationResult(
      positions: positions,
      engineId: engineId,
      engineVersion: engineVersion,
      calculatedAtUtc: calculatedAtUtc,
      ascendantLongitudeDegrees: ascendantLongitudeDegrees,
      midheavenLongitudeDegrees: midheavenLongitudeDegrees,
      houseCuspsDegrees: houseCuspsDegrees,
      requestedHouseSystem: requestedHouseSystem,
      effectiveHouseSystem: effectiveHouseSystem,
      usedPolarHouseFallback: usedPolarHouseFallback,
      aspects: calculatedAspects,
    );
  }

  bool get isValid {
    final bodyIds = positions.map((position) => position.bodyId).toSet();
    return positions.every((position) => position.isValid) &&
        bodyIds.length == positions.length &&
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
                effectiveHouseSystem?.trim().isNotEmpty == true)) &&
        aspects.every((aspect) =>
            aspect.firstBodyId != aspect.secondBodyId &&
            bodyIds.contains(aspect.firstBodyId) &&
            bodyIds.contains(aspect.secondBodyId) &&
            aspect.exactAngleDegrees.isFinite &&
            aspect.actualSeparationDegrees.isFinite &&
            aspect.actualSeparationDegrees >= 0 &&
            aspect.actualSeparationDegrees <= 180 &&
            aspect.orbDegrees.isFinite &&
            aspect.orbDegrees >= 0);
  }

  static bool _isValidAngle(double? value) =>
      value == null || (value.isFinite && value >= 0 && value < 360);

  static bool _isValidHouseCusp(double value) =>
      value.isFinite && value >= 0 && value < 360;
}
