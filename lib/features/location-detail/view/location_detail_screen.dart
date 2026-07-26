// lib/features/location-detail/view/location_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/location-detail/domain/domain.dart';
import 'package:jolutrip_app/features/location-detail/view/bloc/location_detail_cubit.dart';
import 'package:jolutrip_app/features/location-detail/view/bloc/location_detail_state.dart';
import 'package:jolutrip_app/features/location-detail/view/widgets/widgets.dart';
import 'package:share_plus/share_plus.dart';

class LocationDetailScreen extends StatefulWidget {
  final String locationId;

  const LocationDetailScreen({super.key, required this.locationId});

  @override
  State<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() =>
      context.read<LocationDetailCubit>().loadLocationDetail(widget.locationId);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: BlocBuilder<LocationDetailCubit, LocationDetailState>(
          builder: (context, state) {
            return switch (state) {
              LocationDetailLoading() => const LocationDetailSkeleton(),

              LocationDetailError(message: final msg) => _ErrorView(
                message: msg,
                onRetry: _load,
                onBack: () => context.pop(),
              ),

              LocationDetailLoaded(location: final location) => _LoadedView(
                location: location,
              ),

              _ => const LocationDetailSkeleton(),
            };
          },
        ),
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  final LocationDetailEntity location;

  const _LoadedView({required this.location});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // Обложка сворачивается в тулбар, поэтому при скролле всегда
            // видно, где ты находишься. Раньше кнопка «назад» просто висела
            // в Stack поверх картинки и уезжала вместе с ней вверх.
            SliverAppBar(
              pinned: true,
              stretch: true,
              expandedHeight: LocationHeroSection.heightFor(context),
              backgroundColor: AppColors.bgDark,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              leadingWidth: 56,
              leading: Padding(
                padding: const EdgeInsets.only(left: AppDimens.space8),
                child: _CircleAction(
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Назад',
                  onTap: () => context.pop(),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: AppDimens.space8),
                  child: _CircleAction(
                    icon: Icons.ios_share_rounded,
                    tooltip: 'Поделиться',
                    onTap: () => _share(location),
                  ),
                ),
              ],
              flexibleSpace: LocationHeroSection(location: location),
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimens.space20),
                  LocationInfoCards(location: location),
                  LocationDescription(location: location),
                  LocationMapPreview(
                    location: location,
                    onOpenMap: () => _showSelfDriveSheet(context, location),
                  ),
                  LocationRoadsidePlaces(places: location.roadsidePlaces),
                  const SizedBox(height: AppDimens.space32),
                  LocationCheckinCard(location: location),
                  const SizedBox(height: AppDimens.space16),
                  const LocationGuideCard(),
                ],
              ),
            ),

            // Отступ ровно под высоту панели действий вместо «150».
            SliverToBoxAdapter(
              child: SizedBox(
                height: LocationActionBar.heightOf(context) + AppDimens.space32,
              ),
            ),
          ],
        ),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: LocationActionBar(
            onSelfDrive: () => _showSelfDriveSheet(context, location),
            onWithGuide: () => _showGuideSheet(context),
          ),
        ),
      ],
    );
  }

  Future<void> _share(LocationDetailEntity location) {
    return SharePlus.instance.share(
      ShareParams(
        subject: location.name,
        text:
            '${location.name}\n'
            '${location.shortDescription}\n\n'
            'Координаты: ${location.formattedCoordinates}',
      ),
    );
  }

  void _showSelfDriveSheet(
    BuildContext context,
    LocationDetailEntity location,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => LocationSelfDriveSheet(location: location),
    );
  }

  void _showGuideSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      // LocationGuideSheet, а не сама карточка: у карточки нет ни ручки,
      // ни подложки шита — она висела в прозрачной пустоте.
      builder: (_) => const LocationGuideSheet(),
    );
  }
}

/// Круглая кнопка над обложкой: фон 40px внутри 48px области нажатия.
/// Раньше кнопка «назад» была целиком 40px и не дотягивала до минимального
/// размера тач-таргета.
class _CircleAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _CircleAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.black.withValues(alpha: 0.45),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: AppDimens.avatar40,
              height: AppDimens.avatar40,
              child: Icon(icon, color: Colors.white, size: AppDimens.icon20),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        // Без падингов текст ошибки упирался в края экрана, а кнопка
        // «Повторить» растягивалась во всю ширину из-за minimumSize в теме.
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppDimens.avatar64,
              height: AppDimens.avatar64,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: AppColors.error,
                size: AppDimens.icon32,
              ),
            ),
            const SizedBox(height: AppDimens.space20),
            Text(
              'Что-то пошло не так',
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.space8),
            Text(
              message,
              style: AppTextStyles.subtext,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppDimens.space24),
            SizedBox(
              width: 200,
              height: AppDimens.buttonMinHeight,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: AppDimens.icon20),
                label: const Text('Повторить'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  minimumSize: const Size(0, AppDimens.buttonMinHeight),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.space8),
            TextButton(
              onPressed: onBack,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
              child: const Text('Назад'),
            ),
          ],
        ),
      ),
    );
  }
}
