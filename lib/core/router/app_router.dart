import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/di/service_locator.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/features/auth/bloc/auth_cubit.dart';
import 'package:jolutrip_app/features/auth/presentation/auth_screen.dart';
import 'package:jolutrip_app/features/auth/presentation/role_selection_screen.dart';
import 'package:jolutrip_app/features/guide_auth/bloc/guide_auth_cubit.dart';
import 'package:jolutrip_app/features/guide_auth/presentation/guide_auth_screen.dart';
import 'package:jolutrip_app/features/guide_auth/presentation/guide_onboarding_screen.dart';
import 'package:jolutrip_app/features/navigation/presentation/widgets/jolu_bottom_bar.dart';
import 'package:jolutrip_app/features/profile/bloc/profile_cubit.dart';
import 'package:jolutrip_app/features/profile/presentation/profile_screen.dart';
import 'package:jolutrip_app/features/reels/cubit/reels_cubit.dart';
import 'package:jolutrip_app/features/reels/presentation/reels_screen.dart';

class AppRouterWithShell {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final ProfileCubit _profileCubit = ProfileCubit();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/reels',
    routes: [
      // ═══════════════════════════════════════════════════
      // СТАРТОВЫЙ ЭКРАН ВЫБОРА РОЛИ
      // ═══════════════════════════════════════════════════
      GoRoute(
        path: '/auth',
        name: 'auth',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RoleSelectionScreen(),
      ),

      // ═══════════════════════════════════════════════════
      // АВТОРИЗАЦИЯ ТУРИСТА
      // ═══════════════════════════════════════════════════
      GoRoute(
        path: '/auth/tourist',
        name: 'touristAuth',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => BlocProvider<AuthCubit>(
          create: (_) => sl<AuthCubit>(),
          child: const AuthScreen(),
        ),
      ),

      // ═══════════════════════════════════════════════════
      // АВТОРИЗАЦИЯ ГИДА
      // ═══════════════════════════════════════════════════
      GoRoute(
        path: '/auth/guide',
        name: 'guideAuth',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          debugPrint('🛠️ Building GuideAuthScreen with BlocProvider.value');
          return BlocProvider<GuideAuthCubit>.value(
            value: sl<GuideAuthCubit>(), // 🔥 Берём из DI
            child: const GuideAuthScreen(),
          );
        },
      ),

      // ═══════════════════════════════════════════════════
      // ONBOARDING ГИДА (shared Cubit)
      // ═══════════════════════════════════════════════════
      GoRoute(
        path: '/guide/onboarding',
        name: 'guideOnboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          debugPrint('🛠️ Building GuideOnboardingScreen with shared Cubit');
          return BlocProvider<GuideAuthCubit>.value(
            value: sl<GuideAuthCubit>(), // 🔥 Тот же экземпляр!
            child: const GuideOnboardingScreen(),
          );
        },
      ),

      // ═══════════════════════════════════════════════════
      // ОСНОВНАЯ НАВИГАЦИЯ (Shell)
      // ═══════════════════════════════════════════════════
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BlocProvider<ProfileCubit>.value(
            value: _profileCubit,
            child: Scaffold(
              backgroundColor: AppColors.bgDark,
              body: navigationShell,
              bottomNavigationBar: JoluBottomBar(
                currentIndex: navigationShell.currentIndex,
                onTap: (index) {
                  if (index == 3) _profileCubit.loadProfile();
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
          // Reels
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reels',
                name: 'reels',
                builder: (context, state) => BlocProvider<ReelsCubit>(
                  create: (_) => sl<ReelsCubit>()..loadReels(),
                  child: const ReelsScreen(),
                ),
              ),
            ],
          ),
          // Locations
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
          // Trips
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
          // Profile
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
            Icon(
              icon,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
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
          ],
        ),
      ),
    );
  }
}