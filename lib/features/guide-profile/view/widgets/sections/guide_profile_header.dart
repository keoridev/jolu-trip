import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/guide-profile/domain/entities/guide_profile_entity.dart';

class GuideProfileHeader extends StatelessWidget {
  final GuideProfileEntity profile;
  final VoidCallback? onAvatarTap;

  const GuideProfileHeader({
    super.key,
    required this.profile,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    // Убрали рамку и фон. Хедер дышит и становится органичной частью экрана.
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space24,
        vertical: AppDimens.space32, // Больше воздуха сверху и снизу
      ),
      child: Column(
        children: [
          _buildAvatarSection(),
          const SizedBox(height: AppDimens.space24),
          _buildNameSection(),
          const SizedBox(height: AppDimens.space8),
          _buildPhoneSection(),
          const SizedBox(height: AppDimens.space16),
          _buildStatusBadge(), // Единая точка понимания статуса
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return GestureDetector(
      onTap: onAvatarTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Крупный, чистый аватар без цветных колец
          CircleAvatar(
            radius: 56, // Увеличили размер для "сочности"
            backgroundColor: AppColors.bgElevated,
            backgroundImage: profile.avatarUrl != null
                ? NetworkImage(profile.avatarUrl!)
                : null,
            child: profile.avatarUrl == null
                ? Icon(
                    Icons.person,
                    size: 48,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  )
                : null,
          ),
          // Явный аффорданс для редактирования (если доступно)
          if (onAvatarTap != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(AppDimens.space8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors
                        .bgDark, // Цвет фона под аватаром, создает вырез
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNameSection() {
    return Text(
      profile.fullName ?? 'Новый гид',
      style: AppTextStyles.headlineMedium.copyWith(
        fontSize: 28, // Крупный, уверенный заголовок
        fontWeight: FontWeight.w800, // Экстра-жирный для контраста
        letterSpacing: -0.5, // Слегка сужаем межбуквенное, стиль Apple
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPhoneSection() {
    return Text(
      profile.phone ?? 'Телефон не указан',
      style: AppTextStyles.body.copyWith(
        color: AppColors.textSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildStatusBadge() {
    // Определяем конфигурацию бейджа в одном месте
    final (
      Color color,
      Color bgColor,
      IconData icon,
      String text,
    ) = switch (true) {
      _ when profile.isVerified => (
        AppColors.success,
        AppColors.success.withValues(alpha: 0.15),
        Icons.verified_rounded,
        'Верифицирован',
      ),
      _ when profile.isPending => (
        AppColors.warning,
        AppColors.warning.withValues(alpha: 0.15),
        Icons.hourglass_top_rounded,
        'На проверке',
      ),
      _ when profile.isRejected => (
        AppColors.error,
        AppColors.error.withValues(alpha: 0.15),
        Icons.error_outline_rounded,
        'Отклонен',
      ),
      _ => (
        AppColors.textSecondary,
        AppColors.textSecondary.withValues(alpha: 0.15),
        Icons.info_outline_rounded,
        'Заполните профиль',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space16,
        vertical: AppDimens.space8,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusRound),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: AppDimens.space8),
          Text(
            text,
            style: AppTextStyles.body.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
