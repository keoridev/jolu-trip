import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/location-detail/domain/domain.dart';

/// Обложка локации. Живёт внутри `SliverAppBar.flexibleSpace`, поэтому сама
/// вычисляет прогресс сворачивания через [FlexibleSpaceBarSettings]:
/// крупный заголовок гаснет, а компактный в тулбаре — появляется.
class LocationHeroSection extends StatelessWidget {
  final LocationDetailEntity location;
  final VoidCallback? onVideoTap;

  const LocationHeroSection({
    super.key,
    required this.location,
    this.onVideoTap,
  });

  /// Высота обложки: пропорциональна ширине, но с потолком — на планшете
  /// картинка 16/10 съела бы весь первый экран.
  static double heightFor(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return (width * 0.78).clamp(300.0, 420.0);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();

    // t = 0 — развёрнуто, t = 1 — свёрнуто в тулбар.
    double t = 0;
    if (settings != null) {
      final delta = settings.maxExtent - settings.minExtent;
      if (delta > 0) {
        t =
            (1 - (settings.currentExtent - settings.minExtent) / delta).clamp(
              0.0,
              1.0,
            );
      }
    }

    final toolbarHeight =
        MediaQuery.viewPaddingOf(context).top + kToolbarHeight;

    return Stack(
      fit: StackFit.expand,
      children: [
        _HeroImage(url: location.thumbnailUrl),

        // Затемнение сверху — под системную строку и кнопки навигации.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: toolbarHeight + AppDimens.space24,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x99000000), Colors.transparent],
              ),
            ),
          ),
        ),

        // Затемнение снизу — под текст. Растёт при сворачивании, чтобы
        // компактный заголовок оставался читаемым на любой картинке.
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.bgDark.withValues(alpha: 0.55 + 0.35 * t),
                  AppColors.bgDark.withValues(alpha: 0.92 + 0.08 * t),
                ],
                stops: const [0, 0.55, 1],
              ),
            ),
          ),
        ),

        // Кнопка появляется только когда обработчик реально передан: плеера
        // для локаций ещё нет, а видимая кнопка «play», которая ничего не
        // делает, хуже её отсутствия.
        if (location.videoUrl.isNotEmpty && onVideoTap != null)
          Positioned.fill(
            bottom: 120,
            child: IgnorePointer(
              ignoring: t > 0.5,
              child: Opacity(
                opacity: (1 - t * 2).clamp(0.0, 1.0),
                child: Center(child: _PlayButton(onTap: onVideoTap)),
              ),
            ),
          ),

        // Крупный заголовок: бейдж → название → короткое описание.
        // Всё одной колонкой, поэтому длинное название больше не наезжает
        // на бейдж (раньше заголовок был прибит к `bottom: 45`).
        Positioned(
          left: AppDimens.space16,
          right: AppDimens.space16,
          bottom: AppDimens.space20,
          child: Opacity(
            opacity: (1 - t * 1.6).clamp(0.0, 1.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _CategoryBadge(category: location.category),
                const SizedBox(height: AppDimens.space10),
                Text(
                  location.name,
                  style: AppTextStyles.headline.copyWith(fontSize: 28),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (location.shortDescription.isNotEmpty) ...[
                  const SizedBox(height: AppDimens.space6),
                  Text(
                    location.shortDescription,
                    style: AppTextStyles.subtext,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),

        // Компактный заголовок в тулбаре. Отступы 56px слева и справа —
        // чтобы не залезать под кнопки «назад» и «поделиться».
        Positioned(
          top: MediaQuery.viewPaddingOf(context).top,
          left: 56,
          right: 56,
          height: kToolbarHeight,
          child: IgnorePointer(
            child: Opacity(
              opacity: ((t - 0.65) / 0.3).clamp(0.0, 1.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  location.name,
                  style: AppTextStyles.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  final String url;

  const _HeroImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const _HeroFallback();

    return Image.network(
      url,
      fit: BoxFit.cover,
      // Картинка проявляется, а не «выпрыгивает» — раньше не было ни
      // loadingBuilder, ни плавного появления.
      frameBuilder: (_, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          child: child,
        );
      },
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return const ColoredBox(color: AppColors.cardDark);
      },
      errorBuilder: (_, _, _) => const _HeroFallback(),
    );
  }
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardElevated, AppColors.cardDark],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.terrain_rounded,
          color: AppColors.textMuted,
          size: 56,
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _PlayButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.7),
              width: AppDimens.strokeDefault,
            ),
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    if (category.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space10,
        vertical: AppDimens.space6,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppDimens.radiusRound),
        border: Border.all(color: AppColors.primaryBright.withValues(alpha: 0.5)),
      ),
      child: Text(
        category.toUpperCase(),
        // onPrimary, а не Colors.black: черный на #1B5E3A — контраст 1.6:1.
        style: AppTextStyles.badge.copyWith(
          color: AppColors.onPrimary,
          fontSize: 10,
        ),
      ),
    );
  }
}
