class BirthProfile {
  const BirthProfile({
    required this.id,
    required this.name,
    required this.birthDate,
    this.birthTime,
    this.birthPlace,
    this.birthPlaceLatitude,
    this.birthPlaceLongitude,
    this.birthPlaceTimeZoneId,
    this.birthPlaceCountry,
  });

  final String id;
  final String name;
  final DateTime birthDate;
  final String? birthTime;
  final String? birthPlace;

  /// Coordinates and IANA zone are persisted from the user's selected result.
  /// Older profiles without these fields remain readable and can be resolved
  /// through the geocoder when needed.
  final double? birthPlaceLatitude;
  final double? birthPlaceLongitude;
  final String? birthPlaceTimeZoneId;
  final String? birthPlaceCountry;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'birthDate': birthDate.toIso8601String(),
        'birthTime': birthTime,
        'birthPlace': birthPlace,
        'birthPlaceLatitude': birthPlaceLatitude,
        'birthPlaceLongitude': birthPlaceLongitude,
        'birthPlaceTimeZoneId': birthPlaceTimeZoneId,
        'birthPlaceCountry': birthPlaceCountry,
      };

  factory BirthProfile.fromJson(Map<String, dynamic> json) => BirthProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        birthDate: DateTime.parse(json['birthDate'] as String),
        birthTime: json['birthTime'] as String?,
        birthPlace: json['birthPlace'] as String?,
        birthPlaceLatitude: (json['birthPlaceLatitude'] as num?)?.toDouble(),
        birthPlaceLongitude: (json['birthPlaceLongitude'] as num?)?.toDouble(),
        birthPlaceTimeZoneId: json['birthPlaceTimeZoneId'] as String?,
        birthPlaceCountry: json['birthPlaceCountry'] as String?,
      );
}
