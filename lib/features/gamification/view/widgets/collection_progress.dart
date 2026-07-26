// lib/features/gamification/view/widgets/collection_progress.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/collection.dart';
import '../../domain/entities/stamp.dart';
import '../blocs/stamps/stamps_cubit.dart';
import '../blocs/stamps/stamps_state.dart';
import '../pages/collection_detail_screen.dart';
import 'stamp_medallion.dart';
import 'stamp_visuals.dart';

class CollectionProgress extends StatelessWidget {
  final Collection collection;

  const CollectionProgress({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    final progress = collection.progress;
    final isCompleted = collection.isCompleted;
    final accent = isCompleted ? AppColors.success : AppColors.accent;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space16,
        vertical: AppDimens.space6,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDetail(context),
          borderRadius: BorderRadius.circular(AppDimens.radius20),
          child: Ink(
            padding: const EdgeInsets.all(AppDimens.space16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.radius20),
              border: Border.all(
                color: isCompleted
                    ? accent.withValues(alpha: 0.4)
                    : AppColors.borderDark,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isCompleted
                    ? const [Color(0xFF14231C), Color(0xFF141517)]
                    : const [Color(0xFF1A1B1E), Color(0xFF141517)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  collection.title,
                                  style: AppTextStyles.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (collection.isSeasonal) ...[
                                const SizedBox(width: AppDimens.space8),
                                const _Tag(
                                  label: 'СЕЗОН',
                                  color: AppColors.warning,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            collection.description,
                            style: AppTextStyles.subtext.copyWith(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimens.space8),
                    if (isCompleted)
                      const _Tag(label: 'ГОТОВО', color: AppColors.success)
                    else
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textSecondary,
                        size: AppDimens.icon20,
                      ),
                  ],
                ),

                const SizedBox(height: AppDimens.space14),

                _StampPreview(
                  stampIds: collection.stampIds,
                  earnedIds: collection.earnedStampIds.toSet(),
                ),

                const SizedBox(height: AppDimens.space14),

                Row(
                  children: [
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                          begin: 0,
                          end: progress.isNaN ? 0 : progress,
                        ),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) => ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusRound,
                          ),
                          child: Stack(
                            children: [
                              Container(
                                height: 6,
                                color: Colors.white.withValues(alpha: 0.07),
                              ),
                              FractionallySizedBox(
                                widthFactor: value,
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        accent.withValues(alpha: 0.6),
                                        accent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.space12),
                    Text(
                      '${collection.earnedStampIds.length}/${collection.stampIds.length}',
                      style: AppTextStyles.mono.copyWith(
                        fontSize: 12,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    final state = context.read<StampsCubit>().state;
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
  }
}

/// Мини-превью печатей коллекции — те же медальоны, только маленькие.
class _StampPreview extends StatelessWidget {
  final List<String> stampIds;
  final Set<String> earnedIds;

  const _StampPreview({required this.stampIds, required this.earnedIds});

  static const int _maxVisible = 6;

  @override
  Widget build(BuildContext context) {
    final visible = stampIds.take(_maxVisible).toList();
    final hidden = stampIds.length - visible.length;

    return Row(
      children: [
        ...visible.map((stampId) {
          final earned = earnedIds.contains(stampId);
          return Padding(
            padding: const EdgeInsets.only(right: AppDimens.space8),
            child: StampMedallion(
              stampId: stampId,
              rarity: stampInfoFor(stampId).rarity,
              size: 34,
              locked: !earned,
            ),
          );
        }),
        if (hidden > 0)
          Text(
            '+$hidden',
            style: AppTextStyles.subtext.copyWith(fontSize: 12),
          ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppDimens.radiusRound),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(color: color, fontSize: 9),
      ),
    );
  }
}
