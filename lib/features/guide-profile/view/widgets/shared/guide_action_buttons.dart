
import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';

class GuideActionButtons extends StatelessWidget {
  final bool isVerified;
  final VoidCallback? onCreateTour;
  final VoidCallback? onMyTours;
  final VoidCallback? onReuploadDocs;

  const GuideActionButtons({
    super.key,
    required this.isVerified,
    this.onCreateTour,
    this.onMyTours,
    this.onReuploadDocs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isVerified) ...[
          // ✅ Верифицирован — активные кнопки
          JoluButton(
            text: 'Создать тур',
            variant: JoluButtonVariant.primary,
            isFullWidth: true,
            leadingIcon: Icons.add_circle_outline,
            onPressed: onCreateTour,
          ),
          const SizedBox(height: AppDimens.space16),
          JoluButton(
            text: 'Мои туры',
            variant: JoluButtonVariant.outline,
            isFullWidth: true,
            leadingIcon: Icons.route_outlined,
            onPressed: onMyTours,
          ),
        ] else if (onReuploadDocs != null) ...[
          // ❌ Отклонён — кнопка перезагрузки
          _DisabledButton(
            icon: Icons.upload_file_outlined,
            label: 'Перезагрузить документы',
            hint: 'Исправьте замечания и отправьте снова',
            onTap: onReuploadDocs,
            isAction: true,
          ),
        ] else ...[
          // ⏳ Pending — заблокированные
          const _DisabledButton(
            icon: Icons.add_circle_outline,
            label: 'Создать тур',
            hint: 'Доступно после проверки профиля',
          ),
          const SizedBox(height: AppDimens.space16),
          const _DisabledButton(
            icon: Icons.route_outlined,
            label: 'Мои туры',
            hint: 'Доступно после проверки профиля',
          ),
        ],
      ],
    );
  }
}

class _DisabledButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final VoidCallback? onTap;
  final bool isAction;

  const _DisabledButton({
    required this.icon,
    required this.label,
    required this.hint,
    this.onTap,
    this.isAction = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimens.space24),
        decoration: BoxDecoration(
          color: isAction
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.cardDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          border: Border.all(
            color: isAction
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.borderDark.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isAction
                    ? AppColors.primary.withOpacity(0.15)
                    : AppColors.textMuted.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
              ),
              child: Icon(
                icon,
                color: isAction ? AppColors.primary : AppColors.textMuted,
                size: 24,
              ),
            ),
            const SizedBox(width: AppDimens.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.subtitle.copyWith(
                      color: isAction ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hint,
                    style: AppTextStyles.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (!isAction)
              Icon(
                Icons.lock_outline,
                color: AppColors.textMuted.withOpacity(0.5),
                size: 20,
              )
            else
              Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 16),
          ],
        ),
      ),
    );
  }
}
