// lib/features/guide_auth/data/datasources/guide_auth_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:jolutrip_app/core/config/app_config.dart';
import 'package:jolutrip_app/core/errors/exceptions.dart';

abstract class GuideAuthRemoteDataSource {
  Future<void> sendLoginOtp(String phone);
  Future<Response> verifyLoginOtp(String phone, String code);
  Future<void> sendRegisterOtp({
    required String fullName,
    required String gender,
    required String phone,
  });
  Future<Response> verifyRegisterOtp({
    required String fullName,
    required String gender,
    required String phone,
    required String code,
  });
}

class GuideAuthRemoteDataSourceImpl implements GuideAuthRemoteDataSource {
  final Dio _client;
  GuideAuthRemoteDataSourceImpl({required Dio client}) : _client = client;

  @override
  Future<void> sendLoginOtp(String phone) async {
    try {
      final response = await _client.post(
        AppConfig.guideLogin,
        data: {'phone': phone},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException('Ошибка: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Response> verifyLoginOtp(String phone, String code) async {
    try {
      final response = await _client.post(
        AppConfig.guideLoginVerify,
        data: {'phone': phone, 'code': code},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      }
      throw ServerException('Ошибка верификации');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> sendRegisterOtp({
    required String fullName,
    required String gender,
    required String phone,
  }) async {
    try {
      final response = await _client.post(
        AppConfig.guideRegister,
        data: {'full_name': fullName, 'gender': gender, 'phone': phone},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException('Ошибка: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Response> verifyRegisterOtp({
    required String fullName,
    required String gender,
    required String phone,
    required String code,
  }) async {
    try {
      final response = await _client.post(
        AppConfig.guideVerify,
        data: {
          'full_name': fullName,
          'gender': gender,
          'phone': phone,
          'code_sms': code,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      }
      throw ServerException('Ошибка регистрации');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    final responseData = e.response?.data;
    if (responseData is Map<String, dynamic>) {
      final errorMessage = responseData['error'] as String? ?? '';
      if (errorMessage.isNotEmpty) {
        return ServerException(errorMessage);
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkException('Сервер не отвечает');
      case DioExceptionType.connectionError:
        return NetworkException('Нет подключения');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        return switch (statusCode) {
          400 => ServerException('Неверный запрос. Проверьте данные.'),
          401 => ServerException('Неавторизован. Войдите заново.'),
          404 => ServerException('Эндпоинт не найден. Проверьте URL.'),
          409 => ServerException('Конфликт данных'),
          429 => ServerException('Слишком много запросов'),
          413 => ServerException('Файлы слишком большие'),
          500 => ServerException('Ошибка сервера'),
          _ => ServerException('Ошибка: $statusCode'),
        };
      default:
        return ServerException(e.message ?? 'Неизвестная ошибка');
    }
  }
}
