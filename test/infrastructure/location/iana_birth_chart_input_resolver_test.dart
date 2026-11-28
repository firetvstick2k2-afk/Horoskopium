import 'package:flutter_test/flutter_test.dart';
import 'package:horoskopium/application/ports/birth_place_geocoder.dart';
import 'package:horoskopium/domain/location/geocoded_birth_place.dart';
import 'package:horoskopium/infrastructure/location/iana_birth_chart_input_resolver.dart';
import 'package:horoskopium/models/birth_profile.dart';

void main() {
  group('IanaBirthChartInputResolver', () {
    late _FakeGeocoder geocoder;
    late IanaBirthChartInputResolver resolver;

    setUp(() {
      geocoder = _FakeGeocoder(const [
        GeocodedBirthPlace(
          name: 'Münster',
          country: 'Germany',
          latitudeDegrees: 51.9607,
          longitudeDegrees: 7.6261,
          timeZoneId: 'Europe/Berlin',
        ),
      ]);
      resolver = IanaBirthChartInputResolver(geocoder: geocoder);
    });

    test('converts German summer time to UTC', () async {
      final result = await resolver.resolve(_profile(
        date: DateTime(1990, 4, 12),
        time: '14:35',
      ));

      expect(result.utcDateTime, DateTime.utc(1990, 4, 12, 12, 35));
      expect(result.latitudeDegrees, 51.9607);
      expect(result.longitudeDegrees, 7.6261);
    });

    test('converts German winter time to UTC', () async {
      final result = await resolver.resolve(_profile(
        date: DateTime(1990, 1, 12),
        time: '14:35',
      ));

      expect(result.utcDateTime, DateTime.utc(1990, 1, 12, 13, 35));
    });

    test('uses the saved place selection without querying the geocoder', () async {
      final result = await resolver.resolve(BirthProfile(
        id: 'saved',
        name: 'Test',
        birthDate: DateTime(1990, 4, 12),
        birthTime: '14:35',
        birthPlace: 'Münster, Germany',
        birthPlaceLatitude: 51.9607,
        birthPlaceLongitude: 7.6261,
        birthPlaceTimeZoneId: 'Europe/Berlin',
        birthPlaceCountry: 'Germany',
      ));

      expect(result.utcDateTime, DateTime.utc(1990, 4, 12, 12, 35));
      expect(result.latitudeDegrees, 51.9607);
      expect(geocoder.callCount, 0);
    });

    test('rejects a nonexistent time during spring-forward', () async {
      await expectLater(
        resolver.resolve(_profile(
          date: DateTime(2024, 3, 31),
          time: '02:30',
        )),
        throwsA(isA<StateError>()),
      );
    });

    test('rejects an ambiguous time during fall-back', () async {
      await expectLater(
        resolver.resolve(_profile(
          date: DateTime(2024, 10, 27),
          time: '02:30',
        )),
        throwsA(isA<StateError>()),
      );
    });

    test('requires an exact birth time', () async {
      await expectLater(
        resolver.resolve(_profile(date: DateTime(1990, 4, 12), time: null)),
        throwsA(isA<StateError>()),
      );
    });

    test('requires an unambiguous place result for legacy profiles', () async {
      geocoder.results = const [
        GeocodedBirthPlace(
          name: 'Münster',
          latitudeDegrees: 51.96,
          longitudeDegrees: 7.62,
          timeZoneId: 'Europe/Berlin',
        ),
        GeocodedBirthPlace(
          name: 'Muenster',
          latitudeDegrees: 49.03,
          longitudeDegrees: 8.40,
          timeZoneId: 'Europe/Berlin',
        ),
      ];

      await expectLater(
        resolver.resolve(_profile(date: DateTime(1990, 4, 12), time: '14:35')),
        throwsA(isA<StateError>()),
      );
    });
  });
}

BirthProfile _profile({required DateTime date, required String? time}) {
  return BirthProfile(
    id: 'test',
    name: 'Test',
    birthDate: date,
    birthTime: time,
    birthPlace: 'Münster, Germany',
  );
}

class _FakeGeocoder implements BirthPlaceGeocoder {
  _FakeGeocoder(this.results);

  List<GeocodedBirthPlace> results;
  int callCount = 0;

  @override
  Future<List<GeocodedBirthPlace>> search(String query) async {
    callCount++;
    return results;
  }
}
