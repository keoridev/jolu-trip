import 'package:dio/dio.dart';
import 'package:jolutrip_app/core/config/app_config.dart';
import 'package:jolutrip_app/core/errors/exceptions.dart';
import 'package:jolutrip_app/features/guide_tours/data/models/create_tour_request_model.dart';
import 'package:jolutrip_app/features/guide_tours/data/models/promo_video_response_model.dart';
import 'package:jolutrip_app/features/guide_tours/data/models/tour_model.dart';

abstract class GuideToursRemoteDataSource {
  Future<PromoVideoResponseModel> uploadPromoVideo(
    List<int> videoBytes,
    String fileName,
  );
  Future<TourModel> createTour(CreateTourRequestModel request);
}

class GuideToursRemoteDataSourceImpl implements GuideToursRemoteDataSource {
  final Dio dio;

  GuideToursRemoteDataSourceImpl({required this.dio});

  @override
  Future<PromoVideoResponseModel> uploadPromoVideo(
    List<int> videoBytes,
    String fileName,
  ) async {
    try {
      final formData = FormData.fromMap({
        'video': MultipartFile.fromBytes(videoBytes, filename: fileName),
      });

      final response = await dio.post(
        AppConfig.guideToursPromoVideo,
        data: formData,
      );

      return PromoVideoResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Failed to upload promo video',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<TourModel> createTour(CreateTourRequestModel request) async {
    try {
      final response = await dio.post(
        AppConfig.guideTours,
        data: request.toJson(),
      );

      final data = response.data as Map<String, dynamic>;
      final tourData =
          data['tour'] as Map<String, dynamic>; // ← достаём из обёртки

      return TourModel.fromJson(tourData);
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Failed to create tour',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
