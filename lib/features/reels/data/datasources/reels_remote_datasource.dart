import 'package:dio/dio.dart';
import 'package:jolutrip_app/core/config/app_config.dart';
import 'package:jolutrip_app/core/errors/exceptions.dart';
import 'package:jolutrip_app/features/reels/data/data.dart';

abstract class ReelsRemoteDataSource {
  Future<List<ReelModel>> getReels();
}

class ReelsRemoteDataSourceImpl implements ReelsRemoteDataSource {
  final Dio _client;

  ReelsRemoteDataSourceImpl({required Dio client}) : _client = client;

  @override
  Future<List<ReelModel>> getReels() async {
    try {
      final response = await _client.get(AppConfig.reels);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ReelModel.fromJson(json)).toList();
      }

      throw ServerException('Ошибка загрузки reels: ${response.statusCode}');
    } on DioException catch (e) {
      throw NetworkException('Нет связи с сервером: ${e.message}');
    }
  }
}
