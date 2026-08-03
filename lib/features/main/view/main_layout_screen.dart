import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/core/di/service_locator.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/navigation/view/widgets/jolu_bottom_bar.dart';
import 'package:jolutrip_app/features/profile/view/bloc/profile_cubit.dart';
import 'package:jolutrip_app/features/profile/view/profile_router_screen.dart';
import 'package:jolutrip_app/features/reels/view/bloc/reels_cubit.dart';
import 'package:jolutrip_app/features/reels/view/reels_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // ✅ УДАЛЕНО: Ручное создание _profileCubit и двойной вызов loadProfile()
  }

  @override
  void dispose() {
    _pageController.dispose();
    // ✅ УДАЛЕНО: _profileCubit.close(). Этим теперь управляет BlocProvider.
    super.dispose();
  }

  void _onTabChanged(int index) {
    // ✅ УДАЛЕНО: Принудительный _profileCubit.loadProfile() при каждом тапе.
    // Это вызывало бы лишние сетевые запросы. Cubit сам должен кэшировать состояние 
    // или обновляться по Pull-to-Refresh внутри ProfileRouterScreen.
    
    setState(() => _currentIndex = index);
    
    // Используем jumpToPage вместо animateToPage для мгновенного отклика UI 
    // (стандартное поведение Bottom Navigation), либо оставляем animateToPage, 
    // но с защитой от частых кликов.
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    }
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
              physics: const NeverScrollableScrollPhysics(), // ✅ Правильно
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
                
                // 4. Профиль
                // ✅ ИСПРАВЛЕНО: Единый подход через DI, как у ReelsCubit
                BlocProvider<ProfileCubit>(
                  create: (_) => sl<ProfileCubit>()..loadProfile(),
                  child: const ProfileRouterScreen(),
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
            decoration: const BoxDecoration(
              color: AppColors.cardDark,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimens.space24),
          Text(title, style: AppTextStyles.headline.copyWith(fontSize: 22)),
          const SizedBox(height: AppDimens.space12),
          Text(
            description,
            style: AppTextStyles.subtext,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.space24),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.space16,
              vertical: AppDimens.space12,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
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