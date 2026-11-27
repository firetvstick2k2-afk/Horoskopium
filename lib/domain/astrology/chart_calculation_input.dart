/// Immutable, calculation-ready birth data.
///
/// [utcDateTime] must already represent the birth instant in UTC. Resolving a
/// historical local time and its timezone/DST belongs to the location/time
/// resolution layer, not to an ephemeris implementation.
class ChartCalculationInput {
  const ChartCalculationInput({
    required this.utcDateTime,
    required this.latitudeDegrees,
    required this.longitudeDegrees,
    this.houseSystem = 'Placidus',
  });

  final DateTime utcDateTime;
  final double latitudeDegrees;
  final double longitudeDegrees;
  final String houseSystem;

  bool get isValid =>
      utcDateTime.isUtc &&
      latitudeDegrees.isFinite &&
      latitudeDegrees >= -90 &&
      latitudeDegrees <= 90 &&
      longitudeDegrees.isFinite &&
      longitudeDegrees >= -180 &&
      longitudeDegrees <= 180 &&
      houseSystem.trim().isNotEmpty;
}
