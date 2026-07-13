import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/guide-profile/view/widgets/modals/bottom_sheet_wrapper.dart';

class EditCarSheet extends StatefulWidget {
  final String carModel;
  final String carNumber;
  final Function(String model, String number) onSave;

  const EditCarSheet({
    super.key,
    required this.carModel,
    required this.carNumber,
    required this.onSave,
  });

  @override
  State<EditCarSheet> createState() => _EditCarSheetState();
}

class _EditCarSheetState extends State<EditCarSheet> {
  late final _modelController = TextEditingController(text: widget.carModel);
  late final _numberController = TextEditingController(text: widget.carNumber);

  bool get _canSave =>
      _modelController.text.trim().isNotEmpty &&
      _numberController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _modelController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetWrapper(
      title: 'Редактировать авто',
      icon: Icons.directions_car_rounded,
      canSave: _canSave,
      onSave: _canSave
          ? () {
              widget.onSave(
                _modelController.text.trim(),
                _numberController.text.trim().toUpperCase(),
              );
              Navigator.pop(context);
            }
          : null,
      children: [
        _AppTextField(
          controller: _modelController,
          label: 'Модель автомобиля',
          icon: Icons.car_rental_rounded,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppDimens.space16),
        _AppTextField(
          controller: _numberController,
          label: 'Гос. номер',
          icon: Icons.pin_rounded,
          textCapitalization: TextCapitalization.characters,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }
}

/// Переиспользуемое поле ввода — вынесено для чистоты.
class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextCapitalization? textCapitalization;
  final ValueChanged<String>? onChanged;

  const _AppTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.textCapitalization,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        filled: true,
        fillColor: AppColors.bgDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: AppDimens.space16,
        ),
      ),
      onChanged: onChanged,
    );
  }
}