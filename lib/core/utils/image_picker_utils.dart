import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerUtils {
  final ImagePicker _picker = ImagePicker();

  bool _isPicking = false;

  // Метод для выбора из камеры или галереи с диалогом
  Future<Uint8List?> showImagePickerDialog(BuildContext context) async {
    return showModalBottomSheet<Uint8List?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Выберите фото',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  context,
                  icon: Icons.photo_library,
                  label: 'Галерея',
                  onTap: () async {
                    final bytes = await pickImageFromSource(
                      source: ImageSource.gallery,
                    );
                    if (context.mounted) Navigator.pop(context, bytes);
                  },
                ),
                _buildPickerOption(
                  context,
                  icon: Icons.photo_camera,
                  label: 'Камера',
                  onTap: () async {
                    final bytes = await pickImageFromSource(
                      source: ImageSource.camera,
                    );
                    if (context.mounted) Navigator.pop(context, bytes);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
              child: const Text('Отмена'),
            ),
          ],
        ),
      ),
    ).then((value) => value);
  }

  // Метод для выбора изображения из конкретного источника
  Future<Uint8List?> pickImageFromSource({
    required ImageSource source,
    double maxWidth = 1920,
    double maxHeight = 1080,
    int imageQuality = 85,
  }) async {
    // Предотвращаем множественные вызовы
    if (_isPicking) {
      debugPrint('⚠️ Image picker is already active');
      return null;
    }

    try {
      _isPicking = true;

      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        return bytes;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error picking image: $e');
      return null;
    } finally {
      _isPicking = false;
    }
  }

  // Виджет опции выбора
  Widget _buildPickerOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
