// lib/features/gamification/presentation/pages/stamps_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/stamp.dart';
import '../../domain/entities/collection.dart';
import '../blocs/stamps/stamps_cubit.dart';
import '../blocs/stamps/stamps_state.dart';
import '../widgets/stamp_card.dart';
import '../widgets/collection_progress.dart';
import '../widgets/stamp_unlock_overlay.dart';

class StampsScreen extends StatelessWidget {
  const StampsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Мои печати',
          style: AppTextStyles.headline.copyWith(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<StampsCubit, StampsState>(
        listener: (context, state) {
          if (state is StampsLoaded && 
              state.showAnimation && 
              state.lastEarnedStamps.isNotEmpty) {
            _showUnlockAnimation(context, state.lastEarnedStamps);
          }
        },
        builder: (context, state) {
          if (state is StampsInitial || state is StampsLoading) {
            return const _LoadingView();
          }
          if (state is StampsError) {
            return _ErrorView(message: state.message);
          }
          if (state is StampsLoaded) {
            return _StampsView(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showUnlockAnimation(BuildContext context, List<Stamp> stamps) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StampUnlockOverlay(
        stamps: stamps,
        onComplete: () {
          Navigator.of(context).pop();
          context.read<StampsCubit>().animationShown();
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          Text(message, style: AppTextStyles.subtext, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _StampsView extends StatelessWidget {
  final StampsLoaded state;
  const _StampsView({required this.state});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _TravelerStatusCard(
            status: state.travelerStatus ?? 'Турист',
            totalStamps: state.totalStamps,
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Коллекции',
              style: AppTextStyles.headline.copyWith(fontSize: 20),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => CollectionProgress(
              collection: state.collections[index],
            ),
            childCount: state.collections.length,
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Мои печати',
                  style: AppTextStyles.headline.copyWith(fontSize: 20),
                ),
                Text(
                  '${state.stamps.length}',
                  style: AppTextStyles.subtext.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        ),

        if (state.stamps.isEmpty)
          SliverToBoxAdapter(
            child: _EmptyStampsView(),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => StampCard(stamp: state.stamps[index]),
                childCount: state.stamps.length,
              ),
            ),
          ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
      ],
    );
  }
}

class _TravelerStatusCard extends StatelessWidget {
  final String status;
  final int totalStamps;

  const _TravelerStatusCard({
    required this.status,
    required this.totalStamps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.map_outlined,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: AppTextStyles.headline.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalStamps печатей',
                  style: AppTextStyles.subtext,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStampsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          Icon(
            Icons.stars_outlined,
            size: 48,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Пока нет печатей',
            style: AppTextStyles.title.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Посещайте локации, чтобы получать печати',
            style: AppTextStyles.subtext,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}