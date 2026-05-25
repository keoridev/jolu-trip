import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jolutrip_app/core/config/app_config.dart';
import 'package:jolutrip_app/core/errors/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<void> sendOtp(String phone);
  Future<String> verifyOtp(String phone, String code);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _client;

  AuthRemoteDataSourceImpl({required Dio client}) : _client = client;

  @override
  Future<void> sendOtp(String phone) async {
    try {
      final jsonBody = jsonEncode({'phone': phone});
      debugPrint('📤 Отправка OTP: $jsonBody');

      final response = await _client.post(AppConfig.sendOtp, data: jsonBody);

      debugPrint('📥 Ответ OTP: ${response.statusCode}');
      debugPrint('📥 Тело: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException('Ошибка сервера: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('❌ Ошибка отправки OTP: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<String> verifyOtp(String phone, String code) async {
    try {
      final jsonBody = jsonEncode({'phone': phone, 'code': code});
      debugPrint('📤 Отправка верификации: $jsonBody');

      final response = await _client.post(AppConfig.verifyOtp, data: jsonBody);

      debugPrint('📥 Ответ верификации: ${response.statusCode}');
      debugPrint('📥 Тело: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'] as String?;
        if (token == null) throw ServerException('Токен не получен');
        return token;
      }

      throw ServerException('Ошибка верификации');
    } on DioException catch (e) {
      debugPrint('❌ Ошибка верификации: ${e.message}');
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    // Пробуем получить сообщение от сервера
    if (e.response?.data != null) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('error')) {
        return ServerException(data['error'].toString());
      }
      if (data is Map && data.containsKey('message')) {
        return ServerException(data['message'].toString());
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Сервер не отвечает. Проверьте интернет.');
      case DioExceptionType.connectionError:
        return NetworkException('Нет подключения к сети.');
      case DioExceptionType.badResponse:
        return ServerException('Ошибка сервера: ${e.response?.statusCode}');
      default:
        return ServerException(e.message ?? 'Неизвестная ошибка');
    }
  }
}
