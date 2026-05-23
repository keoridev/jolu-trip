import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/di/service_locator.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  runApp(const JoluTripApp());
}
