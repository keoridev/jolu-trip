
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

class VideoPreviewWidget extends StatelessWidget {
  final Uint8List? videoBytes;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const VideoPreviewWidget({
    super.key,
    required this.videoBytes,
    required this.onTap,
    required this.onRemove,
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
            color: videoBytes != null
                ? AppColors.primary
                : AppColors.borderDark,
            width: videoBytes != null ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: videoBytes != null
                        ? AppColors.primary.withOpacity(0.15)
                        : AppColors.borderDark,
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                  ),
                  child: Icon(
                    videoBytes != null
                        ? Icons.check_circle
                        : Icons.videocam_outlined,
                    color: videoBytes != null
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
                      Text('Видео-визитка', style: AppTextStyles.subtitle),
                      const SizedBox(height: 4),
                      Text(
                        videoBytes != null ? 'Загружено ✓' : 'До 1 минуты',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (videoBytes != null)
                  GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: AppColors.error,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
            if (videoBytes == null) ...[
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
                        'Запишите короткое видео о себе (до 1 мин)',
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
            if (videoBytes != null) ...[
              const SizedBox(height: AppDimens.space16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimens.radiusS),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      color: AppColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Видео загружено. Нажмите чтобы заменить',
                        style: AppTextStyles.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
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
