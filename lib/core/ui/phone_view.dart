// lib/core/ui/widgets/phone_input_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

/// Универсальное поле для ввода номера телефона
/// 
/// Особенности:
/// - Автоматическое форматирование (+996 (XXX) XX-XX-XX)
/// - Валидация длины (12 цифр)
/// - Кастомизация через параметры
/// - Поддержка автофокуса
class PhoneInputField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? labelText;
  final bool autoFocus;
  final bool showValidationIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<bool>? onValidityChanged;
  final VoidCallback? onSubmitted;

  const PhoneInputField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = '+996 700 000 000',
    this.labelText,
    this.autoFocus = false,
    this.showValidationIcon = true,
    this.onChanged,
    this.onValidityChanged,
    this.onSubmitted,
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    
    _controller.addListener(_validateInput);
    
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  void _validateInput() {
    final isValid = _getCleanPhone().length == 12;
    if (isValid != _isValid) {
      setState(() => _isValid = isValid);
      widget.onValidityChanged?.call(isValid);
    }
    widget.onChanged?.call(_controller.text);
  }

  String _getCleanPhone() {
    return _controller.text.replaceAll(RegExp(r'\D'), '');
  }

  String get rawPhone => _getCleanPhone();
  bool get isValid => _isValid;

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: AppTextStyles.subtext.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimens.space12),
        ],
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
            _PhoneNumberFormatter(),
          ],
          style: AppTextStyles.headline.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTextStyles.subtext.copyWith(
              fontSize: 24,
              color: AppColors.textTertiary,
            ),
            labelText: widget.labelText,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(right: AppDimens.space8),
              child: Icon(
                Icons.phone_android_rounded,
                color: AppColors.textSecondary,
                size: AppDimens.icon24,
              ),
            ),
            suffixIcon: widget.showValidationIcon && _isValid
                ? const Padding(
                    padding: EdgeInsets.only(right: AppDimens.space16),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 20,
                    ),
                  )
                : null,
            border: InputBorder.none,
            filled: true,
            fillColor: AppColors.cardDark,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: BorderSide(color: AppColors.borderDark),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: BorderSide(
                color: _isValid ? AppColors.success : AppColors.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: AppDimens.space16,
              horizontal: AppDimens.space16,
            ),
          ),
          onEditingComplete: () {
            if (_isValid) {
              widget.onSubmitted?.call();
            }
          },
        ),
      ],
    );
  }
}

/// Форматтер для номера телефона: +996 (XXX) XX-XX-XX
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 0) buffer.write('(');
      buffer.write(text[i]);
      if (i == 2) buffer.write(') ');
      if (i == 5) buffer.write(' ');
      if (i == 7) buffer.write('-');
    }

    return newValue.copyWith(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}