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
    return Container(
      margin: AppDimens.screenPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.cardDark,
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimens.radius20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar with status badge
            Stack(
              children: [
                GestureDetector(
                  onTap: onAvatarTap,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _statusColor, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.cardDark,
                      backgroundImage: profile.avatarUrl != null
                          ? NetworkImage(profile.avatarUrl!)
                          : null,
                      child: profile.avatarUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 48,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.bgDark, width: 2),
                    ),
                    child: Text(
                      _statusText,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              profile.fullName ?? 'Гид',
              style: AppTextStyles.headline.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 4),
            Text(
              profile.phone ?? '',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            if (profile.isVerified)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.verified,
                    color: AppColors.success,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Верифицированный гид',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color get _statusColor {
    if (profile.isVerified) return AppColors.success;
    if (profile.isPending) return AppColors.warning;
    if (profile.isRejected) return AppColors.error;
    return AppColors.textSecondary;
  }

  String get _statusText {
    if (profile.isVerified) return 'VERIFIED';
    if (profile.isPending) return 'PENDING';
    if (profile.isRejected) return 'REJECTED';
    return 'NEW';
  }
}