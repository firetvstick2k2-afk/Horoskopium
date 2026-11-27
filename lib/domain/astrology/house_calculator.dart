import 'dart:math' as math;

import 'angle.dart';

/// Supported astrological house systems.
///
/// Placidus is the default western quadrant system. Whole Sign is provided as
/// a robust alternative and as the explicit fallback where Placidus is
/// mathematically undefined.
enum HouseSystem {
  placidus,
  wholeSign;

  static HouseSystem parse(String value) {
    switch (value.trim().toLowerCase().replaceAll(RegExp(r'[ _-]'), '')) {
      case 'placidus':
        return HouseSystem.placidus;
      case 'wholesign':
      case 'whole':
        return HouseSystem.wholeSign;
      default:
        throw ArgumentError.value(value, 'value', 'Unsupported house system.');
    }
  }

  String get displayName =>
      this == HouseSystem.placidus ? 'Placidus' : 'Whole Sign';
}

/// Result of a house-cusp calculation. Cusps are ordered houses 1 through 12.
class HouseCalculation {
  HouseCalculation({
    required List<double> cusps,
    required this.requestedSystem,
    required this.effectiveSystem,
    required this.usedPolarFallback,
  }) : cusps = List.unmodifiable(cusps) {
    if (this.cusps.length != 12 ||
        this.cusps.any((cusp) => !cusp.isFinite || cusp < 0 || cusp >= 360)) {
      throw ArgumentError('A house calculation must contain 12 valid cusps.');
    }
  }

  final List<double> cusps;
  final HouseSystem requestedSystem;
  final HouseSystem effectiveSystem;
  final bool usedPolarFallback;
}

/// Pure-Dart house geometry. Inputs are apparent ecliptic-of-date angles and
/// true obliquity, all in degrees. Geographic longitude is represented by
/// ARMC (local apparent sidereal time), not by longitude directly.
class HouseCalculator {
  const HouseCalculator._();

  static const double _polarLimitToleranceDegrees = 1e-10;
  static const int _maxIterations = 100;
  static const double _convergenceRadians = 1e-12;

  /// Calculates all twelve house cusps.
  ///
  /// Placidus is undefined when |latitude| >= 90° - obliquity. In that
  /// situation the calculation explicitly falls back to Whole Sign and
  /// records the fallback; it never returns fabricated Placidus cusps.
  static HouseCalculation calculate({
    required String system,
    required double ascendantDegrees,
    required double midheavenDegrees,
    required double armcDegrees,
    required double latitudeDegrees,
    required double obliquityDegrees,
  }) {
    final requested = HouseSystem.parse(system);
    _validateAngle(ascendantDegrees, 'ascendantDegrees');
    _validateAngle(midheavenDegrees, 'midheavenDegrees');
    _validateFinite(armcDegrees, 'armcDegrees');
    _validateFinite(latitudeDegrees, 'latitudeDegrees');
    _validateFinite(obliquityDegrees, 'obliquityDegrees');
    if (latitudeDegrees < -90 || latitudeDegrees > 90) {
      throw ArgumentError.value(latitudeDegrees, 'latitudeDegrees');
    }
    if (obliquityDegrees <= 0 || obliquityDegrees >= 90) {
      throw ArgumentError.value(obliquityDegrees, 'obliquityDegrees');
    }

    final polarLimit = 90 - obliquityDegrees;
    final polar = latitudeDegrees.abs() >=
        polarLimit - _polarLimitToleranceDegrees;
    final effective = requested == HouseSystem.placidus && polar
        ? HouseSystem.wholeSign
        : requested;

    final cusps = effective == HouseSystem.wholeSign
        ? _wholeSign(ascendantDegrees)
        : _placidus(
            ascendantDegrees: ascendantDegrees,
            midheavenDegrees: midheavenDegrees,
            armcDegrees: armcDegrees,
            latitudeDegrees: latitudeDegrees,
            obliquityDegrees: obliquityDegrees,
          );

    return HouseCalculation(
      cusps: cusps,
      requestedSystem: requested,
      effectiveSystem: effective,
      usedPolarFallback: requested == HouseSystem.placidus && polar,
    );
  }

  static List<double> _wholeSign(double ascendant) {
    final first = (ascendant / 30).floor() * 30.0;
    return List<double>.generate(12, (index) => Angle.normalize(first + 30 * index));
  }

  static List<double> _placidus({
    required double ascendantDegrees,
    required double midheavenDegrees,
    required double armcDegrees,
    required double latitudeDegrees,
    required double obliquityDegrees,
  }) {
    final phi = _radians(latitudeDegrees);
    final epsilon = _radians(obliquityDegrees);
    final ramc = _radians(armcDegrees);

    // The four intermediate cusps divide the relevant diurnal/nocturnal
    // semi-arcs into thirds. The fixed-point equation is:
    // RA = ARMC + offset + fraction * asin(tan(phi) * tan(declination)).
    final ra11 = _solveCuspRa(ramc, phi, epsilon, 30, 1 / 3);
    final ra12 = _solveCuspRa(ramc, phi, epsilon, 60, 2 / 3);
    final ra2 = _solveCuspRa(ramc, phi, epsilon, 120, 2 / 3);
    final ra3 = _solveCuspRa(ramc, phi, epsilon, 150, 1 / 3);

    final lambda11 = _rightAscensionToLongitude(ra11, epsilon);
    final lambda12 = _rightAscensionToLongitude(ra12, epsilon);
    final lambda2 = _rightAscensionToLongitude(ra2, epsilon);
    final lambda3 = _rightAscensionToLongitude(ra3, epsilon);

    return <double>[
      Angle.normalize(ascendantDegrees),
      lambda2,
      lambda3,
      Angle.normalize(midheavenDegrees + 180),
      Angle.normalize(lambda11 + 180),
      Angle.normalize(lambda12 + 180),
      Angle.normalize(ascendantDegrees + 180),
      Angle.normalize(lambda2 + 180),
      Angle.normalize(lambda3 + 180),
      Angle.normalize(midheavenDegrees),
      lambda11,
      lambda12,
    ];
  }

  static double _solveCuspRa(
    double ramc,
    double latitude,
    double obliquity,
    double offsetDegrees,
    double fraction,
  ) {
    final offset = _radians(offsetDegrees);
    var rightAscension = ramc + offset;

    for (var iteration = 0; iteration < _maxIterations; iteration++) {
      final declination = math.asin(
        math.sin(rightAscension) * math.sin(obliquity),
      );
      final tangentProduct = math.tan(latitude) * math.tan(declination);
      if (!tangentProduct.isFinite || tangentProduct.abs() >= 1) {
        throw StateError(
          'Placidus cusp is circumpolar at this latitude; no valid cusp exists.',
        );
      }
      final semiArcCorrection = math.asin(tangentProduct);
      final next = ramc + offset + fraction * semiArcCorrection;
      if ((next - rightAscension).abs() < _convergenceRadians) {
        return next;
      }
      rightAscension = next;
    }

    throw StateError('Placidus cusp iteration did not converge.');
  }

  static double _rightAscensionToLongitude(double rightAscension, double eps) {
    final longitude = math.atan2(
      math.sin(rightAscension),
      math.cos(rightAscension) * math.cos(eps),
    );
    return Angle.normalize(_degrees(longitude));
  }

  static void _validateAngle(double value, String name) {
    _validateFinite(value, name);
    if (value < 0 || value >= 360) {
      throw ArgumentError.value(value, name, 'Must be in [0, 360).');
    }
  }

  static void _validateFinite(double value, String name) {
    if (!value.isFinite) {
      throw ArgumentError.value(value, name, 'Must be finite.');
    }
  }

  static double _radians(double degrees) => degrees * math.pi / 180;
  static double _degrees(double radians) => radians * 180 / math.pi;
}
