import 'dart:io';

import 'package:flutter/foundation.dart';

class EnvironmentSwitch {
  static const String emulatorUrl = 'http://10.0.2.2:8085/api/v1';
  static const String realDeviceUrl =
      'http://192.168.1.100:8085/api/v1';
  static const String localhostUrl = 'http://localhost:8085/api/v1';

  static String get currentUrl {
    if (kIsWeb) return localhostUrl;
    if (Platform.isAndroid) {
      return emulatorUrl;
    }
    return localhostUrl;
  }

  static void logCurrentEnvironment() {
    debugPrint('🏗️ Текущее окружение:');
    debugPrint('   Платформа: ${kIsWeb ? "Web" : Platform.operatingSystem}');
    debugPrint('   URL: $currentUrl');
  }
}
