// lib/features/location-detail/view/location_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/di/service_locator.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

import 'package:jolutrip_app/features/gamification/view/blocs/checkin/checkin_cubit.dart';
import 'package:jolutrip_app/features/gamification/view/blocs/checkin/checkin_state.dart';
import 'package:jolutrip_app/features/gamification/view/blocs/stamps/stamps_cubit.dart';
import 'package:jolutrip_app/features/location-detail/view/bloc/location_detail_cubit.dart';
import 'package:jolutrip_app/features/location-detail/view/bloc/location_detail_state.dart';
import 'package:jolutrip_app/features/location-detail/domain/domain.dart';
import 'package:jolutrip_app/features/location-detail/view/widgets/widgets.dart';

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
    context.read<LocationDetailCubit>().loadLocationDetail(widget.locationId);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: BlocBuilder<LocationDetailCubit, LocationDetailState>(
          builder: (context, state) {
            return switch (state) {
              LocationDetailLoading() => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),

              LocationDetailError(message: final msg) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      msg,
                      style: AppTextStyles.body,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<LocationDetailCubit>()
                          .loadLocationDetail(widget.locationId),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),

              LocationDetailLoaded(location: final location) => Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      // Hero с кнопкой назад
                      SliverToBoxAdapter(
                        child: Stack(
                          children: [
                            LocationHeroSection(
                              location: location,
                              onVideoTap: () {
                                // TODO: Открыть полноэкранное видео
                              },
                            ),
                            Positioned(
                              top: MediaQuery.of(context).padding.top + 8,
                              left: AppDimens.space16,
                              child: GestureDetector(
                                onTap: () => context.pop(),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: LocationInfoCards(location: location),
                      ),

                      SliverToBoxAdapter(
                        child: LocationDescription(location: location),
                      ),

                      SliverToBoxAdapter(
                        child: LocationMapPreview(
                          location: location,
                          onOpenMap: () => _showSelfDriveSheet(location),
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: LocationRoadsidePlaces(
                          places: location.roadsidePlaces,
                        ),
                      ),

                      const SliverToBoxAdapter(child: LocationGuideCard()),

                      // ═══════════════════════════════════════════════════
                      // КНОПКА ЧЕКИНА (новое)
                      // ═══════════════════════════════════════════════════
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _CheckinButton(location: location),
                        ),
                      ),

                      const SliverPadding(
                        padding: EdgeInsets.only(bottom: 150),
                      ),
                    ],
                  ),

                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: LocationActionBar(
                      onSelfDrive: () => _showSelfDriveSheet(location),
                      onWithGuide: () => _showGuideSheet(location),
                    ),
                  ),
                ],
              ),

              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }

  void _showSelfDriveSheet(LocationDetailEntity location) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => LocationSelfDriveSheet(location: location),
    );
  }

  void _showGuideSheet(LocationDetailEntity location) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const LocationGuideCard(),
    );
  }
}

// ═══════════════════════════════════════════════════
// КНОПКА ЧЕКИНА
// ═══════════════════════════════════════════════════

class _CheckinButton extends StatelessWidget {
  final LocationDetailEntity location;

  const _CheckinButton({required this.location});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CheckinCubit>(),
      child: Builder(
        builder: (context) {
          return BlocConsumer<CheckinCubit, CheckinState>(
            listener: (context, state) {
              if (state is CheckinSuccess) {
                // Обновляем печати
                context.read<StampsCubit>().onCheckinCompleted(state.newStamps);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Чекин в ${state.locationName}!'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );

                // Если есть новые печати — показываем анимацию
                if (state.newStamps.isNotEmpty) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    context.push('/stamps');
                  });
                }
              } else if (state is CheckinFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ ${state.message}'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is CheckinValidating;

              return SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () {
                          context.read<CheckinCubit>().checkin(
                            locationId: location.id,
                            locationName: location.name,
                            locationLat: location.latitude,
                            locationLng: location.longitude,
                            locationTags: location.roadFeatures,
                          );
                        },
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.location_on),
                  label: Text(
                    isLoading ? 'Проверка...' : 'Я здесь',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    ),
                    elevation: 0,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
