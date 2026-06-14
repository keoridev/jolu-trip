import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/inputs/jolu_text_field.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/guide_auth/domain/entities/guide_entity.dart';

class GuideRegisterForm extends StatefulWidget {
  final String phone;
  final VoidCallback? onBack;
  final Function(String fullName, GuideGender gender) onSubmit;

  const GuideRegisterForm({
    super.key,
    required this.phone,
    this.onBack,
    required this.onSubmit,
  });

  @override
  State<GuideRegisterForm> createState() => _GuideRegisterFormState();
}

class _GuideRegisterFormState extends State<GuideRegisterForm> {
  final _nameController = TextEditingController();
  GuideGender? _gender;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppDimens.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),

          // Кнопка назад
          if (widget.onBack != null) ...[
            GestureDetector(
              onTap: widget.onBack,
              child: Container(
                padding: const EdgeInsets.all(AppDimens.spaceXS),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: AppDimens.spaceXL),
          ],

          Text('Регистрация гида', style: AppTextStyles.headline),
          const SizedBox(height: AppDimens.spaceS),
          Text(
            'Заполните данные для создания аккаунта',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppDimens.spaceXL * 2),

          // ФИО
          JoluTextField(
            controller: _nameController,
            label: 'ФИО полностью',
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: AppDimens.spaceXL),

          // Пол
          Text('Пол', style: AppTextStyles.title),
          const SizedBox(height: AppDimens.spaceM),
          Row(
            children: [
              Expanded(
                child: _GenderCard(
                  icon: Icons.male,
                  label: 'Мужской',
                  isSelected: _gender == GuideGender.male,
                  onTap: () => setState(() => _gender = GuideGender.male),
                ),
              ),
              const SizedBox(width: AppDimens.spaceM),
              Expanded(
                child: _GenderCard(
                  icon: Icons.female,
                  label: 'Женский',
                  isSelected: _gender == GuideGender.female,
                  onTap: () => setState(() => _gender = GuideGender.female),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceXL * 2),

          // Номер телефона
          Container(
            padding: const EdgeInsets.all(AppDimens.spaceM),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Row(
              children: [
                Icon(Icons.phone, color: AppColors.textMuted, size: 20),
                const SizedBox(width: AppDimens.spaceM),
                Text(widget.phone, style: AppTextStyles.body),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.spaceXL),

          JoluButton(
            text: 'Получить код',
            variant: JoluButtonVariant.primary,
            size: JoluButtonSize.large,
            isFullWidth: true,
            onPressed: _nameController.text.trim().length >= 5 && _gender != null
                ? () => widget.onSubmit(_nameController.text.trim(), _gender!)
                : null,
          ),
        ],
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderDark,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
