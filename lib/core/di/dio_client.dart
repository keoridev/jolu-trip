import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jolutrip_app/core/config/app_config.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        contentType: 'application/json',
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          logPrint: (obj) => debugPrint('🌐 $obj'),
        ),
      );
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          debugPrint('📤 ====== ЗАПРОС ======');
          debugPrint('📤 ${options.method} ${options.uri}');
          debugPrint('📤 Headers: ${options.headers}');
          debugPrint('📤 Body: ${options.data}');
          debugPrint('📤 ===================');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('📥 ====== ОТВЕТ ======');
          debugPrint(
            '📥 ${response.statusCode} ${response.requestOptions.uri}',
          );
          debugPrint('📥 Data: ${response.data}');
          debugPrint('📥 ==================');
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('❌ ====== ОШИБКА ======');
          debugPrint('❌ ${error.type} | ${error.message}');
          if (error.response != null) {
            debugPrint('❌ Статус: ${error.response?.statusCode}');
            debugPrint('❌ Данные: ${error.response?.data}');
          }
          if (error.requestOptions.data != null) {
            debugPrint('❌ Что отправили: ${error.requestOptions.data}');
          }
          debugPrint('❌ ===================');
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
}

