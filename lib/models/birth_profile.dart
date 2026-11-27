class BirthProfile {
  const BirthProfile({
    required this.id,
    required this.name,
    required this.birthDate,
    this.birthTime,
    this.birthPlace,
  });

  final String id;
  final String name;
  final DateTime birthDate;
  final String? birthTime;
  final String? birthPlace;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'birthDate': birthDate.toIso8601String(),
        'birthTime': birthTime,
        'birthPlace': birthPlace,
      };

  factory BirthProfile.fromJson(Map<String, dynamic> json) => BirthProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        birthDate: DateTime.parse(json['birthDate'] as String),
        birthTime: json['birthTime'] as String?,
        birthPlace: json['birthPlace'] as String?,
      );
}
