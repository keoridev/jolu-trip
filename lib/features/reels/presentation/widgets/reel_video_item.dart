import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/features/reels/data/data.dart';
import 'package:video_player/video_player.dart';

class ReelVideoItem extends StatefulWidget {
  final ReelModel reel;
  final bool isCurrent;
  final Function(VideoPlayerController)? onControllerReady;

  const ReelVideoItem({
    super.key,
    required this.reel,
    required this.isCurrent,
    this.onControllerReady,
  });

  @override
  State<ReelVideoItem> createState() => ReelVideoItemState();
}

class ReelVideoItemState extends State<ReelVideoItem> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _showLikeHeart = false;
  double _hearthScale = 0.0;
  bool _isFastForwarding = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.reel.videoUrl),
    );

    try {
      await _controller!.initialize();
      await _controller!.setLooping(true);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        widget.onControllerReady?.call(_controller!);

        if (widget.isCurrent) {
          _controller!.play();
        }
      }
    } catch (e) {
      debugPrint("Ошибка инициализации видео: $e");
    }
  }

  void destroyVideo() {
    if (_controller != null) {
      _controller!.pause();
      _controller!.dispose();
      _controller = null;
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
      debugPrint('🗑️ Видео уничтожено');
    }
  }

  void rebuildVideo() {
    if (!_isInitialized && mounted) {
      _initializePlayer();
      debugPrint('🔄 Видео пересоздано');
    }
  }

  void handleDoubleTap() {
    if (_controller == null || !_isInitialized) return;

    setState(() {
      _showLikeHeart = true;
      _hearthScale = 1.2;
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _hearthScale = 1.0);
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showLikeHeart = false;
          _hearthScale = 0.0;
        });
      }
    });
  }

  void handleTap() {
    if (_controller == null || !_isInitialized) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
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
    if (_controller != null && _isInitialized) {
      if (widget.isCurrent && !_controller!.value.isPlaying) {
        _controller!.setPlaybackSpeed(1.0);
        _controller!.play();
      } else if (!widget.isCurrent && _controller!.value.isPlaying) {
        _controller!.pause();
        _controller!.seekTo(Duration.zero);
      }
    }
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
      _controller = null;
    }
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
          if (_controller != null && _isInitialized)
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
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.cardDark,
                  child: const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: AppColors.textSecondary,
                      size: 48,
                    ),
                  ),
                );
              },
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

          if (_controller != null &&
              _isInitialized &&
              !_controller!.value.isPlaying &&
              !_showLikeHeart)
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
              scale: _hearthScale,
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
