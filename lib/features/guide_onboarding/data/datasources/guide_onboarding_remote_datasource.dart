import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:jolutrip_app/core/config/app_config.dart';
import 'package:jolutrip_app/core/errors/exceptions.dart';
import 'package:jolutrip_app/features/guide_onboarding/data/models/onboarding_model.dart';

abstract class GuideOnboardingRemoteDataSource {
  Future<OnboardingModel> submitOnboarding({
    required String token,
    required int experienceYears,
    required String carModel,
    required String carNumber,
    required List<String> languages,
    required List<int> passportScanBytes,
    required List<int> licensePhotoBytes,
    required List<List<int>> carPhotosBytes,
  });
}

class GuideOnboardingRemoteDataSourceImpl
    implements GuideOnboardingRemoteDataSource {
  final Dio dio;

  GuideOnboardingRemoteDataSourceImpl({required this.dio});

  @override
  Future<OnboardingModel> submitOnboarding({
    required String token,
    required int experienceYears,
    required String carModel,
    required String carNumber,
    required List<String> languages,
    required List<int> passportScanBytes,
    required List<int> licensePhotoBytes,
    required List<List<int>> carPhotosBytes,
  }) async {
    try {
      // Создаем FormData для multipart запроса
      final formData = FormData();

      // Добавляем текстовые поля
      formData.fields.addAll([
        MapEntry('experience_years', experienceYears.toString()),
        MapEntry('car_model', carModel),
        MapEntry('car_number', carNumber),
        MapEntry(
          'languages',
          jsonEncode(languages),
        ), // Отправляем как JSON массив
      ]);

      // Добавляем файл паспорта
      formData.files.add(
        MapEntry(
          'passport_scan',
          MultipartFile.fromBytes(
            passportScanBytes,
            filename: 'passport_scan.jpg',
          ),
        ),
      );

      // Добавляем файл водительских прав
      formData.files.add(
        MapEntry(
          'license_photo',
          MultipartFile.fromBytes(
            licensePhotoBytes,
            filename: 'license_photo.jpg',
          ),
        ),
      );

      // Добавляем файлы автомобиля (несколько)
      for (int i = 0; i < carPhotosBytes.length; i++) {
        formData.files.add(
          MapEntry(
            'car_photos',
            MultipartFile.fromBytes(
              carPhotosBytes[i],
              filename: 'car_photo_$i.jpg',
            ),
          ),
        );
      }

      final response = await dio.post(
        AppConfig.guideProfileVerify, // /api/v1/guides/profile/verify
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return OnboardingModel.fromJson(response.data);
      } else {
        throw ServerException(
          'Ошибка загрузки документов: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Ошибка сети';
      throw ServerException(message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
