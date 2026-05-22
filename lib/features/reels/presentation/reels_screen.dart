import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/reels/cubit/reels_cubit.dart';
import 'package:jolutrip_app/features/reels/cubit/reels_state.dart';

import 'widgets/reel_video_item.dart';
import 'widgets/reel_info_overlay.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: BlocBuilder<ReelsCubit, ReelsState>(
        builder: (context, state) {
          if (state is ReelsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (state is ReelsLoaded) {
            if (state.reels.isEmpty) {
              return const Center(
                child: Text(
                  'На данный момент экспедиций не найдено.',
                  style: AppTextStyles.body,
                ),
              );
            }

            return PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: state.reels.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final reel = state.reels[index];
                return Stack(
                  children: [
                    ReelVideoItem(
                      reel: reel,
                      isCurrent: index == _currentIndex,
                    ),

                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.2),
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),

                    ReelInfoOverlay(reel: reel),
                  ],
                );
              },
            );
          }

          if (state is ReelsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.spaceXL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppDimens.spaceM),
                    Text(
                      'Не удалось загрузить ленту',
                      style: AppTextStyles.title,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimens.spaceXS),
                    Text(
                      state.message,
                      style: AppTextStyles.subtext,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimens.spaceL),
                    ElevatedButton(
                      onPressed: () => context.read<ReelsCubit>().loadReels(),
                      child: const Text('Повторить попытку'),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
