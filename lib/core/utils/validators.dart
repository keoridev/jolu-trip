class Validators {
  static bool isValidKgPhone(String phone) {
    if (phone.isEmpty) return false;

    final phoneRegex = RegExp(r'^\+996\d{9}$');

    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    return phoneRegex.hasMatch(cleanPhone);
  }

  static bool isValidPassword(String password) {
    return password.isNotEmpty && password.length >= 6;
  }
}
