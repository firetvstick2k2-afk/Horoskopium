import '../../domain/astrology/chart_calculation_result.dart';
import '../../models/birth_profile.dart';
import '../ports/birth_chart_input_resolver.dart';
import '../ports/ephemeris_engine.dart';
import 'calculate_radix.dart';

/// Orchestrates a saved birth profile through location/time resolution and
/// the selected ephemeris engine.
class CalculateProfileRadix {
  const CalculateProfileRadix({
    required BirthChartInputResolver inputResolver,
    required EphemerisEngine engine,
  })  : _inputResolver = inputResolver,
        _calculateRadix = const CalculateRadix(engine);

  final BirthChartInputResolver _inputResolver;
  final CalculateRadix _calculateRadix;

  Future<ChartCalculationResult> call(BirthProfile profile) async {
    final input = await _inputResolver.resolve(profile);
    return _calculateRadix(input);
  }
}
