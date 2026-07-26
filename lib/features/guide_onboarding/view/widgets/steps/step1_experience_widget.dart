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

          const SizedBox(height: AppDimens.space24),
          KyrgyzPlateInput(
            controller: carNumberController,
            label: 'Гос. номер',
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
