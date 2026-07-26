import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/cache/video_cache_manager.dart';
import 'package:jolutrip_app/core/cache/video_prefetch_queue.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/video/video_controller_pool.dart';
import 'package:jolutrip_app/features/reels/data/data.dart';
import 'package:video_player/video_player.dart';

class ReelVideoItem extends StatefulWidget {
  final ReelModel reel;

  /// Ролик на экране — играет и закреплён в пуле.
  final bool isCurrent;

  /// Следующий по ходу листания: заранее поднимаем плеер, чтобы переход
  /// был без чёрного кадра.
  final bool shouldWarmUp;

  final VoidCallback? onLike;

  const ReelVideoItem({
    super.key,
    required this.reel,
    required this.isCurrent,
    this.shouldWarmUp = false,
    this.onLike,
  });

  @override
  State<ReelVideoItem> createState() => ReelVideoItemState();
}

class ReelVideoItemState extends State<ReelVideoItem> {
  /// Сколько ждём докачки в кэш, прежде чем стартовать стримингом с сети.
  /// Меньше — быстрее старт, больше — чаще играем с диска.
  static const Duration _instantStartWindow = Duration(milliseconds: 700);

  VideoPlayerController? _controller;

  /// Отсекает результаты устаревших асинхронных инициализаций: пока грузился
  /// источник, ролик мог уехать с экрана или быть уничтожен.
  int _activationToken = 0;

  bool _isBuffering = false;
  bool _playsFromCache = false;
  bool _hasError = false;
  bool _isPaused = false;
  bool _isFastForwarding = false;
  bool _showLikeHeart = false;
  double _heartScale = 0.0;

  /// Позиция на момент вытеснения из пула — чтобы вернуться туда же.
  Duration _lastPosition = Duration.zero;

  String get _poolKey => 'reel_${widget.reel.id}';
  String get _videoUrl => widget.reel.videoUrl;
  bool get _isReady => _controller != null;

  @override
  void initState() {
    super.initState();
    if (widget.isCurrent) {
      _activate(autoplay: true);
    } else if (widget.shouldWarmUp) {
      _activate(autoplay: false);
    } else {
      prefetch();
    }
  }

  @override
  void didUpdateWidget(covariant ReelVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.reel.id != oldWidget.reel.id) {
      _releaseController(oldKey: 'reel_${oldWidget.reel.id}');
      _lastPosition = Duration.zero;
      if (widget.isCurrent) {
        _activate(autoplay: true);
      } else if (widget.shouldWarmUp) {
        _activate(autoplay: false);
      }
      return;
    }

    if (widget.isCurrent && !oldWidget.isCurrent) {
      _activate(autoplay: true);
    } else if (!widget.isCurrent && oldWidget.isCurrent) {
      _deactivate();
    } else if (widget.shouldWarmUp && !oldWidget.shouldWarmUp && !_isReady) {
      _activate(autoplay: false);
    }
  }

  @override
  void dispose() {
    _activationToken++;
    _detachListener();
    _controller = null;
    VideoCacheManager.unpin(_videoUrl);
    unawaited(VideoControllerPool.instance.release(_poolKey));
    super.dispose();
  }

  // ==========================================================
  // Жизненный цикл плеера
  // ==========================================================

  /// Только качает байты в кэш — без плеера и без декодера.
  void prefetch() {
    if (_videoUrl.isEmpty) return;
    unawaited(VideoPrefetchQueue.instance.enqueue(_videoUrl, priority: 3));
  }

  Future<void> _activate({required bool autoplay}) async {
    if (_videoUrl.isEmpty) {
      if (mounted) setState(() => _hasError = true);
      return;
    }

    final token = ++_activationToken;

    // Контроллер уже есть — просто снимаем с паузы.
    if (_controller != null) {
      VideoControllerPool.instance.setPinned(_poolKey, autoplay);
      if (autoplay) await _play();
      return;
    }

    if (!_isBuffering) setState(() => _isBuffering = true);

    final controller = await VideoControllerPool.instance.acquire(
      _poolKey,
      pinned: autoplay,
      onEvicted: _handleEviction,
      create: () => _createController(autoplay: autoplay),
    );

    if (!mounted || token != _activationToken) {
      // Пока грузились — ролик уехал. Пул сам вытеснит незакреплённый плеер.
      return;
    }

    if (controller == null) {
      setState(() {
        _isBuffering = false;
        _hasError = true;
      });
      return;
    }

    _controller = controller;
    controller.addListener(_onControllerUpdate);
    await controller.setLooping(true);

    if (_lastPosition > Duration.zero) {
      await controller.seekTo(_lastPosition);
    }

    if (!mounted || token != _activationToken) return;

    setState(() {
      _isBuffering = false;
      _hasError = false;
    });

    if (widget.isCurrent) {
      await _play();
    } else {
      await controller.pause();
    }
  }

  Future<VideoPlayerController> _createController({
    required bool autoplay,
  }) async {
    // Соседний ролик не рвётся на экран — ему можно подождать кэш подольше
    // и не тратить трафик на второй, сетевой источник.
    final File? file = await VideoPrefetchQueue.instance.fileForPlayback(
      _videoUrl,
      waitForCache: autoplay
          ? _instantStartWindow
          : const Duration(seconds: 25),
    );

    if (file != null) {
      _playsFromCache = true;
      // Пока плеер держит файл открытым, LRU не имеет права его удалить.
      VideoCacheManager.pin(_videoUrl);
      return VideoPlayerController.file(file);
    }

    // Кэш не успел — стартуем с сети, чтобы не держать зрителя на заглушке,
    // а загрузка в кэш продолжается в фоне для следующего просмотра.
    _playsFromCache = false;
    return VideoPlayerController.networkUrl(Uri.parse(_videoUrl));
  }

  Future<void> _play() async {
    final controller = _controller;
    if (controller == null) return;
    VideoControllerPool.instance.touch(_poolKey);
    await controller.play();
    if (mounted && _isPaused) setState(() => _isPaused = false);
  }

  /// Ролик ушёл с экрана: останавливаем, перематываем в начало и снимаем
  /// закрепление — теперь пул вправе вытеснить его декодер.
  Future<void> _deactivate() async {
    VideoControllerPool.instance.setPinned(_poolKey, false);
    final controller = _controller;
    if (controller == null) return;

    await controller.pause();
    await controller.seekTo(Duration.zero);
    _lastPosition = Duration.zero;
    if (mounted) setState(() => _isPaused = false);
  }

  void _handleEviction() {
    _detachListener();
    _controller = null;
    VideoCacheManager.unpin(_videoUrl);
    if (mounted) {
      setState(() {
        _isBuffering = false;
        _isPaused = false;
      });
    }
  }

  void _detachListener() {
    _controller?.removeListener(_onControllerUpdate);
  }

  void _releaseController({String? oldKey}) {
    _activationToken++;
    _detachListener();
    _controller = null;
    VideoCacheManager.unpin(_videoUrl);
    unawaited(VideoControllerPool.instance.release(oldKey ?? _poolKey));
  }

  void _onControllerUpdate() {
    final controller = _controller;
    if (!mounted || controller == null) return;

    final value = controller.value;
    if (value.isInitialized) _lastPosition = value.position;

    // Локальный файл «буферизуется» только на seek — спиннер тут только мешает.
    final showSpinner = value.isBuffering && !_playsFromCache;
    if (showSpinner != _isBuffering) {
      setState(() => _isBuffering = showSpinner);
    }
  }

  // ==========================================================
  // Публичное API для экрана ленты
  // ==========================================================

  /// Пауза без уничтожения декодера — уход в фон, переключение вкладки.
  void pauseVideo() {
    final controller = _controller;
    if (controller == null) return;
    unawaited(controller.pause());
    if (mounted) setState(() => _isPaused = true);
  }

  /// Возврат на экран. Контроллер жив — играем сразу, иначе поднимаем заново.
  void resumeVideo() {
    if (!widget.isCurrent) return;
    if (_controller != null) {
      unawaited(_play());
    } else {
      unawaited(_activate(autoplay: true));
    }
  }

  /// Полностью освободить декодер (уход с экрана ленты, сворачивание).
  void releaseVideo() => _releaseController();

  void handleTap() {
    final controller = _controller;
    if (controller == null) return;

    if (controller.value.isPlaying) {
      unawaited(controller.pause());
      setState(() => _isPaused = true);
    } else {
      unawaited(_play());
      setState(() => _isPaused = false);
    }
  }

  void handleDoubleTap() {
    if (_controller == null) return;

    widget.onLike?.call();

    setState(() {
      _showLikeHeart = true;
      _heartScale = 1.2;
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _heartScale = 1.0);
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _showLikeHeart = false;
          _heartScale = 0.0;
        });
      }
    });
  }

  void handleLongPressStart() {
    final controller = _controller;
    if (controller == null) return;
    setState(() => _isFastForwarding = true);
    unawaited(controller.setPlaybackSpeed(2.0));
  }

  void handleLongPressEnd() {
    final controller = _controller;
    if (controller == null) return;
    setState(() => _isFastForwarding = false);
    unawaited(controller.setPlaybackSpeed(1.0));
  }

  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return ColoredBox(
      color: AppColors.bgDark,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          // Постер всегда под видео: пока плеер поднимается и пока первый
          // кадр не отрисован, экран не мигает чёрным.
          ReelThumbnail(url: widget.reel.thumbnailUrl),

          if (controller != null && controller.value.isInitialized)
            _VideoSurface(controller: controller),

          if (_isBuffering) const _BufferingIndicator(),

          if (_hasError) const _PlaybackErrorBadge(),

          if (_isFastForwarding) const _SpeedBadge(),

          if (_isReady && _isPaused && !_showLikeHeart) const _PauseBadge(),

          IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _showLikeHeart ? 1.0 : 0.0,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 250),
                scale: _heartScale,
                curve: Curves.elasticOut,
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 110,
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Вспомогательные виджеты
// ============================================================

class _VideoSurface extends StatelessWidget {
  final VideoPlayerController controller;

  const _VideoSurface({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}

/// Постер ролика.
///
/// `cacheWidth` заставляет декодировать картинку под ширину экрана, а не в
/// исходном разрешении: для полноэкранных превью это разница в разы по
/// памяти на весь видимый диапазон ленты.
class ReelThumbnail extends StatelessWidget {
  final String url;

  const ReelThumbnail({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const ColoredBox(color: AppColors.cardDark);

    final media = MediaQuery.of(context);
    final cacheWidth = (media.size.width * media.devicePixelRatio).round();

    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      cacheWidth: cacheWidth,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => const ColoredBox(
        color: AppColors.cardDark,
        child: Center(
          child: Icon(
            Icons.error_outline,
            color: AppColors.textSecondary,
            size: 48,
          ),
        ),
      ),
    );
  }
}

class _BufferingIndicator extends StatelessWidget {
  const _BufferingIndicator();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.25),
      child: const Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class _PlaybackErrorBadge extends StatelessWidget {
  const _PlaybackErrorBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.videocam_off_rounded,
          size: 36,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _SpeedBadge extends StatelessWidget {
  const _SpeedBadge();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fast_forward_rounded,
              color: AppColors.primary,
              size: 16,
            ),
            SizedBox(width: 6),
            Text(
              '2.0x Ускорение',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PauseBadge extends StatelessWidget {
  const _PauseBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.play_arrow_rounded,
          size: 40,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
