import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/errors/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<void> sendOtp(String phone);
  Future<Response> verifyOtp(
    String phone,
    String code,
  ); // ← Response вместо String
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
  Future<Response> verifyOtp(String phone, String code) async {
    try {
      final response = await _client.post(
        AppConfig.verifyOtp,
        data: {'phone': phone, 'code': code},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response; // ← Возвращаем весь Response
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
