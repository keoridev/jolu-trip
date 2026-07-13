part of 'guide_tours_cubit.dart';

sealed class GuideToursState extends Equatable {
  final String? promoVideoKey;

  const GuideToursState({this.promoVideoKey});

  bool get isLoading => this is GuideToursVideoUploading || this is GuideToursCreating;

  @override
  List<Object?> get props => [promoVideoKey];
}

class GuideToursInitial extends GuideToursState {
  const GuideToursInitial() : super();
}

class GuideToursVideoUploading extends GuideToursState {
  const GuideToursVideoUploading({super.promoVideoKey});
}

class GuideToursVideoUploaded extends GuideToursState {
  const GuideToursVideoUploaded({required super.promoVideoKey});
}

class GuideToursCreating extends GuideToursState {
  const GuideToursCreating({super.promoVideoKey});
}

class GuideToursCreated extends GuideToursState {
  final TourEntity tour;
  const GuideToursCreated({required this.tour, super.promoVideoKey});

  @override
  List<Object?> get props => [tour, promoVideoKey];
}

class GuideToursError extends GuideToursState {
  final String message;
  final bool isNetworkError;
  final bool isValidationError;

  const GuideToursError({
    required this.message,
    this.isNetworkError = false,
    this.isValidationError = false,
    super.promoVideoKey,
  });

  @override
  List<Object?> get props => [message, isNetworkError, isValidationError, promoVideoKey];
}