import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/guide-profile/view/widgets/bottom_sheet_wrapper.dart';

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
    'ru': '🇷🇺 Русский',
    'en': '🇬🇧 English',
    'ky': '🇰🇬 Кыргызча',
  };

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
      onSave: () {
        widget.onSave(_years, _selectedLanguages.toList());
        Navigator.pop(context);
      },
      children: [
        Text('Стаж вождения', style: AppTextStyles.subtitle),
        const SizedBox(height: AppDimens.space12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CircleButton(
              icon: Icons.remove,
              onPressed: _years > 0 ? () => setState(() => _years--) : null,
            ),
            const SizedBox(width: 24),
            Text(
              '$_years',
              style: AppTextStyles.headline.copyWith(fontSize: 32),
            ),
            const SizedBox(width: 24),
            _CircleButton(
              icon: Icons.add,
              onPressed: () => setState(() => _years++),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.space24),
        Text('Языки', style: AppTextStyles.subtitle),
        const SizedBox(height: AppDimens.space12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allLanguages.entries.map((entry) {
            final isSelected = _selectedLanguages.contains(entry.key);
            return FilterChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedLanguages.add(entry.key);
                  } else if (_selectedLanguages.length > 1) {
                    _selectedLanguages.remove(entry.key);
                  }
                });
              },
              backgroundColor: AppColors.cardDark,
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _CircleButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
    );
  }
}
