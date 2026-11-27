import 'package:flutter_test/flutter_test.dart';
import 'package:horoskopium/domain/astrology/house_calculator.dart';

void main() {
  group('HouseCalculator', () {
    test('Whole Sign starts house 1 at the beginning of the rising sign', () {
      final result = HouseCalculator.calculate(
        system: 'Whole Sign',
        ascendantDegrees: 101.646,
        midheavenDegrees: 342.84,
        armcDegrees: 340,
        latitudeDegrees: 48.4,
        obliquityDegrees: 23.44,
      );

      expect(result.cusps, hasLength(12));
      expect(result.cusps.first, 90);
      expect(result.cusps[1], 120);
      expect(result.cusps[11], 60);
      expect(result.effectiveSystem, HouseSystem.wholeSign);
      expect(result.usedPolarFallback, isFalse);
    });

    test('Placidus anchors angles and creates opposite house cusps', () {
      final result = HouseCalculator.calculate(
        system: 'Placidus',
        ascendantDegrees: 90,
        midheavenDegrees: 0,
        armcDegrees: 0,
        latitudeDegrees: 0,
        obliquityDegrees: 23.4392911,
      );

      expect(result.cusps, hasLength(12));
      expect(result.cusps[0], 90);
      expect(result.cusps[3], 180);
      expect(result.cusps[6], 270);
      expect(result.cusps[9], 0);
      expect(result.cusps[4], closeTo((result.cusps[10] + 180) % 360, 1e-9));
      expect(result.cusps[5], closeTo((result.cusps[11] + 180) % 360, 1e-9));
      expect(result.cusps[7], closeTo((result.cusps[1] + 180) % 360, 1e-9));
      expect(result.cusps[8], closeTo((result.cusps[2] + 180) % 360, 1e-9));
      expect(result.usedPolarFallback, isFalse);
    });

    test('Placidus explicitly falls back to Whole Sign inside polar circle', () {
      final result = HouseCalculator.calculate(
        system: 'Placidus',
        ascendantDegrees: 101.646,
        midheavenDegrees: 342.84,
        armcDegrees: 340,
        latitudeDegrees: 67,
        obliquityDegrees: 23.44,
      );

      expect(result.effectiveSystem, HouseSystem.wholeSign);
      expect(result.usedPolarFallback, isTrue);
      expect(result.cusps.first, 90);
    });

    test('rejects unknown systems instead of silently guessing', () {
      expect(
        () => HouseCalculator.calculate(
          system: 'Koch',
          ascendantDegrees: 90,
          midheavenDegrees: 0,
          armcDegrees: 0,
          latitudeDegrees: 0,
          obliquityDegrees: 23.4,
        ),
        throwsArgumentError,
      );
    });
  });
}
