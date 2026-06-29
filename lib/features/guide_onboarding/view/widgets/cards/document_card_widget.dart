// lib/features/guide_onboarding/presentation/widgets/cards/document_card_widget.dart

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

class DocumentCardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Uint8List? imageBytes;
  final VoidCallback onTap;
  final String hint;

  const DocumentCardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.imageBytes,
    required this.onTap,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space24),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          border: Border.all(
            color: imageBytes != null
                ? AppColors.primary
                : AppColors.borderDark,
            width: imageBytes != null ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: imageBytes != null
                        ? AppColors.primary.withOpacity(0.15)
                        : AppColors.borderDark,
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                  ),
                  child: Icon(
                    imageBytes != null ? Icons.check_circle : icon,
                    color: imageBytes != null
                        ? AppColors.primary
                        : AppColors.textMuted,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppDimens.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.subtitle),
                      const SizedBox(height: 4),
                      Text(
                        imageBytes != null ? 'Загружено ✓' : subtitle,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (imageBytes == null) ...[
              const SizedBox(height: AppDimens.space16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimens.radiusS),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.warning,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hint,
                        style: AppTextStyles.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
