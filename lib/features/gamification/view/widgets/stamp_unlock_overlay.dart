// lib/features/gamification/presentation/widgets/stamp_unlock_overlay.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/stamp.dart';
import 'stamp_unlock_animation.dart';

class StampUnlockOverlay extends StatelessWidget {
  final List<Stamp> stamps;
  final VoidCallback onComplete;

  const StampUnlockOverlay({
    super.key,
    required this.stamps,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    // Если несколько печатей — показываем первую
    // Остальные можно показать очередью
    final stamp = stamps.first;

    return StampUnlockAnimation(
      stamp: stamp,
      onComplete: onComplete,
    );
  }
}