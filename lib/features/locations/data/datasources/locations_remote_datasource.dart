import 'package:dio/dio.dart';
import 'package:jolutrip_app/core/config/app_config.dart';
import 'package:jolutrip_app/core/errors/exceptions.dart';
import 'package:jolutrip_app/features/locations/data/models/location_model.dart';

abstract class LocationsRemoteDataSource {
  Future<List<LocationModel>> getLocations();
}

class LocationsRemoteDataSourceImpl implements LocationsRemoteDataSource {
  final Dio dio;

  LocationsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<LocationModel>> getLocations() async {
    try {
      final response = await dio.get(AppConfig.locations);
      final list = response.data as List<dynamic>;
      return list
          .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to load locations');
    }
  }
}
