
import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
class JoluSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    JoluSnackbarType type = JoluSnackbarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_getIcon(type), color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: AppTextStyles.body)),
          ],
        ),
        backgroundColor: _getColor(type),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
        ),
        margin: AppDimens.screenPadding,
        duration: duration,
      ),
    );
  }

  static IconData _getIcon(JoluSnackbarType type) {
    switch (type) {
      case JoluSnackbarType.success:
        return Icons.check_circle_outline;
      case JoluSnackbarType.error:
        return Icons.error_outline;
      case JoluSnackbarType.warning:
        return Icons.warning_amber_outlined;
      case JoluSnackbarType.info:
        return Icons.info_outline;
    }
  }

  static Color _getColor(JoluSnackbarType type) {
    switch (type) {
      case JoluSnackbarType.success:
        return AppColors.success;
      case JoluSnackbarType.error:
        return AppColors.error;
      case JoluSnackbarType.warning:
        return AppColors.warning;
      case JoluSnackbarType.info:
        return AppColors.primary;
    }
  }
}

enum JoluSnackbarType { success, error, warning, info }
