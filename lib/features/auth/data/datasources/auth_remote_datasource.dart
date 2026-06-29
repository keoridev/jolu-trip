import 'package:dio/dio.dart';
import 'package:jolutrip_app/core/config/app_config.dart';
import 'package:jolutrip_app/core/errors/exceptions.dart';


abstract class AuthRemoteDataSource {
  Future<void> sendOtp(String phone);
  Future<Map<String, dynamic>> verifyOtp(String phone, String code); // ← Map вместо Response
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _client;
  AuthRemoteDataSourceImpl({required Dio client}) : _client = client;

  @override
  Future<void> sendOtp(String phone) async {
    try {
      final response = await _client.post(
        AppConfig.sendOtp,
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
  Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    try {
      final response = await _client.post(
        AppConfig.verifyOtp,
        data: {'phone': phone, 'code': code},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>; // ← Сразу парсим
      }
      throw ServerException('Ошибка верификации');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Сервер не отвечает');
      case DioExceptionType.connectionError:
        return NetworkException('Нет подключения');
      default:
        return ServerException(e.message ?? 'Ошибка');
    }
  }
}
