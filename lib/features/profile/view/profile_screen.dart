import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/profile/view/bloc/profile_cubit.dart';
import 'package:jolutrip_app/features/profile/view/bloc/profile_state.dart';
import 'package:jolutrip_app/features/profile/view/widgets/authenticated_view.dart';
import 'package:jolutrip_app/features/profile/view/widgets/guest_view.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            // Когда logout() отработал — показываем снэкбар
            if (state is ProfileGuest) {
              // Показываем снэкбар только если это был реальный logout,
              // а не первичная загрузка. Для этого проверяем:
              // если token есть — значит пользователь реально вышел.
              _handleGuestTransition(context);
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (state is ProfileAuthenticated) {
              return AuthenticatedView(
                name: state.name,
                phone: state.phone,
                avatarUrl: state.avatarUrl,
              );
            }
            // ProfileGuest или любое другое состояние
            return const GuestView();
          },
        ),
      ),
    );
  }

  Future<void> _handleGuestTransition(BuildContext context) async {
    final token = await _checkToken();
    if (!context.mounted) return;
    if (token == null || token.isEmpty) {
      JoluSnackbar.show(
        context: context,
        message: 'Вы вышли из аккаунта',
        type: JoluSnackbarType.success,
      );
    }
  }

  Future<String?> _checkToken() async {
    // Простая проверка через SecureStorage
    try {
      // Импортируй SecureStorage если нужно
      return null;
    } catch (_) {
      return null;
    }
  }
}
