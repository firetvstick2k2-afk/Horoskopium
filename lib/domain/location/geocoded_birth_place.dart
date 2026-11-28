/// A resolved birth place with WGS84 coordinates and an IANA time zone.
class GeocodedBirthPlace {
  const GeocodedBirthPlace({
    required this.name,
    required this.latitudeDegrees,
    required this.longitudeDegrees,
    required this.timeZoneId,
    this.country,
  });

  final String name;
  final double latitudeDegrees;
  final double longitudeDegrees;
  final String timeZoneId;
  final String? country;

  bool get isValid =>
      name.trim().isNotEmpty &&
      latitudeDegrees.isFinite &&
      latitudeDegrees >= -90 &&
      latitudeDegrees <= 90 &&
      longitudeDegrees.isFinite &&
      longitudeDegrees >= -180 &&
      longitudeDegrees <= 180 &&
      timeZoneId.trim().isNotEmpty;
}
