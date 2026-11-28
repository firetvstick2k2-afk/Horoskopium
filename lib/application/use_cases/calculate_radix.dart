import '../../domain/astrology/aspect_calculator.dart';
import '../../domain/astrology/chart_calculation_input.dart';
import '../../domain/astrology/chart_calculation_result.dart';
import '../ports/ephemeris_engine.dart';

/// Application boundary for requesting a radix calculation.
///
/// The ephemeris engine remains responsible only for astronomical positions
/// and chart angles. Derived astrological aspects are calculated here.
class CalculateRadix {
  const CalculateRadix(
    this._engine, {
    AspectCalculator aspectCalculator = const AspectCalculator(),
  }) : _aspectCalculator = aspectCalculator;

  final EphemerisEngine _engine;
  final AspectCalculator _aspectCalculator;

  Future<ChartCalculationResult> call(ChartCalculationInput input) async {
    if (!input.isValid) {
      throw ArgumentError.value(input, 'input', 'Invalid chart calculation input.');
    }

    final result = await _engine.calculate(input);
    if (!result.isValid) {
      throw StateError('The ephemeris engine returned an invalid result.');
    }

    final aspects = _aspectCalculator.calculate(result.positions);
    final enrichedResult = result.withAspects(aspects);
    if (!enrichedResult.isValid) {
      throw StateError('The calculated chart aspects produced an invalid result.');
    }
    return enrichedResult;
  }
}
