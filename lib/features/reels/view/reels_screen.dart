import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/reels/view/bloc/reels_cubit.dart';
import 'package:jolutrip_app/features/reels/view/bloc/reels_state.dart';
import 'package:jolutrip_app/features/reels/data/data.dart';
import 'package:jolutrip_app/features/reels/view/widgets/widgets.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final PageController _pageController;
  int _currentIndex = 0;
  bool _isScreenVisible = true;

  final Map<int, GlobalKey<ReelVideoItemState>> _playerKeys = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ReelsCubit>().loadReels();
      }
    });
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
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _pauseAllVideos();
        break;
      case AppLifecycleState.resumed:
        if (_isScreenVisible) _resumeCurrentVideo();
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  void _pauseAllVideos() {
    for (final entry in _playerKeys.entries) {
      entry.value.currentState?.destroyVideo();
    }
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

  void _prefetchVideos(List<ReelModel> reels, int currentIndex) {
    for (int i = currentIndex + 1; i <= currentIndex + 2; i++) {
      if (i >= reels.length) break;
      final key = _playerKeys[i];
      if (key != null) {
        key.currentState?.preloadVideo();
      }
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

  Future<void> _onRefresh() async {
    _destroyAllVideos();
    await context.read<ReelsCubit>().refreshReels();
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    if (mounted) {
      setState(() => _currentIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                      ? _EmptyView(onRefresh: _onRefresh)
                      : _ReelsView(
                          reels: reels,
                          currentIndex: _currentIndex,
                          pageController: _pageController,
                          onRefresh: _onRefresh,
                          onPageChanged: (index) {
                            setState(() => _currentIndex = index);
                            context.read<ReelsCubit>().setCurrentIndex(index);
                            _prefetchVideos(reels, index);
                            _cleanupDistantVideos();
                          },
                          getKeyForIndex: _getKeyForIndex,
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

// ============================================================
// 🔥 ОСНОВНОЙ ВИДЖЕТ С PULL-TO-REFRESH
// ============================================================

class _ReelsView extends StatefulWidget {
  final List<ReelModel> reels;
  final int currentIndex;
  final PageController pageController;
  final Future<void> Function() onRefresh;
  final ValueChanged<int> onPageChanged;
  final GlobalKey<ReelVideoItemState> Function(int) getKeyForIndex;

  const _ReelsView({
    required this.reels,
    required this.currentIndex,
    required this.pageController,
    required this.onRefresh,
    required this.onPageChanged,
    required this.getKeyForIndex,
  });

  @override
  State<_ReelsView> createState() => _ReelsViewState();
}

class _ReelsViewState extends State<_ReelsView> {
  bool _isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Детектируем overscroll вверх для pull-to-refresh
        if (notification is ScrollStartNotification) {
          // Начало скролла
        }
        return false;
      },
      child: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.cardDark,
        strokeWidth: 3,
        displacement: 80,
        edgeOffset: 0,
        onRefresh: () async {
          if (_isRefreshing) return;
          setState(() => _isRefreshing = true);
          await widget.onRefresh();
          if (mounted) setState(() => _isRefreshing = false);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 🔥 Sliver для pull-to-refresh — пустой, но занимает место
            SliverToBoxAdapter(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _isRefreshing ? 60 : 0,
                child: _isRefreshing
                    ? Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Обновление...',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : null,
              ),
            ),
            // 🔥 PageView на весь экран
            SliverFillRemaining(
              hasScrollBody: true,
              child: PageView.builder(
                controller: widget.pageController,
                scrollDirection: Axis.vertical,
                itemCount: widget.reels.length,
                onPageChanged: widget.onPageChanged,
                itemBuilder: (context, index) {
                  final reel = widget.reels[index];
                  final isCurrent = index == widget.currentIndex;
                  final isNeighbor = (index - widget.currentIndex).abs() <= 1;

                  if (!isCurrent && !isNeighbor) {
                    return _StaticReelPreview(reel: reel);
                  }

                  final playerKey = widget.getKeyForIndex(index);

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => playerKey.currentState?.handleTap(),
                    onDoubleTap: () =>
                        playerKey.currentState?.handleDoubleTap(),
                    onLongPressStart: (_) =>
                        playerKey.currentState?.handleLongPressStart(),
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
                          onLikePressed: () =>
                              playerKey.currentState?.handleDoubleTap(),
                          onBookPressed: () {
                            context.push('/location/${reel.id}');
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ВСПОМОГАТЕЛЬНЫЕ ВИДЖЕТЫ
// ============================================================

class _EmptyView extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptyView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.cardDark,
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.space32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.video_library_outlined,
                      size: 80,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: AppDimens.space24),
                    Text('Нет экспедиций', style: AppTextStyles.headline),
                    const SizedBox(height: AppDimens.space12),
                    Text(
                      'Здесь появятся экспедиции от гидов',
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimens.space32),
                    JoluButton(
                      text: 'Обновить',
                      variant: JoluButtonVariant.primary,
                      leadingIcon: Icons.refresh_rounded,
                      onPressed: () => onRefresh(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
        padding: const EdgeInsets.all(AppDimens.space32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimens.space16),
            Text(
              'Не удалось загрузить ленту',
              style: AppTextStyles.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.space8),
            Text(
              message,
              style: AppTextStyles.subtext,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.space24),
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
