import 'package:flutter_test/flutter_test.dart';
import 'package:horoskopium/infrastructure/licensing/tsl1_license_verifier.dart';

void main() {
  group('Tsl1LicenseVerifier', () {
    final verifier = Tsl1LicenseVerifier(clock: () => DateTime.utc(2026, 11, 28, 12));
    test('rejects malformed tokens', () {
      expect(verifier.verify(''), isNull);
      expect(verifier.verify('TSL1.invalid.invalid'), isNull);
      expect(verifier.verify('TSL2.a.b'), isNull);
      expect(verifier.verify('TSL1.a.b.extra'), isNull);
    });
    test('rejects invalid signatures before trusting payload', () {
      const payload = 'eyJ2ZXJzaW9uIjoxLCJwcm9kdWN0IjoidG9wZl9zZWNyZXQifQ';
      expect(verifier.verify('TSL1.$payload.AA'), isNull);
    });
  });
}
