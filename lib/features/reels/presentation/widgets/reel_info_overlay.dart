import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/string_formatter.dart';
import '../../data/models/reel_model.dart';

class ReelInfoOverlay extends StatelessWidget {
  final ReelModel reel;
  final VoidCallback? onBookPressed;
  final VoidCallback? onLikePressed;
  final VoidCallback? onCommentsPressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onProfilePressed;

  const ReelInfoOverlay({
    super.key,
    required this.reel,
    this.onBookPressed,
    this.onLikePressed,
    this.onCommentsPressed,
    this.onSharePressed,
    this.onProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    // Возвращаем Positioned.fill, чтобы виджет идеально встраивался в Stack экрана ReelsScreen
    return Positioned.fill(
      child: Stack(
        children: [
          // ───── ГЛАВНАЯ ИНФОРМАЦИЯ (Снизу слева) ─────
          Positioned(
            left: AppDimens.spaceM,
            bottom: AppDimens.spaceL,
            right:
                90, // Чуть увеличили отступ, чтобы точно не перекрыть кнопками справа
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ТЕГИ (Минималистичные, полупрозрачные)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildBlurTag(reel.category, AppColors.primary),
                      const SizedBox(width: AppDimens.spaceXS),
                      _buildBlurTag(reel.carRequirement, AppColors.accent),
                      const SizedBox(width: AppDimens.spaceXS),
                      if (!reel.hasInternet)
                        _buildBlurTag('No Signal', AppColors.textSecondary),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.spaceS),

                // ЗАГОЛОВОК (С легкой тенью для читаемости)
                Text(
                  reel.name,
                  style: AppTextStyles.headline.copyWith(
                    fontSize: 26,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),

                // ОПИСАНИЕ (Тонкое и аккуратное)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 4,
                    bottom: AppDimens.spaceM,
                  ),
                  child: Text(
                    reel.shortDescription,
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // ЦЕНА И КНОПКА (В одну линию)
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'от ${reel.priceStartsFrom} сом',
                          style: AppTextStyles.title.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          StringFormatter.formatDuration(
                            reel.travelTimeFromCity,
                          ),
                          style: AppTextStyles.subtext.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppDimens.spaceM),

                    // Кнопка "Забронировать" с размытием
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppDimens.radiusM),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: ElevatedButton(
                            onPressed: onBookPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.9),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppDimens.spaceS,
                              ),
                            ),
                            child: const Text('Забронировать'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ───── БОКОВАЯ ПАНЕЛЬ ДЕЙСТВИЙ (Справа снизу) ─────
          Positioned(
            right: AppDimens.spaceM,
            bottom:
                AppDimens.spaceL +
                10, // Выравниваем аккуратно по высоте с нижним блоком
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRightAction(
                  Icons.favorite_outline,
                  '2.4k',
                  onLikePressed,
                ),
                const SizedBox(height: AppDimens.spaceM),
                _buildRightAction(
                  Icons.chat_bubble_outline,
                  '42',
                  onCommentsPressed,
                ),
                const SizedBox(height: AppDimens.spaceM),
                _buildRightAction(Icons.share_outlined, '', onSharePressed),
                const SizedBox(height: AppDimens.spaceL),

                // Аватарка гида (Клик ведет на профиль гида и его внедорожник)
                GestureDetector(
                  onTap: onProfilePressed,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.cardDark,
                      // В будущем: backgroundImage: NetworkImage(reel.guideAvatarUrl),
                      child: Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Виджет прозрачного тега с блюром
  Widget _buildBlurTag(String text, Color accentColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusS),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          color: Colors.white.withOpacity(0.08),
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              color: accentColor,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }

  // Правые кнопки управления (Обернуты в интерактивный GestureDetector)
  Widget _buildRightAction(IconData icon, String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // Чтобы кликалось даже вокруг иконки
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 28,
            shadows: const [
              Shadow(
                color: Colors.black54,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
