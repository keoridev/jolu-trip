import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';

enum JoluIconButtonVariant { primary, secondary, error }

class JoluIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final JoluIconButtonVariant variant;
  final double size;
  final double iconSize;
  final String? tooltip;

  const JoluIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = JoluIconButtonVariant.secondary,
    this.size = 40,
    this.iconSize = 20,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimens.radiusRound),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: iconSize, color: _getIconColor()),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (onPressed == null) return AppColors.borderDark;

    switch (variant) {
      case JoluIconButtonVariant.primary:
        return AppColors.primary;
      case JoluIconButtonVariant.secondary:
        return AppColors.cardElevated;
      case JoluIconButtonVariant.error:
        return AppColors.error;
    }
  }

  Color _getIconColor() {
    switch (variant) {
      case JoluIconButtonVariant.primary:
        return Colors.black;
      case JoluIconButtonVariant.secondary:
        return AppColors.textPrimary;
      case JoluIconButtonVariant.error:
        return Colors.white;
    }
  }
}
