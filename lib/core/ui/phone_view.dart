import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

class PhoneInputField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final bool autoFocus;
  final ValueChanged<bool>? onValidityChanged;
  final VoidCallback? onSubmitted;

  const PhoneInputField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = '700 000 000',
    this.autoFocus = false,
    this.onValidityChanged,
    this.onSubmitted,
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isValid = false;

  static const String _prefix = '+996 ';
  static const int _maxDigits = 9;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    if (_controller.text.isEmpty) {
      _controller.text = _prefix;
    }

    // ✅ ИСПРАВЛЕНО: Listener только читает и валидирует, НЕ меняет текст
    _controller.addListener(_onTextChanged);

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
          _moveCursorToEnd();
        }
      });
    }
  }

  void _onTextChanged() {
    final digits = _getDigitsOnly();
    final isValid = digits.length == _maxDigits;
    
    if (isValid != _isValid) {
      setState(() => _isValid = isValid);
      widget.onValidityChanged?.call(isValid);
    }
  }

  String _getDigitsOnly() {
    return _controller.text.replaceAll(_prefix, '').replaceAll(RegExp(r'\D'), '');
  }

  String get rawPhone {
    final digits = _getDigitsOnly();
    return digits.length == _maxDigits ? '+996$digits' : '';
  }

  void _moveCursorToEnd() {
    _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.phone,
      // ✅ ИСПРАВЛЕНО: Весь парсинг и управление курсором теперь только здесь
      inputFormatters: [_PhoneNumberInputFormatter(_prefix, _maxDigits)],
      style: AppTextStyles.headline.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: AppTextStyles.subtext.copyWith(fontSize: 24, color: AppColors.textTertiary),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(right: AppDimens.space8),
          child: Icon(Icons.phone_android_rounded, color: AppColors.textSecondary, size: AppDimens.icon24),
        ),
        suffixIcon: _isValid
            ? const Padding(
                padding: EdgeInsets.only(right: AppDimens.space16),
                child: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
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
          borderSide: BorderSide(color: _isValid ? AppColors.success : AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: AppDimens.space16, horizontal: AppDimens.space16),
      ),
      onEditingComplete: () {
        if (_isValid) widget.onSubmitted?.call();
      },
    );
  }
}

class _PhoneNumberInputFormatter extends TextInputFormatter {
  final String prefix;
  final int maxDigits;

  _PhoneNumberInputFormatter(this.prefix, this.maxDigits);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // 1. Защита от полного удаления префикса
    if (newValue.text.length < prefix.length) {
      return TextEditingValue(
        text: prefix,
        selection: TextSelection.collapsed(offset: prefix.length),
      );
    }

    // 2. Извлекаем только цифры, введенные пользователем
    String digits = newValue.text.replaceAll(prefix, '').replaceAll(RegExp(r'\D'), '');

    // 3. Ограничиваем длину
    if (digits.length > maxDigits) {
      digits = digits.substring(0, maxDigits);
    }

    // 4. Форматируем с пробелами (700 000 000)
    final formatted = _formatDigits(digits);
    final result = prefix + formatted;

    // 5. ✅ УМНЫЙ КУРСОР: Сохраняем позицию относительно ввода/удаления
    int cursorPos = result.length;
    final oldDigits = oldValue.text.replaceAll(prefix, '').replaceAll(RegExp(r'\D'), '');
    
    if (newValue.text.length < oldValue.text.length) {
      // Удаление: сдвигаем курсор назад на 1, но не дальше префикса
      cursorPos = (oldValue.selection.baseOffset - 1).clamp(prefix.length, result.length);
    } else {
      // Ввод: курсор в конец нового результата
      cursorPos = result.length;
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
      if (i == 3 || i == 6) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

// ✅ УПРОЩЕННЫЙ КОНТРОЛЛЕР (без ручного dispose, виджет сам разберется)
class PhoneInputFieldController {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  String get rawPhone {
    final text = controller.text;
    const prefix = '+996 ';
    if (text.startsWith(prefix)) {
      final digits = text.replaceAll(prefix, '').replaceAll(RegExp(r'\D'), '');
      if (digits.length == 9) return '+996$digits';
    }
    return '';
  }

  bool get isValid => rawPhone.length == 12;
}