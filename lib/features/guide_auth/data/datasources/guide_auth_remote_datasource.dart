import 'package:dio/dio.dart';
import 'package:jolutrip_app/core/config/app_config.dart';
import 'package:jolutrip_app/core/errors/exceptions.dart';
import 'package:jolutrip_app/features/guide_auth/data/models/guide_model.dart';

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
  Future<GuideModel> submitOnboarding({
    required String guideId,
    required int experienceYears,
    required String carModel,
    required String carNumber,
    required List<String> languages,
    required List<int> passportScanBytes,
    required List<int> licensePhotoBytes,
    required List<List<int>> carPhotosBytes,
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

  // ═══════════════════════════════════════════════════
  // ONBOARDING: POST /api/v1/guides/profile/verify
  // ═══════════════════════════════════════════════════
  @override
  Future<GuideModel> submitOnboarding({
    required String guideId,
    required int experienceYears,
    required String carModel,
    required String carNumber,
    required List<String> languages,
    required List<int> passportScanBytes,
    required List<int> licensePhotoBytes,
    required List<List<int>> carPhotosBytes,
  }) async {
    try {
      final formData = FormData.fromMap({
        'experience_years': experienceYears,
        'car_model': carModel,
        'car_number': carNumber,
        'languages': languages,
        'passport_scan': MultipartFile.fromBytes(
          passportScanBytes,
          filename: 'passport_$guideId.jpg',
        ),
        'license_photo': MultipartFile.fromBytes(
          licensePhotoBytes,
          filename: 'license_$guideId.jpg',
        ),
      });

      // Добавляем фото машин
      for (var i = 0; i < carPhotosBytes.length; i++) {
        formData.files.add(
          MapEntry(
            'car_photos',
            MultipartFile.fromBytes(
              carPhotosBytes[i],
              filename: 'car_${guideId}_$i.jpg',
            ),
          ),
        );
      }

      // 🔥 JWT добавляется автоматически через Dio Interceptor!
      // Не нужно ставить Content-Type вручную — Dio сам с boundary
      final response = await _client.post(
        AppConfig.guideProfileVerify,
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 🔥 Бэкенд возвращает новый токен + обновленные данные
        // Сохраняем новый токен если есть
        if (response.data is Map<String, dynamic>) {
          final newToken = response.data['token'] as String?;
          if (newToken != null) {
            // SecureStorage обновится в Cubit
          }
        }
        return GuideModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException('Ошибка загрузки документов');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    // Парсим тело ответа для читаемых ошибок
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
