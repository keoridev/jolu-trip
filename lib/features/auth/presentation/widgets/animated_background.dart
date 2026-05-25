import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                sin(_controller.value * 2 * pi) * 0.3,
                cos(_controller.value * 2 * pi) * 0.3,
              ),
              radius: 1.0,
              colors: [AppColors.bgDark, AppColors.cardDark],
              stops: const [0.3, 1.0],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
