import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/features/reels/data/models/model.dart';
import 'package:jolutrip_app/features/reels/presentation/widgets/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/reels/cubit/reels_cubit.dart';
import 'package:jolutrip_app/features/reels/cubit/reels_state.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> with WidgetsBindingObserver {
  late final PageController _pageController;
  int _currentIndex = 0;
  bool _isScreenVisible = true;

  final Map<int, GlobalKey<ReelVideoItemState>> _playerKeys = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _destroyAllVideos();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _pauseAllVideos();
        break;
      case AppLifecycleState.resumed:
        if (_isScreenVisible) _resumeCurrentVideo();
        break;
      case AppLifecycleState.inactive:
        // Шторка — не трогаем
        debugPrint('📱 inactive (шторка) — игнорируем');
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _pauseAllVideos();
        break;
    }
  }

  void _pauseAllVideos() {
    for (final entry in _playerKeys.entries) {
      entry.value.currentState?.destroyVideo();
    }
    _playerKeys.clear();
  }

  void _resumeCurrentVideo() {
    final key = _playerKeys[_currentIndex];
    if (key != null && mounted) {
      key.currentState?.rebuildVideo();
    }
  }

  void _destroyAllVideos() {
    for (final key in _playerKeys.values) {
      key.currentState?.destroyVideo();
    }
    _playerKeys.clear();
  }

  /// 🔥 Предзагрузка следующих 2 видео
  void _prefetchVideos(List<ReelModel> reels, int currentIndex) {
    for (int i = currentIndex + 1; i <= currentIndex + 2; i++) {
      if (i >= reels.length) break;

      final key = _playerKeys[i];
      if (key != null) {
        // Уже создан — запускаем предзагрузку
        key.currentState?.preloadVideo();
      }
      // Если ещё не создано — кэш менеджер подтянет при создании
    }
  }

  void _cleanupDistantVideos() {
    final keysToRemove = <int>[];
    for (final index in _playerKeys.keys) {
      if ((index - _currentIndex).abs() > 2) {
        _playerKeys[index]?.currentState?.destroyVideo();
        keysToRemove.add(index);
      }
    }
    for (final index in keysToRemove) {
      _playerKeys.remove(index);
    }
  }

  GlobalKey<ReelVideoItemState> _getKeyForIndex(int index) {
    _playerKeys[index] ??= GlobalKey<ReelVideoItemState>();
    return _playerKeys[index]!;
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('reels_screen'),
      onVisibilityChanged: (info) {
        final isVisible = info.visibleFraction > 0.01;
        if (_isScreenVisible == isVisible) return;

        _isScreenVisible = isVisible;
        if (!isVisible) {
          _pauseAllVideos();
        } else {
          _resumeCurrentVideo();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.black,
        ),
        child: Scaffold(
          backgroundColor: AppColors.bgDark,
          body: BlocBuilder<ReelsCubit, ReelsState>(
            builder: (context, state) {
              return switch (state) {
                ReelsLoading() => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),

                ReelsLoaded(reels: final reels) =>
                  reels.isEmpty
                      ? Center(
                          child: Text(
                            'На данный момент экспедиций не найдено.',
                            style: AppTextStyles.body,
                          ),
                        )
                      : PageView.builder(
                          controller: _pageController,
                          scrollDirection: Axis.vertical,
                          itemCount: reels.length,
                          onPageChanged: (index) {
                            setState(() => _currentIndex = index);
                            context.read<ReelsCubit>().setCurrentIndex(index);

                            // 🔥 Предзагрузка следующих
                            _prefetchVideos(reels, index);
                            _cleanupDistantVideos();
                          },
                          itemBuilder: (context, index) {
                            final reel = reels[index];
                            final isCurrent = index == _currentIndex;
                            final isNeighbor =
                                (index - _currentIndex).abs() <= 1;

                            if (!isCurrent && !isNeighbor) {
                              return _StaticReelPreview(reel: reel);
                            }

                            final playerKey = _getKeyForIndex(index);

                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => playerKey.currentState?.handleTap(),
                              onDoubleTap: () =>
                                  playerKey.currentState?.handleDoubleTap(),
                              onLongPressStart: (_) => playerKey.currentState
                                  ?.handleLongPressStart(),
                              onLongPressEnd: (_) =>
                                  playerKey.currentState?.handleLongPressEnd(),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ReelVideoItem(
                                    key: playerKey,
                                    reel: reel,
                                    isCurrent: isCurrent,
                                    onLike: () {
                                      JoluSnackbar.show(
                                        context: context,
                                        message: 'Добавлено в избранное',
                                        type: JoluSnackbarType.success,
                                        duration: const Duration(seconds: 2),
                                      );
                                    },
                                  ),
                                  const Positioned.fill(
                                    child: IgnorePointer(
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.black26,
                                              Colors.transparent,
                                              Colors.black87,
                                            ],
                                            stops: [0.0, 0.5, 1.0],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  ReelInfoOverlay(
                                    reel: reel,
                                    onLikePressed: () => playerKey.currentState
                                        ?.handleDoubleTap(),
                                    onBookPressed: () {
                                      debugPrint(
                                        "📌 Бронирование: ${reel.name}",
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                ReelsError(message: final msg) => _ErrorView(
                  message: msg,
                  onRetry: () => context.read<ReelsCubit>().loadReels(),
                ),

                _ => const SizedBox.shrink(),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _StaticReelPreview extends StatelessWidget {
  final ReelModel reel;
  const _StaticReelPreview({required this.reel});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          reel.thumbnailUrl,
          fit: BoxFit.cover,
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
        Container(color: Colors.black.withOpacity(0.4)),
        Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimens.spaceM),
            Text(
              'Не удалось загрузить ленту',
              style: AppTextStyles.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.spaceXS),
            Text(
              message,
              style: AppTextStyles.subtext,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.spaceL),
            JoluButton(
              text: 'Повторить попытку',
              variant: JoluButtonVariant.primary,
              isFullWidth: true,
              leadingIcon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
