import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class UserStorage {
  static const _key = 'app_user_v1';
  final FlutterSecureStorage _storage;
  UserStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> save(User user) async {
    final map = {
      'name': user.name,
      'birthDate': user.birthDate,
      'cpf': user.cpf,
      'publicKey': user.publicKey,
    };
    final json = jsonEncode(map);
    debugPrint(
        '[UserStorage] save: saving user name=${user.name} cpf=${user.cpf} publicKey=${user.publicKey}');
    await _storage.write(key: _key, value: json);
  }

  Future<User?> load() async {
    debugPrint('[UserStorage] load: attempting to load user');
    final raw = await _storage.read(key: _key);
    if (raw == null) {
      debugPrint('[UserStorage] load: no user stored');
      return null;
    }
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      debugPrint(
          '[UserStorage] load: loaded user name=${m['name']} cpf=${m['cpf']} publicKey=${m['publicKey']}');
      return User(
        name: m['name'] as String,
        email: m['email'] as String?,
        birthDate: m['birthDate'] as String,
        cpf: m['cpf'] as String,
        publicKey: (m['publicKey'] ?? '') as String,
      );
    } catch (e) {
      debugPrint('[UserStorage] load: error $e');
      return null;
    }
  }

  Future<void> clear() async => _storage.delete(key: _key);
}
