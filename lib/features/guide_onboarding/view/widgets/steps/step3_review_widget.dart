import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

class Step3ReviewWidget extends StatelessWidget {
  final String experience;
  final String carCategory;
  final String carModel;
  final String carNumber;
  final List<String> languages;
  final bool hasPassportMain;
  final bool hasPassportRegistration;
  final bool hasLicenseFront;
  final bool hasLicenseBack;
  final int carPhotosCount;
  final bool hasVideo;

  const Step3ReviewWidget({
    super.key,
    required this.experience,
    required this.carCategory,
    required this.carModel,
    required this.carNumber,
    required this.languages,
    required this.hasPassportMain,
    required this.hasPassportRegistration,
    required this.hasLicenseFront,
    required this.hasLicenseBack,
    required this.carPhotosCount,
    required this.hasVideo,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppDimens.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimens.space32),
          Text('Проверьте данные', style: AppTextStyles.headline),
          const SizedBox(height: AppDimens.space12),
          Text(
            'Убедитесь, что все данные заполнены верно',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppDimens.space32 * 1.5),

          _ReviewItem(label: 'Стаж', value: '$experience лет'),
          _ReviewItem(
            label: 'Категория авто',
            value: _getCategoryLabel(carCategory),
          ),
          _ReviewItem(label: 'Автомобиль', value: carModel),
          _ReviewItem(label: 'Номер', value: carNumber),
          _ReviewItem(
            label: 'Языки',
            value: languages.map((l) => l.toUpperCase()).join(', '),
          ),
          const SizedBox(height: AppDimens.space24),

          _ReviewItem(
            label: 'Паспорт (главная)',
            value: hasPassportMain ? 'Загружено ✓' : 'Не загружено',
            isWarning: !hasPassportMain,
          ),
          _ReviewItem(
            label: 'Паспорт (прописка)',
            value: hasPassportRegistration ? 'Загружено ✓' : 'Не загружено',
            isWarning: !hasPassportRegistration,
          ),
          _ReviewItem(
            label: 'Права (лицевая)',
            value: hasLicenseFront ? 'Загружено ✓' : 'Не загружено',
            isWarning: !hasLicenseFront,
          ),
          _ReviewItem(
            label: 'Права (оборот)',
            value: hasLicenseBack ? 'Загружено ✓' : 'Не загружено',
            isWarning: !hasLicenseBack,
          ),
          _ReviewItem(
            label: 'Фото автомобиля',
            value: '$carPhotosCount/4 шт.',
            isWarning: carPhotosCount < 4,
          ),
          _ReviewItem(
            label: 'Видео-визитка',
            value: hasVideo ? 'Загружено ✓' : 'Не загружено',
            isWarning: !hasVideo,
          ),
          
          const SizedBox(height: AppDimens.space32),
          Container(
            padding: const EdgeInsets.all(AppDimens.space16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'После отправки вы не сможете изменить данные до завершения проверки',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'sedan':
        return 'Седан';
      case 'suv':
        return 'Внедорожник (SUV)';
      case 'minivan':
        return 'Минивэн';
      case 'minibus':
        return 'Микроавтобус';
      case 'ev':
        return 'Электромобиль';
      default:
        return category;
    }
  }
}

class _ReviewItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isWarning;

  const _ReviewItem({
    required this.label,
    required this.value,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.subtext),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: isWarning ? AppColors.warning : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}