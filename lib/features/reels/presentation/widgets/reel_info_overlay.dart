import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/buttons/jolu_button.dart';
import 'package:jolutrip_app/core/utils/string_formatter.dart';
import 'package:jolutrip_app/features/reels/data/data.dart';

class ReelInfoOverlay extends StatelessWidget {
  final ReelModel reel;
  final VoidCallback? onBookPressed;
  final VoidCallback? onLikePressed;
  final VoidCallback? onCommentsPressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onProfilePressed;
  final bool isFavorite;

  const ReelInfoOverlay({
    super.key,
    required this.reel,
    this.onBookPressed,
    this.onLikePressed,
    this.onCommentsPressed,
    this.onSharePressed,
    this.onProfilePressed,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 300,
          child: const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black12,
                    Colors.black54,
                    Colors.black87,
                  ],
                  stops: [0.0, 0.4, 0.75, 1.0],
                ),
              ),
            ),
          ),
        ),

        Positioned(
          right: AppDimens.spaceM,
          bottom: bottomInset + 140,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onProfilePressed,
                child: Container(
                  margin: const EdgeInsets.only(bottom: AppDimens.spaceM),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.cardDark,
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.spaceM),

              _buildSideAction(
                icon: isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_outline_rounded,
                color: isFavorite ? AppColors.error : Colors.white,
                onTap: onLikePressed,
              ),
              const SizedBox(height: AppDimens.spaceM),

              _buildSideAction(
                icon: Icons.chat_bubble_outline_rounded,
                onTap: onCommentsPressed,
              ),
              const SizedBox(height: AppDimens.spaceM),

              _buildSideAction(
                icon: Icons.share_rounded,
                onTap: onSharePressed,
              ),
            ],
          ),
        ),

        Positioned(
          left: AppDimens.spaceM,
          right: 84,
          bottom: bottomInset + AppDimens.spaceM,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppDimens.radiusS),
                ),
                child: Text(
                  reel.category.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.spaceS),

              Text(
                reel.name,
                style: AppTextStyles.headline.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  shadows: const [
                    Shadow(
                      blurRadius: 6,
                      color: Colors.black54,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              _buildMetaRow(),
              const SizedBox(height: AppDimens.spaceM),

              Text(
                reel.shortDescription,
                style: AppTextStyles.body.copyWith(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimens.spaceM),

              JoluButton(
                text: 'от ${reel.priceStartsFrom} сом • Подробнее',
                variant: JoluButtonVariant.secondary,
                size: JoluButtonSize.small,
                onPressed: onBookPressed,
                trailingIcon: Icons.arrow_forward_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetaRow() {
    final travelTimeFormatted = StringFormatter.formatDuration(
      reel.travelTimeFromCity,
    );

    return Row(
      children: [
        _buildMetaItem(Icons.access_time_rounded, travelTimeFormatted),
        _buildDotDivider(),
        _buildMetaItem(
          Icons.directions_car_rounded,
          reel.carRequirement.trim(),
        ),
        _buildDotDivider(),
        _buildMetaItem(
          reel.hasInternet ? Icons.wifi_rounded : Icons.wifi_off_rounded,
          reel.hasInternet ? 'Есть связь' : 'No Signal',
          color: reel.hasInternet ? AppColors.success : AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildMetaItem(
    IconData icon,
    String text, {
    Color color = Colors.white,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color.withOpacity(0.85)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDotDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        '·',
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSideAction({
    required IconData icon,
    required VoidCallback? onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.18)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
        ),
      ),
    );
  }
}
