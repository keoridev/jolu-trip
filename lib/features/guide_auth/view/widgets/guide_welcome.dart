import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';

class GuideWelcome extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  const GuideWelcome({
    super.key,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Навигация
              const SizedBox(height: AppDimens.space16),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimens.space24),

              // Контент
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Иконка профиля
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                          ),
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusL,
                          ),
                        ),
                        child: const Icon(
                          Icons.directions_car_filled,
                          color: Colors.black,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: AppDimens.space32),

                      Text(
                        'Стань гидом\nJoLuTrip',
                        style: AppTextStyles.headline.copyWith(
                          fontSize: 34,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: AppDimens.space16),
                      Text(
                        'Зарабатывайте на своих знаниях о горах. '
                        'Проводите туры, находите клиентов и управляйте '
                        'своим графиком в одном месте.',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: AppDimens.space32),

                      // Преимущества
                      _BenefitItem(
                        icon: Icons.attach_money,
                        title: 'Зарабатывайте',
                        description:
                            'Устанавливайте свои цены и получайте оплату',
                      ),
                      const SizedBox(height: AppDimens.space16),
                      _BenefitItem(
                        icon: Icons.calendar_today,
                        title: 'Управляйте графиком',
                        description:
                            'Создавайте туры и принимайте бронирования',
                      ),
                      const SizedBox(height: AppDimens.space16),
                      _BenefitItem(
                        icon: Icons.people,
                        title: 'Находите клиентов',
                        description: 'Ваши туры увидят тысячи путешественников',
                      ),

                      const SizedBox(height: AppDimens.space48),

                      // Кнопки
                      JoluButton(
                        text: 'Создать аккаунт',
                        variant: JoluButtonVariant.primary,
                        size: JoluButtonSize.large,
                        isFullWidth: true,
                        onPressed: onRegister,
                      ),
                      const SizedBox(height: AppDimens.space16),
                      TextButton(
                        onPressed: onLogin,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Уже есть аккаунт? ',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              'Войти',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimens.space24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
          ),
          child: Icon(icon, color: AppColors.primary, size: AppDimens.icon20),
        ),
        const SizedBox(width: AppDimens.space16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.subtitle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
