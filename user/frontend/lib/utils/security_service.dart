import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart';
import 'stellar.dart';

/// Responsável por proteger acesso à seed Stellar via PIN + biometria.
class SecurityService {
  static const _pinKey = 'user_pin_hash_v1';
  static const _failedAttemptsKey = 'pin_failed_attempts';
  static const _lockUntilKey = 'pin_lock_until_epoch';
  static const _maxAttempts = 5;
  static const _lockMinutes = 5;
  // trusted flag is now stored in-memory; no persistent key needed

  final FlutterSecureStorage _storage;
  final LocalAuthentication _auth;
  final StellarKeyManager keyManager;
  bool _trusted = false; // volatile in-memory flag

  SecurityService({
    FlutterSecureStorage? storage,
    LocalAuthentication? auth,
    required this.keyManager,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _auth = auth ?? LocalAuthentication();

  Future<bool> hasWallet() async => (await keyManager.load()) != null;

  Future<bool> hasPin() async => (await _storage.read(key: _pinKey)) != null;

  Future<void> setPin(String pin) async {
    final hash = _hash(pin);
    debugPrint('[SecurityService] setPin: saving pin hash');
    await _storage.write(key: _pinKey, value: hash);
  }

  Future<bool> authenticateWithPin(String pin) async {
    debugPrint('[SecurityService] authenticateWithPin: attempt');
    if (await _isLocked()) {
      debugPrint('[SecurityService] authenticateWithPin: locked');
      return false;
    }
    final stored = await _storage.read(key: _pinKey);
    if (stored == null) {
      debugPrint('[SecurityService] authenticateWithPin: no pin stored');
      return false;
    }
    final ok = stored == _hash(pin);
    debugPrint('[SecurityService] authenticateWithPin: ok=$ok');
    if (ok) {
      await _resetAttempts();
      return true;
    }
    await _registerFail();
    return false;
  }

  Future<bool> authenticateBiometric(
      {String reason = 'Autenticar para acessar sua carteira'}) async {
    debugPrint('[SecurityService] authenticateBiometric: trying');
    try {
      final can = await _auth.canCheckBiometrics;
      debugPrint(
          '[SecurityService] authenticateBiometric: canCheckBiometrics=$can');
      if (!can) return false;
      final available = await _auth.getAvailableBiometrics();
      debugPrint(
          '[SecurityService] authenticateBiometric: available=$available');
      if (available.isEmpty) return false;
      final ok = await _auth.authenticate(localizedReason: reason);
      debugPrint('[SecurityService] authenticateBiometric: result=$ok');
      return ok;
    } catch (e) {
      debugPrint('[SecurityService] authenticateBiometric error: $e');
      return false;
    }
  }

  String _hash(String pin) {
    final bytes = utf8.encode('pin|v1|$pin');
    return sha256.convert(bytes).toString();
  }

  Future<bool> _isLocked() async {
    final untilStr = await _storage.read(key: _lockUntilKey);
    if (untilStr == null) return false;
    final until = DateTime.fromMillisecondsSinceEpoch(int.parse(untilStr));
    if (DateTime.now().isAfter(until)) {
      await _resetAttempts();
      return false;
    }
    return true;
  }

  Future<void> _registerFail() async {
    final attemptsStr = await _storage.read(key: _failedAttemptsKey);
    final attempts = (attemptsStr == null) ? 0 : int.parse(attemptsStr);
    final newAttempts = attempts + 1;
    await _storage.write(key: _failedAttemptsKey, value: '$newAttempts');
    if (newAttempts >= _maxAttempts) {
      final lockUntil =
          DateTime.now().add(const Duration(minutes: _lockMinutes));
      await _storage.write(
          key: _lockUntilKey, value: '${lockUntil.millisecondsSinceEpoch}');
    }
  }

  Future<void> _resetAttempts() async {
    await _storage.delete(key: _failedAttemptsKey);
    await _storage.delete(key: _lockUntilKey);
  }

  Future<void> markTrusted() async {
    debugPrint('[SecurityService] markTrusted (in-memory)');
    _trusted = true;
  }

  Future<bool> isTrusted() async {
    debugPrint('[SecurityService] isTrusted(in-memory)=$_trusted');
    return _trusted;
  }

  Future<void> revokeTrust() async {
    debugPrint('[SecurityService] revokeTrust (in-memory)');
    _trusted = false;
  }
}
