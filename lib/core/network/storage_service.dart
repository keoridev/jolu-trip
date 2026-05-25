import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jolutrip_app/features/auth/data/models/user_model.dart';

class StorageService {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_data';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveAuthData(String token, UserModel user) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<UserModel?> getUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> clearAuthData() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
