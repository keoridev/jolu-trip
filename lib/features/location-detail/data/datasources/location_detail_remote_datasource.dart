import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jolutrip_app/core/config/app_config.dart';
import 'package:jolutrip_app/core/errors/exceptions.dart';
import '../models/location_detail_model.dart';

abstract class LocationDetailRemoteDataSource {
  Future<LocationDetailModel> getLocationDetail(String locationId);
}

class LocationDetailRemoteDataSourceImpl
    implements LocationDetailRemoteDataSource {
  final Dio _client;

  LocationDetailRemoteDataSourceImpl({required Dio client}) : _client = client;

  @override
  Future<LocationDetailModel> getLocationDetail(String locationId) async {
    try {
      final url = AppConfig.locationDetail(locationId); // ← Используем метод

      debugPrint('🌐 Запрос: $url'); // Для отладки

      final response = await _client.get(url);

      if (response.statusCode == 200) {
        return LocationDetailModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      throw ServerException('Ошибка загрузки локации: ${response.statusCode}');
    } on DioException catch (e) {
      throw NetworkException('Нет связи с сервером: ${e.message}');
    }
  }
}
