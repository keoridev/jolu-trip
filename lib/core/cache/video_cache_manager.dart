import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hive/hive.dart';

/// Снимок состояния видеокэша.
@immutable
class VideoCacheStats {
  final int fileCount;
  final int totalBytes;

  const VideoCacheStats({required this.fileCount, required this.totalBytes});

  double get megabytes => totalBytes / (1024 * 1024);

  @override
  String toString() =>
      '$fileCount файл(ов) · ${megabytes.toStringAsFixed(1)} МБ';
}

/// Хранилище видео для ленты reels.
///
/// Поверх [CacheManager] здесь добавлено то, чего у него нет из коробки:
///  * лимит кэша **в байтах**, а не только по количеству файлов — видео весит
///    десятки мегабайт, и «50 объектов» может означать и 200 МБ, и 3 ГБ;
///  * LRU-вытеснение: удаляется то, что дольше всего не открывали, а не то,
///    что дольше всего лежит;
///  * загрузка с прогрессом и таймаутом.
///
/// Планированием загрузок (очередь, приоритеты, дедупликация) занимается
/// `VideoPrefetchQueue` — здесь только хранение.
class VideoCacheManager {
  VideoCacheManager._();

  static const String cacheKey = 'reels_video_cache';
  static const String _indexBoxName = 'reels_video_cache_index';

  /// Сколько файл живёт без обращений.
  static const Duration stalePeriod = Duration(days: 14);

  /// Страховка на уровне flutter_cache_manager.
  static const int maxCacheObjects = 60;

  /// Основной лимит. ~350 МБ — примерно 20–35 вертикальных роликов.
  static const int maxCacheBytes = 350 * 1024 * 1024;

  static final CacheManager instance = CacheManager(
    Config(
      cacheKey,
      stalePeriod: stalePeriod,
      maxNrOfCacheObjects: maxCacheObjects,
    ),
  );

  static final Map<String, _CacheMeta> _index = {};

  /// Файлы, которые сейчас открыты плеером. Удалять их нельзя: под играющим
  /// [VideoPlayerController] файл исчезнет и воспроизведение оборвётся.
  static final Set<String> _pinned = {};

  static Box<dynamic>? _box;
  static Future<void>? _ready;

  // ==========================================================
  // Инициализация
  // ==========================================================

  /// Поднимает LRU-индекс и приводит кэш к лимиту.
  ///
  /// Вызывать один раз при старте приложения. Ждать не обязательно —
  /// все остальные методы дожидаются готовности сами.
  static Future<void> warmUp() async {
    await _ensureReady();
    await _reconcile();
    await enforceBudget();
    if (kDebugMode) {
      debugPrint('📦 Видеокэш готов: ${await stats()}');
    }
  }

  static Future<void> _ensureReady() {
    return _ready ??= _load();
  }

  static Future<void> _load() async {
    try {
      final box = await Hive.openBox<dynamic>(_indexBoxName);
      _box = box;
      for (final key in box.keys) {
        final raw = box.get(key);
        if (raw is Map) {
          _index[key.toString()] = _CacheMeta(
            bytes: (raw['b'] as num?)?.toInt() ?? 0,
            lastAccess: (raw['t'] as num?)?.toInt() ?? 0,
          );
        }
      }
    } catch (e) {
      // Hive может быть не инициализирован (тесты, изолят) — работаем в памяти.
      debugPrint('⚠️ LRU-индекс видеокэша только в памяти: $e');
    }
  }

  /// Выбрасывает из индекса записи, чьих файлов уже нет на диске
  /// (их мог удалить сам flutter_cache_manager по stalePeriod).
  static Future<void> _reconcile() async {
    final stale = <String>[];
    for (final url in _index.keys.toList()) {
      final info = await instance.getFileFromCache(url);
      if (info == null || !await info.file.exists()) {
        stale.add(url);
      }
    }
    for (final url in stale) {
      _forgetMeta(url);
    }
  }

  // ==========================================================
  // Чтение
  // ==========================================================

  /// Файл из кэша, если он там есть. Обновляет отметку последнего доступа.
  static Future<FileInfo?> getCachedFile(String videoUrl) async {
    if (videoUrl.isEmpty) return null;
    await _ensureReady();

    final info = await instance.getFileFromCache(videoUrl);
    if (info == null) {
      _forgetMeta(videoUrl);
      return null;
    }
    if (!await info.file.exists()) {
      _forgetMeta(videoUrl);
      return null;
    }

    await _touch(videoUrl, info.file);
    return info;
  }

  static Future<bool> isCached(String videoUrl) async =>
      await getCachedFile(videoUrl) != null;

  /// Сколько занято и сколько файлов лежит.
  static Future<VideoCacheStats> stats() async {
    await _ensureReady();
    var total = 0;
    for (final meta in _index.values) {
      total += meta.bytes;
    }
    return VideoCacheStats(fileCount: _index.length, totalBytes: total);
  }

  // ==========================================================
  // Загрузка
  // ==========================================================

  /// Скачивает видео в кэш.
  ///
  /// [onProgress] — 0.0…1.0, приходит только если сервер отдал Content-Length.
  /// [cancelled] позволяет бросить загрузку, если ролик уехал из окна
  /// предзагрузки: мы перестаём ждать результат и не занимаем слот очереди.
  static Future<File?> download(
    String videoUrl, {
    Duration timeout = const Duration(seconds: 45),
    ValueChanged<double>? onProgress,
    bool Function()? cancelled,
  }) async {
    if (videoUrl.isEmpty) return null;
    await _ensureReady();

    final completer = Completer<File?>();
    StreamSubscription<FileResponse>? sub;
    Timer? timer;

    void finish(File? file, [Object? error]) {
      if (completer.isCompleted) return;
      timer?.cancel();
      sub?.cancel();
      if (error != null) {
        completer.completeError(error);
      } else {
        completer.complete(file);
      }
    }

    timer = Timer(timeout, () {
      finish(null, TimeoutException('Таймаут загрузки видео', timeout));
    });

    sub = instance
        .getFileStream(videoUrl, withProgress: onProgress != null)
        .listen(
          (response) {
            if (cancelled?.call() ?? false) {
              finish(null);
              return;
            }
            if (response is DownloadProgress) {
              final total = response.totalSize;
              if (total != null && total > 0) {
                onProgress?.call(response.downloaded / total);
              }
            } else if (response is FileInfo) {
              finish(response.file);
            }
          },
          onError: (Object e, StackTrace s) => finish(null, e),
          onDone: () => finish(null),
          cancelOnError: true,
        );

    final file = await completer.future;
    if (file != null) {
      await _touch(videoUrl, file);
      unawaited(enforceBudget());
    }
    return file;
  }

  // ==========================================================
  // Вытеснение
  // ==========================================================

  /// Защитить файл от вытеснения на время воспроизведения.
  static void pin(String videoUrl) {
    if (videoUrl.isNotEmpty) _pinned.add(videoUrl);
  }

  static void unpin(String videoUrl) => _pinned.remove(videoUrl);

  /// Удаляет самые давно не используемые файлы, пока кэш не влезет в лимит.
  static Future<void> enforceBudget({int? maxBytes}) async {
    await _ensureReady();
    final limit = maxBytes ?? maxCacheBytes;

    var total = _index.values.fold<int>(0, (sum, m) => sum + m.bytes);
    if (total <= limit) return;

    final byAge = _index.entries.toList()
      ..sort((a, b) => a.value.lastAccess.compareTo(b.value.lastAccess));

    for (final entry in byAge) {
      if (total <= limit) break;
      if (_pinned.contains(entry.key)) continue;
      total -= entry.value.bytes;
      await removeFromCache(entry.key);
      if (kDebugMode) {
        debugPrint(
          '🧹 Вытеснено из кэша (LRU): ${entry.value.bytes ~/ (1024 * 1024)} МБ',
        );
      }
    }
  }

  static Future<void> removeFromCache(String videoUrl) async {
    try {
      await instance.removeFile(videoUrl);
    } catch (_) {
      // Файла уже нет — индекс всё равно чистим.
    }
    _forgetMeta(videoUrl);
  }

  static Future<void> clearAllCache() async {
    await instance.emptyCache();
    _index.clear();
    await _box?.clear();
    debugPrint('🗑️ Видеокэш очищен полностью');
  }

  // ==========================================================
  // LRU-индекс
  // ==========================================================

  static Future<void> _touch(String url, File file) async {
    int bytes = _index[url]?.bytes ?? 0;
    if (bytes == 0) {
      try {
        bytes = await file.length();
      } catch (_) {
        bytes = 0;
      }
    }
    final meta = _CacheMeta(
      bytes: bytes,
      lastAccess: DateTime.now().millisecondsSinceEpoch,
    );
    _index[url] = meta;
    try {
      await _box?.put(url, {'b': meta.bytes, 't': meta.lastAccess});
    } catch (_) {
      // Персистентность индекса — не критично, в памяти он уже обновлён.
    }
  }

  static void _forgetMeta(String url) {
    if (_index.remove(url) == null) return;
    try {
      _box?.delete(url);
    } catch (_) {
      // см. _touch
    }
  }
}

@immutable
class _CacheMeta {
  final int bytes;
  final int lastAccess;

  const _CacheMeta({required this.bytes, required this.lastAccess});
}
