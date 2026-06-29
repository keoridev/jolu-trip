import 'package:dio/dio.dart';
import 'package:jolutrip_app/core/config/app_config.dart';
import 'package:jolutrip_app/core/errors/exceptions.dart';
import 'package:jolutrip_app/features/guide_onboarding/data/models/model.dart';

abstract class GuideOnboardingRemoteDataSource {
  Future<OnboardingModel> submitOnboarding({
    required String token,
    required int experienceYears,
    required String carCategory,
    required String carModel,
    required String carNumber,
    required List<String> languages,
    required List<int> passportMainPhotoBytes,
    required List<int> passportRegistrationPhotoBytes,
    required List<int> licensePhotoFrontBytes,
    required List<int> licensePhotoBackBytes,
    required List<List<int>> carPhotosBytes,
    required List<int> presentationVideoBytes,
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
    required String carCategory,
    required String carModel,
    required String carNumber,
    required List<String> languages,
    required List<int> passportMainPhotoBytes,
    required List<int> passportRegistrationPhotoBytes,
    required List<int> licensePhotoFrontBytes,
    required List<int> licensePhotoBackBytes,
    required List<List<int>> carPhotosBytes,
    required List<int> presentationVideoBytes,
  }) async {
    try {
      final formData = FormData();

      // Text fields
      formData.fields.addAll([
        MapEntry('experience_years', experienceYears.toString()),
        MapEntry('car_category', carCategory),
        MapEntry('car_model', carModel),
        MapEntry('car_number', carNumber),
        MapEntry('languages', languages.join(',')),
      ]);

      // Passport: главная страница
      formData.files.add(
        MapEntry(
          'passport_main_photo',
          MultipartFile.fromBytes(
            passportMainPhotoBytes,
            filename: 'passport_main.jpg',
          ),
        ),
      );

      // Passport: страница прописки
      formData.files.add(
        MapEntry(
          'passport_registration_photo',
          MultipartFile.fromBytes(
            passportRegistrationPhotoBytes,
            filename: 'passport_registration.jpg',
          ),
        ),
      );

      // License: лицевая сторона
      formData.files.add(
        MapEntry(
          'license_photo_front',
          MultipartFile.fromBytes(
            licensePhotoFrontBytes,
            filename: 'license_front.jpg',
          ),
        ),
      );

      // License: оборотная сторона
      formData.files.add(
        MapEntry(
          'license_photo_back',
          MultipartFile.fromBytes(
            licensePhotoBackBytes,
            filename: 'license_back.jpg',
          ),
        ),
      );

      // Car photos (ровно 4)
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

      // Presentation video
      formData.files.add(
        MapEntry(
          'presentation_video',
          MultipartFile.fromBytes(
            presentationVideoBytes,
            filename: 'presentation_video.mp4',
          ),
        ),
      );

      final response = await dio.post(
        AppConfig.guideProfileVerify,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return OnboardingModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          'Ошибка загрузки документов: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data is Map ? (data['message'] ?? data['error']) : null;
      throw ServerException(msg ?? 'Ошибка сети', statusCode: e.response?.statusCode);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}