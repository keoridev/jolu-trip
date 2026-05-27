import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/core/di/service_locator.dart';
import 'package:jolutrip_app/core/router/app_router.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/features/navigation/presentation/widgets/widgets.dart';
import 'package:jolutrip_app/features/profile/bloc/profile_cubit.dart';
import 'package:jolutrip_app/features/profile/presentation/profile_screen.dart';
import 'package:jolutrip_app/features/reels/cubit/reels_cubit.dart';
import 'package:jolutrip_app/features/reels/presentation/reels_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;
  late final PageController _pageController;
  late final ProfileCubit _profileCubit;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _profileCubit = ProfileCubit()..loadProfile();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _profileCubit.close();
    super.dispose();
  }

  void _onTabChanged(int index) {
    if (index == 3) {
      _profileCubit.loadProfile();
    }

    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Reels
                BlocProvider<ReelsCubit>(
                  create: (_) => sl<ReelsCubit>()..loadReels(),
                  child: const ReelsScreen(),
                ),
                // Locations
                const DummyScreen(
                  'Поиск и карта локаций',
                  Icons.explore_outlined,
                ),
                // Trips
                const DummyScreen(
                  'Бронирование поездок',
                  Icons.directions_car_outlined,
                ),
                // Profile — с единым ProfileCubit!
                BlocProvider<ProfileCubit>.value(
                  value: _profileCubit,
                  child: const ProfileScreen(),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: JoluBottomBar(
              currentIndex: _currentIndex,
              onTap: _onTabChanged,
            ),
          ),
        ],
      ),
    );
  }
}
