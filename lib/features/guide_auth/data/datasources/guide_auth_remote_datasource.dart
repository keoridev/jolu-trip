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
  Future<void> resendSms(String phone);
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
        throw ServerException('Ошибка: ${response.statusCode}', statusCode: response.statusCode);
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
      throw ServerException('Ошибка верификации', statusCode: response.statusCode);
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
        throw ServerException('Ошибка: ${response.statusCode}', statusCode: response.statusCode);
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
      throw ServerException('Ошибка регистрации', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> resendSms(String phone) async {
    try {
      final response = await _client.post(
        AppConfig.guideResendSms,
        data: {'phone': phone},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException('Ошибка: ${response.statusCode}', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    final responseData = e.response?.data;
    String? errorMessage;

    if (responseData is Map<String, dynamic>) {
      errorMessage = responseData['error'] as String?
                  ?? responseData['message'] as String?;
    }

    if (errorMessage != null && errorMessage.isNotEmpty) {
      return ServerException(errorMessage, statusCode: e.response?.statusCode);
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
          400 => ServerException('Неверный запрос. Проверьте данные.', statusCode: statusCode),
          401 => ServerException('Неавторизован. Войдите заново.', statusCode: statusCode),
          404 => ServerException('Эндпоинт не найден. Проверьте URL.', statusCode: statusCode),
          409 => ServerException('Конфликт данных', statusCode: statusCode),
          429 => ServerException('Слишком много запросов', statusCode: statusCode),
          413 => ServerException('Файлы слишком большие', statusCode: statusCode),
          500 => ServerException('Ошибка сервера', statusCode: statusCode),
          _ => ServerException('Ошибка: $statusCode', statusCode: statusCode),
        };
      default:
        return ServerException(e.message ?? 'Неизвестная ошибка');
    }
  }
}