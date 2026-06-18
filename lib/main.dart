import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jolutrip_app/core/di/service_locator.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const JoluTripApp());
}
