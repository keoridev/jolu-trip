import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/buttons/jolu_back_button.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/tourist_health_card/domain/entities/health_card_entity.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'bloc/health_card_cubit.dart';
import 'bloc/health_card_state.dart';

class HealthCardScreen extends StatefulWidget {
  const HealthCardScreen({super.key});

  @override
  State<HealthCardScreen> createState() => _HealthCardScreenState();
}

class _HealthCardScreenState extends State<HealthCardScreen> {
  static const _bloodTypes = ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'];
  final _maskFormatter = MaskTextInputFormatter(
    mask: '+### (###) ##-##-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  // Контроллеры
  final _allergiesController = TextEditingController();
  final _chronicController = TextEditingController();
  final _additionalController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  String? _selectedBloodType;
  bool _hasAllergies = false;
  bool _hasChronic = false;

  @override
  void initState() {
    super.initState();
    // Загружаем карточку при открытии
    context.read<HealthCardCubit>().load();
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    _chronicController.dispose();
    _additionalController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  void _hydrateFrom(HealthCardEntity? card) {
    if (card == null) return;
    _selectedBloodType = card.bloodType.isEmpty ? null : card.bloodType;
    _hasAllergies = card.allergies.isNotEmpty;
    _hasChronic = card.chronicDiseases.isNotEmpty;
    _allergiesController.text = card.allergies;
    _chronicController.text = card.chronicDiseases;
    _additionalController.text = card.additionalInfo;
    _contactNameController.text = card.emergencyContact.name;
    if (card.emergencyContact.phone.isNotEmpty) {
      _contactPhoneController.text = _maskFormatter.maskText(
        card.emergencyContact.phone,
      );
    }
  }

  HealthCardEntity _buildDraft() {
    return HealthCardEntity(
      bloodType: _selectedBloodType ?? '',
      allergies: _hasAllergies ? _allergiesController.text.trim() : '',
      chronicDiseases: _hasChronic ? _chronicController.text.trim() : '',
      additionalInfo: _additionalController.text.trim(),
      emergencyContact: EmergencyContact(
        name: _contactNameController.text.trim(),
        phone: _buildPhone(),
      ),
    );
  }

  String _buildPhone() {
    final unmasked = _maskFormatter.getUnmaskedText() ?? '';
    if (unmasked.isEmpty) return '';
    // Если уже начинается с + — оставляем, иначе добавляем
    return unmasked.startsWith('+') ? unmasked : '+$unmasked';
  }

  bool get _canSave {
    // Хотя бы что-то должно быть заполнено
    final draft = _buildDraft();
    return draft.bloodType.isNotEmpty ||
        draft.allergies.isNotEmpty ||
        draft.chronicDiseases.isNotEmpty ||
        draft.additionalInfo.isNotEmpty ||
        draft.emergencyContact.isNotEmpty;
  }

  void _save() {
    FocusScope.of(context).unfocus();
    final draft = _buildDraft();
    if (draft.isEmpty) {
      JoluSnackbar.show(
        context: context,
        message: 'Заполните хотя бы одно поле',
        type: JoluSnackbarType.warning,
      );
      return;
    }
    context.read<HealthCardCubit>().save(draft);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: BlocConsumer<HealthCardCubit, HealthCardState>(
          listener: (context, state) {
            if (state is HealthCardSaved) {
              JoluSnackbar.show(
                context: context,
                message: 'Карточка сохранена',
                type: JoluSnackbarType.success,
              );
              context.pop();
            } else if (state is HealthCardError) {
              JoluSnackbar.show(
                context: context,
                message: state.message,
                type: JoluSnackbarType.error,
              );
            } else if (state is HealthCardLoaded) {
              _hydrateFrom(state.card);
            }
          },
          builder: (context, state) {
            final isLoading =
                state is HealthCardLoading || state is HealthCardSaving;

            return Column(
              children: [
                _buildHeader(isLoading: isLoading),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.space16,
                      AppDimens.space16,
                      AppDimens.space16,
                      AppDimens.space32,
                    ),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIntroBanner(),
                        const SizedBox(height: AppDimens.space24),
                        _Section(
                          title: 'Группа крови',
                          icon: Icons.bloodtype_rounded,
                          subtitle: 'Выберите вашу группу',
                          child: _buildBloodTypeSelector(),
                        ),
                        const SizedBox(height: AppDimens.space24),
                        _Section(
                          title: 'Аллергии',
                          icon: Icons.warning_amber_rounded,
                          subtitle: 'Есть ли у вас аллергии?',
                          child: _buildAllergiesBlock(),
                        ),
                        const SizedBox(height: AppDimens.space24),
                        _Section(
                          title: 'Хронические заболевания',
                          icon: Icons.favorite_border_rounded,
                          subtitle: 'Заболевания, о которых должен знать гид',
                          child: _buildChronicBlock(),
                        ),
                        const SizedBox(height: AppDimens.space24),
                        _Section(
                          title: 'Экстренный контакт',
                          icon: Icons.contact_phone_rounded,
                          subtitle: 'Кому звонить в случае ЧП',
                          child: _buildEmergencyContactBlock(),
                        ),
                        const SizedBox(height: AppDimens.space24),
                        _Section(
                          title: 'Дополнительная информация',
                          icon: Icons.notes_rounded,
                          subtitle: 'Особенности здоровья, приём лекарств',
                          child: _buildAdditionalBlock(),
                        ),
                        const SizedBox(height: AppDimens.space32),
                        _buildPrivacyNote(),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(isLoading: isLoading),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader({required bool isLoading}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space16,
        AppDimens.space12,
        AppDimens.space16,
        AppDimens.space8,
      ),
      child: Row(
        children: [
          AppBackButton(
            onPressed: () => context.pop(),
            style: BackButtonStyle.icon,
          ),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Карточка здоровья', style: AppTextStyles.headlineSmall),
                Text(
                  'Важная информация для гида',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIntroBanner() {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.success.withValues(alpha: 0.14),
            AppColors.accent.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.success,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ваша безопасность — наш приоритет',
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Эти данные увидит только ваш гид при бронировании тура. '
                  'Заполните карточку — это поможет в экстренной ситуации.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Селектор группы крови ─────────────────────────────────────────
  Widget _buildBloodTypeSelector() {
    return Wrap(
      spacing: AppDimens.space8,
      runSpacing: AppDimens.space8,
      children: _bloodTypes.map((type) {
        final isSelected = _selectedBloodType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedBloodType = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.space16,
              vertical: AppDimens.space12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.error.withValues(alpha: 0.16)
                  : AppColors.cardDark,
              borderRadius: BorderRadius.circular(AppDimens.radius12),
              border: Border.all(
                color: isSelected ? AppColors.error : AppColors.borderDark,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              type,
              style: AppTextStyles.subtitle.copyWith(
                color: isSelected ? AppColors.error : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Блок аллергий с toggle ─────────────────────────────────────────
  Widget _buildAllergiesBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ToggleRow(
          value: _hasAllergies,
          onChanged: (v) => setState(() => _hasAllergies = v),
          label: 'У меня есть аллергии',
        ),
        if (_hasAllergies) ...[
          const SizedBox(height: AppDimens.space12),
          JoluTextField(
            controller: _allergiesController,
            label: 'Перечислите аллергии',
            hint: 'Например: орехи, пенициллин, пыльца',
            maxLines: 3,
            minLines: 2,
          ),
        ],
      ],
    );
  }

  Widget _buildChronicBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ToggleRow(
          value: _hasChronic,
          onChanged: (v) => setState(() => _hasChronic = v),
          label: 'У меня есть хронические заболевания',
        ),
        if (_hasChronic) ...[
          const SizedBox(height: AppDimens.space12),
          JoluTextField(
            controller: _chronicController,
            label: 'Опишите заболевания',
            hint: 'Например: диабет 2 типа, астма',
            maxLines: 3,
            minLines: 2,
          ),
        ],
      ],
    );
  }

  // ─── Экстренный контакт ─────────────────────────────────────────────
  Widget _buildEmergencyContactBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JoluTextField(
          controller: _contactNameController,
          label: 'Имя контакта',
          hint: 'Например: Анна (жена)',
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: AppDimens.space16),
        JoluTextField(
          controller: _contactPhoneController,
          label: 'Телефон',
          hint: '+996 (555) 12-34-56',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          inputFormatters: [_maskFormatter],
        ),
      ],
    );
  }

  Widget _buildAdditionalBlock() {
    return JoluTextField(
      controller: _additionalController,
      label: 'Дополнительно',
      hint: 'Особенности здоровья, лекарства, которые принимаете...',
      maxLines: 4,
      minLines: 3,
    );
  }

  Widget _buildPrivacyNote() {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.textTertiary,
            size: 18,
          ),
          const SizedBox(width: AppDimens.space10),
          Expanded(
            child: Text(
              'Ваши данные защищены. Они передаются гиду только '
              'после подтверждения брони и не видны другим пользователям.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar({required bool isLoading}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space16,
        AppDimens.space12,
        AppDimens.space16,
        AppDimens.space16,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        border: Border(top: BorderSide(color: AppColors.borderDark)),
      ),
      child: SafeArea(
        top: false,
        child: JoluButton(
          text: 'Сохранить карточку',
          variant: JoluButtonVariant.primary,
          size: JoluButtonSize.large,
          isFullWidth: true,
          isLoading: isLoading,
          leadingIcon: Icons.save_outlined,
          onPressed: _canSave ? _save : null,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Section Wrapper
// ═══════════════════════════════════════════════════════════════
class _Section extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget child;

  const _Section({
    required this.title,
    required this.icon,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimens.radius8),
                ),
                child: Icon(icon, color: AppColors.accent, size: 18),
              ),
              const SizedBox(width: AppDimens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.subtitle),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space16),
          child,
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Toggle Row
// ═══════════════════════════════════════════════════════════════
class _ToggleRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  const _ToggleRow({
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppDimens.radius12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.space8),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 24,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: value ? AppColors.success : AppColors.borderDark,
                borderRadius: BorderRadius.circular(AppDimens.radiusRound),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimens.space12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: value
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: value ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
