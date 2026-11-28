import 'dart:convert';
import 'dart:io';

import '../../application/ports/birth_place_geocoder.dart';
import '../../domain/location/geocoded_birth_place.dart';

typedef JsonGet = Future<Map<String, dynamic>> Function(Uri uri);

/// Open-Meteo/GeoNames geocoding adapter.
///
/// The transport can be injected in tests. The default implementation uses
/// HTTPS and a short timeout; no account or API key is needed for non-commercial
/// use under the provider's published API terms.
class OpenMeteoBirthPlaceGeocoder implements BirthPlaceGeocoder {
  OpenMeteoBirthPlaceGeocoder({JsonGet? getJson}) : _getJson = getJson ?? _get;

  final JsonGet _getJson;

  @override
  Future<List<GeocodedBirthPlace>> search(String query) async {
    final normalized = query.trim();
    if (normalized.length < 2) {
      throw ArgumentError.value(query, 'query', 'Enter at least two characters.');
    }

    final uri = Uri.https(
      'geocoding-api.open-meteo.com',
      '/v1/search',
      {'name': normalized, 'count': '10', 'language': 'en', 'format': 'json'},
    );
    final json = await _getJson(uri);
    final rawResults = json['results'];
    if (rawResults == null) return const [];
    if (rawResults is! List) {
      throw const FormatException('Invalid geocoding response.');
    }

    return rawResults.map((raw) {
      if (raw is! Map) {
        throw const FormatException('Invalid geocoding result.');
      }
      final item = Map<String, dynamic>.from(raw);
      final name = item['name'];
      final latitude = item['latitude'];
      final longitude = item['longitude'];
      final timezone = item['timezone'];
      if (name is! String ||
          latitude is! num ||
          longitude is! num ||
          timezone is! String) {
        throw const FormatException('Geocoding result is missing required fields.');
      }
      final place = GeocodedBirthPlace(
        name: name,
        latitudeDegrees: latitude.toDouble(),
        longitudeDegrees: longitude.toDouble(),
        timeZoneId: timezone,
        country: item['country'] is String ? item['country'] as String : null,
      );
      if (!place.isValid) {
        throw const FormatException('Geocoding result contains invalid coordinates.');
      }
      return place;
    }).toList(growable: false);
  }

  static Future<Map<String, dynamic>> _get(Uri uri) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client.getUrl(uri).timeout(const Duration(seconds: 10));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close().timeout(const Duration(seconds: 10));
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'Geocoding service returned HTTP ${response.statusCode}.',
          uri: uri,
        );
      }
      final decoded = jsonDecode(body);
      if (decoded is! Map) {
        throw const FormatException('Invalid geocoding response.');
      }
      return Map<String, dynamic>.from(decoded);
    } finally {
      client.close(force: true);
    }
  }
}
