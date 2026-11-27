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

    test('Placidus converts equatorial right ascensions to ecliptic longitude', () {
      final result = HouseCalculator.calculate(
        system: 'Placidus',
        ascendantDegrees: 90,
        midheavenDegrees: 0,
        armcDegrees: 0,
        latitudeDegrees: 0,
        obliquityDegrees: 23.4391667,
      );

      // At the equator the semi-arc correction is zero, so the four
      // intermediate cusp right ascensions are exactly 30°, 60°, 120°,
      // and 150°. Convert those equatorial coordinates back to the ecliptic.
      expect(result.cusps, hasLength(12));
      expect(result.cusps[0], 90);
      expect(result.cusps[9], 0);
      expect(result.cusps[10], closeTo(32.1812, 0.001));
      expect(result.cusps[11], closeTo(62.0894, 0.001));
      expect(result.cusps[1], closeTo(117.9106, 0.001));
      expect(result.cusps[2], closeTo(147.8188, 0.001));
      expect(result.cusps[3], 180);
      expect(result.cusps[6], 270);
      expect(result.cusps[4], closeTo((result.cusps[10] + 180) % 360, 1e-9));
      expect(result.cusps[5], closeTo((result.cusps[11] + 180) % 360, 1e-9));
      expect(result.cusps[7], closeTo((result.cusps[1] + 180) % 360, 1e-9));
      expect(result.cusps[8], closeTo((result.cusps[2] + 180) % 360, 1e-9));
      expect(result.usedPolarFallback, isFalse);
    });


    test('Placidus matches independent mid-latitude northern reference', () {
      final result = HouseCalculator.calculate(
        system: 'Placidus',
        ascendantDegrees: 98.1302524996,
        midheavenDegrees: 338.3613918334,
        armcDegrees: 340,
        latitudeDegrees: 48.4,
        obliquityDegrees: 23.44,
      );

      expect(result.cusps[10], closeTo(12.9698064956, 1e-6));
      expect(result.cusps[11], closeTo(58.1538739006, 1e-6));
      expect(result.cusps[1], closeTo(115.2138876784, 1e-6));
      expect(result.cusps[2], closeTo(134.0757419582, 1e-6));
      expect(result.usedPolarFallback, isFalse);
    });

    test('Placidus matches independent southern-hemisphere reference', () {
      final result = HouseCalculator.calculate(
        system: 'Placidus',
        ascendantDegrees: 257.5351559756,
        midheavenDegrees: 147.8186022875,
        armcDegrees: 150,
        latitudeDegrees: -33.9,
        obliquityDegrees: 23.44,
      );

      expect(result.cusps[10], closeTo(180, 1e-6));
      expect(result.cusps[11], closeTo(219.0726503747, 1e-6));
      expect(result.cusps[1], closeTo(280.1817895065, 1e-6));
      expect(result.cusps[2], closeTo(302.3538433669, 1e-6));
      expect(result.usedPolarFallback, isFalse);
    });

    test('Placidus matches independent high-latitude reference', () {
      final result = HouseCalculator.calculate(
        system: 'Placidus',
        ascendantDegrees: 136.8603499374,
        midheavenDegrees: 21.6386081666,
        armcDegrees: 20,
        latitudeDegrees: 60,
        obliquityDegrees: 23.44,
      );

      expect(result.cusps[10], closeTo(66.0592749704, 1e-6));
      expect(result.cusps[11], closeTo(108.4076699806, 1e-6));
      expect(result.cusps[1], closeTo(151.1598652036, 1e-6));
      expect(result.cusps[2], closeTo(171.2907761673, 1e-6));
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


    test('Placidus matches all twelve independent cusps across the zodiac wrap', () {
      final result = HouseCalculator.calculate(
        system: 'Placidus',
        ascendantDegrees: 138.2963505356,
        midheavenDegrees: 47.4643295619,
        armcDegrees: 45,
        latitudeDegrees: 20,
        obliquityDegrees: 23.44,
      );
      const expected = <double>[
        138.2963505356, 165.24548807, 195.48080802, 227.46432956,
        258.92740475, 289.08397962, 318.29635054, 345.24548807,
        15.48080802, 47.46432956, 78.92740475, 109.08397962,
      ];
      expect(result.cusps, hasLength(12));
      for (var i = 0; i < 12; i++) {
        expect(result.cusps[i], closeTo(expected[i], 1e-6), reason: 'House ${i + 1}');
      }
      expect(result.usedPolarFallback, isFalse);
    });

    test('Placidus matches all twelve independent southern cusps', () {
      final result = HouseCalculator.calculate(
        system: 'Placidus',
        ascendantDegrees: 317.1260495714,
        midheavenDegrees: 212.1813977125,
        armcDegrees: 210,
        latitudeDegrees: -50,
        obliquityDegrees: 23.44,
      );
      const expected = <double>[
        317.1260495714, 335.78474024, 0, 32.18139771,
        71.21577235, 107.9426748, 137.12604957, 155.78474024,
        180, 212.18139771, 251.21577235, 287.9426748,
      ];
      for (var i = 0; i < 12; i++) {
        expect(result.cusps[i], closeTo(expected[i], 1e-6), reason: 'House ${i + 1}');
      }
      expect(result.usedPolarFallback, isFalse);
    });

    test('Placidus matches all twelve independent high-northern cusps', () {
      final result = HouseCalculator.calculate(
        system: 'Placidus',
        ascendantDegrees: 65.6335006673,
        midheavenDegrees: 297.9104226544,
        armcDegrees: 300,
        latitudeDegrees: 55,
        obliquityDegrees: 23.44,
      );
      const expected = <double>[
        65.6335006673, 85.78601497, 101.40794384, 117.91042265,
        140.23947305, 180, 245.63350067, 265.78601497,
        281.40794384, 297.91042265, 320.23947305, 0,
      ];
      for (var i = 0; i < 12; i++) {
        expect(result.cusps[i], closeTo(expected[i], 1e-6), reason: 'House ${i + 1}');
      }
      expect(result.usedPolarFallback, isFalse);
    });

    test('Placidus remains available just below the polar-circle limit', () {
      final result = HouseCalculator.calculate(
        system: 'Placidus',
        ascendantDegrees: 155.7016416969,
        midheavenDegrees: 47.4643295619,
        armcDegrees: 45,
        latitudeDegrees: 66.559,
        obliquityDegrees: 23.44,
      );
      const expected = <double>[
        155.7016416969, 170.2053530162, 192.2327650366, 227.4643295619,
        280.3393441205, 312.5345786485, 335.7016416969, 350.2053530162,
        12.2327650366, 47.4643295619, 100.3393441205, 132.5345786485,
      ];
      for (var i = 0; i < 12; i++) {
        expect(result.cusps[i], closeTo(expected[i], 1e-6), reason: 'House ${i + 1}');
      }
      expect(result.effectiveSystem, HouseSystem.placidus);
      expect(result.usedPolarFallback, isFalse);
    });

    test('Placidus falls back exactly at the polar-circle limit', () {
      final result = HouseCalculator.calculate(
        system: 'Placidus',
        ascendantDegrees: 155.7016416969,
        midheavenDegrees: 47.4643295619,
        armcDegrees: 45,
        latitudeDegrees: 66.56,
        obliquityDegrees: 23.44,
      );

      expect(result.effectiveSystem, HouseSystem.wholeSign);
      expect(result.usedPolarFallback, isTrue);
      expect(result.cusps, hasLength(12));
      expect(result.cusps.first, 150);
      expect(result.cusps[1], 180);
      expect(result.cusps[11], 120);
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
