import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

enum JoluButtonVariant {
  primary,
  secondary,
  outline,
  text,
  error,
  success,
  warning,
}

enum JoluButtonSize { small, medium, large }

class JoluButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final JoluButtonVariant variant;
  final JoluButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  const JoluButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = JoluButtonVariant.primary,
    this.size = JoluButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: _getButtonStyle(),
        child: _buildChild(),
      ),
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _getTextColor(),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: _getIconSize()),
          const SizedBox(width: AppDimens.spaceS),
        ],
        Text(text, style: _getTextStyle()),
        if (trailingIcon != null) ...[
          const SizedBox(width: AppDimens.spaceS),
          Icon(trailingIcon, size: _getIconSize()),
        ],
      ],
    );
  }

  ButtonStyle _getButtonStyle() {
    final isEnabled = onPressed != null && !isLoading;

    return ElevatedButton.styleFrom(
      backgroundColor: _getBackgroundColor(),
      foregroundColor: _getTextColor(),
      disabledBackgroundColor: _getDisabledBackgroundColor(),
      disabledForegroundColor: AppColors.textTertiary,
      elevation: variant == JoluButtonVariant.primary ? 0 : 0,
      padding: _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        side: _getBorderSide(),
      ),
      shadowColor: variant == JoluButtonVariant.primary
          ? AppColors.primary.withOpacity(0.3)
          : Colors.transparent,
    );
  }

  Color _getBackgroundColor() {
    if (onPressed == null || isLoading) return AppColors.borderDark;

    switch (variant) {
      case JoluButtonVariant.primary:
        return AppColors.primary;
      case JoluButtonVariant.secondary:
        return AppColors.cardElevated;
      case JoluButtonVariant.outline:
        return Colors.transparent;
      case JoluButtonVariant.text:
        return Colors.transparent;
      case JoluButtonVariant.error:
        return AppColors.error;
      case JoluButtonVariant.success:
        return AppColors.success;
      case JoluButtonVariant.warning:
        return AppColors.warning;
    }
  }

  Color _getTextColor() {
    switch (variant) {
      case JoluButtonVariant.primary:
        return Colors.black;
      case JoluButtonVariant.secondary:
        return AppColors.textPrimary;
      case JoluButtonVariant.outline:
        return AppColors.primary;
      case JoluButtonVariant.text:
        return AppColors.primary;
      case JoluButtonVariant.error:
        return Colors.white;
      case JoluButtonVariant.success:
        return Colors.white;
      case JoluButtonVariant.warning:
        return Colors.black;
    }
  }

  Color _getDisabledBackgroundColor() {
    return AppColors.borderDark;
  }

  BorderSide _getBorderSide() {
    if (variant == JoluButtonVariant.outline) {
      return BorderSide(color: AppColors.primary, width: 1.5);
    }
    return BorderSide.none;
  }

  double _getHeight() {
    switch (size) {
      case JoluButtonSize.small:
        return 36;
      case JoluButtonSize.medium:
        return 48;
      case JoluButtonSize.large:
        return 56;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case JoluButtonSize.small:
        return AppDimens.radiusS;
      case JoluButtonSize.medium:
        return AppDimens.radiusM;
      case JoluButtonSize.large:
        return AppDimens.radiusM;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case JoluButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case JoluButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case JoluButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case JoluButtonSize.small:
        return AppTextStyles.button.copyWith(fontSize: 13);
      case JoluButtonSize.medium:
        return AppTextStyles.button;
      case JoluButtonSize.large:
        return AppTextStyles.button.copyWith(fontSize: 16);
    }
  }

  double _getIconSize() {
    switch (size) {
      case JoluButtonSize.small:
        return 16;
      case JoluButtonSize.medium:
        return 18;
      case JoluButtonSize.large:
        return 20;
    }
  }
}
