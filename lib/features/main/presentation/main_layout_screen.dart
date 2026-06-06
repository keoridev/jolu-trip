import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/core/di/service_locator.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/navigation/presentation/widgets/jolu_bottom_bar.dart';
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
    _pageController = PageController();
    _profileCubit = ProfileCubit()..loadProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileCubit.loadProfile();
    });
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
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // 1. Reels
                BlocProvider<ReelsCubit>(
                  create: (_) => sl<ReelsCubit>()..loadReels(),
                  child: const ReelsScreen(),
                ),
                // 2. Локации
                const _PlaceholderScreen(
                  title: 'Локации',
                  icon: Icons.explore_outlined,
                  description: 'Карта треков и мест',
                ),
                // 3. Поездки
                const _PlaceholderScreen(
                  title: 'Поездки',
                  icon: Icons.directions_car_outlined,
                  description: 'Бронирования и маршруты',
                ),
                BlocProvider<ProfileCubit>.value(
                  value: _profileCubit,
                  child: const ProfileScreen(),
                ),
              ],
            ),
          ),
          JoluBottomBar(currentIndex: _currentIndex, onTap: _onTabChanged),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;

  const _PlaceholderScreen({
    required this.title,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimens.spaceL),
          Text(title, style: AppTextStyles.headline.copyWith(fontSize: 22)),
          const SizedBox(height: AppDimens.spaceS),
          Text(
            description,
            style: AppTextStyles.subtext,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.spaceL),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spaceM,
              vertical: AppDimens.spaceS,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimens.radiusRound),
            ),
            child: Text(
              'Скоро здесь появится контент',
              style: AppTextStyles.accentBadge.copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
