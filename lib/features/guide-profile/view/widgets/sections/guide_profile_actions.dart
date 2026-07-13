import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/buttons/jolu_button.dart';

/// Редизайн блока действий гида.
///
/// Структура:
/// - Primary: "Создать тур" (disabled если не верифицирован, с подсказкой)
/// - Secondary: "Мои туры"
/// - Ghost: "Выйти из аккаунта"
///
/// UX:
/// - Три уровня важности вместо двух
/// - "Создать тур" — главный CTA, всегда сверху
/// - Подсказка под disabled-кнопкой — почему нельзя
class GuideActionButtons extends StatelessWidget {
  final bool isVerified;
  final bool isLoading;
  final VoidCallback? onCreateTour;
  final VoidCallback? onMyTours;
  final VoidCallback? onReuploadDocs;

  const GuideActionButtons({
    super.key,
    required this.isVerified,
    this.isLoading = false,
    this.onCreateTour,
    this.onMyTours,
    this.onReuploadDocs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimens.screenPadding,
      child: Column(
        children: [
          // Primary: Создать тур
          _CreateTourButton(
            isVerified: isVerified,
            isLoading: isLoading,
            onPressed: onCreateTour,
          ),
          const SizedBox(height: AppDimens.space10),

          // Secondary: Мои туры
          JoluButton(
            text: 'Мои туры',
            variant: JoluButtonVariant.outline,
            trailingIcon: Icons.list_alt,
            onPressed: onMyTours,
          ),

          // Reupload docs (только если rejected)
          if (onReuploadDocs != null) ...[
            const SizedBox(height: AppDimens.space10),
            JoluButton(
              text: 'Перезагрузить документы',
              variant: JoluButtonVariant.outline,
              trailingIcon: Icons.upload_file,
              onPressed: onReuploadDocs,
            ),
          ],

          const SizedBox(height: AppDimens.space16),

          // Ghost: Выйти
          GestureDetector(
            onTap: () => _showLogoutSheet(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimens.space8),
              child: Text(
                'Выйти из аккаунта',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogoutBottomSheet(),
    );
  }
}

class _CreateTourButton extends StatelessWidget {
  final bool isVerified;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _CreateTourButton({
    required this.isVerified,
    required this.isLoading,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        JoluButton(
          text: 'Создать новый тур',
          trailingIcon: Icons.add_circle_outline,
          isLoading: isLoading,
          onPressed: isVerified ? onPressed : null,
        ),
        if (!isVerified) ...[
          const SizedBox(height: AppDimens.space8),
          Text(
            'Доступно после верификации профиля',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _LogoutBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.radius24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + AppDimens.space16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag indicator
          Container(
            margin: const EdgeInsets.only(top: AppDimens.space12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppDimens.space24),
          Icon(Icons.logout_rounded, size: 48, color: AppColors.error),
          const SizedBox(height: AppDimens.space16),
          Text('Выйти из аккаунта?', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppDimens.space8),
          Text(
            'Вы уверены, что хотите выйти?',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.space24),
          Padding(
            padding: AppDimens.screenPadding,
            child: Row(
              children: [
                Expanded(
                  child: JoluButton(
                    text: 'Отмена',
                    variant: JoluButtonVariant.outline,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: AppDimens.space12),
                Expanded(
                  child: JoluButton(
                    text: 'Выйти',
                    variant: JoluButtonVariant.error,
                    onPressed: () {
                      // logout logic
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}