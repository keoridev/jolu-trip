// lib/core/ui/widgets/kyrgyz_license_plate.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

class KyrgyzLicensePlate extends StatelessWidget {
  final String region; // "01"
  final String digits; // "777"
  final String letters; // "AAA"
  final double height;
  final bool showShadow;

  const KyrgyzLicensePlate({
    super.key,
    required this.region,
    required this.digits,
    required this.letters,
    this.height = 70,
    this.showShadow = true,
  });

  factory KyrgyzLicensePlate.fromString(String plate, {double height = 70}) {
    final clean = plate.toUpperCase().replaceAll(' ', '').replaceAll('-', '');
    if (clean.length >= 8) {
      final region = clean.substring(0, 2);
      final digits = clean.substring(4, 7);
      final letters = clean.substring(7);
      return KyrgyzLicensePlate(
        region: region,
        digits: digits,
        letters: letters,
        height: height,
      );
    }
    return KyrgyzLicensePlate(
      region: '01',
      digits: '000',
      letters: 'AAA',
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = height * 4.5; // Соотношение сторон ~4.5:1

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(height * 0.08),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: width * 0.22,
            height: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.black, width: 1.2),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Цифры региона
                Text(
                  region,
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: height * 0.45,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    height: 1.0,
                  ),
                ),

                SizedBox(height: height * 0.02),

                // Флаг КР + KG
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Флаг КР (программно)
                    _KyrgyzFlag(size: height * 0.18),
                    SizedBox(width: height * 0.04),
                    Text(
                      'KG',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: height * 0.30,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ═══════════════════════════════════════════
          // ПРАВАЯ ЧАСТЬ: Номер
          // ═══════════════════════════════════════════
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: height * 0.15),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Цифры
                    Text(
                      digits,
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: height * 0.55,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: height * 0.02,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(width: height * 0.08),
                    // Буквы
                    Text(
                      letters,
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: height * 0.55,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: height * 0.02,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔥 Программный флаг Кыргызстана (красный фон + жёлтое солнце с 40 лучами)
class _KyrgyzFlag extends StatelessWidget {
  final double size;

  const _KyrgyzFlag({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 1.4,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE4002B), // Красный флаг КР
        borderRadius: BorderRadius.circular(size * 0.05),
        border: Border.all(color: Colors.black26, width: 0.5),
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.7, size * 0.7),
          painter: _SunPainter(),
        ),
      ),
    );
  }
}

class _SunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;
    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    // Центральный круг
    canvas.drawCircle(center, radius * 0.35, paint);

    // 40 лучей
    final rayPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 40; i++) {
      final angle = (i * 9) * math.pi / 180; // 360/40 = 9 градусов
      final innerRadius = radius * 0.45;
      final outerRadius = radius * 0.85;
      final midRadius = radius * 0.55;

      // Треугольный луч
      final path = Path()
        ..moveTo(
          center.dx + math.cos(angle - 0.04) * innerRadius,
          center.dy + math.sin(angle - 0.04) * innerRadius,
        )
        ..lineTo(
          center.dx + math.cos(angle) * outerRadius,
          center.dy + math.sin(angle) * outerRadius,
        )
        ..lineTo(
          center.dx + math.cos(angle + 0.04) * innerRadius,
          center.dy + math.sin(angle + 0.04) * innerRadius,
        )
        ..close();

      canvas.drawPath(path, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
