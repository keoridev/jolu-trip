import 'package:dio/dio.dart';
import 'package:jolutrip_app/core/config/app_config.dart';
import 'package:jolutrip_app/core/errors/exceptions.dart';
import 'package:jolutrip_app/features/guide-profile/data/models/models.dart';

abstract class GuideProfileRemoteDataSource {
  Future<GuideProfileModel> getProfile(String token);
  
  Future<GuideProfileModel> updateProfile({
    required String token,
    required Map<String, dynamic> data,
  });

  Future<String> updateAvatar({
    required String token,
    required List<int> avatarBytes,
  });
}

class GuideProfileRemoteDataSourceImpl implements GuideProfileRemoteDataSource {
  final Dio _dio;

  GuideProfileRemoteDataSourceImpl(this._dio);

  @override
  Future<GuideProfileModel> getProfile(String token) async {
    try {
      final response = await _dio.get(
        AppConfig.guideMe,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return GuideProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<GuideProfileModel> updateProfile({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.patch(
        AppConfig.guideProfile,
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return GuideProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<String> updateAvatar({
    required String token,
    required List<int> avatarBytes,
  }) async {
    try {
      final formData = FormData.fromMap({
        'avatar': MultipartFile.fromBytes(avatarBytes, filename: 'avatar.jpg'),
      });

      final response = await _dio.patch(
        AppConfig.guideAvatar,
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.data['avatar_url'] as String;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ServerException _handleError(DioException e) {
    final data = e.response?.data;
    final msg = data is Map ? (data['message'] ?? data['error']) : null;
    return ServerException(msg ?? 'Ошибка запроса', statusCode: e.response?.statusCode);
  }
}