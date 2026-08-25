import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/profile/view/widgets/widgets.dart';
import 'package:jolutrip_app/features/tourist_health_card/view/widgets/health_card_status_block.dart';

class AuthenticatedView extends StatelessWidget {
  final String name;
  final String phone;
  final String? avatarUrl;

  const AuthenticatedView({
    super.key,
    required this.name,
    required this.phone,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppDimens.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          ProfileHeader(name: name, phone: phone, avatarUrl: avatarUrl),
          const SizedBox(height: AppDimens.space32),
          const GamificationBlock(),
          const SizedBox(height: AppDimens.space32),
          const HealthCardStatusBlock(),
          const SizedBox(height: AppDimens.space32),
          ProfileMenuSection(
            title: 'Мой атлас',
            themeColor: const Color(0xFFF59E0B),
            children: const [
              ProfileMenuItem(
                icon: Icons.stars_outlined,
                title: 'Мои печати',
                subtitle: 'Коллекции и достижения',
                themeColor: Color(0xFFF59E0B),
                route: '/stamps',
              ),
              ProfileMenuItem(
                icon: Icons.book_outlined,
                title: 'Журнал путешествий',
                subtitle: 'История посещений',
                themeColor: Color(0xFFF59E0B),
                route: '/journal',
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space20),
          ProfileMenuSection(
            title: 'Безопасность',
            themeColor: const Color(0xFF10B981),
            children: const [
              ProfileMenuItem(
                icon: Icons.emergency_outlined,
                title: 'SOS-помощь',
                subtitle: 'Экстренные номера и координаты',
                themeColor: AppColors.error,
                route: '/safety',
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space20),
          ProfileMenuSection(
            title: 'Активность',
            themeColor: const Color(0xFF3B82F6),
            children: const [
              ProfileMenuItem(
                icon: Icons.route_outlined,
                title: 'Мои поездки',
                subtitle: 'Запланированные маршруты',
                themeColor: Color(0xFF3B82F6),
                route: '/trips',
              ),
              ProfileMenuItem(
                icon: Icons.bookmark_border_rounded,
                title: 'Сохранённые',
                subtitle: 'Избранные локации',
                themeColor: Color(0xFF3B82F6),
                route: '/saved',
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space32),
          SizedBox(
            width: double.infinity,
            child: JoluButton(
              text: 'Выйти из аккаунта',
              variant: JoluButtonVariant.error,
              size: JoluButtonSize.large,
              isFullWidth: true,
              leadingIcon: Icons.logout_rounded,
              onPressed: () => showLogoutDialog(context),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
