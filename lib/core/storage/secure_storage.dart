import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static const String _tokenKey = 'jwt_token';
  static const String _userIdKey = 'user_id';
  static const String _phoneKey = 'user_phone';
  static const String _nameKey = 'user_name'; // 🔥 const!
  static const String _avatarKey = 'user_avatar'; // 🔥 const!

  static final _authController = StreamController<void>.broadcast();
  static Stream<void> get authChanges => _authController.stream;

  static Future<void> saveAuthData({
    required String token,
    required String userId,
    required String phone,
    String? name,
    String? avatarUrl,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _phoneKey, value: phone);
    if (name != null) await _storage.write(key: _nameKey, value: name);
    if (avatarUrl != null) await _storage.write(key: _avatarKey, value: avatarUrl);
    _authController.add(null);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
    _authController.add(null);
  }

  // 🔥 Не забудь вызвать при выходе из приложения
  static void dispose() {
    _authController.close();
  }

  static Future<String?> getToken() => _storage.read(key: _tokenKey);
  static Future<String?> getUserId() => _storage.read(key: _userIdKey);
  static Future<String?> getPhone() => _storage.read(key: _phoneKey);
  static Future<String?> getName() => _storage.read(key: _nameKey);
  static Future<String?> getAvatar() => _storage.read(key: _avatarKey);
}