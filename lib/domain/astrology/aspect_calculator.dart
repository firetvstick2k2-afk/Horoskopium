import 'angle.dart';
import 'celestial_position.dart';

/// Major aspects supported by the first radix aspect-calculation milestone.
enum MajorAspect {
  conjunction(0, 'Konjunktion'),
  sextile(60, 'Sextil'),
  square(90, 'Quadrat'),
  trine(120, 'Trigon'),
  opposition(180, 'Opposition');

  const MajorAspect(this.exactAngleDegrees, this.displayName);

  final double exactAngleDegrees;
  final String displayName;
}

/// Explicit, configurable maximum deviations from each exact aspect angle.
///
/// These are application defaults, not universal astrological standards.
/// Users or later chart-school settings can supply different values.
class AspectOrbConfiguration {
  const AspectOrbConfiguration({
    this.conjunction = 8,
    this.sextile = 6,
    this.square = 7,
    this.trine = 7,
    this.opposition = 8,
  });

  final double conjunction;
  final double sextile;
  final double square;
  final double trine;
  final double opposition;

  double forAspect(MajorAspect aspect) => switch (aspect) {
        MajorAspect.conjunction => conjunction,
        MajorAspect.sextile => sextile,
        MajorAspect.square => square,
        MajorAspect.trine => trine,
        MajorAspect.opposition => opposition,
      };

  bool get isValid => [
        conjunction,
        sextile,
        square,
        trine,
        opposition,
      ].every((orb) => orb.isFinite && orb >= 0 && orb <= 15);
}

/// One geometrically detected major aspect between two chart bodies.
class CalculatedAspect {
  const CalculatedAspect({
    required this.firstBodyId,
    required this.secondBodyId,
    required this.aspect,
    required this.exactAngleDegrees,
    required this.actualSeparationDegrees,
    required this.orbDegrees,
  });

  final String firstBodyId;
  final String secondBodyId;
  final MajorAspect aspect;
  final double exactAngleDegrees;
  final double actualSeparationDegrees;
  final double orbDegrees;
}

/// Pure calculation of major aspects from verified ecliptic longitudes.
///
/// This class does not infer motion/applying-vs-separating because the
/// current position model does not carry longitudinal speed.
class AspectCalculator {
  const AspectCalculator();

  static const AspectOrbConfiguration defaultOrbs =
      AspectOrbConfiguration();

  List<CalculatedAspect> calculate(
    List<CelestialPosition> positions, {
    AspectOrbConfiguration orbs = defaultOrbs,
  }) {
    if (!orbs.isValid) {
      throw ArgumentError.value(orbs, 'orbs', 'Invalid aspect orb settings.');
    }
    for (final position in positions) {
      if (!position.isValid) {
        throw ArgumentError.value(
          position,
          'positions',
          'All celestial positions must be valid.',
        );
      }
    }

    final aspects = <CalculatedAspect>[];
    for (var first = 0; first < positions.length; first++) {
      for (var second = first + 1; second < positions.length; second++) {
        final a = positions[first];
        final b = positions[second];
        final separation =
            Angle.separation(a.longitudeDegrees, b.longitudeDegrees);

        MajorAspect? matched;
        var matchedOrb = 0.0;
        for (final aspect in MajorAspect.values) {
          final orb = (separation - aspect.exactAngleDegrees).abs();
          if (orb <= orbs.forAspect(aspect)) {
            matched = aspect;
            matchedOrb = orb;
            break;
          }
        }

        if (matched != null) {
          aspects.add(CalculatedAspect(
            firstBodyId: a.bodyId,
            secondBodyId: b.bodyId,
            aspect: matched,
            exactAngleDegrees: matched.exactAngleDegrees,
            actualSeparationDegrees: separation,
            orbDegrees: matchedOrb,
          ));
        }
      }
    }
    return List.unmodifiable(aspects);
  }
}
