import 'package:flutter_test/flutter_test.dart';
import 'package:horoskopium/models/birth_profile.dart';

void main() {
  test('round-trips selected birth place metadata', () {
    final profile = BirthProfile(
      id: 'profile-1',
      name: 'Ada',
      birthDate: DateTime(1990, 4, 12),
      birthTime: '14:35',
      birthPlace: 'Münster, Germany',
      birthPlaceLatitude: 51.9607,
      birthPlaceLongitude: 7.6261,
      birthPlaceTimeZoneId: 'Europe/Berlin',
      birthPlaceCountry: 'Germany',
    );

    final restored = BirthProfile.fromJson(profile.toJson());

    expect(restored.birthPlaceLatitude, 51.9607);
    expect(restored.birthPlaceLongitude, 7.6261);
    expect(restored.birthPlaceTimeZoneId, 'Europe/Berlin');
    expect(restored.birthPlaceCountry, 'Germany');
  });

  test('loads legacy profile data without selected-place metadata', () {
    final restored = BirthProfile.fromJson({
      'id': 'legacy',
      'name': 'Ada',
      'birthDate': '1990-04-12T00:00:00.000',
      'birthTime': '14:35',
      'birthPlace': 'Münster',
    });

    expect(restored.birthPlaceLatitude, isNull);
    expect(restored.birthPlaceLongitude, isNull);
    expect(restored.birthPlaceTimeZoneId, isNull);
  });
}
