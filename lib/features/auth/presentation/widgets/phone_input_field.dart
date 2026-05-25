import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

class PhoneInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onPhoneChanged;

  const PhoneInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onPhoneChanged,
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  /// Форматирует 9 цифр в +996 (XXX) XX-XX-XX
  String _formatDigits(String digits) {
    if (digits.isEmpty) return '+996 ';

    final buffer = StringBuffer('+996 ');

    // (XXX)
    if (digits.length >= 1) buffer.write('(');
    if (digits.length >= 1)
      buffer.write(digits.substring(0, digits.length.clamp(1, 3)));
    if (digits.length >= 3) buffer.write(') ');

    // XX
    if (digits.length > 3)
      buffer.write(digits.substring(3, digits.length.clamp(3, 5)));

    // -XX
    if (digits.length > 5) {
      buffer.write('-');
      buffer.write(digits.substring(5, digits.length.clamp(5, 7)));
    }

    // -XX
    if (digits.length > 7) {
      buffer.write('-');
      buffer.write(digits.substring(7, digits.length.clamp(7, 9)));
    }

    return buffer.toString();
  }

  /// Извлекает только 9 цифр после +996
  String _extractDigits(String text) {
    // Убираем всё кроме цифр
    final allDigits = text.replaceAll(RegExp(r'\D'), '');
    // Убираем префикс 996 если есть
    if (allDigits.startsWith('996')) {
      return allDigits.substring(3);
    }
    return allDigits;
  }

  @override
  void initState() {
    super.initState();
    // Устанавливаем начальное значение +996
    widget.controller.text = '+996 ';
    widget.controller.selection = TextSelection.fromPosition(
      const TextPosition(offset: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      keyboardType: TextInputType.phone,
      style: AppTextStyles.title.copyWith(
        fontSize: 24,
        letterSpacing: 1,
        color: AppColors.textPrimary,
      ),
      inputFormatters: [
        // Запрещаем ввод не-цифр и ограничиваем длину
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(12), // 996 + 9 цифр
      ],
      decoration: InputDecoration(
        hintText: '+996 (XXX) XX-XX-XX',
        hintStyle: AppTextStyles.title.copyWith(
          color: AppColors.textSecondary.withOpacity(0.3),
          fontSize: 24,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderDark, width: 1.5),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onChanged: (value) {
        // Получаем только цифры (без +996)
        final digits = _extractDigits(value);

        // Форматируем
        final formatted = _formatDigits(digits);

        // Обновляем контроллер
        widget.controller.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );

        // Отправляем чистый номер (+996XXXXXXXXX) наружу
        final cleanPhone = digits.length >= 9 ? '+996$digits' : '';
        widget.onPhoneChanged(cleanPhone);
      },
    );
  }
}
