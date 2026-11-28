import 'package:flutter_test/flutter_test.dart';
import 'package:horoskopium/infrastructure/location/open_meteo_birth_place_geocoder.dart';

void main() {
  test('maps Open-Meteo geocoding results to validated birth places', () async {
    Uri? requested;
    final geocoder = OpenMeteoBirthPlaceGeocoder(
      getJson: (uri) async {
        requested = uri;
        return {
          'results': [
            {
              'name': 'Münster',
              'country': 'Deutschland',
              'latitude': 51.9607,
              'longitude': 7.6261,
              'timezone': 'Europe/Berlin',
            },
          ],
        };
      },
    );

    final results = await geocoder.search('Münster, Germany');

    expect(requested!.scheme, 'https');
    expect(requested!.host, 'geocoding-api.open-meteo.com');
    expect(requested!.queryParameters['name'], 'Münster, Germany');
    expect(results.single.name, 'Münster');
    expect(results.single.timeZoneId, 'Europe/Berlin');
    expect(results.single.latitudeDegrees, 51.9607);
  });

  test('returns an empty list when provider has no matching places', () async {
    final geocoder = OpenMeteoBirthPlaceGeocoder(
      getJson: (_) async => {},
    );

    expect(await geocoder.search('Atlantis'), isEmpty);
  });

  test('rejects malformed provider results', () async {
    final geocoder = OpenMeteoBirthPlaceGeocoder(
      getJson: (_) async => {
        'results': [
          {'name': 'Unknown', 'latitude': 'north'},
        ],
      },
    );

    await expectLater(
      geocoder.search('Unknown'),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects a query that is too short', () async {
    final geocoder = OpenMeteoBirthPlaceGeocoder(
      getJson: (_) async => {},
    );

    await expectLater(
      geocoder.search('A'),
      throwsArgumentError,
    );
  });
}
