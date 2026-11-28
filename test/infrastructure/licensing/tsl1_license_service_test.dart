import 'package:flutter_test/flutter_test.dart';
import 'package:horoskopium/infrastructure/licensing/tsl1_license_verifier.dart';
import 'package:horoskopium/services/tsl1_license_service.dart';

class MemoryTokenStore implements LicenseTokenStore {
  String? value;
  bool failReads = false;
  @override
  Future<String?> read() async {
    if (failReads) throw StateError('storage unavailable');
    return value;
  }
  @override
  Future<void> write(String token) async => value = token;
  @override
  Future<void> delete() async => value = null;
}

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

  group('Tsl1LicenseService', () {
    test('restores an empty store as not activated', () async {
      final store = MemoryTokenStore();
      final service = Tsl1LicenseService(store: store);
      await service.restore();
      expect(service.status, LicenseStatus.notActivated);
      expect(service.isRestored, isTrue);
    });

    test('re-verifies a stored token and marks an invalid token invalid', () async {
      final store = MemoryTokenStore()..value = 'TSL1.invalid.invalid';
      final service = Tsl1LicenseService(store: store);
      await service.restore();
      expect(service.status, LicenseStatus.invalid);
    });

    test('does not store a token that fails verification', () async {
      final store = MemoryTokenStore();
      final service = Tsl1LicenseService(store: store);
      expect(await service.activate('TSL1.invalid.invalid'), isFalse);
      expect(store.value, isNull);
      expect(service.status, LicenseStatus.invalid);
    });

    test('surfaces secure storage errors without plaintext fallback', () async {
      final store = MemoryTokenStore()..failReads = true;
      final service = Tsl1LicenseService(store: store);
      await service.restore();
      expect(service.status, LicenseStatus.storageError);
      expect(service.storageError, contains('storage unavailable'));
    });

    test('deactivates by deleting the stored token', () async {
      final store = MemoryTokenStore()..value = 'TSL1.invalid.invalid';
      final service = Tsl1LicenseService(store: store);
      await service.deactivate();
      expect(store.value, isNull);
      expect(service.status, LicenseStatus.notActivated);
    });
  });
}
