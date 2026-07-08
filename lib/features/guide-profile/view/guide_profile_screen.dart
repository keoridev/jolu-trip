import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/core/utils/image_picker_utils.dart';
import 'package:jolutrip_app/features/guide-profile/domain/entities/entities.dart';
import 'package:jolutrip_app/features/guide-profile/view/bloc/guide_profile_cubit.dart';
import 'package:jolutrip_app/features/guide-profile/view/bloc/guide_profile_state.dart';
import 'package:jolutrip_app/features/guide-profile/view/widgets/guide_profile_actions.dart';
import 'package:jolutrip_app/features/guide-profile/view/widgets/guide_profile_error.dart';
import 'package:jolutrip_app/features/guide-profile/view/widgets/guide_profile_header.dart';
import 'package:jolutrip_app/features/guide-profile/view/widgets/guide_profile_media_grid.dart';
import 'package:jolutrip_app/features/guide-profile/view/widgets/guide_profile_skeleton.dart';
import 'package:jolutrip_app/features/guide-profile/view/widgets/guide_profile_stats.dart';
import 'package:jolutrip_app/features/guide-profile/view/widgets/guide_status_banner.dart';

class GuideProfileScreen extends StatelessWidget {
  const GuideProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: BlocConsumer<GuideProfileCubit, GuideProfileState>(
          listener: (context, state) {
            if (state is GuideProfileError) {
              JoluSnackbar.show(
                context: context,
                message: state.message,
                type: JoluSnackbarType.error,
              );
            }
          },
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: switch (state) {
                GuideProfileInitial() ||
                GuideProfileLoading() => const GuideProfileSkeleton(),
                GuideProfileLoaded(profile: final profile) => _ProfileContent(
                  key: const ValueKey('loaded'),
                  profile: profile,
                ),
                GuideProfileError() => GuideProfileErrorWidget(state: state),
                GuideProfileState() => throw UnimplementedError(),
              },
            );
          },
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final GuideProfileEntity profile;

  const _ProfileContent({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Header: avatar, name, phone, status
        SliverToBoxAdapter(
          child: GuideProfileHeader(
            profile: profile,
            onAvatarTap: profile.canEdit ? () => _onAvatarTap(context) : null,
          ),
        ),

        // Status banner (if pending/rejected)
        if (profile.isPending || profile.isRejected)
          SliverToBoxAdapter(
            child: Padding(
              padding: AppDimens.screenPadding.copyWith(top: 0, bottom: 0),
              child: Column(
                children: [
                  const SizedBox(height: AppDimens.space16),
                  GuideStatusBanner(profile: profile),
                ],
              ),
            ),
          ),

        // Stats: tours, rating, reviews
        const SliverToBoxAdapter(child: SizedBox(height: AppDimens.space24)),
        SliverToBoxAdapter(child: GuideProfileStats(profile: profile)),

        // Media grid (avatar + car photos + video) — "как в инсте"
        const SliverToBoxAdapter(child: SizedBox(height: AppDimens.space24)),
        SliverToBoxAdapter(child: GuideProfileMediaGrid(profile: profile)),

        // Actions: create tour, my tours, logout
        const SliverToBoxAdapter(child: SizedBox(height: AppDimens.space24)),
        SliverToBoxAdapter(child: GuideProfileActions(profile: profile)),
      ],
    );
  }

  void _onAvatarTap(BuildContext context) async {
    final bytes = await ImagePickerUtils().showImagePickerDialog(context);
    if (bytes != null && context.mounted) {
      context.read<GuideProfileCubit>().updateAvatar(bytes);
    }
  }
}
