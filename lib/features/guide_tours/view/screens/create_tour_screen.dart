import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/guide-profile/view/bloc/guide_profile_cubit.dart';
import 'package:jolutrip_app/features/guide-profile/view/bloc/guide_profile_state.dart';
import 'package:jolutrip_app/features/guide_tours/view/bloc/guide_tours_cubit.dart';
import 'package:jolutrip_app/features/guide_tours/view/create_tour_contrloller.dart';
import 'package:jolutrip_app/features/guide_tours/view/widgets/create_tour_app_bar.dart';
import 'package:jolutrip_app/features/guide_tours/view/widgets/create_tour_bottom_nav.dart';
import 'package:jolutrip_app/features/guide_tours/view/widgets/create_tour_step_indicator.dart';
import 'package:jolutrip_app/features/guide_tours/view/widgets/step_basic_info.dart';
import 'package:jolutrip_app/features/guide_tours/view/widgets/step_details.dart';
import 'package:jolutrip_app/features/guide_tours/view/widgets/step_itinerary.dart';

class CreateTourScreen extends StatefulWidget {
  const CreateTourScreen({super.key});

  @override
  State<CreateTourScreen> createState() => _CreateTourScreenState();
}

class _CreateTourScreenState extends State<CreateTourScreen> {
  final _pageController = PageController();
  final _controller = CreateTourController();
  int _currentStep = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (!_controller.canGoNext(_currentStep)) {
      _showValidationError();
      return;
    }
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  void _showValidationError() {
    final errors = _controller.getValidationErrors(_currentStep);
    JoluSnackbar.show(
      context: context,
      message: 'Заполните обязательные поля:\n${errors.join('\n')}',
      type: JoluSnackbarType.warning,
    );
  }

  void _onSubmit() {
    if (!_controller.canGoNext(_currentStep)) {
      _showValidationError();
      return;
    }

    final promoKey = context.read<GuideToursCubit>().state.promoVideoKey;
    final entity = _controller.toEntity(promoVideoKey: promoKey);
    context.read<GuideToursCubit>().createTour(entity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: BlocConsumer<GuideToursCubit, GuideToursState>(
        listener: (context, state) {
          if (state is GuideToursCreated) {
            JoluSnackbar.show(
              context: context,
              message: 'Тур успешно создан!',
              type: JoluSnackbarType.success,
            );
            context.pop();
          } else if (state is GuideToursError) {
            if (state.message.contains('верифицирован') ||
                state.message.contains('403')) {
              JoluSnackbar.show(
                context: context,
                message: 'Создание туров доступно только после верификации',
                type: JoluSnackbarType.warning,
              );
              context.go('/profile');
            } else {
              JoluSnackbar.show(
                context: context,
                message: state.message,
                type: JoluSnackbarType.error,
              );
            }
          }
        },
        builder: (context, state) {
          final isLoading = state.isLoading;

          return ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              return Column(
                children: [
                  CreateTourAppBar(
                    currentStep: _currentStep,
                    onBack: _currentStep > 0 ? _prevStep : () => context.pop(),
                  ),
                  CreateTourStepIndicator(currentStep: _currentStep),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        StepBasicInfo(controller: _controller),
                        StepDetails(controller: _controller),
                        StepItinerary(controller: _controller),
                      ],
                    ),
                  ),
                  CreateTourBottomNav(
                    currentStep: _currentStep,
                    isLoading: isLoading,
                    canSubmit: _controller.canGoNext(_currentStep),
                    onNext: _currentStep == 2 ? _onSubmit : _nextStep,
                    onPrev: _prevStep,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}