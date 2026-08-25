import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/gamification/domain/entities/stamp.dart';
import 'package:jolutrip_app/features/gamification/view/blocs/stamps/stamps_cubit.dart';
import 'package:jolutrip_app/features/gamification/view/blocs/stamps/stamps_state.dart';
import 'package:jolutrip_app/features/gamification/view/widgets/stamps_carousel.dart';

class GamificationBlock extends StatelessWidget {
  const GamificationBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StampsCubit, StampsState>(
      builder: (context, state) {
        final loaded = state is StampsLoaded ? state : null;
        final stamps = loaded?.stamps ?? const <Stamp>[];

        final lockedIds = <String>{
          for (final collection in loaded?.collections ?? [])
            ...collection.stampIds,
        }..removeAll(stamps.map((s) => s.id).toSet());

        final recent = [...stamps]
          ..sort(
            (a, b) => (b.earnedAt ?? DateTime(2000)).compareTo(
              a.earnedAt ?? DateTime(2000),
            ),
          );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusCard(
              status: loaded?.travelerStatus ?? 'Турист',
              stampCount: loaded?.totalStamps ?? 0,
            ),
            const SizedBox(height: AppDimens.space24),
            Row(
              children: [
                Text(
                  'Мои печати',
                  style: AppTextStyles.headlineSmall.copyWith(fontSize: 17),
                ),
                const SizedBox(width: AppDimens.space8),
                if (stamps.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(
                        AppDimens.radiusRound,
                      ),
                    ),
                    child: Text(
                      '${stamps.length}',
                      style: AppTextStyles.badge.copyWith(
                        color: AppColors.accent,
                        fontSize: 11,
                      ),
                    ),
                  ),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push('/stamps'),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Text(
                        'Все',
                        style: AppTextStyles.subtext.copyWith(
                          fontSize: 13,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.accent,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.space12),
            StampsCarousel(
              stamps: recent,
              lockedIds: lockedIds.toList(),
              height: 190,
            ),
          ],
        );
      },
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String status;
  final int stampCount;

  const _StatusCard({required this.status, required this.stampCount});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/stamps'),
      borderRadius: BorderRadius.circular(AppDimens.radius16),
      child: Ink(
        padding: const EdgeInsets.all(AppDimens.space16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radius16),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A2321), Color(0xFF141517)],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.12),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: AppColors.accent,
                size: 24,
              ),
            ),
            const SizedBox(width: AppDimens.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'СТАТУС ПУТЕШЕСТВЕННИКА',
                    style: AppTextStyles.badge.copyWith(
                      color: AppColors.accent,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: AppTextStyles.title.copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$stampCount печатей собрано',
                    style: AppTextStyles.subtext.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
