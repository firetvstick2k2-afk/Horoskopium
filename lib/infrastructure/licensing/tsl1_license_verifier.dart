import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

class AstraliumLicense {
  const AstraliumLicense({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.type,
    required this.issuedAt,
    this.expiresAt,
    this.durationValue,
    this.durationUnit,
  });

  final String id;
  final String customerName;
  final String customerEmail;
  final String type;
  final DateTime issuedAt;
  final DateTime? expiresAt;
  final int? durationValue;
  final String? durationUnit;

  bool get isLifetime => type == 'lifetime';
}

/// Dart port of Topf Secret's LicenseVerifier.kt.
///
/// Token format: TSL1.<base64url-payload>.<base64url-ECDSA-SHA256-signature>
/// The signed product claim remains "topf_secret" for both applications.
class Tsl1LicenseVerifier {
  Tsl1LicenseVerifier({
    String publicKeyBase64Url = publicKey,
    DateTime Function()? clock,
  })  : _key = publicKeyBase64Url,
        _clock = clock ?? DateTime.now;

  static const publicKey =
      'MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEEO_8xiWBZLIQw--gBpf1Touzg5jPDJLbLHbHiRUlakcvVTgdEcqSBf3-wsU9pzvsF9yCpKZfz4lWWB4bj2LGnQ';

  // X.509 SubjectPublicKeyInfo header for an uncompressed P-256 EC point.
  static const List<int> _p256SpkiPrefix = [
    0x30,  0x59,  0x30,  0x13,  0x06,  0x07,  0x2a,  0x86,  0x48,
    0xce,  0x3d,  0x02,  0x01,  0x06,  0x08,  0x2a,  0x86,  0x48,
    0xce,  0x3d,  0x03,  0x01,  0x07,  0x03,  0x42,  0x00,
  ];

  final String _key;
  final DateTime Function() _clock;

  AstraliumLicense? verify(String token) {
    try {
      final parts = token.trim().split('.');
      if (parts.length != 3 || parts[0] != 'TSL1') return null;

      final payloadBytes = _base64UrlDecode(parts[1]);
      final signatureBytes = _base64UrlDecode(parts[2]);
      final publicKeyBytes = _base64UrlDecode(_key);

      if (!_verifySignature(publicKeyBytes, payloadBytes, signatureBytes)) {
        return null;
      }

      final decoded = jsonDecode(utf8.decode(payloadBytes));
      if (decoded is! Map<String, dynamic>) return null;

      final id = decoded['id'];
      final customerName = decoded['customerName'];
      final emailValue = decoded['customerEmail'];
      final customerEmail = emailValue is String ? emailValue : '';
      final type = decoded['type'];
      final issuedAt = decoded['issuedAt'];

      // Keep the same payload contract as Topf Secret's LicenseVerifier.kt.
      if (decoded['version'] != 1 ||
          decoded['product'] != 'topf_secret' ||
          id is! String ||
          !_isUuid(id) ||
          customerName is! String ||
          customerName.trim().isEmpty ||
          type is! String ||
          !{
            'lifetime',
            'monthly',
            'quarterly',
            'half_yearly',
            'yearly',
            'custom',
          }.contains(type) ||
          issuedAt is! int ||
          issuedAt <= 0) {
        return null;
      }

      final issued = DateTime.fromMillisecondsSinceEpoch(
        issuedAt * 1000,
        isUtc: true,
      );

      if (type == 'lifetime') {
        if (decoded.containsKey('expiresAt')) return null;
        return AstraliumLicense(
          id: id,
          customerName: customerName,
          customerEmail: customerEmail,
          type: type,
          issuedAt: issued,
        );
      }

      final expiresAt = decoded['expiresAt'];
      final durationValue = decoded['durationValue'];
      final durationUnit = decoded['durationUnit'];
      final nowSeconds = _clock().toUtc().millisecondsSinceEpoch ~/ 1000;

      if (expiresAt is! int ||
          expiresAt <= issuedAt ||
          expiresAt <= nowSeconds ||
          durationValue is! int ||
          durationValue < 1 ||
          durationValue > 3650 ||
          durationUnit is! String ||
          !{'days', 'months', 'years'}.contains(durationUnit)) {
        return null;
      }

      return AstraliumLicense(
        id: id,
        customerName: customerName,
        customerEmail: customerEmail,
        type: type,
        issuedAt: issued,
        expiresAt: DateTime.fromMillisecondsSinceEpoch(
          expiresAt * 1000,
          isUtc: true,
        ),
        durationValue: durationValue,
        durationUnit: durationUnit,
      );
    } on Object {
      return null;
    }
  }

  static Uint8List _base64UrlDecode(String value) {
    if (value.isEmpty ||
        !RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(value)) {
      throw const FormatException('Invalid Base64URL value');
    }
    return Uint8List.fromList(
      base64Url.decode(base64Url.normalize(value)),
    );
  }

  static bool _isUuid(String value) => RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      ).hasMatch(value);

  static bool _verifySignature(
    Uint8List subjectPublicKeyInfo,
    Uint8List message,
    Uint8List derSignature,
  ) {
    if (subjectPublicKeyInfo.length != _p256SpkiPrefix.length + 65) {
      return false;
    }
    for (var i = 0; i < _p256SpkiPrefix.length; i++) {
      if (subjectPublicKeyInfo[i] != _p256SpkiPrefix[i]) return false;
    }

    final pointBytes = subjectPublicKeyInfo.sublist(_p256SpkiPrefix.length);
    if (pointBytes.first != 0x04) return false;

    final domain = ECDomainParameters('prime256v1');
    final point = domain.curve.decodePoint(pointBytes);
    if (point == null) return false;

    final signature = _decodeDerSignature(derSignature, domain.n);
    final signer = ECDSASigner(SHA256Digest(), HMac(SHA256Digest(), 64))
      ..init(
        false,
        PublicKeyParameter<ECPublicKey>(ECPublicKey(point, domain)),
      );
    return signer.verifySignature(message, signature);
  }

  /// Strict DER decoding for the ASN.1 ECDSA signature emitted by Java
  /// SHA256withECDSA. P-256 signatures fit in the short-form DER lengths.
  static ECSignature _decodeDerSignature(Uint8List bytes, BigInt order) {
    var offset = 0;

    if (bytes.length < 8 || bytes[offset++] != 0x30) {
      throw const FormatException('Invalid ECDSA sequence');
    }

    final sequenceLength = bytes[offset++];
    if (sequenceLength >= 0x80 ||
        sequenceLength != bytes.length - offset) {
      throw const FormatException('Invalid ECDSA sequence length');
    }

    BigInt readInteger() {
      if (offset + 2 > bytes.length || bytes[offset++] != 0x02) {
        throw const FormatException('Invalid ECDSA integer');
      }
      final length = bytes[offset++];
      if (length == 0 || length > 33 || offset + length > bytes.length) {
        throw const FormatException('Invalid ECDSA integer length');
      }

      final encoded = bytes.sublist(offset, offset + length);
      offset += length;

      if ((encoded.first & 0x80) != 0 ||
          (encoded.length > 1 &&
              encoded.first == 0 &&
              (encoded[1] & 0x80) == 0)) {
        throw const FormatException('Non-canonical ECDSA integer');
      }

      final valueBytes =
          encoded.length > 1 && encoded.first == 0
              ? encoded.sublist(1)
              : encoded;
      final value = BigInt.parse(
        valueBytes
            .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
            .join(),
        radix: 16,
      );
      if (value <= BigInt.zero || value >= order) {
        throw const FormatException('ECDSA integer out of range');
      }
      return value;
    }

    final r = readInteger();
    final s = readInteger();
    if (offset != bytes.length) {
      throw const FormatException('Trailing ECDSA signature data');
    }
    return ECSignature(r, s);
  }
}
