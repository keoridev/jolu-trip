import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
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
                            // Кнопка назад
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

                      // Инфо-карточки
                      SliverToBoxAdapter(
                        child: LocationInfoCards(location: location),
                      ),

                      // Описание
                      SliverToBoxAdapter(
                        child: LocationDescription(location: location),
                      ),

                      // Карта
                      SliverToBoxAdapter(
                        child: LocationMapPreview(
                          location: location,
                          onOpenMap: () => _showSelfDriveSheet(location),
                        ),
                      ),

                      // Места для остановки
                      SliverToBoxAdapter(
                        child: LocationRoadsidePlaces(
                          places: location.roadsidePlaces,
                        ),
                      ),

                      // Гид (заглушка)
                      const SliverToBoxAdapter(child: LocationGuideCard()),

                      // Отступ для нижней панели
                      const SliverPadding(
                        padding: EdgeInsets.only(bottom: 100),
                      ),
                    ],
                  ),

                  // Нижняя панель действий
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
