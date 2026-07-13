import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/guide_tours/view/create_tour_contrloller.dart';
import 'package:jolutrip_app/features/guide_tours/view/widgets/location_search_sheet.dart';

class StepBasicInfo extends StatelessWidget {
  final CreateTourController controller;

  const StepBasicInfo({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppDimens.screenPadding,
      children: [
        _SectionHeader(
          title: 'Расскажите о туре',
          subtitle: 'Заполните основную информацию',
        ),
        const SizedBox(height: AppDimens.space24),

        // Название
        _TitleField(controller: controller),
        const SizedBox(height: AppDimens.space16),

        // Локация
        _LocationPicker(controller: controller),
        const SizedBox(height: AppDimens.space16),

        // Дата
        _DateTimePicker(controller: controller),
        const SizedBox(height: AppDimens.space16),

        // Длительность
        _DurationSelector(controller: controller),
        const SizedBox(height: AppDimens.space32),

        _TipCard(text: '💡 Совет: Чем конкретнее название, тем больше кликов'),
      ],
    );
  }
}

// === Подвиджеты ===

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.title.copyWith(fontSize: 22)),
        const SizedBox(height: 4),
        Text(subtitle, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _TitleField extends StatelessWidget {
  final CreateTourController controller;

  const _TitleField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _AppTextField(
      controller: controller.titleController,
      label: 'Название тура',
      hint: 'Например: Поход к озеру Сон-Куль',
      icon: Icons.title,
      onChanged: (_) => controller.notifyListeners(),
    );
  }
}

class _LocationPicker extends StatelessWidget {
  final CreateTourController controller;

  const _LocationPicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    final hasLocation = controller.selectedLocationName != null;

    return _PickerCard(
      icon: Icons.location_on_outlined,
      label: 'Локация',
      value: hasLocation
          ? controller.selectedLocationName!
          : 'Выберите локацию',
      isSelected: hasLocation,
      onTap: () => _showLocationSearch(context),
    );
  }

  void _showLocationSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => LocationSearchSheet(
        onSelect: (id, name) => controller.setLocation(id, name),
      ),
    );
  }
}

class _DateTimePicker extends StatelessWidget {
  final CreateTourController controller;

  const _DateTimePicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    final hasDate = controller.departureDate != null;
    final formatted = hasDate
        ? DateFormat(
            'dd MMMM yyyy, HH:mm',
            'ru',
          ).format(controller.departureDate!)
        : 'Выберите дату и время';

    return _PickerCard(
      icon: Icons.calendar_today_outlined,
      label: 'Дата отправления',
      value: formatted,
      isSelected: hasDate,
      onTap: () => _pickDateTime(context),
    );
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (time == null) return;

    controller.setDate(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }
}

class _DurationSelector extends StatelessWidget {
  final CreateTourController controller;

  const _DurationSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Длительность',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimens.space12),
        Row(
          children: [
            _DurationButton(
              icon: Icons.remove,
              onPressed: controller.durationDays > 1
                  ? () => controller.changeDuration(-1)
                  : null,
            ),
            const SizedBox(width: AppDimens.space16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimens.space16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                ),
                child: Column(
                  children: [
                    Text(
                      '${controller.durationDays}',
                      style: AppTextStyles.title.copyWith(
                        fontSize: 32,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      _pluralDays(controller.durationDays),
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppDimens.space16),
            _DurationButton(
              icon: Icons.add,
              onPressed: () => controller.changeDuration(1),
            ),
          ],
        ),
      ],
    );
  }

  String _pluralDays(int days) {
    final last = days % 10;
    final lastTwo = days % 100;
    if (lastTwo >= 11 && lastTwo <= 14) return 'дней';
    if (last == 1) return 'день';
    if (last >= 2 && last <= 4) return 'дня';
    return 'дней';
  }
}

class _DurationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _DurationButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isEnabled
              ? AppColors.cardDark
              : AppColors.cardDark.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
        ),
        child: Icon(
          icon,
          color: isEnabled
              ? AppColors.textPrimary
              : AppColors.textSecondary.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _PickerCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _PickerCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppDimens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTextStyles.body.copyWith(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String text;

  const _TipCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: AppColors.primary.withValues(alpha: 0.7),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final ValueChanged<String>? onChanged;

  const _AppTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: AppColors.cardDark,
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.textSecondary, size: 20)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
