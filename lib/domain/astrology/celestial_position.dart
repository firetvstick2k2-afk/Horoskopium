/// A calculated ecliptic position. Values are supplied by an ephemeris engine.
class CelestialPosition {
  const CelestialPosition({
    required this.bodyId,
    required this.longitudeDegrees,
    this.latitudeDegrees = 0,
    this.distanceAu,
    this.isRetrograde = false,
  });

  final String bodyId;
  final double longitudeDegrees;
  final double latitudeDegrees;
  final double? distanceAu;
  final bool isRetrograde;

  bool get isValid =>
      bodyId.trim().isNotEmpty &&
      longitudeDegrees.isFinite &&
      longitudeDegrees >= 0 &&
      longitudeDegrees < 360 &&
      latitudeDegrees.isFinite &&
      (distanceAu == null || (distanceAu!.isFinite && distanceAu! > 0));
}
