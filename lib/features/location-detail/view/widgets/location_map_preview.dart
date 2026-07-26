import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/feedback/jolu_snackbar.dart';
import 'package:jolutrip_app/features/location-detail/domain/domain.dart';

import 'location_section.dart';
import 'map_fullscreen_sheet.dart';

class LocationMapPreview extends StatelessWidget {
  final LocationDetailEntity location;

  /// Открыть шит с навигаторами.
  final VoidCallback? onOpenMap;

  const LocationMapPreview({super.key, required this.location, this.onOpenMap});

  @override
  Widget build(BuildContext context) {
    return LocationSection(
      title: 'Где это',
      subtitle: 'Сохраните координаты — связи на месте может не быть',
      trailing: LocationSectionAction(
        icon: Icons.open_in_full_rounded,
        label: 'Карта',
        onTap: () => _showFullscreenMap(context),
      ),
      child: Column(
        children: [
          // Тап по превью раскрывает карту. Раньше и превью, и кнопка внутри
          // открывали один и тот же шит с навигаторами — «развернуть» было
          // некуда, хотя рядом висела кнопка «На весь экран».
          Material(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _showFullscreenMap(context),
              child: SizedBox(
                height: 170,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _MapPlaceholder(
                      latitude: location.latitude,
                      longitude: location.longitude,
                    ),
                    const Center(child: _Marker()),
                    Positioned(
                      right: AppDimens.space12,
                      top: AppDimens.space12,
                      child: Container(
                        padding: const EdgeInsets.all(AppDimens.space6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusS,
                          ),
                        ),
                        child: const Icon(
                          Icons.open_in_full_rounded,
                          color: Colors.white,
                          size: AppDimens.icon16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.space12),

          // Координаты вынесены из-под картинки в отдельную строку: там они
          // лежали на градиенте и конкурировали с маркером за внимание.
          Row(
            children: [
              Expanded(
                child: _CoordinatesTile(
                  coordinates: location.formattedCoordinates,
                  onCopy: () => _copyCoordinates(context),
                ),
              ),
              const SizedBox(width: AppDimens.space12),
              _RouteButton(onTap: onOpenMap),
            ],
          ),
        ],
      ),
    );
  }

  // Раньше здесь показывался снекбар «Координаты скопированы», хотя в буфер
  // обмена ничего не записывалось — снекбар обманывал пользователя.
  Future<void> _copyCoordinates(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: location.formattedCoordinates),
    );
    await HapticFeedback.selectionClick();

    if (!context.mounted) return;
    JoluSnackbar.show(
      context: context,
      message: 'Координаты скопированы',
      type: JoluSnackbarType.success,
    );
  }

  void _showFullscreenMap(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MapFullscreenSheet(location: location),
    );
  }
}

class _CoordinatesTile extends StatelessWidget {
  final String coordinates;
  final VoidCallback onCopy;

  const _CoordinatesTile({required this.coordinates, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardDark,
      borderRadius: BorderRadius.circular(AppDimens.radiusM),
      child: InkWell(
        onTap: onCopy,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.my_location_rounded,
                color: AppColors.primaryBright,
                size: AppDimens.icon20,
              ),
              const SizedBox(width: AppDimens.space10),
              Expanded(
                child: Text(
                  coordinates,
                  style: AppTextStyles.monoSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppDimens.space8),
              const Icon(
                Icons.copy_rounded,
                color: AppColors.textSecondary,
                size: AppDimens.icon16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _RouteButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppDimens.radiusM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space16),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Белая иконка вместо черной: черный на #1B5E3A нечитаем.
              const Icon(
                Icons.navigation_rounded,
                color: AppColors.onPrimary,
                size: AppDimens.icon20,
              ),
              const SizedBox(width: AppDimens.space8),
              Text(
                'Маршрут',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.onPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space10),
      decoration: BoxDecoration(
        color: AppColors.primaryBright.withValues(alpha: 0.16),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryBright.withValues(alpha: 0.4),
        ),
      ),
      child: const Icon(
        Icons.place_rounded,
        color: AppColors.primaryBright,
        size: AppDimens.icon28,
      ),
    );
  }
}

/// Заглушка карты с координатной сеткой.
class _MapPlaceholder extends StatelessWidget {
  final double latitude;
  final double longitude;

  const _MapPlaceholder({required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16241D), Color(0xFF11161B)],
        ),
      ),
      child: CustomPaint(
        size: Size.infinite,
        painter: _GridPainter(),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.space12),
            child: Text(
              '${latitude.toStringAsFixed(2)}°N  ${longitude.toStringAsFixed(2)}°E',
              style: AppTextStyles.monoSmall.copyWith(
                color: AppColors.textTertiary,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    const spacing = 32.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
