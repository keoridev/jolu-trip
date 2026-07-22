import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/core/di/service_locator.dart';
import 'package:jolutrip_app/core/storage/secure_storage.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/features/gamification/view/blocs/stamps/stamps_cubit.dart';
import 'package:jolutrip_app/features/guide-profile/view/bloc/guide_profile_cubit.dart';
import 'package:jolutrip_app/features/guide-profile/view/guide_profile_screen.dart';
import 'package:jolutrip_app/features/profile/view/bloc/profile_cubit.dart';
import 'package:jolutrip_app/features/profile/view/profile_screen.dart';

class ProfileRouterScreen extends StatefulWidget {
  const ProfileRouterScreen({super.key});

  @override
  State<ProfileRouterScreen> createState() => _ProfileRouterScreenState();
}

class _ProfileRouterScreenState extends State<ProfileRouterScreen> {
  String? _role;
  bool _isLoading = true;
  StreamSubscription<void>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _determineRole();

    // Слушаем изменения auth — когда роль меняется, перезагружаем
    _authSubscription = SecureStorage.authChanges.listen((_) {
      debugPrint('🔍 Auth changed, reloading role');
      _determineRole();
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _determineRole() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final token = await SecureStorage.getToken();
      debugPrint('🔍 Token: $token');

      if (token == null) {
        debugPrint('🔍 No token, showing guest profile');
        setState(() {
          _role = null;
          _isLoading = false;
        });
        return;
      }

      final savedRole = await SecureStorage.getRole();
      debugPrint('🔍 Saved role: $savedRole');

      if (mounted) {
        setState(() {
          _role = savedRole;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error determining role: $e');
      if (mounted) {
        setState(() {
          _role = null;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    debugPrint('🔍 Building profile for role: $_role');

    if (_role == null) {
      debugPrint('🔍 Showing GUEST profile');
      return const ProfileScreen();
    }

    if (_role == 'guide') {
      debugPrint('🔍 Showing GUIDE profile');
      return BlocProvider<GuideProfileCubit>(
        create: (_) => sl<GuideProfileCubit>()..loadProfile(),
        child: const GuideProfileScreen(),
      );
    }

    debugPrint('🔍 Showing TOURIST profile');
    return BlocProvider(
      create: (_) => sl<StampsCubit>()..loadStamps(),
      child: const ProfileScreen(),
    );
  }
}
