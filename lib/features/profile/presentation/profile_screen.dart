import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: AppDimens.screenPadding,
          child: Column(
            children: [
              const SizedBox(height: 48),

              // Аватар-заглушка
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cardDark,
                  border: Border.all(color: AppColors.borderDark, width: 2),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppDimens.spaceL),

              Text('Гость', style: AppTextStyles.headline),

              const SizedBox(height: AppDimens.spaceS),

              Text(
                'Войди или зарегистрируйся, чтобы\nсохранять поездки и делиться контентом',
                style: AppTextStyles.subtext,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimens.spaceXL),

              // Кнопка "Зарегистрироваться"
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.push('/auth'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    ),
                  ),
                  child: Text(
                    'Зарегистрироваться',
                    style: AppTextStyles.button,
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
