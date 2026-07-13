// lib/features/guide_auth/presentation/widgets/guide_register_form.dart

import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/buttons/jolu_back_button.dart';
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
  bool _isNameTouched = false;

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
        leading: AppBackButton(
          onPressed: widget.onBack,
          style: BackButtonStyle.iconOnly,
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                    kToolbarHeight - 
                    MediaQuery.of(context).padding.top - 
                    MediaQuery.of(context).padding.bottom - 80,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDimens.space8),

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

                    // ✅ Поле ФИО
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ваше полное имя',
                          style: AppTextStyles.subtitle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppDimens.space12),
                        TextField(
                          controller: _nameController,
                          onChanged: (_) {
                            setState(() => _isNameTouched = true);
                          },
                          style: AppTextStyles.body.copyWith(fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Узумаки Атай Даттебаевич',
                            hintStyle: AppTextStyles.subtext.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: AppColors.cardDark,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimens.radiusM,
                              ),
                              borderSide: BorderSide(color: AppColors.borderDark),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimens.radiusM,
                              ),
                              borderSide: BorderSide(color: AppColors.borderDark),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimens.radiusM,
                              ),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimens.radiusM,
                              ),
                              borderSide: BorderSide(
                                color: Colors.transparent,
                                width: 0,
                              ),
                            ),
                            errorStyle: const TextStyle(height: 0),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: AppDimens.space16,
                              horizontal: AppDimens.space16,
                            ),
                          ),
                        ),
                        if (_isNameTouched && 
                            _nameController.text.trim().length < 3)
                          Padding(
                            padding: const EdgeInsets.only(top: AppDimens.space8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 14,
                                  color: AppColors.error,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Минимум 3 символа',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: AppDimens.space24),

                    // ✅ Пол
                    Text(
                      'Ваш пол',
                      style: AppTextStyles.subtitle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimens.space12),
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

                    if (_gender == null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppDimens.space8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Выберите ваш пол',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: AppDimens.space24),

                    // ✅ Номер телефона
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

                    const SizedBox(height: AppDimens.space32),

                    // ✅ Кнопка
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isValid ? 1.0 : 0.3,
                      child: JoluButton(
                        text: 'Получить код подтверждения',
                        variant: JoluButtonVariant.primary,
                        size: JoluButtonSize.large,
                        isFullWidth: true,
                        onPressed: _isValid
                            ? () => widget.onSubmit(
                                _nameController.text.trim(),
                                _gender!,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: AppDimens.space12),

                    if (!_isValid)
                      Center(
                        child: Text(
                          'Заполните имя (мин. 3 символа) и выберите пол',
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
              ? AppColors.primary.withValues(alpha: 0.12)
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