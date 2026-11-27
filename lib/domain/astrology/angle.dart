/// Utilities for angles used by chart geometry and aspect calculations.
class Angle {
  const Angle._();

  /// Normalizes an angle to the interval [0, 360).
  static double normalize(double degrees) {
    if (!degrees.isFinite) {
      throw ArgumentError.value(degrees, 'degrees', 'Must be finite.');
    }
    final normalized = degrees % 360;
    return normalized < 0 ? normalized + 360 : normalized;
  }

  /// Returns the smallest unsigned angular distance in [0, 180].
  static double separation(double firstDegrees, double secondDegrees) {
    final difference = (normalize(firstDegrees) - normalize(secondDegrees)).abs();
    return difference > 180 ? 360 - difference : difference;
  }
}
