// lib/features/guide_profile/presentation/widgets/blocks/guide_header.dart

import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/guide-profile/domain/entities/guide_profile_entity.dart';
import 'package:jolutrip_app/features/guide_auth/domain/entities/guide_entity.dart';

class GuideHeader extends StatelessWidget {
  final GuideProfileEntity profile;
  final VoidCallback? onAvatarTap;

  const GuideHeader({super.key, required this.profile, this.onAvatarTap});

  @override
  Widget build(BuildContext context) {
    final guide = profile.guide;

    return Row(
      children: [
        // Аватар с возможностью смены
        GestureDetector(
          onTap: onAvatarTap,
          child: Stack(
            children: [
              _buildAvatar(guide.avatarUrl),
              if (onAvatarTap != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.bgDark, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: AppDimens.space24),

        // Инфо
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                guide.fullName,
                style: AppTextStyles.headline.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 4),
              _buildInfoRow(icon: _genderIcon, text: _genderLabel),
              const SizedBox(height: 4),
              _buildInfoRow(
                icon: Icons.phone_outlined,
                text: guide.phone,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppDimens.space12),
              _buildStatusChip(guide.status),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(String? url) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: Border.all(color: AppColors.borderDark),
        image: url != null
            ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
            : null,
      ),
      child: url == null
          ? Icon(Icons.person_outline, size: 40, color: AppColors.textMuted)
          : null,
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color ?? AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(text, style: AppTextStyles.bodySmall.copyWith(color: color)),
      ],
    );
  }

  Widget _buildStatusChip(GuideStatus status) {
    final (label, color, bg) = switch (status) {
      GuideStatus.pending => (
        'На проверке',
        AppColors.warning,
        AppColors.warning.withOpacity(0.1),
      ),
      GuideStatus.verified => (
        'Верифицирован',
        AppColors.success,
        AppColors.success.withOpacity(0.1),
      ),
      GuideStatus.rejected => (
        'Отклонён',
        AppColors.error,
        AppColors.error.withOpacity(0.1),
      ),
      _ => (
        'Не заполнен',
        AppColors.textMuted,
        AppColors.textMuted.withOpacity(0.1),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  IconData get _genderIcon => switch (profile.guide.gender) {
    GuideGender.male => Icons.male_outlined,
    GuideGender.female => Icons.female_outlined,
  };

  String get _genderLabel => switch (profile.guide.gender) {
    GuideGender.male => 'Мужской',
    GuideGender.female => 'Женский',
  };
}
