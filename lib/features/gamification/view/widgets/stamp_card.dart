// lib/features/gamification/view/widgets/stamp_card.dart

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/stamp.dart';
import 'stamp_detail_sheet.dart';
import 'stamp_medallion.dart';
import 'stamp_visuals.dart';

/// Карточка полученной печати в сетке.
class StampCard extends StatelessWidget {
  final Stamp stamp;
  final VoidCallback? onTap;

  const StampCard({super.key, required this.stamp, this.onTap});

  @override
  Widget build(BuildContext context) {
    final style = rarityStyle(stamp.rarity);

    return _StampTile(
      accent: style.accent,
      gradient: style.cardGradient,
      borderColor: style.accent.withValues(alpha: 0.28),
      glow: style.glow(0.12),
      onTap: onTap ?? () => showStampDetailSheet(context, stamp: stamp),
      medallion: StampMedallion(
        stampId: stamp.id,
        rarity: stamp.rarity,
        imageAsset: stamp.imageAsset,
        size: 60,
      ),
      title: stamp.title,
      caption: style.label,
      captionColor: style.accent,
    );
  }
}

/// Карточка ещё не полученной печати — тизер в сетке.
class LockedStampCard extends StatelessWidget {
  final String stampId;
  final VoidCallback? onTap;

  const LockedStampCard({super.key, required this.stampId, this.onTap});

  @override
  Widget build(BuildContext context) {
    final info = stampInfoFor(stampId);

    return _StampTile(
      accent: AppColors.textMuted,
      gradient: const LinearGradient(
        colors: [Color(0xFF17181B), Color(0xFF121212)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      borderColor: AppColors.borderDark,
      glow: Colors.transparent,
      onTap: onTap ?? () => showStampDetailSheet(context, stampId: stampId),
      medallion: StampMedallion(
        stampId: stampId,
        rarity: info.rarity,
        size: 60,
        locked: true,
      ),
      title: '???',
      caption: 'Закрыта',
      captionColor: AppColors.textMuted,
    );
  }
}

class _StampTile extends StatelessWidget {
  final Color accent;
  final Gradient gradient;
  final Color borderColor;
  final Color glow;
  final VoidCallback onTap;
  final Widget medallion;
  final String title;
  final String caption;
  final Color captionColor;

  const _StampTile({
    required this.accent,
    required this.gradient,
    required this.borderColor,
    required this.glow,
    required this.onTap,
    required this.medallion,
    required this.title,
    required this.caption,
    required this.captionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppDimens.radius16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(color: glow, blurRadius: 18, offset: const Offset(0, 6)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Center(child: medallion)),
                const SizedBox(height: AppDimens.space8),
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 3),
                Text(
                  caption.toUpperCase(),
                  style: AppTextStyles.badge.copyWith(
                    fontSize: 8,
                    color: captionColor,
                    letterSpacing: 0.6,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
