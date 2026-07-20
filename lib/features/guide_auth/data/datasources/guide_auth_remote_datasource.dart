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
      _validateResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<Response> verifyLoginOtp(String phone, String code) async {
    try {
      final response = await _client.post(
        AppConfig.guideLoginVerify,
        data: {'phone': phone, 'code': code},
      );
      _validateResponse(response);
      return response;
    } on DioException catch (e) {
      _handleDioError(e);
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
      _validateResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
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
      _validateResponse(response);
      return response;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<void> resendSms(String phone) async {
    try {
      final response = await _client.post(
        AppConfig.guideResendSms,
        data: {'phone': phone},
      );
      _validateResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  void _validateResponse(Response response) {
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ServerException(
        'Ошибка: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  Never _handleDioError(DioException e) {
    // ← Never вместо Exception
    final responseData = e.response?.data;
    String? errorMessage;

    if (responseData is Map<String, dynamic>) {
      errorMessage =
          responseData['error'] as String? ??
          responseData['message'] as String?;
    }

    if (errorMessage != null && errorMessage.isNotEmpty) {
      throw ServerException(errorMessage, statusCode: e.response?.statusCode);
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        throw NetworkException('Сервер не отвечает');
      case DioExceptionType.connectionError:
        throw NetworkException('Нет подключения');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        throw switch (statusCode) {
          400 => ServerException(
            'Неверный запрос. Проверьте данные.',
            statusCode: statusCode,
          ),
          401 => ServerException(
            'Неавторизован. Войдите заново.',
            statusCode: statusCode,
          ),
          404 => ServerException('Гид не найден.', statusCode: statusCode),
          409 => ServerException('Конфликт данных', statusCode: statusCode),
          429 => ServerException(
            'Слишком много запросов',
            statusCode: statusCode,
          ),
          413 => ServerException(
            'Файлы слишком большие',
            statusCode: statusCode,
          ),
          500 => ServerException('Ошибка сервера', statusCode: statusCode),
          _ => ServerException('Ошибка: $statusCode', statusCode: statusCode),
        };
      default:
        throw ServerException(e.message ?? 'Неизвестная ошибка');
    }
  }
}
