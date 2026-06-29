import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/inputs/kyrgyz_plate_input.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/shared/language_chip_widget.dart';

class Step1ExperienceWidget extends StatelessWidget {
  final TextEditingController experienceController;
  final TextEditingController carModelController;
  final TextEditingController carNumberController;
  final List<String> selectedLanguages;
  final String? selectedCarCategory;
  final Function(String) onToggleLanguage;
  final Function(String?) onCategoryChanged;

  const Step1ExperienceWidget({
    super.key,
    required this.experienceController,
    required this.carModelController,
    required this.carNumberController,
    required this.selectedLanguages,
    required this.selectedCarCategory,
    required this.onToggleLanguage,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppDimens.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimens.space32),
          Text('Опыт и автомобиль', style: AppTextStyles.headline),
          const SizedBox(height: AppDimens.space12),
          Text(
            'Расскажите о вашем опыте и транспорте',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppDimens.space32 * 1.5),

          JoluTextField(
            controller: experienceController,
            label: 'Стаж вождения (лет)',
            hint: 'Например: 5',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.timer_outlined,
          ),
          const SizedBox(height: AppDimens.space32),

          // Категория автомобиля
          DropdownButtonFormField<String>(
            value: selectedCarCategory,
            decoration: InputDecoration(
              labelText: 'Категория автомобиля',
              hintText: 'Выберите категорию',
              prefixIcon: Icon(Icons.category_outlined, color: AppColors.textMuted),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
                borderSide: BorderSide(color: AppColors.borderDark),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
                borderSide: BorderSide(color: AppColors.borderDark),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: AppColors.cardDark,
            ),
            dropdownColor: AppColors.cardDark,
            style: TextStyle(color: AppColors.textPrimary),
            icon: Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
            items: const [
              DropdownMenuItem(
                value: 'sedan',
                child: Text('Седан'),
              ),
              DropdownMenuItem(
                value: 'suv',
                child: Text('Внедорожник (SUV)'),
              ),
              DropdownMenuItem(
                value: 'minivan',
                child: Text('Минивэн'),
              ),
              DropdownMenuItem(
                value: 'minibus',
                child: Text('Микроавтобус'),
              ),
              DropdownMenuItem(
                value: 'ev',
                child: Text('Электромобиль'),
              ),
            ],
            onChanged: onCategoryChanged,
          ),
          const SizedBox(height: AppDimens.space32),

          JoluTextField(
            controller: carModelController,
            label: 'Модель автомобиля',
            hint: 'Toyota Sequoia',
            prefixIcon: Icons.directions_car_outlined,
          ),
          const SizedBox(height: AppDimens.space32),

          KyrgyzPlateInput(
            controller: carNumberController,
            label: 'Гос. номер автомобиля',
            onChanged: (raw, formatted) {
              debugPrint('Raw: $raw, Formatted: $formatted');
            },
          ),
          const SizedBox(height: AppDimens.space32),

          Text('Языки', style: AppTextStyles.title),
          const SizedBox(height: AppDimens.space16),
          Text(
            'Выберите языки, на которых вы говорите',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppDimens.space16),
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
