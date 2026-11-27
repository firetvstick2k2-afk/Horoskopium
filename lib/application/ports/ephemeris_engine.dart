import '../../domain/astrology/chart_calculation_input.dart';
import '../../domain/astrology/chart_calculation_result.dart';

/// Port implemented by the selected, license-reviewed ephemeris adapter.
///
/// Implementations must return calculated values, never visual placeholders.
abstract interface class EphemerisEngine {
  String get engineId;
  String get engineVersion;

  Future<ChartCalculationResult> calculate(
    ChartCalculationInput input,
  );
}
