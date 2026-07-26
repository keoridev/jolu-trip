// lib/features/gamification/view/widgets/stamp_visuals.dart
//
// Единая визуальная система печатей: палитра редкости + справочник печатей.
// Используется карточками, каруселью, медальоном и деталкой.

import 'package:flutter/material.dart';
import '../../domain/entities/stamp.dart';

// ═══════════════════════════════════════════════════
// РЕДКОСТЬ
// ═══════════════════════════════════════════════════

class RarityStyle {
  /// Основной акцент — рамки, подписи, свечение.
  final Color accent;

  /// Тёмный конец градиента медальона.
  final Color deep;

  /// Подложка карточки (почти чёрная, с оттенком редкости).
  final Color surface;

  /// Контрастный цвет поверх акцента.
  final Color onAccent;

  final String label;

  const RarityStyle({
    required this.accent,
    required this.deep,
    required this.surface,
    required this.onAccent,
    required this.label,
  });

  LinearGradient get gradient => LinearGradient(
    colors: [accent, deep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  LinearGradient get cardGradient => LinearGradient(
    colors: [surface, const Color(0xFF141414)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  Color glow(double opacity) => accent.withValues(alpha: opacity);
}

const RarityStyle _common = RarityStyle(
  accent: Color(0xFF9CA3AF),
  deep: Color(0xFF4B5563),
  surface: Color(0xFF1A1C1F),
  onAccent: Color(0xFF0E0E10),
  label: 'Обычная',
);

const RarityStyle _silver = RarityStyle(
  accent: Color(0xFFD7DEE9),
  deep: Color(0xFF77839A),
  surface: Color(0xFF171A21),
  onAccent: Color(0xFF0E0E10),
  label: 'Серебряная',
);

const RarityStyle _gold = RarityStyle(
  accent: Color(0xFFFFC93C),
  deep: Color(0xFFB86E00),
  surface: Color(0xFF1F1808),
  onAccent: Color(0xFF231A00),
  label: 'Золотая',
);

const RarityStyle _legendary = RarityStyle(
  accent: Color(0xFFB388FF),
  deep: Color(0xFF6D28D9),
  surface: Color(0xFF191029),
  onAccent: Color(0xFFF5F0FF),
  label: 'Легендарная',
);

RarityStyle rarityStyle(StampRarity rarity) => switch (rarity) {
  StampRarity.common => _common,
  StampRarity.silver => _silver,
  StampRarity.gold => _gold,
  StampRarity.legendary => _legendary,
};

/// Порядок для сортировки: сначала самые редкие.
int rarityWeight(StampRarity rarity) => switch (rarity) {
  StampRarity.legendary => 3,
  StampRarity.gold => 2,
  StampRarity.silver => 1,
  StampRarity.common => 0,
};

// ═══════════════════════════════════════════════════
// СПРАВОЧНИК ПЕЧАТЕЙ
// ═══════════════════════════════════════════════════

class StampInfo {
  final String title;
  final String emoji;
  final IconData icon;
  final StampRarity rarity;

  /// Что нужно сделать, чтобы открыть печать.
  final String hint;
  final String region;

  const StampInfo({
    required this.title,
    required this.emoji,
    required this.icon,
    required this.rarity,
    required this.hint,
    required this.region,
  });
}

const Map<String, StampInfo> _catalog = {
  'first_step': StampInfo(
    title: 'Первый шаг',
    emoji: '👣',
    icon: Icons.hiking_rounded,
    rarity: StampRarity.common,
    hint: 'Сделайте первый чекин в любой локации',
    region: 'Кыргызстан',
  ),
  'first_canyon': StampInfo(
    title: 'Первый каньон',
    emoji: '🏜️',
    icon: Icons.terrain_rounded,
    rarity: StampRarity.gold,
    hint: 'Посетите свой первый каньон',
    region: 'Иссык-Кульская область',
  ),
  'skazka': StampInfo(
    title: 'Сказка',
    emoji: '🏔️',
    icon: Icons.landscape_rounded,
    rarity: StampRarity.gold,
    hint: 'Посетите каньон Сказка',
    region: 'Иссык-Кульская область',
  ),
  'konorchek': StampInfo(
    title: 'Конорчек',
    emoji: '🪨',
    icon: Icons.filter_hdr_rounded,
    rarity: StampRarity.silver,
    hint: 'Посетите каньон Конорчек',
    region: 'Чуйская область',
  ),
  'fairytale': StampInfo(
    title: 'Фейри Тейл',
    emoji: '🧚',
    icon: Icons.auto_awesome_rounded,
    rarity: StampRarity.legendary,
    hint: 'Посетите каньон Фейри Тейл',
    region: 'Иссык-Кульская область',
  ),
  'issyk_kul': StampInfo(
    title: 'Иссык-Куль',
    emoji: '🌊',
    icon: Icons.water_rounded,
    rarity: StampRarity.common,
    hint: 'Посетите озеро Иссык-Куль',
    region: 'Иссык-Кульская область',
  ),
  'ala_archa': StampInfo(
    title: 'Ала-Арча',
    emoji: '⛰️',
    icon: Icons.landscape_rounded,
    rarity: StampRarity.gold,
    hint: 'Посетите ущелье Ала-Арча',
    region: 'Чуйская область',
  ),
  'son_kul': StampInfo(
    title: 'Сон-Куль',
    emoji: '🐎',
    icon: Icons.grass_rounded,
    rarity: StampRarity.silver,
    hint: 'Посетите озеро Сон-Куль',
    region: 'Нарынская область',
  ),
  'guided': StampInfo(
    title: 'С проводником',
    emoji: '🧭',
    icon: Icons.verified_user_rounded,
    rarity: StampRarity.silver,
    hint: 'Пройдите маршрут с гидом',
    region: 'Кыргызстан',
  ),
  'autumn_1': StampInfo(
    title: 'Осенний старт',
    emoji: '🍂',
    icon: Icons.park_rounded,
    rarity: StampRarity.common,
    hint: 'Пройдите первый осенний маршрут',
    region: 'Кыргызстан',
  ),
  'autumn_2': StampInfo(
    title: 'Золотая тропа',
    emoji: '🍁',
    icon: Icons.forest_rounded,
    rarity: StampRarity.gold,
    hint: 'Пройдите второй осенний маршрут',
    region: 'Кыргызстан',
  ),
  'autumn_3': StampInfo(
    title: 'Хранитель осени',
    emoji: '🌰',
    icon: Icons.emoji_events_rounded,
    rarity: StampRarity.legendary,
    hint: 'Пройдите третий осенний маршрут',
    region: 'Кыргызстан',
  ),
};

const StampInfo _unknownStamp = StampInfo(
  title: '???',
  emoji: '❓',
  icon: Icons.help_outline_rounded,
  rarity: StampRarity.common,
  hint: 'Посетите локацию и сделайте чекин',
  region: 'Кыргызстан',
);

StampInfo stampInfoFor(String stampId) => _catalog[stampId] ?? _unknownStamp;
