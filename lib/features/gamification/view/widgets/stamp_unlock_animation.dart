import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/stamp.dart';

class StampUnlockAnimation extends StatefulWidget {
  final Stamp stamp;
  final VoidCallback onComplete;

  const StampUnlockAnimation({
    super.key,
    required this.stamp,
    required this.onComplete,
  });

  @override
  State<StampUnlockAnimation> createState() => _StampUnlockAnimationState();
}

class _StampUnlockAnimationState extends State<StampUnlockAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _ringController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Вибрация при старте
    HapticFeedback.mediumImpact();

    // Контроллер масштаба печати
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Контроллер кольцевой волны
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ringController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Запускаем
    _scaleController.forward();
    _ringController.forward();

    // Закрываем через 2.5 секунды
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Кольцевая волна
            AnimatedBuilder(
              animation: _ringController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Волна 1
                    _buildRing(0),
                    // Волна 2 (с задержкой)
                    _buildRing(0.3),
                    // Волна 3 (с задержкой)
                    _buildRing(0.6),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // Текст
            Text(
              'Новая печать!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: _getRarityColor(
                      widget.stamp.rarity,
                    ).withOpacity(0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Печать с анимацией масштаба
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getRarityColor(widget.stamp.rarity),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getRarityColor(
                        widget.stamp.rarity,
                      ).withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    widget.stamp.imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: _getRarityColor(
                        widget.stamp.rarity,
                      ).withOpacity(0.2),
                      child: Icon(
                        Icons.stars,
                        size: 60,
                        color: _getRarityColor(widget.stamp.rarity),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Название печати
            Text(
              widget.stamp.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            // Редкость
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _getRarityColor(widget.stamp.rarity).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getRarityColor(widget.stamp.rarity).withOpacity(0.5),
                ),
              ),
              child: Text(
                _getRarityLabel(widget.stamp.rarity),
                style: TextStyle(
                  color: _getRarityColor(widget.stamp.rarity),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRing(double delay) {
    final delayedValue =
        (_ringController.value - delay).clamp(0.0, 1.0) / (1 - delay);

    if (delayedValue <= 0) return const SizedBox.shrink();

    return Opacity(
      opacity: (1 - delayedValue) * _opacityAnimation.value,
      child: Transform.scale(
        scale: 0.5 + (delayedValue * 1.5),
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _getRarityColor(widget.stamp.rarity).withOpacity(0.6),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Color _getRarityColor(StampRarity rarity) {
    return switch (rarity) {
      StampRarity.common => Colors.grey[400]!,
      StampRarity.silver => Colors.grey[300]!,
      StampRarity.gold => const Color(0xFFFFD700),
      StampRarity.legendary => const Color(0xFFB388FF),
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
}
