import '../../domain/astrology/chart_calculation_input.dart';
import '../../models/birth_profile.dart';

/// Resolves a saved civil birth profile into calculation-ready astronomical
/// input.
///
/// Implementations must interpret [BirthProfile.birthDate] as the calendar
/// date entered by the user, not as a UTC instant or as a date in the phone's
/// current timezone. They must resolve [BirthProfile.birthPlace] to verified
/// coordinates and the historical IANA timezone, then convert the entered
/// local birth time to UTC using the timezone rules valid on that date.
///
/// A missing or ambiguous birth time must not be silently replaced with noon.
/// Until reduced-precision calculations are modelled explicitly, a resolver
/// should reject profiles without a sufficiently precise birth time.
abstract interface class BirthChartInputResolver {
  Future<ChartCalculationInput> resolve(BirthProfile profile);
}
