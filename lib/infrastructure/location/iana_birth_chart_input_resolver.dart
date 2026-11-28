import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../application/ports/birth_chart_input_resolver.dart';
import '../../application/ports/birth_place_geocoder.dart';
import '../../domain/astrology/chart_calculation_input.dart';
import '../../domain/location/geocoded_birth_place.dart';
import '../../models/birth_profile.dart';

/// Resolves a civil birth record to UTC using the place's historical IANA rules.
///
/// Ambiguous clock times (DST fall-back) and nonexistent clock times
/// (DST spring-forward) are rejected instead of guessed.
class IanaBirthChartInputResolver implements BirthChartInputResolver {
  IanaBirthChartInputResolver({required BirthPlaceGeocoder geocoder})
      : _geocoder = geocoder {
    _initializeTimeZones();
  }

  final BirthPlaceGeocoder _geocoder;

  static bool _timeZonesInitialized = false;

  static void _initializeTimeZones() {
    if (_timeZonesInitialized) return;
    tzdata.initializeTimeZones();
    _timeZonesInitialized = true;
  }

  @override
  Future<ChartCalculationInput> resolve(BirthProfile profile) async {
    final time = _parseBirthTime(profile.birthTime);
    final place = await _resolvePlace(profile);
    if (!place.isValid) {
      throw StateError('Die Ortsdaten sind unvollständig oder ungültig.');
    }

    final location = _getTimeZone(place.timeZoneId);
    final utc = _resolveLocalTime(
      date: profile.birthDate,
      hour: time.$1,
      minute: time.$2,
      location: location,
    );

    return ChartCalculationInput(
      utcDateTime: utc,
      latitudeDegrees: place.latitudeDegrees,
      longitudeDegrees: place.longitudeDegrees,
    );
  }

  Future<GeocodedBirthPlace> _resolvePlace(BirthProfile profile) async {
    final latitude = profile.birthPlaceLatitude;
    final longitude = profile.birthPlaceLongitude;
    final zone = profile.birthPlaceTimeZoneId?.trim() ?? '';
    if (latitude != null && longitude != null && zone.isNotEmpty) {
      return GeocodedBirthPlace(
        name: profile.birthPlace?.trim().isNotEmpty == true
            ? profile.birthPlace!.trim()
            : 'Gespeicherter Geburtsort',
        latitudeDegrees: latitude,
        longitudeDegrees: longitude,
        timeZoneId: zone,
        country: profile.birthPlaceCountry,
      );
    }

    final query = profile.birthPlace?.trim() ?? '';
    if (query.isEmpty) {
      throw StateError('Für das Geburtsprofil fehlt der Geburtsort.');
    }
    final matches = await _geocoder.search(query);
    if (matches.isEmpty) {
      throw StateError('Der Geburtsort „$query“ wurde nicht gefunden.');
    }
    if (matches.length > 1) {
      throw StateError(
        'Der Geburtsort ist nicht eindeutig. Bitte Ort und Land ergänzen.',
      );
    }
    return matches.single;
  }

  static (int, int) _parseBirthTime(String? value) {
    final match = RegExp(r'^(?:([01]\d|2[0-3])):([0-5]\d)$')
        .firstMatch(value?.trim() ?? '');
    if (match == null) {
      throw StateError('Bitte eine genaue Geburtszeit im Format HH:MM eingeben.');
    }
    return (int.parse(match.group(1)!), int.parse(match.group(2)!));
  }

  static tz.Location _getTimeZone(String id) {
    try {
      return tz.getLocation(id);
    } on ArgumentError {
      throw StateError('Die Zeitzone „$id“ ist in der IANA-Datenbank unbekannt.');
    }
  }

  static DateTime _resolveLocalTime({
    required DateTime date,
    required int hour,
    required int minute,
    required tz.Location location,
  }) {
    final localAsUtc = DateTime.utc(date.year, date.month, date.day, hour, minute);
    final candidates = <DateTime>{};

    for (var hours = -96; hours <= 96; hours += 3) {
      final sample = localAsUtc.add(Duration(hours: hours));
      final offset = location.timeZone(sample.millisecondsSinceEpoch).offset;
      final candidate = localAsUtc.subtract(offset);
      final local = tz.TZDateTime.from(candidate, location);
      if (local.year == date.year &&
          local.month == date.month &&
          local.day == date.day &&
          local.hour == hour &&
          local.minute == minute &&
          local.second == 0) {
        candidates.add(candidate);
      }
    }

    if (candidates.isEmpty) {
      throw StateError(
        'Diese lokale Geburtszeit existiert wegen einer Zeitumstellung nicht.',
      );
    }
    if (candidates.length > 1) {
      throw StateError(
        'Diese lokale Geburtszeit kommt wegen der Zeitumstellung zweimal vor. '
        'Bitte die genaue UTC-Abweichung bzw. Sommer-/Winterzeit klären.',
      );
    }
    return candidates.single.toUtc();
  }
}
