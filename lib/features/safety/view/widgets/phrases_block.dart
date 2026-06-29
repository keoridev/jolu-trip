import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/safety/data/datasources/datasources.dart';
import 'package:jolutrip_app/features/safety/data/models/safety_models.dart';
import 'package:jolutrip_app/features/safety/view/widgets/shared/block_title.dart';

class PhrasesBlock extends StatelessWidget {
  const PhrasesBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BlockTitle(
          icon: Icons.translate_rounded,
          title: 'Полезные фразы',
          color: Colors.purple,
        ),
        const SizedBox(height: AppDimens.space24),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.35,
            crossAxisSpacing: AppDimens.space16,
            mainAxisSpacing: AppDimens.space16,
          ),
          itemCount: SafetyLocalDataSource.phrases.length,
          itemBuilder: (context, index) =>
              _PhraseCard(phrase: SafetyLocalDataSource.phrases[index]),
        ),
      ],
    );
  }
}

class _PhraseCard extends StatelessWidget {
  final Phrase phrase;

  const _PhraseCard({required this.phrase});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardDark,
      borderRadius: BorderRadius.circular(AppDimens.radiusL),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        onTap: () {
          Clipboard.setData(ClipboardData(text: phrase.kyrgyz));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${phrase.kyrgyz} — скопировано'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(AppDimens.space16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusL),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(phrase.icon, color: AppColors.primary, size: 20),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.copy_outlined,
                      color: AppColors.primary,
                      size: 12,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    phrase.kyrgyz,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    phrase.transcription,
                    style: AppTextStyles.subtext.copyWith(
                      color: AppColors.primary,
                      fontStyle: FontStyle.italic,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phrase.transcription,
                    style: AppTextStyles.subtext.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
