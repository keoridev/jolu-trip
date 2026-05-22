import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/features/reels/data/data.dart';
import 'package:video_player/video_player.dart';

class ReelVideoItem extends StatefulWidget {
  final ReelModel reel;
  final bool isCurrent;

  const ReelVideoItem({super.key, required this.reel, required this.isCurrent});

  @override
  State<ReelVideoItem> createState() => _ReelVideoItemState();
}

class _ReelVideoItemState extends State<ReelVideoItem> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() async {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.reel.videoUrl),
    );
    try {
      await _controller.initialize();
      await _controller.setLooping(true);
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        if (widget.isCurrent) {
          _controller.play();
        }
      }
    } catch (e) {
      debugPrint("Ошибка инициализации видео: $e");
    }
  }

  @override
  void didUpdateWidget(covariant ReelVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isInitialized) {
      if (widget.isCurrent && !_controller.value.isPlaying) {
        _controller.play();
      } else if (!widget.isCurrent && _controller.value.isPlaying) {
        _controller.pause();
        _controller.seekTo(Duration.zero); // Сбрасываем видео при перелистывании
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isInitialized) {
          _controller.value.isPlaying
              ? _controller.pause()
              : _controller.play();
        }
      },
      child: SizedBox.expand(
        child: Container(
          color: AppColors.bgDark,
          child: _isInitialized
              ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(widget.reel.thumbnailUrl, fit: BoxFit.cover),
                    const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}