import 'package:flutter/material.dart';

/// Каталоги вариантов, общие для всех шагов анкеты.
///
/// Шаг 1 строит по ним селекторы, шаг 3 — сводку. За счёт этого подписи в
/// сводке всегда совпадают с тем, что гид реально выбрал.

// ─── Категория автомобиля ────────────────────────────────────────────────
class CarCategoryOption {
  final String value;
  final String label;
  final String description;
  final IconData icon;

  const CarCategoryOption({
    required this.value,
    required this.label,
    required this.description,
    required this.icon,
  });
}

const List<CarCategoryOption> carCategoryOptions = [
  CarCategoryOption(
    value: 'sedan',
    label: 'Седан',
    description: 'До 3 гостей',
    icon: Icons.directions_car_rounded,
  ),
  CarCategoryOption(
    value: 'suv',
    label: 'Внедорожник',
    description: 'Горные дороги',
    icon: Icons.terrain_rounded,
  ),
  CarCategoryOption(
    value: 'minivan',
    label: 'Минивэн',
    description: 'До 6 гостей',
    icon: Icons.airport_shuttle_rounded,
  ),
  CarCategoryOption(
    value: 'minibus',
    label: 'Микроавтобус',
    description: 'До 15 гостей',
    icon: Icons.directions_bus_rounded,
  ),
  CarCategoryOption(
    value: 'ev',
    label: 'Электромобиль',
    description: 'Без выбросов',
    icon: Icons.electric_car_rounded,
  ),
];

CarCategoryOption? carCategoryByValue(String? value) {
  if (value == null) return null;
  for (final option in carCategoryOptions) {
    if (option.value == value) return option;
  }
  return null;
}

String carCategoryLabel(String? value) =>
    carCategoryByValue(value)?.label ?? 'Не выбрана';

// ─── Языки ───────────────────────────────────────────────────────────────
class LanguageOption {
  final String code;
  final String label;

  const LanguageOption({required this.code, required this.label});
}

const List<LanguageOption> languageOptions = [
  LanguageOption(code: 'ru', label: 'Русский'),
  LanguageOption(code: 'en', label: 'English'),
  LanguageOption(code: 'ky', label: 'Кыргызча'),
];

String languageLabel(String code) {
  for (final option in languageOptions) {
    if (option.code == code) return option.label;
  }
  return code.toUpperCase();
}

// ─── Слоты фото автомобиля ───────────────────────────────────────────────
/// Ровно четыре ракурса в фиксированном порядке. Порядок важен: он же уходит
/// на бэкенд, поэтому слоты нумерованные, а не «просто список фото».
class CarPhotoSlot {
  final String label;
  final String hint;
  final IconData icon;

  const CarPhotoSlot({
    required this.label,
    required this.hint,
    required this.icon,
  });
}

const List<CarPhotoSlot> carPhotoSlots = [
  CarPhotoSlot(
    label: 'Спереди',
    hint: 'Вид спереди целиком',
    icon: Icons.directions_car_rounded,
  ),
  CarPhotoSlot(
    label: 'Сзади',
    hint: 'Виден гос. номер',
    icon: Icons.rotate_left_rounded,
  ),
  CarPhotoSlot(
    label: 'Салон',
    hint: 'Передние и задние сиденья',
    icon: Icons.airline_seat_recline_normal_rounded,
  ),
  CarPhotoSlot(
    label: 'Багажник',
    hint: 'Открытый багажник',
    icon: Icons.luggage_rounded,
  ),
];

class CarFeatureOption {
  final String value;
  final String label;

  const CarFeatureOption({required this.value, required this.label});
}

const List<CarFeatureOption> carFeatureOptions = [
  CarFeatureOption(value: 'ac', label: 'Кондиционер'),
  CarFeatureOption(value: 'child_seat', label: 'Детское кресло'),
  CarFeatureOption(value: 'wifi', label: 'Wi-Fi'),
  CarFeatureOption(value: 'usb_charging', label: 'Зарядка USB'),
  CarFeatureOption(value: 'large_trunk', label: 'Большой багажник'),
  CarFeatureOption(value: 'leather_seats', label: 'Кожаный салон'),
  CarFeatureOption(value: 'panoramic_roof', label: 'Панорамная крыша'),
  CarFeatureOption(value: 'heated_seats', label: 'Подогрев сидений'),
];

String carFeatureLabel(String value) {
  for (final option in carFeatureOptions) {
    if (option.value == value) return option.label;
  }
  return value;
}
