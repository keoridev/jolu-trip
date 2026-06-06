
import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

class JoluLoading extends StatelessWidget {
  final String? message;
  final bool isOverlay;

  const JoluLoading({super.key, this.message, this.isOverlay = false});

  @override
  Widget build(BuildContext context) {
    final child = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppDimens.spaceM),
            Text(
              message!,
              style: AppTextStyles.subtext,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );

    if (isOverlay) {
      return Stack(
        children: [
          Container(color: Colors.black.withOpacity(0.7)),
          child,
        ],
      );
    }

    return child;
  }
}
