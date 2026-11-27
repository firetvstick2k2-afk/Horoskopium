/// Utilities for angles used by chart geometry and aspect calculations.
class Angle {
  const Angle._();

  /// Normalizes an angle to the interval [0, 360).
  static double normalize(double degrees) {
    if (!degrees.isFinite) {
      throw ArgumentError.value(degrees, 'degrees', 'Must be finite.');
    }
    final normalized = degrees % 360;
    final wrapped = normalized < 0 ? normalized + 360 : normalized;
    // Adding 360 to a tiny negative remainder can round to exactly 360.0.
    // Keep the documented half-open interval [0, 360) even at that boundary.
    return wrapped >= 360 ? 0 : wrapped;
  }

  /// Returns the smallest unsigned angular distance in [0, 180].
  static double separation(double firstDegrees, double secondDegrees) {
    final difference = (normalize(firstDegrees) - normalize(secondDegrees)).abs();
    return difference > 180 ? 360 - difference : difference;
  }
}
