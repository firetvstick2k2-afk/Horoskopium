import 'package:flutter_test/flutter_test.dart';
import 'package:horoskopium/domain/astrology/aspect_calculator.dart';
import 'package:horoskopium/domain/astrology/celestial_position.dart';

void main() {
  const calculator = AspectCalculator();

  CelestialPosition body(String id, double longitude) =>
      CelestialPosition(bodyId: id, longitudeDegrees: longitude);

  group('AspectCalculator', () {
    test('detects each supported major aspect at its exact angle', () {
      const expected = <(double, MajorAspect)>[
        (0, MajorAspect.conjunction),
        (60, MajorAspect.sextile),
        (90, MajorAspect.square),
        (120, MajorAspect.trine),
        (180, MajorAspect.opposition),
      ];

      for (final (angle, aspect) in expected) {
        final result = calculator.calculate([
          body('first', 10),
          body('second', 10 + angle),
        ]);
        expect(result, hasLength(1));
        expect(result.single.aspect, aspect);
        expect(result.single.orbDegrees, 0);
        expect(result.single.actualSeparationDegrees, angle);
      }
    });

    test('uses shortest angular separation across zero degrees', () {
      final result = calculator.calculate([
        body('venus', 357),
        body('mars', 3),
      ]);

      expect(result, hasLength(1));
      expect(result.single.aspect, MajorAspect.conjunction);
      expect(result.single.actualSeparationDegrees, 6);
      expect(result.single.orbDegrees, 6);
    });

    test('accepts exact orb boundary and rejects outside boundary', () {
      final atBoundary = calculator.calculate([
        body('sun', 0),
        body('moon', 66),
      ]);
      final outside = calculator.calculate([
        body('sun', 0),
        body('moon', 66.0001),
      ]);

      expect(atBoundary, hasLength(1));
      expect(atBoundary.single.aspect, MajorAspect.sextile);
      expect(atBoundary.single.orbDegrees, 6);
      expect(outside, isEmpty);
    });

    test('supports configurable aspect orbs', () {
      const narrow = AspectOrbConfiguration(
        conjunction: 2,
        sextile: 2,
        square: 2,
        trine: 2,
        opposition: 2,
      );
      final result = calculator.calculate([
        body('sun', 0),
        body('jupiter', 64),
      ], orbs: narrow);

      expect(result, isEmpty);
    });

    test('returns each unordered body pair only once', () {
      final result = calculator.calculate([
        body('sun', 0),
        body('moon', 90),
        body('venus', 180),
      ]);

      expect(result, hasLength(3));
      expect(
        result.map((aspect) => 'undefined:undefined'),
        ['sun:moon', 'sun:venus', 'moon:venus'],
      );
    });

    test('does not invent an aspect when outside every configured orb', () {
      final result = calculator.calculate([
        body('first', 0),
        body('second', 37),
      ]);

      expect(result, isEmpty);
    });

    test('rejects invalid positions and invalid orb configuration', () {
      expect(
        () => calculator.calculate([
          body('sun', 0),
          const CelestialPosition(bodyId: 'moon', longitudeDegrees: 360),
        ]),
        throwsArgumentError,
      );
      expect(
        () => calculator.calculate(
          [body('sun', 0), body('moon', 60)],
          orbs: const AspectOrbConfiguration(sextile: 16),
        ),
        throwsArgumentError,
      );
    });

    test('returns an immutable result list', () {
      final result = calculator.calculate([
        body('sun', 0),
        body('moon', 60),
      ]);
      expect(() => result.add(result.single), throwsUnsupportedError);
    });
  });
}
