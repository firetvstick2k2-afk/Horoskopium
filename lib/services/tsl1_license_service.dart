import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../infrastructure/licensing/tsl1_license_verifier.dart';

enum LicenseStatus { notActivated, active, invalid, storageError }

abstract interface class LicenseTokenStore {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> delete();
}

class SecureLicenseTokenStore implements LicenseTokenStore {
  SecureLicenseTokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'astralium_tsl1_license';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String token) => _storage.write(key: _key, value: token);

  @override
  Future<void> delete() => _storage.delete(key: _key);
}

/// Keeps the signed token in platform secure storage and re-verifies it
/// whenever the app starts. This service reports entitlement state only;
/// it deliberately does not lock the rest of the app.
class Tsl1LicenseService extends ChangeNotifier {
  Tsl1LicenseService({
    LicenseTokenStore? store,
    Tsl1LicenseVerifier? verifier,
  })  : _store = store ?? SecureLicenseTokenStore(),
        _verifier = verifier ?? Tsl1LicenseVerifier();

  final LicenseTokenStore _store;
  final Tsl1LicenseVerifier _verifier;
  LicenseStatus _status = LicenseStatus.notActivated;
  AstraliumLicense? _license;
  String? _storageError;
  bool _restored = false;
  Timer? _expiryTimer;

  LicenseStatus get status => _status;
  AstraliumLicense? get license => _license;
  String? get storageError => _storageError;
  bool get isRestored => _restored;

  Future<void> restore() async {
    try {
      final token = await _store.read();
      if (token == null || token.isEmpty) {
        _set(LicenseStatus.notActivated);
      } else {
        final license = _verifier.verify(token, allowExpired: true);
        _license = license;
        if (license == null) {
          _set(LicenseStatus.invalid);
        } else {
          _refreshExpiryState();
        }
      }
    } catch (error) {
      _storageError = error.toString();
      _set(LicenseStatus.storageError);
    } finally {
      _restored = true;
      notifyListeners();
    }
  }

  Future<bool> activate(String token) async {
    final license = _verifier.verify(token);
    if (license == null) {
      _license = null;
      _set(LicenseStatus.invalid);
      return false;
    }
    try {
      await _store.write(token.trim());
      _license = license;
      _storageError = null;
      _refreshExpiryState();
      return true;
    } catch (error) {
      _license = null;
      _storageError = error.toString();
      _set(LicenseStatus.storageError);
      return false;
    }
  }

  Future<void> deactivate() async {
    try {
      await _store.delete();
      _expiryTimer?.cancel();
      _license = null;
      _storageError = null;
      _set(LicenseStatus.notActivated);
    } catch (error) {
      _storageError = error.toString();
      _set(LicenseStatus.storageError);
    }
  }

  void _refreshExpiryState() {
    _expiryTimer?.cancel();
    final expiresAt = _license?.expiresAt;
    if (expiresAt == null) {
      _set(LicenseStatus.active);
      return;
    }
    final remaining = expiresAt.difference(DateTime.now().toUtc());
    if (remaining <= Duration.zero) {
      _set(LicenseStatus.invalid);
      return;
    }
    _set(LicenseStatus.active);
    _expiryTimer = Timer(remaining, () {
      final expiry = _license?.expiresAt;
      if (expiry == null) return;
      if (!expiry.isAfter(DateTime.now().toUtc())) {
        _set(LicenseStatus.invalid);
      } else {
        _refreshExpiryState();
      }
    });
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }

  void _set(LicenseStatus value) {
    _status = value;
    notifyListeners();
  }
}
