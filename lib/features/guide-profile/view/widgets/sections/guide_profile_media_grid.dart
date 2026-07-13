import 'dart:io';
import 'dart:ui'; // Обязательно для ImageFilter (BackdropFilter)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/guide-profile/domain/entities/guide_profile_entity.dart';
import 'package:jolutrip_app/features/guide-profile/view/bloc/guide_profile_cubit.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GuideProfileMediaGrid extends StatelessWidget {
  final GuideProfileEntity profile;
  final VoidCallback? onEditVideo;

  const GuideProfileMediaGrid({
    super.key,
    required this.profile,
    this.onEditVideo,
  });

  @override
  Widget build(BuildContext context) {
    final videoUrl = profile.presentationVideoUrl;
    final hasVideo = videoUrl != null && videoUrl.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppDimens.screenPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('Видео-визитка', style: AppTextStyles.subtitle),
              // Показываем кнопку в шапке ТОЛЬКО если видео уже есть (для замены)
              if (profile.canEdit && hasVideo)
                TextButton(
                  onPressed: onEditVideo, // ← ИСПОЛЬЗУЕМ колбэк вместо прямого вызова
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Заменить',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.space12),
        Padding(
          padding: AppDimens.screenPadding,
          child: hasVideo
              ? _InlineVideoPlayer(videoUrl: videoUrl)
              : _EmptyVideoCard(
                  canEdit: profile.canEdit,
                  onTap: () => _pickVideo(context),
                ),
        ),
      ],
    );
  }

  Future<void> _pickVideo(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 2),
    );

    if (pickedFile != null && context.mounted) {
      final bytes = await File(pickedFile.path).readAsBytes();
      context.read<GuideProfileCubit>().updatePresentationVideo(bytes);
    }
  }
}

/// ============================================================
/// ВИДЕО ПЛЕЕР С ЗАПУСКОМ НА МЕСТЕ
/// ============================================================

class _InlineVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const _InlineVideoPlayer({required this.videoUrl});

  @override
  State<_InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<_InlineVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isPlaying = false;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _initController();
  }

  Future<void> _initController() async {
    try {
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.setVolume(1.0);

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('❌ Video init error: $e');
      if (mounted) setState(() => _hasError = true);
    }
  }

  void _togglePlay() {
    if (!_isInitialized) return;

    if (_controller.value.isPlaying) {
      _controller.pause();
      setState(() => _isPlaying = false);
    } else {
      _controller.play();
      setState(() => _isPlaying = true);
    }
  }

  void _enterFullscreen() async {
    setState(() => _isFullscreen = true);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _exitFullscreen() async {
    setState(() => _isFullscreen = false);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_isFullscreen) _exitFullscreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusL),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: AppColors.bgElevated, // Более глубокий темный цвет
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_isInitialized && !_hasError) VideoPlayer(_controller),

              // Постер (первый кадр видео, если инициализировано, но не играет)
              if (!_isPlaying || !_isInitialized) _buildPosterGradient(),

              // Кнопка Play (эффект матового стекла)
              if (!_isPlaying && !_hasError && _isInitialized)
                Center(
                  child: _buildGlassButton(
                    onTap: _togglePlay,
                    icon: Icons.play_arrow_rounded,
                    size: 64,
                    iconSize: 36,
                  ),
                ),

              // Контролы с плавным появлением
              AnimatedOpacity(
                opacity: (_isPlaying && !_hasError) ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: _isPlaying
                    ? _buildControlsOverlay()
                    : const SizedBox.shrink(),
              ),

              if (_hasError) _buildErrorState(),
              if (!_isInitialized && !_hasError) _buildLoadingState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPosterGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
          stops: const [0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return GestureDetector(
      onTap: _togglePlay, // Пауза по клику на любую область
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Нижняя панель с градиентом для читаемости
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Expanded(child: _VideoProgressBar(controller: _controller)),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: _enterFullscreen,
                    child: const Icon(
                      Icons.fullscreen_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required VoidCallback onTap,
    required IconData icon,
    double size = 56,
    double iconSize = 28,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: iconSize),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.white54, size: 40),
          SizedBox(height: 8),
          Text(
            'Ошибка загрузки',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );
  }
}

/// ============================================================
/// ПРОГРЕСС-БАР (Безопасный LayoutBuilder)
/// ============================================================

class _VideoProgressBar extends StatefulWidget {
  final VideoPlayerController controller;

  const _VideoProgressBar({required this.controller});

  @override
  State<_VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<_VideoProgressBar> {
  bool _isDragging = false;
  double _dragProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, value, child) {
        final duration = value.duration.inMilliseconds;
        final position = value.position.inMilliseconds;

        final progress = duration > 0
            ? (_isDragging ? _dragProgress : (position / duration))
            : 0.0;

        return LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;

            void updatePosition(Offset localPosition) {
              final newProgress = (localPosition.dx / maxWidth).clamp(0.0, 1.0);
              setState(() => _dragProgress = newProgress);
            }

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (details) {
                setState(() => _isDragging = true);
                updatePosition(details.localPosition);
              },
              onHorizontalDragUpdate: (details) =>
                  updatePosition(details.localPosition),
              onHorizontalDragEnd: (_) {
                widget.controller.seekTo(
                  Duration(milliseconds: (_dragProgress * duration).toInt()),
                );
                setState(() => _isDragging = false);
              },
              onTapDown: (details) {
                updatePosition(details.localPosition);
                widget.controller.seekTo(
                  Duration(milliseconds: (_dragProgress * duration).toInt()),
                );
              },
              child: Container(
                height: 24, // Более широкая зона для тапа (хитбокс)
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  clipBehavior: Clip.none,
                  children: [
                    // Фон
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Заполненный прогресс
                    Container(
                      height: 4,
                      width: maxWidth * progress,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Ползунок (Thumb) позиционируется безопасно относительно maxWidth
                    Positioned(
                      left: (maxWidth * progress) - 6,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// ============================================================
/// EMPTY STATE (Активная зона загрузки)
/// ============================================================

class _EmptyVideoCard extends StatelessWidget {
  final bool canEdit;
  final VoidCallback onTap;

  const _EmptyVideoCard({required this.canEdit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: canEdit ? onTap : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: AppColors.bgElevated,
            // Пунктирная граница или мягкий stroke (если есть пакет dotted_border — используй его)
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1.5,
                // Для пунктира лучше использовать сторонний пакет, но пока имитируем бордером
              ),
              borderRadius: BorderRadius.circular(AppDimens.radiusL),
              color: AppColors.primary.withValues(alpha: 0.05), // Мягкий tint
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    canEdit
                        ? Icons.video_call_rounded
                        : Icons.videocam_off_rounded,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  canEdit ? 'Добавить видео-визитку' : 'Нет видео-визитки',
                  style: AppTextStyles.body.copyWith(
                    color: canEdit
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (canEdit) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Расскажите туристам о себе (до 2 мин)',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
