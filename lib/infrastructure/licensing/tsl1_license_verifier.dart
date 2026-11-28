import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

class AstraliumLicense {
  const AstraliumLicense({required this.id, required this.customerName, required this.customerEmail, required this.type, required this.issuedAt, this.expiresAt, this.durationValue, this.durationUnit});
  final String id, customerName, customerEmail, type;
  final DateTime issuedAt;
  final DateTime? expiresAt;
  final int? durationValue;
  final String? durationUnit;
  bool get isLifetime => type == 'lifetime';
}

/// Offline verifier for Licence Studio TSL1 tokens (ECDSA P-256 / SHA-256).
/// The signed product claim "topf_secret" is the shared license namespace
/// used by both Topf Secret and ASTRALIUM; the issuer is not modified.
class Tsl1LicenseVerifier {
  Tsl1LicenseVerifier({String publicKeyBase64Url = publicKey, DateTime Function()? clock})
      : _key = publicKeyBase64Url, _clock = clock ?? DateTime.now;
  static const publicKey = 'MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEEO_8xiWBZLIQw--gBpf1Touzg5jPDJLbLHbHiRUlakcvVTgdEcqSBf3-wsU9pzvsF9yCpKZfz4lWWB4bj2LGnQ';
  final String _key;
  final DateTime Function() _clock;

  AstraliumLicense? verify(String token) {
    try {
      final p = token.trim().split('.');
      if (p.length != 3 || p[0] != 'TSL1') return null;
      final payloadBytes = _b64(p[1]), sigBytes = _b64(p[2]), keyBytes = _b64(_key);
      if (!_verify(keyBytes, payloadBytes, sigBytes)) return null;
      final decoded = jsonDecode(utf8.decode(payloadBytes));
      if (decoded is! Map<String, dynamic>) return null;
      final x = decoded;
      final id = x['id'], name = x['customerName'], email = x['customerEmail'];
      final type = x['type'], issuedAt = x['issuedAt'];
      if (x['version'] != 1 || x['product'] != 'topf_secret' ||
          id is! String || !_uuid(id) || name is! String || name.trim().isEmpty ||
          email is! String || type is! String ||
          !{'lifetime','monthly','quarterly','half_yearly','yearly','custom'}.contains(type) ||
          issuedAt is! int || issuedAt <= 0) return null;
      final now = _clock().toUtc();
      final issued = DateTime.fromMillisecondsSinceEpoch(issuedAt * 1000, isUtc: true);
      if (issued.isAfter(now.add(const Duration(minutes: 5)))) return null;
      if (type == 'lifetime') {
        if (x.containsKey('expiresAt')) return null;
        return AstraliumLicense(id:id, customerName:name, customerEmail:email, type:type, issuedAt:issued);
      }
      final expiry = x['expiresAt'], duration = x['durationValue'], unit = x['durationUnit'];
      if (expiry is! int || expiry <= issuedAt || expiry <= now.millisecondsSinceEpoch ~/ 1000 ||
          duration is! int || duration < 1 || duration > 3650 ||
          unit is! String || !{'days','months','years'}.contains(unit)) return null;
      return AstraliumLicense(id:id, customerName:name, customerEmail:email, type:type,
        issuedAt:issued, expiresAt:DateTime.fromMillisecondsSinceEpoch(expiry * 1000, isUtc:true),
        durationValue:duration, durationUnit:unit);
    } on Object { return null; }
  }

  static Uint8List _b64(String s) {
    if (s.isEmpty || !RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(s)) throw const FormatException();
    return Uint8List.fromList(base64Url.decode(base64Url.normalize(s)));
  }
  static bool _uuid(String s) => RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-8][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$').hasMatch(s);

  static bool _verify(Uint8List spki, Uint8List message, Uint8List der) {
    if (spki.length < 65) return false;
    final pointBytes = spki.sublist(spki.length - 65);
    if (pointBytes.first != 4) return false;
    final domain = ECDomainParameters('prime256v1');
    final point = domain.curve.decodePoint(pointBytes);
    if (point == null) return false;
    final signer = ECDSASigner(SHA256Digest(), HMac(SHA256Digest(), 64))
      ..init(false, PublicKeyParameter<ECPublicKey>(ECPublicKey(point, domain)));
    return signer.verifySignature(message, _derSignature(der));
  }

  static ECSignature _derSignature(Uint8List b) {
    var i = 0;
    int len() {
      final n = b[i++];
      if (n < 128) return n;
      final count = n & 127;
      if (count == 0 || count > 2 || i + count > b.length) throw const FormatException();
      var v = 0;
      for (var j=0;j<count;j++) { v=(v<<8)|b[i++]; }
      return v;
    }
    if (b.isEmpty || b[i++] != 0x30) throw const FormatException();
    final seq = len();
    if (seq != b.length-i || b[i++] != 2) throw const FormatException();
    final rl = len();
    if (rl == 0 || i+rl > b.length) throw const FormatException();
    final r = _integer(b.sublist(i,i+rl)); i+=rl;
    if (i >= b.length || b[i++] != 2) throw const FormatException();
    final sl = len();
    if (sl == 0 || i+sl != b.length) throw const FormatException();
    return ECSignature(r,_integer(b.sublist(i,i+sl)));
  }
  static BigInt _integer(Uint8List b) {
    if (b.isEmpty || (b.first & 128) != 0) throw const FormatException();
    var i=0;
    while (i < b.length-1 && b[i]==0 && (b[i+1]&128)==0) { i++; }
    return BigInt.parse(b.sublist(i).map((x)=>x.toRadixString(16).padLeft(2,'0')).join(),radix:16);
  }
}
