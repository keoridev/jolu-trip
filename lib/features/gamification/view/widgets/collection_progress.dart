// lib/features/gamification/presentation/widgets/collection_progress.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/collection.dart';

class CollectionProgress extends StatelessWidget {
  final Collection collection;

  const CollectionProgress({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    final progress = collection.progress;
    final isCompleted = collection.isCompleted;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(
          color: isCompleted 
              ? AppColors.primary.withOpacity(0.5) 
              : AppColors.borderDark,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.title,
                      style: AppTextStyles.title,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      collection.description,
                      style: AppTextStyles.subtext.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Завершено!',
                    style: AppTextStyles.accentBadge.copyWith(fontSize: 11),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // ПРОГРЕСС-БАР — ФИКС
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.isNaN ? 0 : progress,
              backgroundColor: Colors.grey[800], // Тёмный фон
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? AppColors.primary : AppColors.primary.withOpacity(0.7),
              ),
              minHeight: 8,
            ),
          ),
          
          const SizedBox(height: 8),
          Text(
            '${collection.earnedStampIds.length} из ${collection.stampIds.length}',
            style: AppTextStyles.subtext.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}