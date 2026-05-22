class StringFormatter {
  static String formatDuration(String rawDuration) {
    if (rawDuration.isEmpty) return 'Неизветсно';

    final hourRegExp = RegExp(r'(\d+)h');
    final minuteRegExp = RegExp(r'(\d+)m');

    final hourMath = hourRegExp.firstMatch(rawDuration);
    final minuteMatch = minuteRegExp.firstMatch(rawDuration);

    String result = '';

    if (hourMath != null) {
      final hours = hourMath.group(1);
      result += '$hours ч. ';
    }

    if (minuteMatch != null) {
      final minutes = minuteMatch.group(1);
      result += '$minutes мин.';
    }

    if (result.isEmpty) return rawDuration;

    return result.trim();
  }
}
