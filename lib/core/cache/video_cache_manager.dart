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
}
