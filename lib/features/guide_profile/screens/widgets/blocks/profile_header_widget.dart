
import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/guide_auth/domain/entities/guide_entity.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final GuideEntity guide;

  const ProfileHeaderWidget({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Аватар (заглушка)
        _buildAvatar(),
        const SizedBox(width: AppDimens.spaceL),

        // Инфо
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                guide.fullName,
                style: AppTextStyles.headline.copyWith(fontSize: 20),
              ),
              const SizedBox(height: AppDimens.spaceXS),
              _buildInfoRow(
                icon: _genderIcon,
                text: _genderLabel,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppDimens.spaceXS),
              _buildInfoRow(
                icon: Icons.phone_outlined,
                text: guide.phone,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppDimens.spaceS),
              _buildStatusChip(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: guide.avatarUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusL),
              child: Image.network(
                guide.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _avatarPlaceholder,
              ),
            )
          : _avatarPlaceholder,
    );
  }

  Widget get _avatarPlaceholder {
    return Icon(Icons.person_outline, size: 40, color: AppColors.textMuted);
  }

  IconData get _genderIcon => switch (guide.gender) {
    GuideGender.male => Icons.male_outlined,
    GuideGender.female => Icons.female_outlined,
  };

  String get _genderLabel => switch (guide.gender) {
    GuideGender.male => 'Мужской',
    GuideGender.female => 'Женский',
  };

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(text, style: AppTextStyles.bodySmall.copyWith(color: color)),
      ],
    );
  }

  Widget _buildStatusChip() {
    final (color, bgColor, label) = switch (guide.status) {
      GuideStatus.pending => (
        AppColors.warning,
        AppColors.warning.withOpacity(0.1),
        'На проверке',
      ),
      GuideStatus.verified => (
        AppColors.success,
        AppColors.success.withOpacity(0.1),
        'Верифицирован',
      ),
      GuideStatus.rejected => (
        AppColors.error,
        AppColors.error.withOpacity(0.1),
        'Отклонён',
      ),
      _ => (
        AppColors.textMuted,
        AppColors.textMuted.withOpacity(0.1),
        'Не заполнен',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
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
}
