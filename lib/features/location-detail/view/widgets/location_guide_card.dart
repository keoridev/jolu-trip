import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

class LocationGuideCard extends StatelessWidget {
  final VoidCallback? onBook;

  /// Внутри шита у карточки не должно быть внешних отступов — их задаёт шит.
  final bool insideSheet;

  const LocationGuideCard({super.key, this.onBook, this.insideSheet = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: insideSheet
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: AppDimens.space16),
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.28),
            AppColors.accent.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(
          color: AppColors.primaryBright.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppDimens.avatar48,
                height: AppDimens.avatar48,
                decoration: BoxDecoration(
                  color: AppColors.cardElevated,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryBright.withValues(alpha: 0.35),
                  ),
                ),
                child: const Icon(
                  Icons.hiking_rounded,
                  color: AppColors.primaryBright,
                  size: AppDimens.icon24,
                ),
              ),
              const SizedBox(width: AppDimens.space14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Flexible, иначе заголовок выдавливает бейдж
                        // «СКОРО» за пределы карточки на узком экране.
                        Flexible(
                          child: Text(
                            'Поехать с гидом',
                            style: AppTextStyles.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppDimens.space8),
                        const _SoonBadge(),
                      ],
                    ),
                    const SizedBox(height: AppDimens.space4),
                    Text(
                      'Верифицируем лучших горных гидов Кыргызстана',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space16),
          SizedBox(
            width: double.infinity,
            height: AppDimens.buttonMinHeight,
            child: ElevatedButton.icon(
              onPressed: onBook,
              icon: const Icon(
                Icons.notifications_active_outlined,
                size: AppDimens.icon20,
              ),
              label: const Text('Сообщить, когда появятся'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                // Белый, а не черный: черный на #1B5E3A даёт контраст 1.6:1.
                foregroundColor: AppColors.onPrimary,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.4,
                ),
                disabledForegroundColor: AppColors.textSecondary,
                textStyle: AppTextStyles.button.copyWith(fontSize: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoonBadge extends StatelessWidget {
  const _SoonBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppDimens.radiusRound),
      ),
      child: Text(
        'СКОРО',
        style: AppTextStyles.badge.copyWith(color: AppColors.warning),
      ),
    );
  }
}

/// Раньше в шит отдавалась сама [LocationGuideCard] — с внешними отступами
/// страницы и без фона шита. Получалась карточка, висящая в пустоте, без
/// ручки и без скруглённой подложки.
class LocationGuideSheet extends StatelessWidget {
  final VoidCallback? onBook;

  const LocationGuideSheet({super.key, this.onBook});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: AppDimens.space12,
        left: AppDimens.space20,
        right: AppDimens.space20,
        bottom: MediaQuery.viewPaddingOf(context).bottom + AppDimens.space24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.space24),
          Text('Поездка с гидом', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppDimens.space8),
          Text(
            'Гид знает дорогу, договорится о ночёвке и покажет то, '
            'что не найти по координатам.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppDimens.space24),
          LocationGuideCard(onBook: onBook, insideSheet: true),
        ],
      ),
    );
  }
}
