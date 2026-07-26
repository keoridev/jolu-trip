// lib/features/gamification/view/widgets/stamp_medallion.dart
//
// Медальон печати: зубчатая «сургучная» печать с градиентом редкости,
// вращающимся кольцом делений и бликом. Одинаково выглядит в сетке,
// карусели и деталке — меняется только размер и наличие анимации.

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../domain/entities/stamp.dart';
import 'stamp_visuals.dart';

class StampMedallion extends StatefulWidget {
  final String stampId;
  final StampRarity rarity;

  /// Ассет печати. Если файла нет — рисуем эмодзи из справочника.
  final String? imageAsset;

  final double size;

  /// Закрытая печать: обесцвеченная, с замком.
  final bool locked;

  /// Вращение кольца + пробегающий блик. Включаем точечно,
  /// чтобы не анимировать всю сетку разом.
  final bool animate;

  const StampMedallion({
    super.key,
    required this.stampId,
    required this.rarity,
    this.imageAsset,
    this.size = 72,
    this.locked = false,
    this.animate = false,
  });

  @override
  State<StampMedallion> createState() => _StampMedallionState();
}

class _StampMedallionState extends State<StampMedallion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  );

  @override
  void initState() {
    super.initState();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant StampMedallion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate ||
        oldWidget.locked != widget.locked) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    final shouldRun = widget.animate && !widget.locked;
    if (shouldRun && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!shouldRun && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = stampInfoFor(widget.stampId);
    final style = rarityStyle(widget.rarity);
    final size = widget.size;

    final medallion = SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Зубчатая печать + кольцо делений
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              size: Size.square(size),
              painter: _SealPainter(
                accent: widget.locked ? const Color(0xFF3A3D45) : style.accent,
                deep: widget.locked ? const Color(0xFF23262C) : style.deep,
                rotation: _controller.value * 2 * math.pi,
                dim: widget.locked,
              ),
            ),
          ),

          // Центр: картинка или эмодзи
          ClipOval(
            child: SizedBox(
              width: size * 0.50,
              height: size * 0.50,
              child: _MedallionCore(
                info: info,
                imageAsset: widget.imageAsset,
                size: size,
                locked: widget.locked,
              ),
            ),
          ),

          // Пробегающий блик
          if (widget.animate && !widget.locked)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => IgnorePointer(
                child: ClipOval(
                  child: SizedBox(
                    width: size * 0.88,
                    height: size * 0.88,
                    child: Transform.rotate(
                      angle: _controller.value * 2 * math.pi,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            stops: const [0.30, 0.48, 0.66],
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.22),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Замок для закрытых
          if (widget.locked)
            Container(
              width: size * 0.36,
              height: size * 0.36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0E0F12).withValues(alpha: 0.85),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Icon(
                Icons.lock_rounded,
                size: size * 0.18,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
        ],
      ),
    );

    if (widget.locked) return medallion;

    // Свечение по цвету редкости
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: style.glow(0.28),
            blurRadius: size * 0.34,
            spreadRadius: size * 0.01,
          ),
        ],
      ),
      child: medallion,
    );
  }
}

class _MedallionCore extends StatelessWidget {
  final StampInfo info;
  final String? imageAsset;
  final double size;
  final bool locked;

  const _MedallionCore({
    required this.info,
    required this.imageAsset,
    required this.size,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Center(
      child: Text(info.emoji, style: TextStyle(fontSize: size * 0.30)),
    );

    Widget core = imageAsset == null || imageAsset!.isEmpty
        ? fallback
        : Image.asset(
            imageAsset!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => fallback,
          );

    if (locked) {
      core = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0, //
          0.2126, 0.7152, 0.0722, 0, 0, //
          0.2126, 0.7152, 0.0722, 0, 0, //
          0, 0, 0, 0.45, 0, //
        ]),
        child: core,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF101216),
      ),
      child: core,
    );
  }
}

// ═══════════════════════════════════════════════════
// ОТРИСОВКА ПЕЧАТИ
// ═══════════════════════════════════════════════════

class _SealPainter extends CustomPainter {
  final Color accent;
  final Color deep;
  final double rotation;
  final bool dim;

  const _SealPainter({
    required this.accent,
    required this.deep,
    required this.rotation,
    required this.dim,
  });

  static const int _teeth = 24;
  static const int _ticks = 36;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Зубчатый внешний диск
    final sealPath = _sealPath(center, radius, radius * 0.90);
    canvas.drawPath(
      sealPath,
      Paint()
        ..shader = LinearGradient(
          colors: [accent, deep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect),
    );

    // 2. Внутренний тёмный круг — «поле» печати
    canvas.drawCircle(
      center,
      radius * 0.78,
      Paint()..color = const Color(0xFF121317),
    );

    // 3. Кольцо делений, медленно вращается
    final tickPaint = Paint()
      ..color = accent.withValues(alpha: dim ? 0.25 : 0.65)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.0, radius * 0.045);

    for (int i = 0; i < _ticks; i++) {
      final angle = rotation + i * 2 * math.pi / _ticks;
      final long = i % 3 == 0;
      final rOuter = radius * 0.73;
      final rInner = radius * (long ? 0.62 : 0.67);
      final dir = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(center + dir * rInner, center + dir * rOuter, tickPaint);
    }

    // 4. Тонкий ободок вокруг центра
    canvas.drawCircle(
      center,
      radius * 0.55,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, radius * 0.03)
        ..color = accent.withValues(alpha: dim ? 0.2 : 0.5),
    );

    // 5. Верхний блик по краю — объём
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.92),
      math.pi * 1.15,
      math.pi * 0.55,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = math.max(1.0, radius * 0.06)
        ..color = Colors.white.withValues(alpha: dim ? 0.05 : 0.28),
    );
  }

  Path _sealPath(Offset center, double rOuter, double rInner) {
    final path = Path();
    const steps = _teeth * 2;
    for (int i = 0; i <= steps; i++) {
      final angle = i / steps * 2 * math.pi - math.pi / 2;
      final r = i.isEven ? rOuter : rInner;
      final point = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant _SealPainter old) =>
      old.rotation != rotation ||
      old.accent != accent ||
      old.deep != deep ||
      old.dim != dim;
}
