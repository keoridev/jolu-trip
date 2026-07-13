import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

/// Предупреждение перед редактированием полей, требующих повторной модерации.
///
/// Показывается как bottom sheet перед открытием редактора.
/// Критичные поля: машина, видео-визитка, фото профиля.
/// Некритичные: языки, опыт — открываются сразу.
class ModerationWarningSheet extends StatelessWidget {
  final String fieldName;
  final VoidCallback onContinue;
  final VoidCallback onCancel;

  const ModerationWarningSheet({
    super.key,
    required this.fieldName,
    required this.onContinue,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppDimens.space20,
        right: AppDimens.space20,
        top: AppDimens.space16,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimens.space24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radius16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.space24),

          // Warning icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimens.radiusL),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: AppColors.warning,
              size: 24,
            ),
          ),
          const SizedBox(height: AppDimens.space16),

          // Title
          Text(
            'Изменение $fieldName',
            style: AppTextStyles.subtitle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimens.space8),

          // Description
          Text(
            'Если вы измените $fieldName, ваш профиль отправится на повторную проверку. '
            'Во время модерации вы не сможете создавать новые туры.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppDimens.space24),

          // Impact list
          _ImpactItem(
            icon: Icons.timer_outlined,
            text: 'Профиль на проверке — туры недоступны',
            isNegative: true,
          ),
          const SizedBox(height: AppDimens.space12),
          _ImpactItem(
            icon: Icons.check_circle_outline,
            text: 'После одобрения всё восстановится',
            isNegative: false,
          ),
          const SizedBox(height: AppDimens.space32),

          // Primary CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppDimens.space14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                ),
                elevation: 0,
              ),
              child: Text(
                'Понятно, продолжить',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.space12),

          // Secondary CTA
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppDimens.space12),
              ),
              child: Text(
                'Отмена',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpactItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isNegative;

  const _ImpactItem({
    required this.icon,
    required this.text,
    required this.isNegative,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: isNegative ? AppColors.warning : AppColors.success,
        ),
        const SizedBox(width: AppDimens.space10),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}