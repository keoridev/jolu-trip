// lib/core/utils/validators.dart

class Validators {
  const Validators._();

  static bool isValidKgPhone(String phone) {
    if (phone.isEmpty) return false;
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Поддерживаем форматы:
    // +996XXXXXXXXX (13 символов)
    // 996XXXXXXXXX (12 цифр)
    return RegExp(r'^(\+996|996)\d{9}$').hasMatch(cleanPhone);
  }

  static String formatPhoneForApi(String phone) {
    // Убираем все лишние символы
    final clean = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Если уже есть + в начале
    if (clean.startsWith('+')) return clean;

    // Если начинается с 996
    if (clean.startsWith('996')) return '+$clean';

    // Если только цифры без префикса
    if (clean.length == 9) return '+996$clean';

    // Fallback
    return '+996$clean';
  }

  static String formatPhoneForDisplay(String phone) {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.length >= 12) {
      final code = clean.substring(3, 6);
      final part1 = clean.substring(6, 8);
      final part2 = clean.substring(8, 10);
      final part3 = clean.substring(10, 12);
      return '+996 ($code) $part1-$part2-$part3';
    }
    return phone;
  }

  static bool isValidPassword(String password) {
    return password.isNotEmpty && password.length >= 6;
  }

  static bool isValidOtp(String code) {
    return code.length == 4 && RegExp(r'^\d{4}$').hasMatch(code);
  }
}
