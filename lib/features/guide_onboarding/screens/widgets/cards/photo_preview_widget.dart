import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';

class PhotoPreviewWidget extends StatelessWidget {
  final Uint8List bytes;
  final int index;
  final VoidCallback onRemove;

  const PhotoPreviewWidget({
    super.key,
    required this.bytes,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final photoTypes = ['Перед', 'Зад', 'Салон', 'Багажник'];

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              photoTypes[index % photoTypes.length],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}
