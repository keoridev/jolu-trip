import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/guide-profile/domain/entities/guide_profile_entity.dart';

class GuideStatusBanner extends StatelessWidget {
  final GuideProfileEntity profile;

  const GuideStatusBanner({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    if (profile.isPending) return _buildPendingBanner();
    if (profile.isRejected) return _buildRejectedBanner();
    return const SizedBox.shrink();
  }

  Widget _buildPendingBanner() {
    return _Banner(
      icon: Icons.hourglass_top_rounded,
      iconColor: AppColors.warning,
      bgColor: AppColors.warning.withValues(
        alpha: 0.1,
      ), // ← withOpacity → withValues
      borderColor: AppColors.warning.withValues(alpha: 0.3),
      title: 'Профиль на проверке',
      message:
          'Ваш профиль находится на проверке модератором. Обычно это занимает от 1 до 3 часов. На это время функции создания туров временно недоступны.',
    );
  }

  Widget _buildRejectedBanner() {
    return _Banner(
      icon: Icons.cancel_outlined,
      iconColor: AppColors.error,
      bgColor: AppColors.error.withValues(alpha: 0.1),
      borderColor: AppColors.error.withValues(alpha: 0.3),
      title: 'Профиль отклонён',
      message:
          'Причина: ${profile.rejectionReason ?? "Не указана"}\n\nПожалуйста, исправьте замечания и загрузите документы повторно.',
    );
  }
}

class _Banner extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;
  final String title;
  final String message;

  const _Banner({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: AppDimens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.subtitle.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimens.space8),
                Text(
                  message,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
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
