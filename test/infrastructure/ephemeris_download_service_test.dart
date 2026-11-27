import 'package:flutter_test/flutter_test.dart';
import 'package:horoskopium/services/ephemeris_download_service.dart';

void main() {
  group('EphemerisKernel catalog', () {
    test('offers compact and extended JPL kernels', () {
      expect(
        EphemerisKernel.available.map((kernel) => kernel.id),
        ['de440s', 'de442'],
      );
      expect(EphemerisKernel.de440s.coverage, contains('1849'));
      expect(EphemerisKernel.de442.coverage, contains('2650'));
    });

    test('pins HTTPS sources and SHA-256 checksums', () {
      for (final kernel in EphemerisKernel.available) {
        expect(Uri.parse(kernel.url).scheme, 'https');
        expect(kernel.sha256, matches(RegExp(r'^[0-9a-f]{64}$')));
      }
    });
  });
}
