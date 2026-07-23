// lib/features/gamification/presentation/widgets/collection_progress.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/features/gamification/domain/entities/stamp.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/collection.dart';
import '../blocs/stamps/stamps_cubit.dart';
import '../blocs/stamps/stamps_state.dart';
import '../pages/collection_detail_screen.dart';

class CollectionProgress extends StatelessWidget {
  final Collection collection;

  const CollectionProgress({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    final progress = collection.progress;
    final isCompleted = collection.isCompleted;

    return InkWell(
      onTap: () {
        final stampsCubit = context.read<StampsCubit>();
        final state = stampsCubit.state;
        final earnedStamps = state is StampsLoaded ? state.stamps : <Stamp>[];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CollectionDetailScreen(
              collection: collection,
              earnedStamps: earnedStamps,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(AppDimens.radiusM),
      child: Container(
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
                      Text(collection.title, style: AppTextStyles.title),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Завершено!',
                      style: AppTextStyles.accentBadge.copyWith(fontSize: 11),
                    ),
                  ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Показываем мини-превью печатей
            _StampPreview(
              collection: collection,
              earnedIds: collection.earnedStampIds.toSet(),
            ),

            const SizedBox(height: 12),

            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.isNaN ? 0 : progress,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.7),
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
      ),
    );
  }
}

// Мини-превью печатей в карточке коллекции
class _StampPreview extends StatelessWidget {
  final Collection collection;
  final Set<String> earnedIds;

  const _StampPreview({required this.collection, required this.earnedIds});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: collection.stampIds.map((stampId) {
        final isEarned = earnedIds.contains(stampId);

        return Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isEarned
                ? AppColors.primary.withOpacity(0.2)
                : Colors.grey[800],
            border: Border.all(
              color: isEarned
                  ? AppColors.primary.withOpacity(0.5)
                  : Colors.grey[700]!,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Icon(
              isEarned ? Icons.check : Icons.lock,
              size: 14,
              color: isEarned ? AppColors.primary : Colors.grey[600],
            ),
          ),
        );
      }).toList(),
    );
  }
}
