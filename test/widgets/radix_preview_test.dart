import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horoskopium/domain/astrology/chart_calculation_result.dart';
import 'package:horoskopium/domain/astrology/celestial_position.dart';
import 'package:horoskopium/widgets/radix_preview.dart';

void main() {
  testWidgets('Radix wheel paints real positions, angles and house cusps', (tester) async {
    final result = ChartCalculationResult(
      positions: const [
        CelestialPosition(bodyId: 'sun', longitudeDegrees: 15),
        CelestialPosition(bodyId: 'moon', longitudeDegrees: 48, isRetrograde: false),
        CelestialPosition(bodyId: 'mercury', longitudeDegrees: 17),
        CelestialPosition(bodyId: 'north_node_true', longitudeDegrees: 210),
      ],
      engineId: 'test-engine',
      engineVersion: '1.0',
      calculatedAtUtc: DateTime.utc(2000, 1, 1),
      ascendantLongitudeDegrees: 5,
      midheavenLongitudeDegrees: 275,
      houseCuspsDegrees: const [5, 32, 61, 95, 126, 154, 185, 212, 241, 275, 306, 334],
      requestedHouseSystem: 'Placidus',
      effectiveHouseSystem: 'Placidus',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Center(child: RadixPreview(result: result))),
    ));

    expect(find.byType(RadixPreview), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Radix wheel keeps its neutral placeholder without a result', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: RadixPreview())),
    ));

    expect(find.text('DEIN RADIX'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
