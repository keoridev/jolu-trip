import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/inputs/kyrgyz_plate_input.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/cards/car_category_card_widget.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/shared/info_note_widget.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/shared/language_chip_widget.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/shared/onboarding_options.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/shared/section_header_widget.dart';

class Step1ExperienceWidget extends StatelessWidget {
  final TextEditingController experienceController;
  final TextEditingController carModelController;
  final TextEditingController carNumberController;
  final TextEditingController carYearController; // ← новое
  final TextEditingController carSeatsController; // ← новое
  final List<String> selectedLanguages;
  final List<String> selectedCarFeatures; // ← новое
  final String? selectedCarCategory;
  final String selectedSteeringWheel; // ← новое
  final Function(String) onToggleLanguage;
  final Function(String?) onCategoryChanged;
  final Function(String) onSteeringChanged; // ← новое
  final Function(String) onToggleFeature; // ← новое

  const Step1ExperienceWidget({
    super.key,
    required this.experienceController,
    required this.carModelController,
    required this.carNumberController,
    required this.carYearController,
    required this.carSeatsController,
    required this.selectedLanguages,
    required this.selectedCarFeatures,
    required this.selectedCarCategory,
    required this.selectedSteeringWheel,
    required this.onToggleLanguage,
    required this.onCategoryChanged,
    required this.onSteeringChanged,
    required this.onToggleFeature,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space16,
        0,
        AppDimens.space16,
        AppDimens.space32,
      ),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Опыт ───────────────────────────────────────────────
          const SectionHeaderWidget(
            icon: Icons.workspace_premium_outlined,
            title: 'Опыт',
            subtitle: 'Сколько лет вы за рулём',
          ),
          const SizedBox(height: AppDimens.space16),
          JoluTextField(
            controller: experienceController,
            label: 'Стаж вождения',
            hint: 'Например: 5',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.timer_outlined,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
          ),

          const SizedBox(height: AppDimens.space32),

          // ─── Автомобиль ─────────────────────────────────────────
          const SectionHeaderWidget(
            icon: Icons.directions_car_outlined,
            title: 'Автомобиль',
            subtitle: 'На чём вы возите гостей',
          ),
          const SizedBox(height: AppDimens.space16),

          const _FieldLabel('Категория'),
          const SizedBox(height: AppDimens.space12),
          ...carCategoryOptions.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.space10),
              child: CarCategoryCardWidget(
                option: option,
                isSelected: selectedCarCategory == option.value,
                onTap: () => onCategoryChanged(option.value),
              ),
            ),
          ),

          const SizedBox(height: AppDimens.space20),
          JoluTextField(
            controller: carModelController,
            label: 'Марка и модель',
            hint: 'Toyota Sequoia',
            prefixIcon: Icons.badge_outlined,
            textCapitalization: TextCapitalization.words,
          ),

          const SizedBox(height: AppDimens.space20),
          JoluTextField(
            controller: carYearController,
            label: 'Год выпуска',
            hint: '2020',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.calendar_today_outlined,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
          ),

          const SizedBox(height: AppDimens.space20),
          JoluTextField(
            controller: carSeatsController,
            label: 'Количество мест',
            hint: '5 (включая водителя)',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.airline_seat_recline_normal_outlined,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
          ),

          const SizedBox(height: AppDimens.space24),
          KyrgyzPlateInput(
            controller: carNumberController,
            label: 'Гос. номер',
          ),

          const SizedBox(height: AppDimens.space24),
          const _FieldLabel('Расположение руля'),
          const SizedBox(height: AppDimens.space12),
          Row(
            children: [
              Expanded(
                child: _SteeringOption(
                  label: 'Левый',
                  icon: Icons.keyboard_arrow_left_rounded,
                  isSelected: selectedSteeringWheel == 'left',
                  onTap: () => onSteeringChanged('left'),
                ),
              ),
              const SizedBox(width: AppDimens.space12),
              Expanded(
                child: _SteeringOption(
                  label: 'Правый',
                  icon: Icons.keyboard_arrow_right_rounded,
                  isSelected: selectedSteeringWheel == 'right',
                  onTap: () => onSteeringChanged('right'),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimens.space32),

          // ─── Преимущества авто ──────────────────────────────────
          SectionHeaderWidget(
            icon: Icons.star_outline_rounded,
            title: 'Преимущества авто',
            subtitle: 'Что есть в вашей машине',
            trailing: SectionCounterBadge(
              done: selectedCarFeatures.length,
              total: carFeatureOptions.length,
            ),
          ),
          const SizedBox(height: AppDimens.space16),
          Wrap(
            spacing: AppDimens.space8,
            runSpacing: AppDimens.space8,
            children: carFeatureOptions
                .map(
                  (feature) => LanguageChipWidget(
                    label: feature.label,
                    isSelected: selectedCarFeatures.contains(feature.value),
                    onTap: () => onToggleFeature(feature.value),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppDimens.space16),
          const InfoNoteWidget(
            message:
                'Укажите все преимущества, которые есть в вашем авто. '
                'Это поможет гостям выбрать подходящий транспорт.',
            tone: InfoNoteTone.info,
            icon: Icons.auto_awesome_rounded,
          ),

          const SizedBox(height: AppDimens.space32),

          // ─── Языки ──────────────────────────────────────────────
          SectionHeaderWidget(
            icon: Icons.translate_rounded,
            title: 'Языки',
            subtitle: 'На каких говорите с гостями',
            trailing: SectionCounterBadge(
              done: selectedLanguages.length,
              total: languageOptions.length,
            ),
          ),
          const SizedBox(height: AppDimens.space16),
          Wrap(
            spacing: AppDimens.space8,
            runSpacing: AppDimens.space8,
            children: languageOptions
                .map(
                  (option) => LanguageChipWidget(
                    label: option.label,
                    isSelected: selectedLanguages.contains(option.code),
                    onTap: () => onToggleLanguage(option.code),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppDimens.space16),
          const InfoNoteWidget(
            message:
                'Чем больше языков вы укажете, тем чаще вас будут находить '
                'иностранные туристы.',
            tone: InfoNoteTone.info,
            icon: Icons.trending_up_rounded,
          ),
        ],
      ),
    );
  }
}

// ─── Сегмент выбора руля ────────────────────────────────────────────────
class _SteeringOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SteeringOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: AppDimens.space14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accent.withValues(alpha: 0.14)
                : AppColors.cardDark,
            borderRadius: BorderRadius.circular(AppDimens.radius12),
            border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.borderDark,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
              ),
              const SizedBox(width: AppDimens.space8),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected
                      ? AppColors.accent
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.subtext.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}
