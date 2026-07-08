// lib/core/ui/widgets/back_button.dart

import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';

enum BackButtonStyle {
  icon,      // Только иконка (круглая)
  text,      // Текст + иконка
  iconOnly,  // Только иконка (без фона)
}

class AppBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  final BackButtonStyle style;
  final String? label;
  final Color? color;

  const AppBackButton({
    super.key,
    required this.onPressed,
    this.style = BackButtonStyle.icon,
    this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case BackButtonStyle.icon:
        return _buildIconButton();
      case BackButtonStyle.text:
        return _buildTextButton();
      case BackButtonStyle.iconOnly:
        return _buildIconOnlyButton();
    }
  }

  // 👇 Круглая кнопка с фоном (как в вашем коде)
  Widget _buildIconButton() {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space8),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          color: color ?? AppColors.textPrimary,
          size: 20,
        ),
      ),
    );
  }

  // 👇 Текстовая кнопка
  Widget _buildTextButton() {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space8,
          vertical: AppDimens.space8,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_back_rounded,
            color: color ?? AppColors.textSecondary,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            label ?? 'Назад',
            style: TextStyle(
              color: color ?? AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 👇 Только иконка (без фона, для AppBar)
  Widget _buildIconOnlyButton() {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        Icons.arrow_back_rounded,
        color: color ?? AppColors.textPrimary,
        size: 24,
      ),
      splashRadius: 24,
      tooltip: 'Назад',
    );
  }
}