// lib/features/guide_profile/presentation/screens/guide_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/guide_auth/domain/entities/guide_entity.dart';
import 'package:jolutrip_app/features/guide_onboarding/domain/entities/onboarding_entity.dart';

import 'package:jolutrip_app/features/guide_profile/screens/widgets/blocks/car_block_widget.dart';
import 'package:jolutrip_app/features/guide_profile/screens/widgets/blocks/experience_languages_block_widget.dart';
import 'package:jolutrip_app/features/guide_profile/screens/widgets/blocks/moderation_banner_widget.dart';
import 'package:jolutrip_app/features/guide_profile/screens/widgets/blocks/profile_header_widget.dart';
import 'package:jolutrip_app/features/guide_profile/screens/widgets/shared/disabled_action_button.dart'
    show DisabledActionButton;

class GuideProfileScreen extends StatelessWidget {
  final GuideEntity guide;
  final OnboardingEntity onboarding;

  const GuideProfileScreen({
    super.key,
    required this.guide,
    required this.onboarding,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go('/reels'),
        ),
        title: Text('Профиль гида', style: AppTextStyles.subtitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppDimens.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Баннер модерации (только если pending)
              if (guide.isPending) ...[
                ModerationBannerWidget(),
                const SizedBox(height: AppDimens.spaceXL),
              ],

              // Шапка профиля
              ProfileHeaderWidget(guide: guide),
              const SizedBox(height: AppDimens.spaceXL * 1.5),

              // Опыт и языки
              ExperienceLanguagesBlockWidget(onboarding: onboarding),
              const SizedBox(height: AppDimens.spaceXL),

              // Автомобиль
              CarBlockWidget(onboarding: onboarding),
              const SizedBox(height: AppDimens.spaceXL * 2),

              // Заблокированные кнопки (только если pending)
              if (guide.isPending) ...[
                _buildDisabledActions(),
                const SizedBox(height: AppDimens.spaceXL),
              ],

              // Кнопка выхода
              JoluButton(
                text: 'Выйти из аккаунта',
                variant: JoluButtonVariant.outline,
                onPressed: () {
                  // Очистить токен и перейти на auth
                  context.go('/auth');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisabledActions() {
    return Column(
      children: [
        DisabledActionButton(
          icon: Icons.add_circle_outline,
          label: 'Создать тур',
          hint: 'Доступно после проверки профиля',
        ),
        const SizedBox(height: AppDimens.spaceM),
        DisabledActionButton(
          icon: Icons.route_outlined,
          label: 'Мои туры',
          hint: 'Доступно после проверки профиля',
        ),
      ],
    );
  }
}
