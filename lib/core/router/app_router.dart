// lib/core/router/app_router.dart (или где у тебя AppRouterWithShell)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/di/service_locator.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/auth/view/auth_screen.dart';
import 'package:jolutrip_app/features/auth/view/bloc/auth_cubit.dart';
import 'package:jolutrip_app/features/auth/view/role_selection_screen.dart';
import 'package:jolutrip_app/features/gamification/view/blocs/journal/journal_cubit.dart';
import 'package:jolutrip_app/features/gamification/view/blocs/stamps/stamps_cubit.dart';
import 'package:jolutrip_app/features/gamification/view/pages/journal_screen.dart';
import 'package:jolutrip_app/features/gamification/view/pages/stamps_screen.dart';
import 'package:jolutrip_app/features/guide-profile/view/bloc/guide_profile_cubit.dart';
import 'package:jolutrip_app/features/guide-profile/view/bloc/guide_profile_state.dart';
import 'package:jolutrip_app/features/guide_auth/view/bloc/guide_auth_cubit.dart';
import 'package:jolutrip_app/features/guide_auth/view/guide_auth_screen.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/bloc/guide_onboarding_cubit.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/guide_onboarding_screen.dart';
import 'package:jolutrip_app/features/guide_tours/view/bloc/guide_tours_cubit.dart';
import 'package:jolutrip_app/features/guide_tours/view/screens/create_tour_screen.dart';
import 'package:jolutrip_app/features/location-detail/view/bloc/location_detail_cubit.dart';
import 'package:jolutrip_app/features/location-detail/view/location_detail_screen.dart';
import 'package:jolutrip_app/features/navigation/view/widgets/jolu_bottom_bar.dart';
import 'package:jolutrip_app/features/profile/view/bloc/profile_cubit.dart';
import 'package:jolutrip_app/features/profile/view/profile_router_screen.dart';
import 'package:jolutrip_app/features/reels/view/bloc/reels_cubit.dart';
import 'package:jolutrip_app/features/reels/view/reels_screen.dart';

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
            value: sl<GuideAuthCubit>(),
            child: const GuideAuthScreen(),
          );
        },
      ),

      // ═══════════════════════════════════════════════════
      // ONBOARDING ГИДА
      // ═══════════════════════════════════════════
      GoRoute(
        path: '/guide/onboarding',
        name: 'guideOnboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final guideId = extra?['guideId'] as String? ?? '';
          final token = extra?['token'] as String? ?? '';

          return BlocProvider<GuideOnboardingCubit>(
            create: (_) => sl<GuideOnboardingCubit>(),
            child: GuideOnboardingScreen(guideId: guideId, token: token),
          );
        },
      ),

      GoRoute(
        path: '/guide/tours/create',
        name: 'createTour',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => BlocProvider<GuideToursCubit>(
          create: (_) => sl<GuideToursCubit>()..reset(),
          child: const CreateTourScreen(),
        ),
      ),

      // ═══════════════════════════════════════════════════
      // ДЕТАЛЬ ЛОКАЦИИ
      // ═══════════════════════════════════════════════════
      GoRoute(
        path: '/location/:id',
        name: 'locationDetail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final locationId = state.pathParameters['id']!;
          return BlocProvider<LocationDetailCubit>(
            create: (_) =>
                sl<LocationDetailCubit>()..loadLocationDetail(locationId),
            child: LocationDetailScreen(locationId: locationId),
          );
        },
      ),

      // ═══════════════════════════════════════════════════
      // ГЕЙМИФИКАЦИЯ (вне shell — полноэкранные)
      // ═══════════════════════════════════════════════════
      GoRoute(
        path: '/stamps',
        name: 'stamps',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => BlocProvider<StampsCubit>(
          create: (_) => sl<StampsCubit>()..loadStamps(),
          child: const StampsScreen(),
        ),
      ),
      GoRoute(
        path: '/journal',
        name: 'journal',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => BlocProvider<JournalCubit>(
          create: (_) => sl<JournalCubit>()..loadJournal(),
          child: const JournalScreen(),
        ),
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
                builder: (context, state) => const ProfileRouterScreen(),
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
