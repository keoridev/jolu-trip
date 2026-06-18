// lib/features/guide_onboarding/presentation/widgets/steps/step1_experience_widget.dart

import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/inputs/kyrgyz_plate_input.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';

import 'package:jolutrip_app/features/guide_onboarding/screens/widgets/shared/language_chip_widget.dart';

class Step1ExperienceWidget extends StatelessWidget {
  final TextEditingController experienceController;
  final TextEditingController carModelController;
  final TextEditingController carNumberController;
  final List<String> selectedLanguages;
  final Function(String) onToggleLanguage;

  const Step1ExperienceWidget({
    super.key,
    required this.experienceController,
    required this.carModelController,
    required this.carNumberController,
    required this.selectedLanguages,
    required this.onToggleLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppDimens.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimens.spaceXL),
          Text('Опыт и автомобиль', style: AppTextStyles.headline),
          const SizedBox(height: AppDimens.spaceS),
          Text(
            'Расскажите о вашем опыте и транспорте',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppDimens.spaceXL * 1.5),

          JoluTextField(
            controller: experienceController,
            label: 'Стаж вождения (лет)',
            hint: 'Например: 5',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.timer_outlined,
          ),
          const SizedBox(height: AppDimens.spaceXL),

          JoluTextField(
            controller: carModelController,
            label: 'Модель автомобиля',
            hint: 'Toyota Sequoia',
            prefixIcon: Icons.directions_car_outlined,
          ),
          const SizedBox(height: AppDimens.spaceXL),

          KyrgyzPlateInput(
            controller: carNumberController,
            label: 'Гос. номер автомобиля',
            onChanged: (raw, formatted) {
              debugPrint('Raw: $raw, Formatted: $formatted');
            },
          ),
          const SizedBox(height: AppDimens.spaceXL),

          Text('Языки', style: AppTextStyles.title),
          const SizedBox(height: AppDimens.spaceM),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              LanguageChipWidget(
                label: 'Русский',
                isSelected: selectedLanguages.contains('ru'),
                onTap: () => onToggleLanguage('ru'),
              ),
              LanguageChipWidget(
                label: 'English',
                isSelected: selectedLanguages.contains('en'),
                onTap: () => onToggleLanguage('en'),
              ),
              LanguageChipWidget(
                label: 'Кыргызча',
                isSelected: selectedLanguages.contains('ky'),
                onTap: () => onToggleLanguage('ky'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
