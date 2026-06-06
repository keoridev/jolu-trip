import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/di/service_locator.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/utils/app_launcher.dart';
import 'package:jolutrip_app/features/safety/bloc/safety_cubit.dart';
import 'package:jolutrip_app/features/safety/bloc/safety_state.dart';
import 'package:jolutrip_app/features/safety/data/models/models.dart';
import 'package:jolutrip_app/features/safety/presentation/widgets/widgets.dart';

class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SafetyCubit>()..loadLocation(),
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildHeader(context),
              _buildSosBlock(),
              _buildContentBlocks(),
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: AppDimens.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildBackButton(context),
            const SizedBox(height: AppDimens.spaceXL),
            _buildTitle(),
            const SizedBox(height: AppDimens.spaceXL),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppDimens.radiusRound),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text('Назад', style: AppTextStyles.subtext.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppDimens.radiusRound),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emergency, color: AppColors.error, size: 14),
              const SizedBox(width: 6),
              Text(
                'SOS',
                style: AppTextStyles.accentBadge.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.spaceM),
        Text(
          'Безопасность\nи помощь',
          style: AppTextStyles.headline.copyWith(fontSize: 32, height: 1.1),
        ),
        const SizedBox(height: AppDimens.spaceS),
        Text(
          'Всё, что спасёт жизнь в горах',
          style: AppTextStyles.subtext.copyWith(fontSize: 15),
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildSosBlock() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: AppDimens.screenPadding,
        child: BlocBuilder<SafetyCubit, SafetyState>(
          builder: (context, state) {
            GpsCoordinates? coordinates;
            bool isLoading = false;

            if (state is SafetyLocationLoaded) {
              coordinates = state.coordinates;
            } else if (state is SafetyLocationLoading) {
              coordinates = state.previousCoords;
              isLoading = true;
            }

            return SosBlock(
              coordinates: coordinates,
              isLoading: isLoading,
              onRefresh: () => context.read<SafetyCubit>().refreshLocation(),
              onSos: () => AppLauncher.callEmergency(),
            );
          },
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildContentBlocks() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: AppDimens.screenPadding,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DigitalToolboxBlock(),
            SizedBox(height: AppDimens.spaceXL),
            SurvivalGuideBlock(),
            SizedBox(height: AppDimens.spaceXL),
            PhrasesBlock(),
            SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
