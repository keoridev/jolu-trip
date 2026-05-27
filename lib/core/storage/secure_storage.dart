import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static const String _tokenKey = 'jwt_token';
  static const String _userIdKey = 'user_id';
  static const String _phoneKey = 'user_phone';
  static const String _nameKey = 'user_name';
  static const String _avatarKey = 'user_avatar';

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
    if (avatarUrl != null)
      await _storage.write(key: _avatarKey, value: avatarUrl);
  }

  static Future<String?> getToken() => _storage.read(key: _tokenKey);
  static Future<String?> getUserId() => _storage.read(key: _userIdKey);
  static Future<String?> getPhone() => _storage.read(key: _phoneKey);
  static Future<String?> getName() => _storage.read(key: _nameKey);
  static Future<String?> getAvatar() => _storage.read(key: _avatarKey);

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
