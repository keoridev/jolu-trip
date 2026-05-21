import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/features/home/home.dart';

abstract class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
