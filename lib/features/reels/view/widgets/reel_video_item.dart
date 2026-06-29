import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/cache/video_cache_manager.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/features/reels/data/data.dart';
import 'package:video_player/video_player.dart';

class ReelVideoItem extends StatefulWidget {
  final ReelModel reel;
  final bool isCurrent;
  final VoidCallback? onLike;

  const ReelVideoItem({
    super.key,
    required this.reel,
    required this.isCurrent,
    this.onLike,
  });

  @override
  State<ReelVideoItem> createState() => ReelVideoItemState();
}

class ReelVideoItemState extends State<ReelVideoItem> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isBuffering = false;
  bool _isCached = false;
  bool _showLikeHeart = false;
  double _heartScale = 0.0;
  bool _isFastForwarding = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    if (widget.isCurrent) {
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    if (_controller != null) return;

    final videoUrl = widget.reel.videoUrl;
    setState(() => _isBuffering = true);

    try {
      final file = await _getVideoWithRetry(videoUrl);
      _isCached = true;
      debugPrint('📦 Cache HIT: ${widget.reel.name}');
      await _setupController(file.path, isLocal: true);
    } catch (e) {
      debugPrint('⚠️ Fallback на network: $e');
      _isCached = false;
      await _setupController(videoUrl, isLocal: false);
    }
  }

  Future<File> _getVideoWithRetry(
    String videoUrl, {
    int maxAttempts = 3,
  }) async {
    Duration delay = const Duration(milliseconds: 500);

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final file = await VideoCacheManager.instance
            .getSingleFile(videoUrl)
            .timeout(Duration(seconds: 10 + (attempt * 3)));

        return file;
      } catch (e) {
        debugPrint('⚠️ Попытка ${attempt + 1}/$maxAttempts не удалась: $e');

        if (attempt < maxAttempts - 1) {
          await Future.delayed(delay);
          delay *= 2; // exponential backoff
        } else {
          rethrow;
        }
      }
    }
    throw Exception('Не удалось загрузить видео после $maxAttempts попыток');
  }

  Future<void> preloadVideo() async {
    if (_controller != null || _isInitialized) return;

    final videoUrl = widget.reel.videoUrl;

    try {
      final file = await VideoCacheManager.instance
          .getSingleFile(videoUrl)
          .timeout(const Duration(seconds: 15));

      _isCached = true;
      await _setupController(file.path, isLocal: true);

      if (mounted && !widget.isCurrent) {
        _controller?.pause();
      }
      debugPrint('🚀 Preloaded: ${widget.reel.name}');
    } catch (e) {
      debugPrint('⚠️ Preload failed [${widget.reel.name}]: $e');
    }
  }

  Future<void> _setupController(
    String pathOrUrl, {
    required bool isLocal,
  }) async {
    try {
      if (isLocal) {
        _controller = VideoPlayerController.file(File(pathOrUrl));
      } else {
        _controller = VideoPlayerController.networkUrl(Uri.parse(pathOrUrl));
      }

      await _controller!.initialize();
      await _controller!.setLooping(true);
      _controller!.addListener(_onControllerUpdate);

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isBuffering = false;
        });

        if (widget.isCurrent) {
          _controller!.play();
          _isPaused = false;
        }
      }
    } catch (e) {
      debugPrint("❌ Ошибка плеера [${widget.reel.name}]: $e");
      if (mounted) setState(() => _isBuffering = false);
    }
  }

  void _onControllerUpdate() {
    if (!mounted || _controller == null) return;

    final isBuffering = _controller!.value.isBuffering;

    if (_isCached && isBuffering) return;

    if (isBuffering != _isBuffering) {
      setState(() => _isBuffering = isBuffering);
    }
  }

  void _disposeController() {
    if (_controller == null) return;

    _controller!.removeListener(_onControllerUpdate);
    _controller!.pause();
    _controller!.dispose();
    _controller = null;

    if (mounted) {
      setState(() {
        _isInitialized = false;
        _isBuffering = false;
        _isPaused = false;
      });
    }
    debugPrint('🗑️ Видео уничтожено: ${widget.reel.name}');
  }

  void destroyVideo() => _disposeController();

  void rebuildVideo() {
    if (!widget.isCurrent) return;

    if (_isInitialized && _controller != null) {
      _controller!.play();
      setState(() => _isPaused = false);
      debugPrint('▶️ Возобновлено (контроллер жив): ${widget.reel.name}');
      return;
    }

    debugPrint('🔄 Переинициализация: ${widget.reel.name}');
    _initializePlayer();
  }

  void handleTap() {
    if (_controller == null || !_isInitialized) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _isPaused = true;
      } else {
        _controller!.play();
        _isPaused = false;
      }
    });
  }

  void handleDoubleTap() {
    if (_controller == null || !_isInitialized) return;

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
    if (_controller == null || !_isInitialized) return;
    setState(() => _isFastForwarding = true);
    _controller!.setPlaybackSpeed(2.0);
  }

  void handleLongPressEnd() {
    if (_controller == null || !_isInitialized) return;
    setState(() => _isFastForwarding = false);
    _controller!.setPlaybackSpeed(1.0);
  }

  @override
  void didUpdateWidget(covariant ReelVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!mounted) return;

    if (widget.isCurrent && !oldWidget.isCurrent) {
      if (_isInitialized) {
        _controller?.play();
        setState(() => _isPaused = false);
      } else {
        _initializePlayer();
      }
    } else if (!widget.isCurrent && oldWidget.isCurrent) {
      if (_isInitialized) {
        _controller?.pause();
        _controller?.seekTo(Duration.zero);
        setState(() => _isPaused = false);
      }
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgDark,
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          if (_isInitialized && _controller != null)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            )
          else
            Image.network(
              widget.reel.thumbnailUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.cardDark,
                child: const Center(
                  child: Icon(
                    Icons.error_outline,
                    color: AppColors.textSecondary,
                    size: 48,
                  ),
                ),
              ),
            ),

          if (_isBuffering && !_isCached)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),

          if (_isFastForwarding)
            Positioned(
              top: 60,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
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
            ),

          if (_isInitialized && _isPaused && !_showLikeHeart)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 40,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

          AnimatedOpacity(
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
        ],
      ),
    );
  }
}
