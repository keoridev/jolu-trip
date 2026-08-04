import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimens.space24),
              
              // Логотип и заголовок
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                      borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    ),
                    child: const Icon(Icons.terrain, color: Colors.black, size: 24),
                  ),
                  const SizedBox(width: AppDimens.space12),
                  const Text('JoLuTrip', style: AppTextStyles.headline),
                ],
              ),
              
              const Spacer(flex: 1),

              const Text(
                'Добро пожаловать',
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: AppDimens.space8),
              Text(
                'Выберите вашу роль, чтобы мы могли\nподобрать лучший опыт для вас',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: AppDimens.space32),

              // Карточка Туриста
              _RoleCard(
                icon: Icons.hiking,
                title: 'Я Турист',
                subtitle: 'Ищу приключения и хочу бронировать туры',
                color: AppColors.primary,
                onTap: () => context.push('/auth/tourist'),
              ),
              const SizedBox(height: AppDimens.space16),

              // Карточка Гида
              _RoleCard(
                icon: Icons.directions_car_filled,
                title: 'Я Гид',
                subtitle: 'Провожу туры, ищу клиентов и управляю заказами',
                color: AppColors.accent,
                onTap: () => context.push('/auth/guide'),
              ),

              const Spacer(flex: 2),
              
              Center(
                child: Text(
                  'Продолжая, вы соглашаетесь с условиями использования',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppDimens.space24),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.space20),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(AppDimens.radiusL),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: AppDimens.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}