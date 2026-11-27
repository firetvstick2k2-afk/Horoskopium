import 'package:hevelius_ephemeris/hevelius_ephemeris.dart';
import 'package:hevelius_ephemeris/spk_io.dart';

import '../../../application/ports/ephemeris_engine.dart';
import '../../../domain/astrology/chart_calculation_input.dart';
import '../../../domain/astrology/chart_calculation_result.dart';
import '../../../domain/astrology/celestial_position.dart';
import '../../../domain/astrology/house_calculator.dart';

/// Hevelius-backed implementation of the application's ephemeris port.
///
/// The caller owns the JPL SPK data file. On mobile, copy the selected .bsp
/// file to an application-readable local file first. Use [fromSpkFilePath]
/// to open it on demand without loading the complete file into memory.
class HeveliusEphemerisEngine implements EphemerisEngine {
  HeveliusEphemerisEngine(this._ephemeris);

  /// Opens a local JPL SPK file and creates an engine backed by that file.
  factory HeveliusEphemerisEngine.fromSpkFilePath(String path) {
    return HeveliusEphemerisEngine(
      SpkEphemeris([openSpkFile(path)]),
    );
  }

  final Ephemeris _ephemeris;

  @override
  String get engineId => 'hevelius';

  @override
  String get engineVersion => '0.1.2+houses.1';

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
    final obliquityRadians = trueObliquity(centuriesSinceJ2000(jdTt));
    final houseCalculation = HouseCalculator.calculate(
      system: input.houseSystem,
      ascendantDegrees: chartAngles.ascendant,
      midheavenDegrees: chartAngles.midheaven,
      armcDegrees: chartAngles.armc,
      latitudeDegrees: input.latitudeDegrees,
      obliquityDegrees: obliquityRadians * 180 / 3.141592653589793,
    );

    return ChartCalculationResult(
      positions: positions,
      engineId: engineId,
      engineVersion: engineVersion,
      calculatedAtUtc: DateTime.now().toUtc(),
      ascendantLongitudeDegrees: chartAngles.ascendant,
      midheavenLongitudeDegrees: chartAngles.midheaven,
      houseCuspsDegrees: houseCalculation.cusps,
      requestedHouseSystem: houseCalculation.requestedSystem.displayName,
      effectiveHouseSystem: houseCalculation.effectiveSystem.displayName,
      usedPolarHouseFallback: houseCalculation.usedPolarFallback,
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
