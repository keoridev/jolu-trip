import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:jolutrip_app/core/cache/video_cache_manager.dart';

/// Планировщик фоновой загрузки видео.
///
/// Зачем он нужен: без очереди быстрый скролл ленты порождает столько
/// параллельных загрузок, сколько роликов успел задеть палец. Они делят канал,
/// и в итоге даже текущее видео стартует медленно.
///
/// Что делает очередь:
///  * ограничивает число одновременных загрузок ([maxConcurrent]);
///  * дедуплицирует — один URL качается ровно один раз, все ждут общий Future;
///  * приоритизирует: чем ближе ролик к экрану, тем меньше `priority`;
///  * отменяет загрузки роликов, уехавших из окна предзагрузки.
class VideoPrefetchQueue {
  VideoPrefetchQueue._();

  static final VideoPrefetchQueue instance = VideoPrefetchQueue._();

  /// 2 потока — компромисс: канал не забивается, но следующий ролик успевает
  /// прогрузиться, пока смотрят текущий.
  static const int maxConcurrent = 2;

  /// Приоритет для видео, которое уже на экране.
  static const int priorityVisible = 0;

  final List<_PrefetchTask> _pending = [];
  final Map<String, _PrefetchTask> _active = {};
  final Set<String> _ready = {};

  /// Поставить видео в очередь. Повторный вызов для того же URL не создаёт
  /// новую загрузку — возвращается уже существующий Future (с поднятым
  /// приоритетом, если новый выше).
  Future<File?> enqueue(String videoUrl, {int priority = 5}) {
    if (videoUrl.isEmpty) return Future.value(null);

    final active = _active[videoUrl];
    if (active != null) return active.completer.future;

    for (final task in _pending) {
      if (task.url == videoUrl) {
        if (priority < task.priority) {
          task.priority = priority;
          _sortPending();
        }
        return task.completer.future;
      }
    }

    final task = _PrefetchTask(url: videoUrl, priority: priority);
    _pending.add(task);
    _sortPending();
    _pump();
    return task.completer.future;
  }

  /// Источник для воспроизведения.
  ///
  /// Ключевая оптимизация ленты. Раньше плеер ждал, пока файл скачается
  /// целиком, — на холодном старте это секунды чёрного экрана. Теперь:
  ///  * файл уже в кэше → отдаём его сразу (мгновенный старт, без сети);
  ///  * файл докачивается → ждём его не дольше [waitForCache];
  ///  * не успел → возвращаем `null`, и плеер стартует стримингом с сети,
  ///    а загрузка в кэш продолжается в фоне для следующего просмотра.
  Future<File?> fileForPlayback(
    String videoUrl, {
    Duration waitForCache = const Duration(milliseconds: 700),
  }) async {
    if (videoUrl.isEmpty) return null;

    final cached = await VideoCacheManager.getCachedFile(videoUrl);
    if (cached != null) {
      _ready.add(videoUrl);
      return cached.file;
    }

    final download = enqueue(videoUrl, priority: priorityVisible);
    try {
      return await download.timeout(waitForCache);
    } on TimeoutException {
      // Загрузка продолжается — просто перестаём её ждать.
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Лежит ли видео в кэше (по данным этой сессии, без обращения к диску).
  bool isReady(String videoUrl) => _ready.contains(videoUrl);

  /// Отменить загрузку — ролик уехал из окна предзагрузки.
  void cancel(String videoUrl) {
    _pending.removeWhere((task) {
      if (task.url != videoUrl) return false;
      task.complete(null);
      return true;
    });
    _active[videoUrl]?.cancelled = true;
  }

  /// Оставить в работе только эти URL, остальное отменить.
  void retainOnly(Set<String> videoUrls) {
    _pending.removeWhere((task) {
      if (videoUrls.contains(task.url)) return false;
      task.complete(null);
      return true;
    });
    for (final entry in _active.entries) {
      if (!videoUrls.contains(entry.key)) {
        entry.value.cancelled = true;
      }
    }
  }

  /// Сбросить очередь целиком (уход с экрана ленты, pull-to-refresh).
  void clear() {
    for (final task in _pending) {
      task.complete(null);
    }
    _pending.clear();
    for (final task in _active.values) {
      task.cancelled = true;
    }
  }

  // ==========================================================

  void _sortPending() {
    _pending.sort((a, b) => a.priority.compareTo(b.priority));
  }

  void _pump() {
    while (_active.length < maxConcurrent && _pending.isNotEmpty) {
      final task = _pending.removeAt(0);
      _active[task.url] = task;
      unawaited(_run(task));
    }
  }

  Future<void> _run(_PrefetchTask task) async {
    try {
      final file = await VideoCacheManager.download(
        task.url,
        timeout: task.priority == priorityVisible
            ? const Duration(seconds: 60)
            : const Duration(seconds: 40),
        cancelled: () => task.cancelled,
      );
      if (file != null) _ready.add(task.url);
      task.complete(file);
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Предзагрузка не удалась: $e');
      task.complete(null);
    } finally {
      _active.remove(task.url);
      _pump();
    }
  }
}

class _PrefetchTask {
  final String url;
  final Completer<File?> completer = Completer<File?>();
  int priority;
  bool cancelled = false;

  _PrefetchTask({required this.url, required this.priority});

  void complete(File? file) {
    if (!completer.isCompleted) completer.complete(file);
  }
}
