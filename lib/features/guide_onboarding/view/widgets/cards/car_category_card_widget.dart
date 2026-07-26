import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/shared/onboarding_options.dart';

/// Плитка выбора категории автомобиля.
///
/// Заменяет `DropdownButtonFormField`: варианты видны сразу, с иконкой и
/// вместимостью, и выбираются одним тапом вместо «тап → список → тап».
class CarCategoryCardWidget extends StatelessWidget {
  final CarCategoryOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const CarCategoryCardWidget({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(AppDimens.space14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accent.withValues(alpha: 0.10)
                : AppColors.cardDark,
            borderRadius: BorderRadius.circular(AppDimens.radius16),
            border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.borderDark,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                option.icon,
                size: 26,
                color: isSelected
                    ? AppColors.accent
                    : AppColors.textTertiary,
              ),
              const SizedBox(width: AppDimens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: AppColors.accent,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
