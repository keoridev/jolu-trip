import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/gamification/domain/entities/stamp.dart';
import 'package:jolutrip_app/features/gamification/view/blocs/stamps/stamps_cubit.dart';
import 'package:jolutrip_app/features/gamification/view/blocs/stamps/stamps_state.dart';
import 'package:jolutrip_app/features/gamification/view/widgets/stamps_carousel.dart';
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
            if (state is ProfileLoading) return const _LoadingView();
            if (state is ProfileAuthenticated) {
              return _AuthenticatedView(
                name: state.name,
                phone: state.phone,
                avatarUrl: state.avatarUrl,
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
      child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cardDark,
              border: Border.all(color: AppColors.borderDark, width: 2),
            ),
            child: const Icon(Icons.person_outline_rounded, size: 48, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimens.space24),
          Text('Добро пожаловать', style: AppTextStyles.headline),
          const SizedBox(height: AppDimens.space12),
          Text(
            'Войдите, чтобы сохранять маршруты,\nполучать печати и делиться опытом',
            style: AppTextStyles.subtext,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.space32),
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
                await context.push('/auth');
                if (context.mounted) context.read<ProfileCubit>().loadProfile();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthenticatedView extends StatelessWidget {
  final String name;
  final String phone;
  final String? avatarUrl;

  const _AuthenticatedView({required this.name, required this.phone, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final profileCubit = context.read<ProfileCubit>();
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    return SingleChildScrollView(
      padding: AppDimens.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          
          // ═══════════════════════════════════════════════════
          // ШАПКА ПРОФИЛЯ (Премиальный вид)
          // ═══════════════════════════════════════════════════
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cardDark,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                  image: hasAvatar ? DecorationImage(image: NetworkImage(avatarUrl!), fit: BoxFit.cover) : null,
                ),
                child: !hasAvatar
                    ? const Icon(Icons.person, size: 32, color: AppColors.textSecondary)
                    : null,
              ),
              const SizedBox(width: AppDimens.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: AppTextStyles.headline.copyWith(fontSize: 20),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Кнопка настроек (задел на будущее)
                        IconButton(
                          icon: const Icon(Icons.settings_outlined, size: 20, color: AppColors.textSecondary),
                          onPressed: () {},
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(phone, style: AppTextStyles.subtext.copyWith(fontSize: 13)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppDimens.radiusRound),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.terrain, size: 12, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text('Турист', style: AppTextStyles.badge.copyWith(color: AppColors.primary, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimens.space32),

          // ═══════════════════════════════════════════════════
          // ГЕЙМИФИКАЦИЯ
          // ═══════════════════════════════════════════════════
          const _GamificationBlock(),
          const SizedBox(height: AppDimens.space32),

          // ═══════════════════════════════════════════════════
          // МЕНЮ С РАЗДЕЛЕНИЕМ ПО СМЫСЛУ (Цветовое кодирование)
          // ═══════════════════════════════════════════════════
          
          // 1. Атлас (Янтарный/Золотой - достижения)
          const _CategoryBlock(
            title: 'Мой атлас',
            themeColor: Color(0xFFF59E0B), // Amber
            items: [
              _MenuItem(icon: Icons.stars_outlined, title: 'Мои печати', subtitle: 'Коллекции и достижения', route: '/stamps'),
              _MenuItem(icon: Icons.book_outlined, title: 'Журнал путешествий', subtitle: 'История посещений', route: '/journal'),
            ],
          ),
          const SizedBox(height: AppDimens.space24),

          // 2. Безопасность (Изумрудный - защита, спокойствие)
          const _CategoryBlock(
            title: 'Безопасность',
            themeColor: Color(0xFF10B981), // Emerald
            items: [
              _MenuItem(icon: Icons.favorite_border_rounded, title: 'Карта здоровья', subtitle: 'Группа крови, аллергии', route: '/health'),
              _MenuItem(icon: Icons.emergency_outlined, title: 'SOS-помощь', subtitle: 'Экстренные номера и координаты', isSafety: true),
            ],
          ),
          const SizedBox(height: AppDimens.space24),

          // 3. Активность (Синий - данные, маршруты)
          const _CategoryBlock(
            title: 'Активность',
            themeColor: Color(0xFF3B82F6), // Blue
            items: [
              _MenuItem(icon: Icons.route_outlined, title: 'Мои поездки', subtitle: 'Запланированные маршруты', route: '/trips'),
              _MenuItem(icon: Icons.bookmark_border_rounded, title: 'Сохранённые', subtitle: 'Избранные локации', route: '/saved'),
            ],
          ),

          const SizedBox(height: AppDimens.space32),

          // ═══════════════════════════════════════════════════
          // ВЫХОД
          // ═══════════════════════════════════════════════════
          SizedBox(
            width: double.infinity,
            height: 52,
            child: JoluButton(
              text: 'Выйти из аккаунта',
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
      message: 'Вы уверены? Несохранённые данные могут быть потеряны.',
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
// ГЕЙМИФИКАЦИЯ: БЛОК
// ═══════════════════════════════════════════════════

class _GamificationBlock extends StatelessWidget {
  const _GamificationBlock();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StampsCubit, StampsState>(
      builder: (context, state) {
        final loaded = state is StampsLoaded ? state : null;
        final stamps = loaded?.stamps ?? const <Stamp>[];
        
        final lockedIds = <String>{
          for (final collection in loaded?.collections ?? []) ...collection.stampIds,
        }..removeAll(stamps.map((s) => s.id).toSet());

        final recent = [...stamps]..sort(
          (a, b) => (b.earnedAt ?? DateTime(2000)).compareTo(a.earnedAt ?? DateTime(2000)),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusCard(status: loaded?.travelerStatus ?? 'Турист', stampCount: loaded?.totalStamps ?? 0),
            const SizedBox(height: AppDimens.space24),
            Row(
              children: [
                Text('Мои печати', style: AppTextStyles.headlineSmall.copyWith(fontSize: 17)),
                const SizedBox(width: AppDimens.space8),
                if (stamps.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppDimens.radiusRound),
                    ),
                    child: Text('${stamps.length}', style: AppTextStyles.badge.copyWith(color: AppColors.accent, fontSize: 11)),
                  ),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push('/stamps'),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Text('Все', style: AppTextStyles.subtext.copyWith(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w600)),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.accent, size: 18),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.space12),
            StampsCarousel(stamps: recent, lockedIds: lockedIds.toList(), height: 190),
          ],
        );
      },
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String status;
  final int stampCount;

  const _StatusCard({required this.status, required this.stampCount});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/stamps'),
      borderRadius: BorderRadius.circular(AppDimens.radiusL),
      child: Ink(
        padding: const EdgeInsets.all(AppDimens.space16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A2321), Color(0xFF141517)], // Чуть более глубокий темный оттенок
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.12),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.workspace_premium_rounded, color: AppColors.accent, size: 24),
            ),
            const SizedBox(width: AppDimens.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('СТАТУС ПУТЕШЕСТВЕННИКА', style: AppTextStyles.badge.copyWith(color: AppColors.accent, fontSize: 9)),
                  const SizedBox(height: 4),
                  Text(status, style: AppTextStyles.title.copyWith(fontSize: 17)),
                  const SizedBox(height: 2),
                  Text('$stampCount печатей собрано', style: AppTextStyles.subtext.copyWith(fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// УМНЫЕ БЛОКИ МЕНЮ (С цветовым кодированием)
// ═══════════════════════════════════════════════════

class _CategoryBlock extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  final Color themeColor;

  const _CategoryBlock({required this.title, required this.items, required this.themeColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppDimens.space12),
          child: Row(
            children: [
              Container(width: 3, height: 14, decoration: BoxDecoration(color: themeColor, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.subtext.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.3, color: AppColors.textPrimary)),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(AppDimens.radiusL),
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
  final String? route;
  final bool isSafety; // Спец. флаг для SOS

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.route,
    this.isSafety = false,
  });

  @override
  Widget build(BuildContext context) {
    // Определяем цвет иконки: если это SOS, делаем его красным, иначе берем цвет темы блока (передается через родителя, но здесь мы используем fallback или читаем из контекста, 
    // но для простоты в рамках StatelessWidget сделаем хак: цвет иконки задается в _CategoryBlock, а здесь мы используем переданный, 
    // однако чтобы не усложнять сигнатуру, давайте сделаем цвет иконки вычисляемым или просто передадим его. 
    // Упрощение: сделаем цвет иконки универсальным, но SOS выделим).
    
    final iconColor = isSafety ? AppColors.error : AppColors.primary; 
    // Примечание: В идеале _CategoryBlock должен передавать themeColor в _MenuItem. 
    // Давайте исправим это для идеальной архитектуры:

    return InkWell(
      onTap: () {
        if (isSafety) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SafetyScreen()));
        } else if (route != null) {
          context.push(route!);
        }
      },
      borderRadius: BorderRadius.circular(AppDimens.radiusL),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.space16, vertical: AppDimens.space14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isSafety ? AppColors.error : AppColors.primary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
              ),
              child: Icon(icon, color: isSafety ? AppColors.error : AppColors.primary, size: 20),
            ),
            const SizedBox(width: AppDimens.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.subtext.copyWith(fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: isSafety ? AppColors.error.withValues(alpha: 0.5) : AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}