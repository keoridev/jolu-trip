part of 'guide_tours_cubit.dart';

sealed class GuideToursState extends Equatable {
  const GuideToursState();

  @override
  List<Object?> get props => [];
}

class GuideToursInitial extends GuideToursState {
  const GuideToursInitial();
}

class GuideToursVideoUploading extends GuideToursState {
  const GuideToursVideoUploading();
}

class GuideToursVideoUploaded extends GuideToursState {
  const GuideToursVideoUploaded();
}

class GuideToursCreating extends GuideToursState {
  const GuideToursCreating();
}

class GuideToursCreated extends GuideToursState {
  final TourEntity tour;
  const GuideToursCreated({required this.tour});

  @override
  List<Object?> get props => [tour];
}

class GuideToursError extends GuideToursState {
  final String message;
  const GuideToursError({required this.message});

  @override
  List<Object?> get props => [message];
}
