// lib/features/gamification/view/widgets/stamp_detail_sheet.dart
//
// Крупный просмотр одной печати. Открывается тапом по карточке в сетке,
// по слайду в карусели профиля и по закрытой печати (с подсказкой).

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/stamp.dart';
import 'stamp_medallion.dart';
import 'stamp_visuals.dart';

/// [stamp] — полученная печать. Если null, показываем закрытую по [stampId].
Future<void> showStampDetailSheet(
  BuildContext context, {
  Stamp? stamp,
  String? stampId,
}) {
  final id = stamp?.id ?? stampId;
  assert(id != null, 'Нужен stamp или stampId');

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.7),
    isScrollControlled: true,
    builder: (_) => _StampDetailSheet(stamp: stamp, stampId: id!),
  );
}

class _StampDetailSheet extends StatelessWidget {
  final Stamp? stamp;
  final String stampId;

  const _StampDetailSheet({required this.stamp, required this.stampId});

  @override
  Widget build(BuildContext context) {
    final info = stampInfoFor(stampId);
    final locked = stamp == null;
    final rarity = stamp?.rarity ?? info.rarity;
    final style = rarityStyle(rarity);
    final title = stamp?.title ?? info.title;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            locked ? const Color(0xFF1B1D22) : style.surface,
            AppColors.bgElevated,
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.radius24),
        ),
        border: Border.all(
          color: locked
              ? AppColors.borderDark
              : style.accent.withValues(alpha: 0.25),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(AppDimens.radiusRound),
              ),
            ),

            const SizedBox(height: AppDimens.space32),

            StampMedallion(
              stampId: stampId,
              rarity: rarity,
              imageAsset: stamp?.imageAsset,
              size: 148,
              locked: locked,
              animate: true,
            ),

            const SizedBox(height: AppDimens.space24),

            Text(
              locked ? '???' : title,
              style: AppTextStyles.headline.copyWith(fontSize: 22),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppDimens.space10),

            _RarityChip(rarity: rarity, muted: locked),

            const SizedBox(height: AppDimens.space16),

            Text(
              locked ? info.hint : (stamp!.description),
              style: AppTextStyles.subtext,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppDimens.space24),

            Container(
              padding: const EdgeInsets.all(AppDimens.space14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Row(
                children: [
                  Icon(
                    locked ? Icons.explore_outlined : Icons.event_available,
                    size: AppDimens.icon20,
                    color: locked ? AppColors.textSecondary : style.accent,
                  ),
                  const SizedBox(width: AppDimens.space12),
                  Expanded(
                    child: Text(
                      locked
                          ? info.region
                          : _earnedLine(stamp!.earnedAt, info.region),
                      style: AppTextStyles.body.copyWith(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            if (locked) ...[
              const SizedBox(height: AppDimens.space12),
              Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    size: AppDimens.icon16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: AppDimens.space8),
                  Expanded(
                    child: Text(
                      'Печать откроется после чекина в локации',
                      style: AppTextStyles.subtext.copyWith(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _earnedLine(DateTime? earnedAt, String region) {
    if (earnedAt == null) return region;
    const months = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ];
    return 'Получена ${earnedAt.day} ${months[earnedAt.month - 1]} '
        '${earnedAt.year} · $region';
  }
}

class _RarityChip extends StatelessWidget {
  final StampRarity rarity;
  final bool muted;

  const _RarityChip({required this.rarity, required this.muted});

  @override
  Widget build(BuildContext context) {
    final style = rarityStyle(rarity);
    final color = muted ? AppColors.textSecondary : style.accent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppDimens.radiusRound),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: AppDimens.space8),
          Text(
            style.label.toUpperCase(),
            style: AppTextStyles.badge.copyWith(color: color, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
