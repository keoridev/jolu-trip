
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

class PhraseCard extends StatelessWidget {
  final int number;
  final String kyrgyz;
  final String russian;
  final String transcription;
  final VoidCallback? onSpeak;

  const PhraseCard({
    super.key,
    required this.number,
    required this.kyrgyz,
    required this.russian,
    required this.transcription,
    this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(AppDimens.spaceM),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: AppTextStyles.accentBadge.copyWith(fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kyrgyz,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  russian,
                  style: AppTextStyles.subtext.copyWith(fontSize: 13),
                ),
                Text(
                  '[$transcription]',
                  style: AppTextStyles.subtext.copyWith(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          if (onSpeak != null)
            IconButton(
              icon: Icon(
                Icons.volume_up,
                color: AppColors.primary.withOpacity(0.6),
                size: 20,
              ),
              onPressed: onSpeak,
            ),
        ],
      ),
    );
  }
}
