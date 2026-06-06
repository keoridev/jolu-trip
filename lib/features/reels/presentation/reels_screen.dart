// lib/features/reels/presentation/reels_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/reels/cubit/reels_cubit.dart';
import 'package:jolutrip_app/features/reels/cubit/reels_state.dart';
import 'widgets/reel_video_item.dart';
import 'widgets/reel_info_overlay.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> with WidgetsBindingObserver {
  late final PageController _pageController;
  int _currentIndex = 0;
  bool _isVisible = true;

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
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _destroyAllVideos();
    } else if (state == AppLifecycleState.resumed && _isVisible) {
      _rebuildCurrentVideo();
    }
  }

  void _destroyAllVideos() {
    for (final key in _playerKeys.values) {
      key.currentState?.destroyVideo();
    }
  }

  void _rebuildCurrentVideo() {
    final currentKey = _playerKeys[_currentIndex];
    if (currentKey != null && mounted) {
      currentKey.currentState?.rebuildVideo();
    }
  }

  GlobalKey<ReelVideoItemState> _getKeyForIndex(int index) {
    if (!_playerKeys.containsKey(index)) {
      _playerKeys[index] = GlobalKey<ReelVideoItemState>();
    }
    return _playerKeys[index]!;
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('reels_screen'),
      onVisibilityChanged: (info) {
        final isVisible = info.visibleFraction > 0.01;
        if (_isVisible != isVisible) {
          _isVisible = isVisible;
          if (!_isVisible) {
            debugPrint('👁️ ReelsScreen НЕ виден - уничтожаем все видео');
            _destroyAllVideos();
          } else {
            debugPrint('👁️ ReelsScreen виден - восстанавливаем текущее видео');
            _rebuildCurrentVideo();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: BlocBuilder<ReelsCubit, ReelsState>(
          builder: (context, state) {
            if (state is ReelsLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }

            if (state is ReelsLoaded) {
              if (state.reels.isEmpty) {
                return Center(
                  child: Text(
                    'На данный момент экспедиций не найдено.',
                    style: AppTextStyles.body,
                  ),
                );
              }

              return PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: state.reels.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  context.read<ReelsCubit>().setCurrentIndex(index);
                },
                itemBuilder: (context, index) {
                  final reel = state.reels[index];
                  final playerKey = _getKeyForIndex(index);
                  final isCurrent = index == _currentIndex;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      playerKey.currentState?.handleTap();
                    },
                    onDoubleTap: () {
                      playerKey.currentState?.handleDoubleTap();
                    },
                    onLongPressStart: (_) {
                      playerKey.currentState?.handleLongPressStart();
                    },
                    onLongPressEnd: (_) {
                      playerKey.currentState?.handleLongPressEnd();
                    },
                    child: Stack(
                      children: [
                        ReelVideoItem(
                          key: playerKey,
                          reel: reel,
                          isCurrent: isCurrent && _isVisible,
                          onControllerReady: (controller) {
                            context.read<ReelsCubit>().registerVideoController(
                              index,
                              controller,
                            );
                          },
                        ),
                        Positioned.fill(
                          child: const IgnorePointer(
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
                          onLikePressed: () {
                            playerKey.currentState?.handleDoubleTap();

                            JoluSnackbar.show(
                              context: context,
                              message: 'Добавлено в избранное',
                              type: JoluSnackbarType.success,
                              duration: const Duration(microseconds: 8000),
                            );
                          },
                          onBookPressed: () {
                            debugPrint("Нажали подробнее для ${reel.name}");
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }

            if (state is ReelsError) {
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
                        state.message,
                        style: AppTextStyles.subtext,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimens.spaceL),
                      ElevatedButton(
                        onPressed: () => context.read<ReelsCubit>().loadReels(),
                        child: const Text('Повторить попытку'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
