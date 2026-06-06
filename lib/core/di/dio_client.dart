import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jolutrip_app/core/config/app_config.dart';
import 'package:jolutrip_app/core/storage/secure_storage.dart';

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
          responseHeader: true, 
          logPrint: (obj) => debugPrint('🌐 $obj'),
        ),
      );
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage.getToken();
          if (token?.isNotEmpty == true &&
              !options.headers.containsKey('Authorization') &&
              !options.headers.containsKey('authorization')) {
            options.headers['Authorization'] = 'Bearer $token';
          }

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
          debugPrint(
            '📥 Headers: ${response.headers}',
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
            debugPrint('❌ Заголовки: ${error.response?.headers}');
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

String _safeBody(Object? data) {
  if (data == null) return 'null';

  try {
    if (data is Map<String, dynamic>) {
      return jsonEncode(_redactMap(data));
    }
    if (data is List) {
      return jsonEncode(
        data
            .map(
              (item) =>
                  item is Map ? _redactMap(item.cast<String, dynamic>()) : item,
            )
            .toList(),
      );
    }
    return data.toString();
  } catch (_) {
    return data.toString();
  }
}

Map<String, dynamic> _redactMap(Map<String, dynamic> source) {
  final redacted = <String, dynamic>{};
  for (final entry in source.entries) {
    final key = entry.key.toLowerCase();
    if (key.contains('password') ||
        key.contains('token') ||
        key.contains('authorization') ||
        key.contains('code')) {
      redacted[entry.key] = '***REDACTED***';
    } else if (entry.value is Map<String, dynamic>) {
      redacted[entry.key] = _redactMap(entry.value as Map<String, dynamic>);
    } else if (entry.value is List) {
      redacted[entry.key] = (entry.value as List).map((item) {
        if (item is Map<String, dynamic>) {
          return _redactMap(item);
        }
        return item;
      }).toList();
    } else {
      redacted[entry.key] = entry.value;
    }
  }
  return redacted;
}

Map<String, dynamic> _safeHeaders(Map<String, dynamic> headers) {
  final safe = <String, dynamic>{};
  for (final entry in headers.entries) {
    final key = entry.key.toLowerCase();
    if (key == 'authorization' || key == 'cookie') {
      safe[entry.key] = '***REDACTED***';
    } else {
      safe[entry.key] = entry.value;
    }
  }
  return safe;
}
