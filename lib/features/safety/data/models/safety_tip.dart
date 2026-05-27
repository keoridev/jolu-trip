
class SafetyTip {
  const SafetyTip({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.priority = 0,
  });
  final String id;
  final String title;
  final String content;
  final SafetyCategory category;
  final int priority;
}

enum SafetyCategory {
  preparation('Подготовка'),
  culture('Культура'),
  language('Язык'),
  health('Здоровье'),
  practical('Практика');

  final String title;
  const SafetyCategory(this.title);
}
