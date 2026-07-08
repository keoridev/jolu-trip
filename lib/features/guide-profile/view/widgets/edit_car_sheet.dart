import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/guide-profile/view/widgets/bottom_sheet_wrapper.dart';

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
      onSave: () {
        widget.onSave(_modelController.text, _numberController.text);
        Navigator.pop(context);
      },
      children: [
        _buildTextField(
          controller: _modelController,
          label: 'Модель автомобиля',
          icon: Icons.car_rental_rounded,
        ),
        const SizedBox(height: AppDimens.space16),
        _buildTextField(
          controller: _numberController,
          label: 'Гос. номер',
          icon: Icons.pin_rounded,
        ),
      ],
    );
  }
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
}) {
  return TextFormField(
    controller: controller,
    style: const TextStyle(color: AppColors.textPrimary),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.bgDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    ),
  );
}
