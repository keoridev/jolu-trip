import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestGalleryPermission() async {
    if (await Permission.photos.request().isGranted) {
      return true;
    }
    if (await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }

  static Future<bool> checkAndRequestPermission(Permission permission) async {
    final status = await permission.request();
    if (status.isGranted) {
      return true;
    }
    if (status.isPermanentlyDenied) {
      // Показываем диалог, чтобы пользователь включил пермишен в настройках
      return false;
    }
    return false;
  }

  static Future<void> showPermissionDeniedDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Доступ запрещен'),
        content: const Text(
          'Пожалуйста, предоставьте доступ к камере и галерее в настройках устройства.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text('Настройки'),
          ),
        ],
      ),
    );
  }
}
