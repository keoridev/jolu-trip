import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/guide-profile/view/widgets/modals/bottom_sheet_wrapper.dart';

class EditExperienceSheet extends StatefulWidget {
  final int experienceYears;
  final List<String> languages;
  final Function(int years, List<String> languages) onSave;

  const EditExperienceSheet({
    super.key,
    required this.experienceYears,
    required this.languages,
    required this.onSave,
  });

  @override
  State<EditExperienceSheet> createState() => _EditExperienceSheetState();
}

class _EditExperienceSheetState extends State<EditExperienceSheet> {
  late int _years;
  late final Set<String> _selectedLanguages;

  final _allLanguages = const {
    'ru': 'Русский',
    'en': 'English',
    'ky': 'Кыргызча',
  };

  bool get _canSave => _selectedLanguages.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _years = widget.experienceYears;
    _selectedLanguages = Set.from(widget.languages);
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetWrapper(
      title: 'Опыт и языки',
      icon: Icons.verified_user_rounded,
      canSave: _canSave,
      onSave: _canSave
          ? () {
              widget.onSave(_years, _selectedLanguages.toList());
              Navigator.pop(context);
            }
          : null,
      children: [
        // Стаж
        Text('Стаж вождения', style: AppTextStyles.subtitle),
        const SizedBox(height: AppDimens.space16),
        _Stepper(
          value: _years,
          min: 0,
          max: 50,
          onChanged: (value) => setState(() => _years = value),
        ),
        const SizedBox(height: AppDimens.space32),
        // Языки
        Text('Языки', style: AppTextStyles.subtitle),
        const SizedBox(height: AppDimens.space16),
        Wrap(
          spacing: AppDimens.space8,
          runSpacing: AppDimens.space8,
          children: _allLanguages.entries.map((entry) {
            final isSelected = _selectedLanguages.contains(entry.key);
            return _LanguageChip(
              label: entry.value,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    if (_selectedLanguages.length > 1) {
                      _selectedLanguages.remove(entry.key);
                    }
                  } else {
                    _selectedLanguages.add(entry.key);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Кастомный степпер — заменяет +/- кнопки на более интуитивный контрол.
class _Stepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _Stepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space16,
        vertical: AppDimens.space12,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StepperButton(
            icon: Icons.remove,
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          Text(
            '$value ${_pluralYears(value)}',
            style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
          ),
          _StepperButton(
            icon: Icons.add,
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }

  String _pluralYears(int years) {
    final last = years % 10;
    final lastTwo = years % 100;
    if (lastTwo >= 11 && lastTwo <= 14) return 'лет';
    if (last == 1) return 'год';
    if (last >= 2 && last <= 4) return 'года';
    return 'лет';
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _StepperButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return Material(
      color: isEnabled
          ? AppColors.primary.withValues(alpha: 0.1)
          : AppColors.borderDark,
      borderRadius: BorderRadius.circular(AppDimens.radiusM),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.space8),
          child: Icon(
            icon,
            color: isEnabled ? AppColors.primary : AppColors.textMuted,
            size: 20,
          ),
        ),
      ),
    );
  }
}

/// Кастомный чип языка — без эмодзи, чище выглядит в тёмной теме.
class _LanguageChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageChip({
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: AppDimens.space12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.bgDark,
          borderRadius: BorderRadius.circular(AppDimens.radiusRound),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.borderDark,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
