import 'package:hevelius_ephemeris/hevelius_ephemeris.dart';

import '../../../application/ports/ephemeris_engine.dart';
import '../../../domain/astrology/chart_calculation_input.dart';
import '../../../domain/astrology/chart_calculation_result.dart';
import '../../../domain/astrology/celestial_position.dart';

/// Hevelius-backed implementation of the application's ephemeris port.
///
/// The caller owns loading and lifecycle of the JPL SPK data. On mobile,
/// copy the selected .bsp file to an application-readable local file first,
/// then create a [SpkEphemeris] and pass it here.
///
/// House cusps are deliberately not returned: the open Hevelius package
/// currently exposes ASC/MC but not a complete house-system calculation.
class HeveliusEphemerisEngine implements EphemerisEngine {
  HeveliusEphemerisEngine(this._ephemeris);

  final Ephemeris _ephemeris;

  @override
  String get engineId => 'hevelius';

  @override
  String get engineVersion => '0.1.2';

  @override
  Future<ChartCalculationResult> calculate(
    ChartCalculationInput input,
  ) async {
    if (!input.isValid) {
      throw ArgumentError.value(input, 'input', 'Invalid chart input.');
    }

    final utc = input.utcDateTime;
    final jdUt = julianDay(
      utc.year,
      utc.month,
      utc.day,
      hour: utc.hour,
      minute: utc.minute,
      second: utc.second +
          (utc.millisecond / 1000) +
          (utc.microsecond / 1000000),
    );
    final jdTt = julianDayTT(jdUt);

    final positions = <CelestialPosition>[
      _bodyPosition('sun', Naif.sun, jdTt),
      _bodyPosition('moon', Naif.moon, jdTt),
      _bodyPosition('mercury', Naif.mercury, jdTt),
      _bodyPosition('venus', Naif.venus, jdTt),
      _bodyPosition('mars', Naif.marsBarycenter, jdTt),
      _bodyPosition('jupiter', Naif.jupiterBarycenter, jdTt),
      _bodyPosition('saturn', Naif.saturnBarycenter, jdTt),
      _bodyPosition('uranus', Naif.uranusBarycenter, jdTt),
      _bodyPosition('neptune', Naif.neptuneBarycenter, jdTt),
      _bodyPosition('pluto', Naif.plutoBarycenter, jdTt),
      _lunarPoint('north_node_mean', LunarPoint.meanNode, jdTt),
      _lunarPoint('north_node_true', LunarPoint.trueNode, jdTt),
      _lunarPoint('lilith_mean', LunarPoint.meanApogee, jdTt),
      _lunarPoint('lilith_osculating', LunarPoint.osculatingApogee, jdTt),
    ];

    final chartAngles = angles(
      jdUt,
      input.latitudeDegrees,
      input.longitudeDegrees,
    );

    return ChartCalculationResult(
      positions: positions,
      engineId: engineId,
      engineVersion: engineVersion,
      calculatedAtUtc: DateTime.now().toUtc(),
      ascendantLongitudeDegrees: chartAngles.ascendant,
      midheavenLongitudeDegrees: chartAngles.midheaven,
    );
  }

  CelestialPosition _bodyPosition(String id, int naifCode, double jdTt) {
    final position = geocentricEcliptic(_ephemeris, naifCode, jdTt);
    final speed = longitudeSpeed(
      bodyLongitude(_ephemeris, naifCode),
      jdTt,
    );

    return CelestialPosition(
      bodyId: id,
      longitudeDegrees: position.longitude,
      latitudeDegrees: position.latitude,
      distanceAu: position.distance / astronomicalUnit,
      isRetrograde: speed < 0,
    );
  }

  CelestialPosition _lunarPoint(
    String id,
    LunarPoint point,
    double jdTt,
  ) {
    final position = lunarPoint(_ephemeris, point, jdTt);
    return CelestialPosition(
      bodyId: id,
      longitudeDegrees: position.longitude,
      latitudeDegrees: position.latitude,
    );
  }
}
