import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jolutrip_app/core/config/app_config.dart';
import 'package:jolutrip_app/core/errors/exceptions.dart';
import 'package:jolutrip_app/features/tourist_health_card/data/models/health_card_model.dart';

abstract class HealthCardRemoteDataSource {
  /// Возвращает null если карточка не найдена (404 или "запись не найдена")
  Future<HealthCardModel?> getHealthCard();
  Future<HealthCardModel> saveHealthCard(HealthCardModel card);
}

class HealthCardRemoteDataSourceImpl implements HealthCardRemoteDataSource {
  final Dio dio;
  HealthCardRemoteDataSourceImpl({required this.dio});

  @override
  Future<HealthCardModel?> getHealthCard() async {
    try {
      final response = await dio.get(AppConfig.touristHealthCard);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return HealthCardModel.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      // 🎯 КЕЙС 1: Правильный 404 от сервера
      if (statusCode == 404) {
        debugPrint('ℹ️ Health card not found (404)');
        return null;
      }

      // 🎯 КЕЙС 2: Бековый БАГ — он возвращает 500 вместо 404
      // Если статус 500 и в тексте "запись не найдена" — трактуем как "карточки нет"
      if (statusCode == 500 && _isNotFoundError(responseData)) {
        debugPrint(
          'ℹ️ Health card not found (500 with "запись не найдена") — бековый баг, адаптируемся',
        );
        return null;
      }

      // Всё остальное — реальная ошибка
      throw _mapDioError(e);
    }
  }

  /// Проверяем, является ли 500 на самом деле "не найдено"
  bool _isNotFoundError(dynamic data) {
    if (data is! Map<String, dynamic>) return false;
    final error = data['error'];
    if (error is! String) return false;
    final lower = error.toLowerCase();
    return lower.contains('не найдена') ||
        lower.contains('not found') ||
        lower.contains('does not exist');
  }

  @override
  Future<HealthCardModel> saveHealthCard(HealthCardModel card) async {
    // Пытаемся PUT (по Swagger — create/update)
    try {
      final response = await dio.put(
        AppConfig.touristHealthCard,
        data: card.toJson(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return HealthCardModel.fromJson(data);
      }
      return card;
    } on DioException catch (e) {
      // Если PUT вернул 500 "запись не найдена" — пробуем POST
      if (_isNotFoundError(e.response?.data)) {
        debugPrint('⚠️ PUT failed, fallback to POST');
        try {
          final response = await dio.post(
            AppConfig.touristHealthCard,
            data: card.toJson(),
          );
          final data = response.data;
          if (data is Map<String, dynamic>) {
            return HealthCardModel.fromJson(data);
          }
          return card;
        } on DioException catch (e2) {
          throw _mapDioError(e2);
        }
      }
      throw _mapDioError(e);
    }
  }

  ServerException _mapDioError(DioException e) {
    final response = e.response;
    final statusCode = response?.statusCode;
    final data = response?.data;

    String message = 'Ошибка сервера';
    if (data is Map<String, dynamic>) {
      message =
          data['message'] as String? ??
          data['error'] as String? ??
          'Ошибка сервера ($statusCode)';
    } else if (statusCode != null) {
      message = 'Ошибка сервера ($statusCode)';
    }

    return ServerException(message, statusCode: statusCode);
  }
}
