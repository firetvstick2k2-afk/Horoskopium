import 'package:flutter_test/flutter_test.dart';
import 'package:horoskopium/application/ports/ephemeris_engine.dart';
import 'package:horoskopium/application/use_cases/calculate_radix.dart';
import 'package:horoskopium/domain/astrology/chart_calculation_input.dart';
import 'package:horoskopium/domain/astrology/chart_calculation_result.dart';
import 'package:horoskopium/domain/astrology/celestial_position.dart';
import 'package:horoskopium/domain/astrology/aspect_calculator.dart';

void main() {
  test('calculates aspects at the application boundary without changing engine output', () async {
    final engine = _FakeEngine();
    final calculate = CalculateRadix(engine);
    final input = ChartCalculationInput(
      utcDateTime: DateTime.utc(2000, 1, 1),
      latitudeDegrees: 51.0,
      longitudeDegrees: 7.0,
    );

    final result = await calculate(input);

    expect(engine.calculationCount, 1);
    expect(result.engineId, 'test-engine');
    expect(result.engineVersion, '1.0');
    expect(result.positions, hasLength(3));
    expect(result.aspects, hasLength(2));
    expect(
      result.aspects.map((aspect) => aspect.aspect),
      [MajorAspect.conjunction, MajorAspect.square],
    );
    expect(result.aspects.first.firstBodyId, 'sun');
    expect(result.aspects.first.secondBodyId, 'moon');
    expect(result.isValid, isTrue);
  });

  test('returns an immutable aspect collection', () async {
    final result = await CalculateRadix(_FakeEngine())(
      ChartCalculationInput(
        utcDateTime: DateTime.utc(2000, 1, 1),
        latitudeDegrees: 51.0,
        longitudeDegrees: 7.0,
      ),
    );

    expect(() => result.aspects.clear(), throwsUnsupportedError);
  });
}

class _FakeEngine implements EphemerisEngine {
  int calculationCount = 0;

  @override
  String get engineId => 'test-engine';

  @override
  String get engineVersion => '1.0';

  @override
  Future<ChartCalculationResult> calculate(ChartCalculationInput input) async {
    calculationCount++;
    return ChartCalculationResult(
      positions: const [
        CelestialPosition(bodyId: 'sun', longitudeDegrees: 10),
        CelestialPosition(bodyId: 'moon', longitudeDegrees: 11),
        CelestialPosition(bodyId: 'mars', longitudeDegrees: 100),
      ],
      engineId: engineId,
      engineVersion: engineVersion,
      calculatedAtUtc: DateTime.utc(2000, 1, 1),
    );
  }
}
