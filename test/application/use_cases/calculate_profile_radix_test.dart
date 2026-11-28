import 'package:flutter_test/flutter_test.dart';
import 'package:horoskopium/application/ports/birth_chart_input_resolver.dart';
import 'package:horoskopium/application/ports/ephemeris_engine.dart';
import 'package:horoskopium/application/use_cases/calculate_profile_radix.dart';
import 'package:horoskopium/domain/astrology/chart_calculation_input.dart';
import 'package:horoskopium/domain/astrology/chart_calculation_result.dart';
import 'package:horoskopium/domain/astrology/celestial_position.dart';
import 'package:horoskopium/models/birth_profile.dart';

void main() {
  final profile = BirthProfile(
    id: 'profile-1',
    name: 'Ada',
    birthDate: DateTime(1990, 4, 12),
    birthTime: '14:35',
    birthPlace: 'Münster',
  );

  test('resolves a saved profile before invoking the ephemeris engine', () async {
    final input = ChartCalculationInput(
      utcDateTime: DateTime.utc(1990, 4, 12, 12, 35),
      latitudeDegrees: 51.9607,
      longitudeDegrees: 7.6261,
    );
    final resolver = _FakeResolver(input);
    final engine = _FakeEngine();
    final calculate = CalculateProfileRadix(
      inputResolver: resolver,
      engine: engine,
    );

    final result = await calculate(profile);

    expect(identical(resolver.receivedProfile, profile), isTrue);
    expect(engine.receivedInput, same(input));
    expect(result.positions.single.bodyId, 'sun');
  });

  test('does not call the engine when resolved input is invalid', () async {
    final input = ChartCalculationInput(
      utcDateTime: DateTime(1990, 4, 12, 12, 35),
      latitudeDegrees: 51.9607,
      longitudeDegrees: 7.6261,
    );
    final engine = _FakeEngine();
    final calculate = CalculateProfileRadix(
      inputResolver: _FakeResolver(input),
      engine: engine,
    );

    await expectLater(calculate(profile), throwsArgumentError);
    expect(engine.receivedInput, isNull);
  });

  test('propagates location and timezone resolution failures', () async {
    final engine = _FakeEngine();
    final calculate = CalculateProfileRadix(
      inputResolver: _FailingResolver(),
      engine: engine,
    );

    await expectLater(calculate(profile), throwsA(isA<StateError>()));
    expect(engine.receivedInput, isNull);
  });
}

class _FakeResolver implements BirthChartInputResolver {
  _FakeResolver(this.input);

  final ChartCalculationInput input;
  BirthProfile? receivedProfile;

  @override
  Future<ChartCalculationInput> resolve(BirthProfile profile) async {
    receivedProfile = profile;
    return input;
  }
}

class _FailingResolver implements BirthChartInputResolver {
  @override
  Future<ChartCalculationInput> resolve(BirthProfile profile) {
    throw StateError('Birth place/time could not be resolved.');
  }
}

class _FakeEngine implements EphemerisEngine {
  ChartCalculationInput? receivedInput;

  @override
  String get engineId => 'test-engine';

  @override
  String get engineVersion => '1';

  @override
  Future<ChartCalculationResult> calculate(ChartCalculationInput input) async {
    receivedInput = input;
    return ChartCalculationResult(
      positions: const [
        CelestialPosition(bodyId: 'sun', longitudeDegrees: 22.5),
      ],
      engineId: engineId,
      engineVersion: engineVersion,
      calculatedAtUtc: DateTime.now().toUtc(),
    );
  }
}
