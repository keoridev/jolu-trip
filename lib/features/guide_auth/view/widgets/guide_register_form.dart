// lib/features/guide_auth/presentation/widgets/guide_register_form.dart

import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/guide_auth/domain/entities/guide_entity.dart';

class GuideRegisterForm extends StatefulWidget {
  final String phone;
  final VoidCallback onBack;
  final Function(String fullName, GuideGender gender) onSubmit;

  const GuideRegisterForm({
    super.key,
    required this.phone,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  State<GuideRegisterForm> createState() => _GuideRegisterFormState();
}

class _GuideRegisterFormState extends State<GuideRegisterForm> {
  final _nameController = TextEditingController();
  GuideGender? _gender;

  bool get _isValid =>
      _nameController.text.trim().length >= 3 && _gender != null;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          'Регистрация',
          style: AppTextStyles.subtext.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimens.space16),

              Text(
                'Расскажите о себе',
                style: AppTextStyles.headline.copyWith(fontSize: 28),
              ),
              const SizedBox(height: AppDimens.space8),
              Text(
                'Заполните данные для создания аккаунта гида',
                style: AppTextStyles.subtext,
              ),
              const SizedBox(height: AppDimens.space32),

              // ФИО
              JoluTextField(
                controller: _nameController,
                label: 'Ваше полное имя',
                hint: 'Иванов Иван Иванович',
                prefixIcon: Icons.person_outline,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppDimens.space32),

              // Пол
              Text(
                'Ваш пол',
                style: AppTextStyles.subtitle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimens.space16),
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
                  const SizedBox(width: AppDimens.space16),
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
              const SizedBox(height: AppDimens.space32),

              // Номер телефона (нередактируемый)
              Container(
                padding: const EdgeInsets.all(AppDimens.space16),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Row(
                  children: [
                    Icon(Icons.phone, color: AppColors.textMuted, size: 20),
                    const SizedBox(width: AppDimens.space16),
                    Text(
                      widget.phone,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.lock_outline,
                      color: AppColors.textMuted,
                      size: 16,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Кнопка
              JoluButton(
                text: 'Получить код подтверждения',
                variant: JoluButtonVariant.primary,
                size: JoluButtonSize.large,
                isFullWidth: true,
                onPressed: _isValid
                    ? () =>
                          widget.onSubmit(_nameController.text.trim(), _gender!)
                    : null,
              ),
              const SizedBox(height: AppDimens.space16),

              // Подсказка
              if (!_isValid)
                Center(
                  child: Text(
                    'Заполните имя и выберите пол',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              const SizedBox(height: AppDimens.space24),
            ],
          ),
        ),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppDimens.space16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.12)
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
              size: 28,
            ),
            const SizedBox(height: AppDimens.space8),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
