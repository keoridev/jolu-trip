import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jolutrip_app/core/di/service_locator.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  setupDependencies();

  await initializeDateFormatting('ru_RU', null);

  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const JoluTripApp());
}
