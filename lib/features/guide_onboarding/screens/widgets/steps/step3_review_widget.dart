import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

class Step3ReviewWidget extends StatelessWidget {
  final String experience;
  final String carModel;
  final String carNumber;
  final List<String> languages;
  final bool hasPassport;
  final bool hasLicense;
  final int carPhotosCount;

  const Step3ReviewWidget({
    super.key,
    required this.experience,
    required this.carModel,
    required this.carNumber,
    required this.languages,
    required this.hasPassport,
    required this.hasLicense,
    required this.carPhotosCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppDimens.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimens.spaceXL),
          Text('Проверьте данные', style: AppTextStyles.headline),
          const SizedBox(height: AppDimens.spaceXL * 1.5),

          _ReviewItem(label: 'Стаж', value: '$experience лет'),
          _ReviewItem(label: 'Автомобиль', value: carModel),
          _ReviewItem(label: 'Номер', value: carNumber),
          _ReviewItem(
            label: 'Языки',
            value: languages.map((l) => l.toUpperCase()).join(', '),
          ),
          const SizedBox(height: AppDimens.spaceL),

          _ReviewItem(
            label: 'Паспорт',
            value: hasPassport ? 'Загружено ✓' : 'Не загружено',
            isWarning: !hasPassport,
          ),
          _ReviewItem(
            label: 'Водительские права',
            value: hasLicense ? 'Загружено ✓' : 'Не загружено',
            isWarning: !hasLicense,
          ),
          _ReviewItem(
            label: 'Фото автомобиля',
            value: '$carPhotosCount/4 шт.',
            isWarning: carPhotosCount < 4,
          ),
        ],
      ),
    );
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
      padding: const EdgeInsets.only(bottom: AppDimens.spaceM),
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
