import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/di/service_locator.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/features/auth/bloc/auth_cubit.dart';
import 'package:jolutrip_app/features/auth/presentation/auth_screen.dart';
import 'package:jolutrip_app/features/navigation/presentation/widgets/jolu_bottom_bar.dart';
import 'package:jolutrip_app/features/profile/presentation/profile_screen.dart';
import 'package:jolutrip_app/features/reels/cubit/reels_cubit.dart';
import 'package:jolutrip_app/features/reels/presentation/reels_screen.dart';

class AppRouterWithShell {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/reels',
    routes: [
      GoRoute(
        path: '/auth',
        name: 'auth',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => BlocProvider<AuthCubit>(
          create: (context) => sl<AuthCubit>(),
          child: const AuthScreen(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _NavigationWrapper(
            navigationShell: navigationShell,
            child: Scaffold(
              backgroundColor: AppColors.bgDark,
              body: navigationShell,
              bottomNavigationBar: JoluBottomBar(
                currentIndex: navigationShell.currentIndex,
                onTap: (index) {
                  navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  );
                },
              ),
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reels',
                name: 'reels',
                builder: (context, state) {
                  return BlocProvider<ReelsCubit>(
                    create: (context) => sl<ReelsCubit>()..loadReels(),
                    child: const ReelsScreen(),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/locations',
                name: 'locations',
                builder: (context, state) => const DummyScreen(
                  'Поиск и карта локаций',
                  Icons.explore_outlined,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/trips',
                name: 'trips',
                builder: (context, state) => const DummyScreen(
                  'Бронирование поездок',
                  Icons.directions_car_outlined,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  static void _pauseReelsVideo(BuildContext context) {
    try {
      final reelsCubit = context.read<ReelsCubit>();
      reelsCubit.pauseCurrentVideo();
      debugPrint('🎬 Видео поставлено на паузу при смене таба');
    } catch (e) {
      debugPrint('⚠️ Не удалось поставить видео на паузу: $e');
    }
  }
}

class _NavigationWrapper extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final Widget child;

  const _NavigationWrapper({
    required this.navigationShell,
    required this.child,
  });

  @override
  State<_NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<_NavigationWrapper> {
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.navigationShell.currentIndex;
  }

  @override
  void didUpdateWidget(_NavigationWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    final currentIndex = widget.navigationShell.currentIndex;
    final oldIndex = oldWidget.navigationShell.currentIndex;

    if (currentIndex != oldIndex) {
      debugPrint('🔄 Смена таба: $oldIndex -> $currentIndex');

      if (oldIndex == 0 && currentIndex != 0) {
        _pauseReelsVideo();
      }

      if (currentIndex == 0 && oldIndex != 0) {
        _resumeReelsVideo();
      }

      _previousIndex = currentIndex;
    }
  }

  void _pauseReelsVideo() {
    try {
      final reelsCubit = context.read<ReelsCubit>();
      reelsCubit.pauseCurrentVideo();
      debugPrint('🎬 Пауза: видео остановлено');
    } catch (e) {
      debugPrint('⚠️ Ошибка паузы: $e');
    }
  }

  void _resumeReelsVideo() {
    try {
      final reelsCubit = context.read<ReelsCubit>();
      reelsCubit.resumeCurrentVideo();
      debugPrint('▶️ Возобновление: видео запущено');
    } catch (e) {
      debugPrint('⚠️ Ошибка возобновления: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class DummyScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  const DummyScreen(this.title, this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgDark,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.primary.withOpacity(0.3)),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Скоро здесь появится контент',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
