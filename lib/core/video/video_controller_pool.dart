import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

typedef VideoControllerFactory = Future<VideoPlayerController> Function();

/// Пул живых [VideoPlayerController].
///
/// Каждый контроллер держит аппаратный видеодекодер. На части Android-устройств
/// их всего 2–4 на процесс: если при быстром скролле ленты насоздавать
/// контроллеров без ограничений, инициализация начнёт молча падать, а картинка
/// — чернеть. Пул удерживает жёсткий потолок [maxLiveControllers] и вытесняет
/// самый давно не использованный контроллер.
///
/// Владелец узнаёт о вытеснении через `onEvicted` и обязан убрать контроллер из
/// дерева: сам dispose откладывается на кадр, чтобы не отрисовать уже
/// уничтоженный плеер.
class VideoControllerPool {
  VideoControllerPool._();

  static final VideoControllerPool instance = VideoControllerPool._();

  /// Текущее + два соседа. Больше не нужно и небезопасно.
  static const int maxLiveControllers = 3;

  final Map<String, _PoolEntry> _entries = {};
  int _clock = 0;

  int get liveCount => _entries.length;

  /// Получить готовый (уже `initialize()`-нутый) контроллер.
  ///
  /// [pinned] — контроллер видимого ролика, его нельзя вытеснять.
  /// [create] вызывается только если контроллера для [key] ещё нет.
  Future<VideoPlayerController?> acquire(
    String key, {
    required VideoControllerFactory create,
    bool pinned = false,
    VoidCallback? onEvicted,
  }) {
    final existing = _entries[key];
    if (existing != null) {
      existing.lastUsed = ++_clock;
      if (pinned) existing.pinned = true;
      if (onEvicted != null) existing.onEvicted = onEvicted;
      return existing.future;
    }

    final entry = _PoolEntry(
      key: key,
      pinned: pinned,
      onEvicted: onEvicted,
      lastUsed: ++_clock,
    );
    _entries[key] = entry;
    entry.future = _create(entry, create);

    _evictIfNeeded(protect: key);
    return entry.future;
  }

  Future<VideoPlayerController?> _create(
    _PoolEntry entry,
    VideoControllerFactory create,
  ) async {
    try {
      final controller = await create();

      // Пока шла загрузка источника, запись могли освободить.
      if (entry.released) {
        await controller.dispose();
        return null;
      }
      entry.controller = controller;

      await controller.initialize();

      if (entry.released) {
        await controller.dispose();
        entry.controller = null;
        return null;
      }
      return controller;
    } catch (e) {
      debugPrint('❌ Не удалось создать плеер [${entry.key}]: $e');
      _entries.remove(entry.key);
      final orphan = entry.controller;
      entry.controller = null;
      unawaited(orphan?.dispose());
      return null;
    }
  }

  /// Пометить контроллер как незаменимый (текущий ролик) или отпустить обратно
  /// в кандидаты на вытеснение.
  void setPinned(String key, bool pinned) {
    final entry = _entries[key];
    if (entry == null) return;
    entry.pinned = pinned;
    if (pinned) entry.lastUsed = ++_clock;
  }

  /// Отметить обращение — контроллер уходит в конец очереди на вытеснение.
  void touch(String key) {
    _entries[key]?.lastUsed = ++_clock;
  }

  bool contains(String key) => _entries.containsKey(key);

  /// Освободить контроллер по инициативе владельца. `onEvicted` не вызывается.
  Future<void> release(String key) async {
    final entry = _entries.remove(key);
    if (entry == null) return;
    await _disposeEntry(entry, notify: false);
  }

  /// Освободить всё, кроме перечисленных ключей.
  Future<void> releaseAllExcept(Set<String> keys) async {
    final doomed = _entries.keys.where((k) => !keys.contains(k)).toList();
    for (final key in doomed) {
      await release(key);
    }
  }

  Future<void> releaseAll() async {
    final keys = _entries.keys.toList();
    for (final key in keys) {
      await release(key);
    }
  }

  /// Поставить на паузу всё, кроме перечисленного (сворачивание приложения).
  Future<void> pauseAllExcept(Set<String> keys) async {
    for (final entry in _entries.values) {
      if (keys.contains(entry.key)) continue;
      final controller = entry.controller;
      if (controller != null && controller.value.isPlaying) {
        await controller.pause();
      }
    }
  }

  void _evictIfNeeded({required String protect}) {
    while (_entries.length > maxLiveControllers) {
      _PoolEntry? victim;
      for (final entry in _entries.values) {
        if (entry.key == protect || entry.pinned) continue;
        if (victim == null || entry.lastUsed < victim.lastUsed) {
          victim = entry;
        }
      }
      if (victim == null) break; // всё закреплено — вытеснять нечего

      _entries.remove(victim.key);
      if (kDebugMode) debugPrint('♻️ Плеер вытеснен из пула: ${victim.key}');
      unawaited(_disposeEntry(victim, notify: true));
    }
  }

  Future<void> _disposeEntry(_PoolEntry entry, {required bool notify}) async {
    entry.released = true;
    if (notify) entry.onEvicted?.call();

    final controller = entry.controller;
    entry.controller = null;
    if (controller == null) return;

    if (notify) {
      // Владелец уже получил сигнал, но кадр с этим контроллером ещё может
      // быть на экране. Даём ему уйти, прежде чем уничтожать плеер.
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }

    try {
      await controller.pause();
    } catch (_) {
      // Контроллер мог не успеть инициализироваться.
    }
    await controller.dispose();
  }
}

class _PoolEntry {
  final String key;
  late Future<VideoPlayerController?> future;
  VideoPlayerController? controller;
  VoidCallback? onEvicted;
  bool pinned;
  bool released = false;
  int lastUsed;

  _PoolEntry({
    required this.key,
    required this.pinned,
    required this.lastUsed,
    this.onEvicted,
  });
}
