// lib/features/gamification/presentation/widgets/collection_complete_animation.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CollectionCompleteAnimation extends StatefulWidget {
  final String collectionTitle;
  final VoidCallback onComplete;

  const CollectionCompleteAnimation({
    super.key,
    required this.collectionTitle,
    required this.onComplete,
  });

  @override
  State<CollectionCompleteAnimation> createState() =>
      _CollectionCompleteAnimationState();
}

class _CollectionCompleteAnimationState
    extends State<CollectionCompleteAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiParticle> _particles;
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();

    HapticFeedback.heavyImpact();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _particles = List.generate(50, (index) => ConfettiParticle.random());

    _controller.forward();

    _autoCloseTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              ..._particles.map((p) => _buildParticle(p)),

              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStar(0),
                    _buildStar(0.2),
                    _buildStar(0.4),

                    const SizedBox(height: 24),

                    _buildTrophy(),

                    const SizedBox(height: 32),

                    Text(
                      'Коллекция завершена!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: const Color(0xFFFFD700).withOpacity(0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      widget.collectionTitle,
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Container(
                      width: 200,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _controller.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildParticle(ConfettiParticle particle) {
    final progress = _controller.value;
    final animationProgress =
        ((progress - particle.delay) / (1 - particle.delay)).clamp(0.0, 1.0);

    if (animationProgress <= 0) return const SizedBox.shrink();

    final x = particle.startX + (particle.velocityX * animationProgress * 300);
    final y = particle.startY +
        (particle.velocityY * animationProgress * 400) +
        (0.5 * 500 * animationProgress * animationProgress);

    final rotation = particle.rotationSpeed * animationProgress * 10;
    final opacity = (1 - animationProgress).clamp(0.0, 1.0);

    return Positioned(
      left: x,
      top: y,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: rotation,
          child: Container(
            width: particle.size,
            height: particle.size,
            decoration: BoxDecoration(
              color: particle.color,
              borderRadius: particle.isCircle
                  ? BorderRadius.circular(particle.size / 2)
                  : BorderRadius.zero,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStar(double delay) {
    final progress = ((_controller.value - delay) / (1 - delay)).clamp(0.0, 1.0);
    if (progress <= 0) return const SizedBox.shrink();

    final scale = sin(progress * pi) * 1.5;
    final opacity = (1 - progress).clamp(0.0, 1.0);

    return Positioned(
      left: 50 + (progress * 250),
      top: 100 + (sin(progress * 4) * 100),
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: const Icon(Icons.star, color: Color(0xFFFFD700), size: 24),
        ),
      ),
    );
  }

  Widget _buildTrophy() {
    final scale = 0.5 + (sin(_controller.value * pi) * 0.5);

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.4),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: const Icon(Icons.emoji_events, color: Colors.white, size: 60),
      ),
    );
  }
}

class ConfettiParticle {
  final double startX;
  final double startY;
  final double velocityX;
  final double velocityY;
  final double size;
  final Color color;
  final bool isCircle;
  final double rotationSpeed;
  final double delay;

  ConfettiParticle({
    required this.startX,
    required this.startY,
    required this.velocityX,
    required this.velocityY,
    required this.size,
    required this.color,
    required this.isCircle,
    required this.rotationSpeed,
    required this.delay,
  });

  factory ConfettiParticle.random() {
    final random = Random();
    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFF95E1D3),
      const Color(0xFFF38181),
      const Color(0xFFAA96DA),
      const Color(0xFFFFD93D),
    ];

    return ConfettiParticle(
      startX: random.nextDouble() * 400 - 50,
      startY: -20,
      velocityX: (random.nextDouble() - 0.5) * 4,
      velocityY: random.nextDouble() * 2 + 1,
      size: random.nextDouble() * 8 + 4,
      color: colors[random.nextInt(colors.length)],
      isCircle: random.nextBool(),
      rotationSpeed: (random.nextDouble() - 0.5) * 2,
      delay: random.nextDouble() * 0.5,
    );
  }
}