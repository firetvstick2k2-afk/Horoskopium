import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:horoskopium/infrastructure/licensing/tsl1_license_verifier.dart';
import 'package:horoskopium/services/tsl1_license_service.dart';
import 'package:pointycastle/export.dart';

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

class TestSigningKey {
  TestSigningKey._(this.privateKey, this.publicKeyBase64Url);

  final ECPrivateKey privateKey;
  final String publicKeyBase64Url;

  static TestSigningKey generate() {
    final source = Random.secure();
    final seed = Uint8List.fromList(
      List<int>.generate(32, (_) => source.nextInt(256)),
    );
    final random = FortunaRandom()..seed(KeyParameter(seed));
    final domain = ECDomainParameters('prime256v1');
    final generator = ECKeyGenerator()
      ..init(ParametersWithRandom(ECKeyGeneratorParameters(domain), random));
    final pair = generator.generateKeyPair();
    final privateKey = pair.privateKey as ECPrivateKey;
    final publicKey = pair.publicKey as ECPublicKey;
    final point = publicKey.Q!.getEncoded(false);
    const spkiPrefix = <int>[
      0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d,
      0x02, 0x01, 0x06, 0x08, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x03, 0x01,
      0x07, 0x03, 0x42, 0x00,
    ];
    final spki = Uint8List.fromList([...spkiPrefix, ...point]);
    return TestSigningKey._(privateKey, _base64Url(spki));
  }

  String signToken({
    required String type,
    required DateTime issuedAt,
    DateTime? expiresAt,
  }) {
    final issuedSeconds = issuedAt.toUtc().millisecondsSinceEpoch ~/ 1000;
    final payload = <String, Object>{
      'version': 1,
      'product': 'topf_secret',
      'id': '123e4567-e89b-42d3-a456-426614174000',
      'customerName': 'TSL1 Test Customer',
      'type': type,
      'issuedAt': issuedSeconds,
      if (expiresAt != null) ...{
        'expiresAt': expiresAt.toUtc().millisecondsSinceEpoch ~/ 1000,
        'durationValue': 1,
        'durationUnit': 'months',
      },
    };
    final payloadBytes = Uint8List.fromList(utf8.encode(jsonEncode(payload)));
    final signer = ECDSASigner(SHA256Digest(), HMac(SHA256Digest(), 64))
      ..init(true, PrivateKeyParameter<ECPrivateKey>(privateKey));
    final signature = signer.generateSignature(payloadBytes) as ECSignature;
    final der = _encodeDerSignature(signature);
    return 'TSL1.${_base64Url(payloadBytes)}.${_base64Url(der)}';
  }
}

String _base64Url(List<int> bytes) =>
    base64Url.encode(bytes).replaceAll('=', '');

Uint8List _encodeDerSignature(ECSignature signature) {
  List<int> integer(BigInt value) {
    var hex = value.toRadixString(16);
    if (hex.length.isOdd) hex = '0$hex';
    var bytes = <int>[
      for (var i = 0; i < hex.length; i += 2)
        int.parse(hex.substring(i, i + 2), radix: 16),
    ];
    if ((bytes.first & 0x80) != 0) bytes = [0, ...bytes];
    return [0x02, bytes.length, ...bytes];
  }

  final r = integer(signature.r);
  final s = integer(signature.s);
  final body = [...r, ...s];
  return Uint8List.fromList([0x30, body.length, ...body]);
}

void main() {
  group('Tsl1LicenseVerifier', () {
    final verifier = Tsl1LicenseVerifier(
      clock: () => DateTime.utc(2026, 11, 28, 12),
    );

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

    test('accepts a valid token signed by an ephemeral P-256 test key', () {
      final key = TestSigningKey.generate();
      final testVerifier = Tsl1LicenseVerifier(
        publicKeyBase64Url: key.publicKeyBase64Url,
        clock: () => DateTime.utc(2026, 11, 28, 12),
      );
      final token = key.signToken(
        type: 'lifetime',
        issuedAt: DateTime.utc(2026, 11, 28, 10),
      );

      final license = testVerifier.verify(token);

      expect(license, isNotNull);
      expect(license!.id, '123e4567-e89b-42d3-a456-426614174000');
      expect(license.type, 'lifetime');
      expect(license.customerName, 'TSL1 Test Customer');
      expect(license.isLifetime, isTrue);
    });
  });

  group('Tsl1LicenseService', () {
    test('activates, stores and restores a valid signed TSL1 token', () async {
      final key = TestSigningKey.generate();
      final store = MemoryTokenStore();
      final verifier = Tsl1LicenseVerifier(
        publicKeyBase64Url: key.publicKeyBase64Url,
        clock: () => DateTime.utc(2026, 11, 28, 12),
      );
      final token = key.signToken(
        type: 'lifetime',
        issuedAt: DateTime.utc(2026, 11, 28, 10),
      );
      final service = Tsl1LicenseService(store: store, verifier: verifier);

      expect(await service.activate(token), isTrue);
      expect(service.status, LicenseStatus.active);
      expect(service.license?.isLifetime, isTrue);
      expect(store.value, token);

      final restoredService = Tsl1LicenseService(
        store: store,
        verifier: verifier,
      );
      await restoredService.restore();

      expect(restoredService.isRestored, isTrue);
      expect(restoredService.status, LicenseStatus.active);
      expect(restoredService.license?.id, '123e4567-e89b-42d3-a456-426614174000');
    });

    test('rejects a correctly signed token at its expiry boundary', () {
      final key = TestSigningKey.generate();
      var now = DateTime.utc(2026, 11, 28, 11, 59);
      final verifier = Tsl1LicenseVerifier(
        publicKeyBase64Url: key.publicKeyBase64Url,
        clock: () => now,
      );
      final token = key.signToken(
        type: 'monthly',
        issuedAt: DateTime.utc(2026, 11, 1),
        expiresAt: DateTime.utc(2026, 11, 28, 12),
      );

      expect(verifier.verify(token), isNotNull);
      now = DateTime.utc(2026, 11, 28, 12);
      expect(verifier.verify(token), isNull);
    });

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
