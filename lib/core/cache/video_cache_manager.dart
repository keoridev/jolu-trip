import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoCacheManager {
  static final CacheManager instance = CacheManager(
    Config(
      'reels_video_cache',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 50,
    ),
  );

  VideoCacheManager._();

  // 🗑️ Очистить весь кэш
  static Future<void> clearAllCache() async {
    await instance.emptyCache();
    debugPrint('🗑️ Весь кэш очищен');
  }

  // 🗑️ Удалить конкретное видео из кэша
  static Future<void> removeFromCache(String videoUrl) async {
    await instance.removeFile(videoUrl);
    debugPrint('❌ Удалено из кэша: $videoUrl');
  }

  // ✅ Проверить, есть ли видео в кэше
  static Future<bool> isCached(String videoUrl) async {
    final file = await instance.getFileFromCache(videoUrl);
    return file != null;
  }

  // 📁 Получить файл из кэша (если есть)
  static Future<FileInfo?> getCachedFile(String videoUrl) async {
    return await instance.getFileFromCache(videoUrl);
  }
}
