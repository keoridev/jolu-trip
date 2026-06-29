import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/inputs/kyrgyz_license_plate.dart';

class KyrgyzPlateInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? errorText;
  final void Function(String raw, String formatted)? onChanged;

  const KyrgyzPlateInput({
    super.key,
    this.controller,
    this.label,
    this.errorText,
    this.onChanged,
  });

  @override
  State<KyrgyzPlateInput> createState() => _KyrgyzPlateInputState();
}

class _KyrgyzPlateInputState extends State<KyrgyzPlateInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onChanged() {
    final raw = _controller.text;
    final plate = _parsePlate(raw);
    final formatted = plate != null
        ? '${plate.region} ${plate.digits} ${plate.letters}'
        : raw;
    widget.onChanged?.call(raw, formatted);
    setState(() {});
  }

  _PlateData? _parsePlate(String raw) {
    final clean = raw.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (clean.length < 8) return null;

    final newFormat = RegExp(r'^(\d{2})([A-Z]{2})(\d{3})([A-Z]{3})$');
    final match = newFormat.firstMatch(clean);
    if (match != null) {
      return _PlateData(
        region: match.group(1)!,
        digits: match.group(3)!,
        letters: match.group(4)!,
      );
    }

    // Старый формат: 01KG7777
    final oldFormat = RegExp(r'^(\d{2})([A-Z]{2})(\d{4})$');
    final oldMatch = oldFormat.firstMatch(clean);
    if (oldMatch != null) {
      return _PlateData(
        region: oldMatch.group(1)!,
        digits: oldMatch.group(3)!,
        letters: '',
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final plate = _parsePlate(_controller.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.subtext.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimens.space12),
        ],

        // Live preview
        Center(
          child: plate != null
              ? KyrgyzLicensePlate(
                  region: plate.region,
                  digits: plate.digits,
                  letters: plate.letters,
                  height: 80,
                )
              : Container(
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Center(
                    child: Text(
                      'Введите номер',
                      style: AppTextStyles.subtext.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
        ),

        const SizedBox(height: AppDimens.space16),

        // Поле ввода
        TextFormField(
          controller: _controller,
          textCapitalization: TextCapitalization.characters,
          style: AppTextStyles.title.copyWith(
            fontSize: 20,
            letterSpacing: 3,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(10),
            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
          ],
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: '01KG777AAA',
            hintStyle: AppTextStyles.title.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              fontSize: 20,
              letterSpacing: 3,
            ),
            errorText: widget.errorText,
            filled: true,
            fillColor: AppColors.cardDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: BorderSide(color: AppColors.borderDark),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: BorderSide(color: AppColors.borderDark),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimens.space16,
              vertical: AppDimens.space16,
            ),
          ),
        ),

        // Подсказка
        if (plate == null && _controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppDimens.space12),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Формат: 01KG777AAA (регион + KG + цифры + буквы)',
                    style: AppTextStyles.subtext.copyWith(
                      color: AppColors.warning,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PlateData {
  final String region;
  final String digits;
  final String letters;
  _PlateData({
    required this.region,
    required this.digits,
    required this.letters,
  });
}
