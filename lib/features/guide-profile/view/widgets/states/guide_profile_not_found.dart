import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';

class GuideProfileNotFound extends StatelessWidget {
  const GuideProfileNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppDimens.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Иконка
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_off_outlined,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),

            // Заголовок
            Text(
              'Аккаунт не найден',
              style: AppTextStyles.headline.copyWith(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Описание
            Text(
              'Ваш аккаунт был удалён или деактивирован. Войдите снова или создайте новый аккаунт.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Кнопка "Войти заново"
            SizedBox(
              width: double.infinity,
              child: JoluButton(
                text: 'Войти заново',
                variant: JoluButtonVariant.primary,
                leadingIcon: Icons.login_rounded,
                onPressed: () => context.go('/auth'),
              ),
            ),
            const SizedBox(height: 12),

            // Кнопка "На главную"
            SizedBox(
              width: double.infinity,
              child: JoluButton(
                text: 'На главную',
                variant: JoluButtonVariant.outline,
                onPressed: () => context.go('/'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
