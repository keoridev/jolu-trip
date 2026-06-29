import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Удаляем все не-цифры
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    // Фиксируем префикс +996
    String formatted;
    int selectionOffset = 0;
    
    if (digits.isEmpty) {
      formatted = '+996 ';
      selectionOffset = 5; // После +996 
    } else if (digits.length <= 3) {
      // Только код страны
      formatted = '+996';
      selectionOffset = digits.length + 1;
    } else if (digits.length <= 5) {
      // +996 (XX
      final first = digits.substring(3, digits.length);
      formatted = '+996 ($first';
      selectionOffset = formatted.length;
    } else if (digits.length <= 7) {
      // +996 (XXX) XX
      final first = digits.substring(3, 6);
      final second = digits.substring(6, digits.length);
      formatted = '+996 ($first) $second';
      selectionOffset = formatted.length;
    } else if (digits.length <= 9) {
      // +996 (XXX) XX-XX
      final first = digits.substring(3, 6);
      final second = digits.substring(6, 8);
      final third = digits.substring(8, digits.length);
      formatted = '+996 ($first) $second-$third';
      selectionOffset = formatted.length;
    } else {
      // +996 (XXX) XX-XX-XX
      final first = digits.substring(3, 6);
      final second = digits.substring(6, 8);
      final third = digits.substring(8, 10);
      final fourth = digits.substring(10, 12);
      formatted = '+996 ($first) $second-$third-$fourth';
      selectionOffset = formatted.length;
    }
    
    // Ограничиваем длину
    if (formatted.length > 21) {
      formatted = formatted.substring(0, 21);
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionOffset),
    );
  }
}