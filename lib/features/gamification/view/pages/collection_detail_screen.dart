import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/collection.dart';
import '../../domain/entities/stamp.dart';

class CollectionDetailScreen extends StatelessWidget {
  final Collection collection;
  final List<Stamp> earnedStamps;

  const CollectionDetailScreen({
    super.key,
    required this.collection,
    required this.earnedStamps,
  });

  @override
  Widget build(BuildContext context) {
    final earnedIds = earnedStamps.map((s) => s.id).toSet();
    final progress = collection.stampIds.isEmpty
        ? 0.0
        : earnedIds.length / collection.stampIds.length;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            backgroundColor: AppColors.bgDark,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
              ),
              onPressed: () => context.pop(),
            ),
            title: Text(
              collection.title,
              style: AppTextStyles.headline.copyWith(fontSize: 18),
            ),
            centerTitle: true,
          ),

          // Заголовок + прогресс
          SliverToBoxAdapter(
            child: _CollectionHeader(
              collection: collection,
              earnedCount: earnedIds.length,
              totalCount: collection.stampIds.length,
              progress: progress,
            ),
          ),

          // Сетка печатей
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final stampId = collection.stampIds[index];
                final isEarned = earnedIds.contains(stampId);
                final stamp = isEarned
                    ? earnedStamps.firstWhere((s) => s.id == stampId)
                    : null;

                return isEarned && stamp != null
                    ? _EarnedStampCard(stamp: stamp)
                    : _LockedStampCard(
                        stampId: stampId,
                        collection: collection,
                      );
              }, childCount: collection.stampIds.length),
            ),
          ),

          // Список "Что нужно сделать"
          if (collection.stampIds.length > earnedIds.length)
            SliverToBoxAdapter(
              child: _TodoList(collection: collection, earnedIds: earnedIds),
            ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// ЗАГОЛОВОК КОЛЛЕКЦИИ
// ═══════════════════════════════════════════════════

class _CollectionHeader extends StatelessWidget {
  final Collection collection;
  final int earnedCount;
  final int totalCount;
  final double progress;

  const _CollectionHeader({
    required this.collection,
    required this.earnedCount,
    required this.totalCount,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = earnedCount == totalCount;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(
          color: isCompleted
              ? AppColors.primary.withOpacity(0.5)
              : AppColors.borderDark,
        ),
      ),
      child: Column(
        children: [
          // Бейдж
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.primary.withOpacity(0.15)
                  : Colors.grey[800],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCompleted ? Icons.emoji_events : Icons.lock_clock,
                  size: 14,
                  color: isCompleted ? AppColors.primary : Colors.grey[500],
                ),
                const SizedBox(width: 6),
                Text(
                  isCompleted ? 'Коллекция завершена!' : 'В процессе',
                  style: TextStyle(
                    color: isCompleted ? AppColors.primary : Colors.grey[500],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            collection.description,
            style: AppTextStyles.subtext,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Прогресс-бар
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.isNaN ? 0 : progress,
                    backgroundColor: Colors.grey[800],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.7),
                    ),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$earnedCount / $totalCount',
                style: AppTextStyles.title.copyWith(
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// ОТКРЫТАЯ ПЕЧАТЬ
// ═══════════════════════════════════════════════════

class _EarnedStampCard extends StatelessWidget {
  final Stamp stamp;

  const _EarnedStampCard({required this.stamp});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _getRarityBgColor(stamp.rarity),
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(
          color: _getRarityColor(stamp.rarity).withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Бейдж "ЕСТЬ"
          Align(
            alignment: Alignment.topRight,
            child: Container(
              margin: const EdgeInsets.only(top: 8, right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getRarityColor(stamp.rarity),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '✓ ЕСТЬ',
                style: TextStyle(
                  color: _getContrastColor(stamp.rarity),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          // Аватар печати
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _getRarityGradient(stamp.rarity),
              boxShadow: [
                BoxShadow(
                  color: _getRarityColor(stamp.rarity).withOpacity(0.25),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                stamp.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(
                    Icons.stars,
                    size: 32,
                    color: _getContrastColor(stamp.rarity),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Название
          Text(
            stamp.title,
            style: AppTextStyles.title.copyWith(fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 2),

          // Редкость
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: _getRarityColor(stamp.rarity).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _getRarityLabel(stamp.rarity),
              style: TextStyle(
                color: _getRarityColor(stamp.rarity),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// ЗАБЛОКИРОВАННАЯ ПЕЧАТЬ
// ═══════════════════════════════════════════════════

class _LockedStampCard extends StatelessWidget {
  final String stampId;
  final Collection collection;

  const _LockedStampCard({required this.stampId, required this.collection});

  @override
  Widget build(BuildContext context) {
    final placeholder = _getPlaceholderForStamp(stampId);

    return Stack(
      children: [
        // Затемнённая карточка подложки
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            border: Border.all(
              color: Colors.white.withOpacity(0.06),
              width: 1.5,
            ),
          ),
          child: Opacity(
            opacity: 0.25,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: placeholder.gradient,
                  ),
                  child: Center(
                    child: Text(
                      placeholder.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  placeholder.title,
                  style: AppTextStyles.title.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: placeholder.rarityColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    placeholder.rarityLabel,
                    style: TextStyle(
                      color: placeholder.rarityColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Оверлей с замком
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0F).withOpacity(0.75),
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: Colors.white54,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ЗАБЛОКИРОВАНО',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    placeholder.unlockHint,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 10,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _StampPlaceholder _getPlaceholderForStamp(String stampId) {
    // Здесь маппинг ID печатей на данные
    return switch (stampId) {
      'first_canyon' => _StampPlaceholder(
        title: 'Сказка',
        emoji: '🏔️',
        rarityColor: const Color(0xFFFFD700),
        rarityLabel: 'Золотая',
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
        ),
        unlockHint: 'Посетите каньон Сказка',
      ),
      'skazka' => _StampPlaceholder(
        title: 'Сказка',
        emoji: '🏔️',
        rarityColor: const Color(0xFFFFD700),
        rarityLabel: 'Золотая',
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
        ),
        unlockHint: 'Посетите каньон Сказка',
      ),
      'konorchek' => _StampPlaceholder(
        title: 'Конорчек',
        emoji: '🪨',
        rarityColor: const Color(0xFFC0C0C0),
        rarityLabel: 'Серебряная',
        gradient: const LinearGradient(
          colors: [Color(0xFFC0C0C0), Color(0xFF888888)],
        ),
        unlockHint: 'Посетите каньон Конорчек',
      ),
      'fairytale' => _StampPlaceholder(
        title: 'Фейри Тейл',
        emoji: '🌊',
        rarityColor: const Color(0xFFB388FF),
        rarityLabel: 'Легендарная',
        gradient: const LinearGradient(
          colors: [Color(0xFFB388FF), Color(0xFF7C4DFF)],
        ),
        unlockHint: 'Посетите каньон Фейри Тейл',
      ),
      'issyk_kul' => _StampPlaceholder(
        title: 'Иссык-Куль',
        emoji: '🌊',
        rarityColor: const Color(0xFF4ECDC4),
        rarityLabel: 'Обычная',
        gradient: const LinearGradient(
          colors: [Color(0xFF4ECDC4), Color(0xFF2A8A84)],
        ),
        unlockHint: 'Посетите озеро Иссык-Куль',
      ),
      'ala_archa' => _StampPlaceholder(
        title: 'Ала-Арча',
        emoji: '🏔️',
        rarityColor: const Color(0xFFFFD700),
        rarityLabel: 'Золотая',
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
        ),
        unlockHint: 'Посетите ущелье Ала-Арча',
      ),
      'son_kul' => _StampPlaceholder(
        title: 'Сон-Куль',
        emoji: '🐎',
        rarityColor: const Color(0xFFC0C0C0),
        rarityLabel: 'Серебряная',
        gradient: const LinearGradient(
          colors: [Color(0xFFC0C0C0), Color(0xFF888888)],
        ),
        unlockHint: 'Посетите озеро Сон-Куль',
      ),
      _ => _StampPlaceholder(
        title: '???',
        emoji: '❓',
        rarityColor: Colors.grey,
        rarityLabel: 'Неизвестно',
        gradient: const LinearGradient(colors: [Colors.grey, Colors.grey]),
        unlockHint: 'Посетите локацию',
      ),
    };
  }
}

class _StampPlaceholder {
  final String title;
  final String emoji;
  final Color rarityColor;
  final String rarityLabel;
  final Gradient gradient;
  final String unlockHint;

  const _StampPlaceholder({
    required this.title,
    required this.emoji,
    required this.rarityColor,
    required this.rarityLabel,
    required this.gradient,
    required this.unlockHint,
  });
}

// ═══════════════════════════════════════════════════
// СПИСОК "ЧТО НУЖНО СДЕЛАТЬ"
// ═══════════════════════════════════════════════════

class _TodoList extends StatelessWidget {
  final Collection collection;
  final Set<String> earnedIds;

  const _TodoList({required this.collection, required this.earnedIds});

  @override
  Widget build(BuildContext context) {
    final lockedIds = collection.stampIds
        .where((id) => !earnedIds.contains(id))
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          Text(
            'Что нужно сделать:',
            style: AppTextStyles.subtext.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 10),

          ...lockedIds.map((stampId) => _TodoItem(stampId: stampId)),

          const SizedBox(height: 8),

          // Подсказка
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: Colors.white38,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Чтобы разблокировать печать, посетите локацию и сделайте чекин',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodoItem extends StatelessWidget {
  final String stampId;

  const _TodoItem({required this.stampId});

  @override
  Widget build(BuildContext context) {
    final info = _getStampInfo(stampId);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: info.color.withOpacity(0.15),
            ),
            child: Center(
              child: Text(info.emoji, style: const TextStyle(fontSize: 14)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.action,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  info.region,
                  style: AppTextStyles.subtext.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[700]!, width: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  ({String emoji, String action, String region, Color color}) _getStampInfo(
    String stampId,
  ) {
    return switch (stampId) {
      'first_canyon' || 'skazka' => (
        emoji: '🏔️',
        action: 'Посетить каньон Сказка',
        region: 'Иссык-Кульская область',
        color: const Color(0xFFFFD700),
      ),
      'konorchek' => (
        emoji: '🪨',
        action: 'Посетить каньон Конорчек',
        region: 'Иссык-Кульская область',
        color: const Color(0xFFC0C0C0),
      ),
      'fairytale' => (
        emoji: '🌊',
        action: 'Посетить каньон Фейри Тейл',
        region: 'Иссык-Кульская область',
        color: const Color(0xFFB388FF),
      ),
      'issyk_kul' => (
        emoji: '🌊',
        action: 'Посетить озеро Иссык-Куль',
        region: 'Иссык-Кульская область',
        color: const Color(0xFF4ECDC4),
      ),
      'ala_archa' => (
        emoji: '🏔️',
        action: 'Посетить ущелье Ала-Арча',
        region: 'Чуйская область',
        color: const Color(0xFFFFD700),
      ),
      'son_kul' => (
        emoji: '🐎',
        action: 'Посетить озеро Сон-Куль',
        region: 'Нарынская область',
        color: const Color(0xFFC0C0C0),
      ),
      _ => (
        emoji: '📍',
        action: 'Посетить локацию',
        region: 'Кыргызстан',
        color: Colors.grey,
      ),
    };
  }
}

// ═══════════════════════════════════════════════════
// ХЕЛПЕРЫ
// ═══════════════════════════════════════════════════

Color _getRarityColor(StampRarity rarity) {
  return switch (rarity) {
    StampRarity.common => Colors.grey[400]!,
    StampRarity.silver => const Color(0xFFC0C0C0),
    StampRarity.gold => const Color(0xFFFFD700),
    StampRarity.legendary => const Color(0xFFB388FF),
  };
}

Color _getRarityBgColor(StampRarity rarity) {
  return switch (rarity) {
    StampRarity.common => Colors.grey[900]!,
    StampRarity.silver => const Color(0xFF1A1A2E),
    StampRarity.gold => const Color(0xFF1A1500),
    StampRarity.legendary => const Color(0xFF1A0A2E),
  };
}

Gradient _getRarityGradient(StampRarity rarity) {
  return switch (rarity) {
    StampRarity.common => LinearGradient(
      colors: [Colors.grey[600]!, Colors.grey[800]!],
    ),
    StampRarity.silver => const LinearGradient(
      colors: [Color(0xFFC0C0C0), Color(0xFF888888)],
    ),
    StampRarity.gold => const LinearGradient(
      colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
    ),
    StampRarity.legendary => const LinearGradient(
      colors: [Color(0xFFB388FF), Color(0xFF7C4DFF)],
    ),
  };
}

String _getRarityLabel(StampRarity rarity) {
  return switch (rarity) {
    StampRarity.common => 'Обычная',
    StampRarity.silver => 'Серебряная',
    StampRarity.gold => 'Золотая',
    StampRarity.legendary => 'Легендарная',
  };
}

Color _getContrastColor(StampRarity rarity) {
  return switch (rarity) {
    StampRarity.common => Colors.black,
    StampRarity.silver => Colors.black,
    StampRarity.gold => Colors.black,
    StampRarity.legendary => Colors.white,
  };
}
