import 'dart:convert';
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
      'email': user.email,
      'birthDate': user.birthDate,
      'cpf': user.cpf,
      'publicKey': user.publicKey,
    };
    await _storage.write(key: _key, value: jsonEncode(map));
  }

  Future<User?> load() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return User(
        name: m['name'] as String,
        email: m['email'] as String?,
        birthDate: m['birthDate'] as String,
        cpf: m['cpf'] as String,
        publicKey: (m['publicKey'] ?? '') as String,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async => _storage.delete(key: _key);
}
