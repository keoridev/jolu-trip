import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';

class AppLauncher {
  static Future<void> openMapsApp(String type, double lat, double lng) async {
    final url = type == '2gis'
        ? 'https://2gis.kg/search/$lat,$lng'
        : 'https://maps.me/?ll=$lng,$lat&z=15';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> openApp(String packageName, String fallbackUrl) async {
    final androidUri = Uri.parse('market://details?id=$packageName');
    final iosUri = Uri.parse('https://apps.apple.com/app/$packageName');
    final fallbackUri = Uri.parse(fallbackUrl);

    try {
      if (await canLaunchUrl(androidUri)) {
        await launchUrl(androidUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(iosUri)) {
        await launchUrl(iosUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(fallbackUri);
      }
    } catch (e) {
      await launchUrl(fallbackUri);
    }
  }

  static Future<void> callEmergency() async {
    final uri = Uri.parse('tel:112');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  static Future<void> copyToClipboard(
    BuildContext context,
    String text,
    String message,
  ) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      JoluSnackbar.show(
        context: context,
        message: message,
        type: JoluSnackbarType.success,
      );
    }
  }
}
