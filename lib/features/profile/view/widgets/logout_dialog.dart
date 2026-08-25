import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/profile/view/bloc/profile_cubit.dart';

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => JoluDialog(
      title: 'Выход из аккаунта',
      message: 'Вы уверены? Несохранённые данные могут быть потеряны.',
      icon: Icons.logout_rounded,
      iconColor: AppColors.error,
      confirmText: 'Выйти',
      cancelText: 'Отмена',
      onConfirm: () {
        Navigator.pop(dialogContext);
        context.read<ProfileCubit>().logout();
      },
    ),
  );
}
