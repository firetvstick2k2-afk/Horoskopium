import 'package:flutter_test/flutter_test.dart';
import 'package:horoskopium/domain/astrology/angle.dart';

void main() {
  group('Angle', () {
    test('normalizes negative and over-revolution angles', () {
      expect(Angle.normalize(-10), 350);
      expect(Angle.normalize(370), 10);
      expect(Angle.normalize(720), 0);
      expect(Angle.normalize(-1e-14), 0);
    });

    test('calculates the smallest angular separation', () {
      expect(Angle.separation(350, 10), 20);
      expect(Angle.separation(10, 350), 20);
      expect(Angle.separation(15, 195), 180);
    });

    test('rejects non-finite values', () {
      expect(() => Angle.normalize(double.nan), throwsArgumentError);
    });
  });
}
