
import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

import '../buttons/jolu_button.dart';

class JoluDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final Color? iconColor;
  final String confirmText;
  final String? cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const JoluDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.iconColor,
    required this.confirmText,
    this.cancelText,
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        side: BorderSide(color: AppColors.borderDark),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.primary,
                  size: 28,
                ),
              ),
            if (icon != null) const SizedBox(height: AppDimens.space16),
            Text(
              title,
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              message,
              style: AppTextStyles.subtext,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.space24),
            Row(
              children: [
                if (cancelText != null)
                  Expanded(
                    child: JoluButton(
                      text: cancelText!,
                      variant: JoluButtonVariant.outline,
                      size: JoluButtonSize.small,
                      onPressed: onCancel ?? () => Navigator.pop(context),
                    ),
                  ),
                if (cancelText != null) const SizedBox(width: AppDimens.space16),
                Expanded(
                  child: JoluButton(
                    text: confirmText,
                    variant: confirmText == 'Выйти'
                        ? JoluButtonVariant.error
                        : JoluButtonVariant.primary,
                    size: JoluButtonSize.small,
                    onPressed: onConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
