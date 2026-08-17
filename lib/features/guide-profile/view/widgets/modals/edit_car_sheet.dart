import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/inputs/kyrgyz_plate_input.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/shared/onboarding_options.dart';

class EditCarSheet extends StatefulWidget {
  final String carModel;
  final String carNumber;
  final int carSeats;          // ← новое
  final int carYear;           // ← новое
  final String steeringWheel;  // ← новое
  final List<String> carFeatures; // ← новое
  final void Function(
    String model,
    String number,
    int seats,
    int year,
    String steering,
    List<String> features,
  ) onSave;

  const EditCarSheet({
    super.key,
    required this.carModel,
    required this.carNumber,
    required this.carSeats,
    required this.carYear,
    required this.steeringWheel,
    required this.carFeatures,
    required this.onSave,
  });

  @override
  State<EditCarSheet> createState() => _EditCarSheetState();
}

class _EditCarSheetState extends State<EditCarSheet> {
  late final TextEditingController _modelController;
  late final TextEditingController _numberController;
  late final TextEditingController _seatsController;
  late final TextEditingController _yearController;
  late String _selectedSteering;
  late List<String> _selectedFeatures;

  @override
  void initState() {
    super.initState();
    _modelController = TextEditingController(text: widget.carModel);
    _numberController = TextEditingController(text: widget.carNumber);
    _seatsController = TextEditingController(text: widget.carSeats.toString());
    _yearController = TextEditingController(text: widget.carYear.toString());
    _selectedSteering = widget.steeringWheel;
    _selectedFeatures = List.from(widget.carFeatures);
  }

  @override
  void dispose() {
    _modelController.dispose();
    _numberController.dispose();
    _seatsController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _onSave() {
    final seats = int.tryParse(_seatsController.text.trim()) ?? 0;
    final year = int.tryParse(_yearController.text.trim()) ?? 0;
    
    widget.onSave(
      _modelController.text.trim(),
      _numberController.text.trim(),
      seats,
      year,
      _selectedSteering,
      _selectedFeatures,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppDimens.space20,
        right: AppDimens.space20,
        top: AppDimens.space16,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimens.space24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.space24),

            Text('Редактировать автомобиль', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppDimens.space24),

            // Марка и модель
            JoluTextField(
              controller: _modelController,
              label: 'Марка и модель',
              hint: 'Toyota Sequoia',
              prefixIcon: Icons.badge_outlined,
            ),
            const SizedBox(height: AppDimens.space16),

            // Год выпуска
            JoluTextField(
              controller: _yearController,
              label: 'Год выпуска',
              hint: '2020',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.calendar_today_outlined,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
            ),
            const SizedBox(height: AppDimens.space16),

            // Количество мест
            JoluTextField(
              controller: _seatsController,
              label: 'Количество мест',
              hint: '5 (включая водителя)',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.airline_seat_recline_normal_outlined,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
            ),
            const SizedBox(height: AppDimens.space16),

            // Гос. номер
            KyrgyzPlateInput(
              controller: _numberController,
              label: 'Гос. номер',
            ),
            const SizedBox(height: AppDimens.space20),

            // Руль
            Text('Расположение руля', style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppDimens.space8),
            Row(
              children: [
                Expanded(
                  child: _SteeringOption(
                    label: 'Левый',
                    isSelected: _selectedSteering == 'left',
                    onTap: () => setState(() => _selectedSteering = 'left'),
                  ),
                ),
                const SizedBox(width: AppDimens.space12),
                Expanded(
                  child: _SteeringOption(
                    label: 'Правый',
                    isSelected: _selectedSteering == 'right',
                    onTap: () => setState(() => _selectedSteering = 'right'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.space20),

            // Преимущества
            Text('Преимущества авто', style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppDimens.space12),
            Wrap(
              spacing: AppDimens.space8,
              runSpacing: AppDimens.space8,
              children: carFeatureOptions.map((feature) {
                final selected = _selectedFeatures.contains(feature.value);
                return ChoiceChip(
                  label: Text(feature.label),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      if (selected) {
                        _selectedFeatures.remove(feature.value);
                      } else {
                        _selectedFeatures.add(feature.value);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimens.space32),

            // Кнопки
            SizedBox(
              width: double.infinity,
              child: JoluButton(
                text: 'Сохранить',
                variant: JoluButtonVariant.primary,
                size: JoluButtonSize.large,
                onPressed: _onSave,
              ),
            ),
            const SizedBox(height: AppDimens.space12),
            SizedBox(
              width: double.infinity,
              child: JoluButton(
                text: 'Отмена',
                variant: JoluButtonVariant.text,
                size: JoluButtonSize.large,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SteeringOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SteeringOption({
    required this.label,
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
        child: Container(
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
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}