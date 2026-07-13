import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jolutrip_app/core/di/service_locator.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  
  await initializeDateFormatting('ru_RU', null);

  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const JoluTripApp());
}