import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/profile/view/bloc/profile_cubit.dart';
import 'package:jolutrip_app/features/profile/view/bloc/profile_state.dart';
import 'package:jolutrip_app/features/safety/view/safety_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const _LoadingView();
            }
            if (state is ProfileAuthenticated) {
              return _AuthenticatedView(
                name: state.name,
                phone: state.phone,
                avatarUrl: state.avatarUrl,
                ecoPoints: state.ecoPoints,
              );
            }
            return const _GuestView();
          },
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
        strokeWidth: 2,
      ),
    );
  }
}

class _GuestView extends StatelessWidget {
  const _GuestView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimens.screenPadding,
      child: Column(
        children: [
          const SizedBox(height: 80),

          // Аватар-заглушка
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cardDark,
              border: Border.all(color: AppColors.borderDark, width: 2),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 48,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: AppDimens.space24),

          Text('Гость', style: AppTextStyles.headline),

          const SizedBox(height: AppDimens.space12),

          Text(
            'Войди или зарегистрируйся, чтобы\nсохранять поездки и делиться контентом',
            style: AppTextStyles.subtext,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppDimens.space32),

          // В _GuestView — изменить кнопку:
          SizedBox(
            width: double.infinity,
            height: 56,
            child: JoluButton(
              text: 'Войти в аккаунт',
              variant: JoluButtonVariant.primary,
              size: JoluButtonSize.large,
              isFullWidth: true,
              leadingIcon: Icons.login_rounded,
              onPressed: () async {
                await context.push('/auth'); // ← Теперь открывает выбор роли!
                if (context.mounted) {
                  context.read<ProfileCubit>().loadProfile();
                }
              },
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}

class _AuthenticatedView extends StatelessWidget {
  final String name;
  final String phone;
  final String? avatarUrl;
  final int ecoPoints;

  const _AuthenticatedView({
    required this.name,
    required this.phone,
    this.avatarUrl,
    required this.ecoPoints,
  });

  @override
  Widget build(BuildContext context) {
    final profileCubit = context.read<ProfileCubit>();

    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    return SingleChildScrollView(
      padding: AppDimens.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),

          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cardDark,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                  image: hasAvatar
                      ? DecorationImage(
                          image: NetworkImage(avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: !hasAvatar
                    ? const Icon(
                        Icons.person,
                        size: 36,
                        color: AppColors.textSecondary,
                      )
                    : null,
              ),

              const SizedBox(width: AppDimens.space24),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.headline.copyWith(fontSize: 22),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phone,
                      style: AppTextStyles.subtext.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusRound,
                        ),
                      ),
                      child: Text(
                        'Турист',
                        style: AppTextStyles.accentBadge.copyWith(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimens.space32),
          Container(
            padding: const EdgeInsets.all(AppDimens.space16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.eco_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppDimens.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$ecoPoints баллов',
                        style: AppTextStyles.title.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Эко-активность в горах',
                        style: AppTextStyles.subtext.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Lvl 1',
                  style: AppTextStyles.accentBadge.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimens.space32),

          // Меню профиля
          _MenuSection(
            title: 'Безопасность',
            items: [
              _MenuItem(
                icon: Icons.favorite_border_rounded,
                title: 'Карта здоровья',
                subtitle: 'Группа крови, аллергии',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.emergency_outlined,
                title: 'SOS-контакты',
                subtitle: 'Экстренные номера',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SafetyScreen()),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimens.space24),

          _MenuSection(
            title: 'Активность',
            items: [
              _MenuItem(
                icon: Icons.route_outlined,
                title: 'Мои поездки',
                subtitle: '3 запланировано',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.bookmark_border_rounded,
                title: 'Сохранённые',
                subtitle: '12 локаций',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: AppDimens.space32),

          // Выход
          SizedBox(
            width: double.infinity,
            height: 52,
            child: JoluButton(
              text: 'Выйти',
              variant: JoluButtonVariant.error,
              size: JoluButtonSize.large,
              isFullWidth: true,
              leadingIcon: Icons.logout_rounded,
              onPressed: () => _showLogoutDialog(context, profileCubit),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

void _showLogoutDialog(BuildContext context, ProfileCubit cubit) {
  showDialog(
    context: context,
    builder: (dialogContext) => JoluDialog(
      title: 'Выход из аккаунта',
      message:
          'Вы уверены, что хотите выйти? Все несохранённые данные будут потеряны.',
      icon: Icons.logout_rounded,
      iconColor: AppColors.error,
      confirmText: 'Выйти',
      cancelText: 'Отмена',
      onConfirm: () {
        Navigator.pop(dialogContext);

        cubit.logout();

        if (context.mounted) {
          JoluSnackbar.show(
            context: context,
            message: 'Вы вышли из аккаунта',
            type: JoluSnackbarType.success,
          );
        }
      },
    ),
  );
}

// ═══════════════════════════════════════════════════
// ВИДЖЕТЫ МЕНЮ
// ═══════════════════════════════════════════════════
class _MenuSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.subtext.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppDimens.space12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusM),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimens.radiusS),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: AppDimens.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.subtext.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
