// lib/core/ui/widgets/phone_input_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

/// Универсальное поле для ввода номера телефона
/// 
/// Особенности:
/// - +996 всегда статичен (пользователь не может его удалить)
/// - Плавное удаление цифр без зависаний
/// - Автоматическое форматирование
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
    this.hintText = '700 000 000',
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
  
  // Статичный префикс
  static const String _prefix = '+996 ';
  static const int _maxDigits = 9; // 9 цифр после +996

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    
    // Устанавливаем начальное значение с префиксом
    if (_controller.text.isEmpty) {
      _controller.text = _prefix;
      _controller.selection = TextSelection.collapsed(offset: _prefix.length);
    }
    
    _controller.addListener(_onTextChanged);
    
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
          _controller.selection = TextSelection.collapsed(
            offset: _controller.text.length,
          );
        }
      });
    }
  }

  void _onTextChanged() {
    // Защита от удаления префикса
    _protectPrefix();
    
    // Валидация
    final digits = _getDigitsOnly();
    final isValid = digits.length == _maxDigits;
    if (isValid != _isValid) {
      setState(() => _isValid = isValid);
      widget.onValidityChanged?.call(isValid);
    }
    widget.onChanged?.call(_controller.text);
  }

  void _protectPrefix() {
    final text = _controller.text;
    
    // Если текст стал короче префикса - восстанавливаем
    if (text.length < _prefix.length) {
      _controller.text = _prefix;
      _controller.selection = TextSelection.collapsed(offset: _prefix.length);
      return;
    }
    
    // Если префикс поврежден - восстанавливаем
    if (!text.startsWith(_prefix)) {
      // Сохраняем только цифры, которые ввел пользователь
      final digits = text.replaceAll(RegExp(r'\D'), '');
      final userDigits = digits.length > 3 ? digits.substring(3) : '';
      _controller.text = _prefix + userDigits;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
      return;
    }
  }

  String _getDigitsOnly() {
    final text = _controller.text;
    // Убираем префикс и все не-цифры
    return text.replaceAll(_prefix, '').replaceAll(RegExp(r'\D'), '');
  }

  String get rawPhone {
    final digits = _getDigitsOnly();
    if (digits.length == _maxDigits) {
      return '+996$digits';
    }
    return '';
  }
  
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
            // Только цифры, но с учетом что префикс уже есть
            _PhoneNumberInputFormatter(_prefix, _maxDigits),
          ],
          style: AppTextStyles.headline.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTextStyles.subtext.copyWith(
              fontSize: 24,
              color: AppColors.textTertiary,
            ),
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

/// Форматтер для номера телефона с защитой префикса
class _PhoneNumberInputFormatter extends TextInputFormatter {
  final String prefix;
  final int maxDigits;
  
  _PhoneNumberInputFormatter(this.prefix, this.maxDigits);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Если текст пустой или короче префикса - возвращаем префикс
    if (newValue.text.length < prefix.length) {
      return TextEditingValue(
        text: prefix,
        selection: TextSelection.collapsed(offset: prefix.length),
      );
    }

    // Получаем только цифры после префикса
    String digits = newValue.text
        .replaceAll(prefix, '')
        .replaceAll(RegExp(r'\D'), '');
    
    // Ограничиваем количество цифр
    if (digits.length > maxDigits) {
      digits = digits.substring(0, maxDigits);
    }

    // Форматируем: 700000000 -> 700 000 000
    final formatted = _formatDigits(digits);
    
    final result = prefix + formatted;
    
    // Вычисляем позицию курсора
    int cursorPos = result.length;
    if (newValue.selection.baseOffset > 0) {
      // Сохраняем позицию курсора относительно ввода
      final oldDigits = oldValue.text.replaceAll(prefix, '').replaceAll(RegExp(r'\D'), '');
      final newDigits = digits;
      
      if (newDigits.length > oldDigits.length) {
        // Добавление символа - курсор в конец
        cursorPos = result.length;
      } else {
        // Удаление символа - курсор в конец
        cursorPos = result.length;
      }
    }

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: cursorPos),
    );
  }

  String _formatDigits(String digits) {
    if (digits.isEmpty) return '';
    
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 3 && i < digits.length) buffer.write(' ');
      if (i == 6 && i < digits.length) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

// lib/core/ui/widgets/phone_input_field.dart (добавить в конец файла)

/// Контроллер для PhoneInputField (упрощает доступ к данным)
class PhoneInputFieldController {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  
  String get rawPhone {
    final text = controller.text;
    final prefix = '+996 ';
    if (text.startsWith(prefix)) {
      final digits = text.replaceAll(prefix, '').replaceAll(RegExp(r'\D'), '');
      if (digits.length == 9) {
        return '+996$digits';
      }
    }
    return '';
  }
  
  bool get isValid => rawPhone.isNotEmpty && rawPhone.length == 12;
  
  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}