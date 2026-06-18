// lib/features/guide_onboarding/presentation/widgets/cards/add_photo_button_widget.dart

import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

class AddPhotoButtonWidget extends StatelessWidget {
  final VoidCallback onTap;

  const AddPhotoButtonWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.textMuted,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text('Добавить фото', style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
