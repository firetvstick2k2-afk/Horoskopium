import '../../domain/astrology/chart_calculation_input.dart';
import '../../domain/astrology/chart_calculation_result.dart';
import '../ports/ephemeris_engine.dart';

/// Application boundary for requesting a radix calculation.
class CalculateRadix {
  const CalculateRadix(this._engine);

  final EphemerisEngine _engine;

  Future<ChartCalculationResult> call(ChartCalculationInput input) async {
    if (!input.isValid) {
      throw ArgumentError.value(input, 'input', 'Invalid chart calculation input.');
    }

    final result = await _engine.calculate(input);
    if (!result.isValid) {
      throw StateError('The ephemeris engine returned an invalid result.');
    }
    return result;
  }
}
