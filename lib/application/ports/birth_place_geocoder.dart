import '../../domain/location/geocoded_birth_place.dart';

/// Converts a user-entered place name into coordinates and an IANA time zone.
abstract interface class BirthPlaceGeocoder {
  Future<List<GeocodedBirthPlace>> search(String query);
}
