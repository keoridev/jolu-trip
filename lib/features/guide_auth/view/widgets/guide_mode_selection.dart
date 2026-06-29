// lib/features/guide_auth/presentation/widgets/guide_mode_selection.dart

import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

class GuideModeSelection extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  const GuideModeSelection({
    super.key,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimens.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),

          // Кнопка назад
          GestureDetector(
            onTap: () {
              debugPrint('🔙 Назад нажато');
              Navigator.of(context).maybePop();
            },
            child: Container(
              padding: const EdgeInsets.all(AppDimens.space8),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.space32),

          Text('Вход для гидов', style: AppTextStyles.headline),
          const SizedBox(height: AppDimens.space12),
          Text(
            'Управляйте турами и принимайте заказы',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppDimens.space32 * 2),

          // Вход — Material для ripple + debug
          _ModeCard(
            icon: Icons.login_rounded,
            title: 'Уже гид JoLuTrip',
            subtitle: 'Войти по номеру телефона',
            color: AppColors.primary,
            onTap: () {
              debugPrint('🔑 Вход нажато');
              onLogin();
            },
          ),
          const SizedBox(height: AppDimens.space16),

          // Регистрация
          _ModeCard(
            icon: Icons.person_add_rounded,
            title: 'Стать гидом',
            subtitle: 'Создать новый аккаунт',
            color: AppColors.accent,
            onTap: () {
              debugPrint('📝 Регистрация нажато');
              onRegister();
            },
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.space24),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: AppDimens.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.subtitle),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textMuted,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
