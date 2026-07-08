import 'package:dio/dio.dart';
import 'package:jolutrip_app/core/config/app_config.dart';
import 'package:jolutrip_app/core/errors/exceptions.dart';
import 'package:jolutrip_app/features/guide-profile/data/models/guide_profile_model.dart';

abstract class GuideProfileRemoteDataSource {
  Future<GuideProfileModel> getMe();
  Future<GuideProfileModel> updateProfile(Map<String, dynamic> data);
  Future<String> uploadAvatar(List<int> bytes);
}

class GuideProfileRemoteDataSourceImpl implements GuideProfileRemoteDataSource {
  final Dio _dio;

  GuideProfileRemoteDataSourceImpl(this._dio);

  @override
  Future<GuideProfileModel> getMe() async {
    try {
      final response = await _dio.get(AppConfig.guideMe);
      return GuideProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<GuideProfileModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch(
        AppConfig.guideProfile,
        data: data,
      );
      return GuideProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<String> uploadAvatar(List<int> bytes) async {
    try {
      final formData = FormData.fromMap({
        'avatar': MultipartFile.fromBytes(bytes, filename: 'avatar.jpg'),
      });
      final response = await _dio.patch(
        AppConfig.guideAvatar,
        data: formData,
      );
      return response.data['avatar_url'] as String;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  ServerException _mapDioError(DioException e) {
    final response = e.response;
    final statusCode = response?.statusCode;
    final data = response?.data;

    String message = 'Server error';
    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ??
          data['error'] as String? ??
          data['status'] as String? ??
          'Server error ($statusCode)';
    } else if (statusCode != null) {
      message = 'Server error ($statusCode)';
    }

    return ServerException(message, statusCode: statusCode);
  }
}