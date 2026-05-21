import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';

class JoluTripApp extends StatelessWidget {
  const JoluTripApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'JoluTrip',
      debugShowCheckedModeBanner: false,
      theme: AppColors.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
