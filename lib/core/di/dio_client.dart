import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jolutrip_app/core/config/app_config.dart';
import 'package:jolutrip_app/core/storage/secure_storage.dart';

class DioClient {
  final Dio _dio;

  DioClient() : _dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Логгер — первым
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: true,
          logPrint: (obj) => debugPrint('🌐 $obj'),
        ),
      );
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 🔑 КЛЮЧЕВОЕ: для FormData сбрасываем Content-Type
          // чтобы Dio сам поставил multipart/form-data с boundary
          if (options.data is FormData) {
            options.headers.remove('Content-Type');
            debugPrint('🔍 FormData detected — removed Content-Type header');
          }

          // Автоматически добавляем токен (не надо вручную в datasource)
          final token = await SecureStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          debugPrint('📤 ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // TODO: refresh token или logout
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  Dio get dio => _dio;
}