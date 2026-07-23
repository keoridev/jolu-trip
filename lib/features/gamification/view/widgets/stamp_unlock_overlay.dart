
import 'package:flutter/material.dart';
import '../../domain/entities/stamp.dart';
import 'stamp_unlock_animation.dart';

class StampUnlockOverlay extends StatefulWidget {
  final List<Stamp> stamps;
  final VoidCallback onComplete;

  const StampUnlockOverlay({
    super.key,
    required this.stamps,
    required this.onComplete,
  });

  @override
  State<StampUnlockOverlay> createState() => _StampUnlockOverlayState();
}

class _StampUnlockOverlayState extends State<StampUnlockOverlay> {
  int _currentIndex = 0;

  void _onNext() {
    if (_currentIndex < widget.stamps.length - 1) {
      setState(() => _currentIndex++);
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stamps.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onComplete());
      return const SizedBox.shrink();
    }

    return StampUnlockAnimation(
      stamp: widget.stamps[_currentIndex],
      onComplete: _onNext,
    );
  }
}