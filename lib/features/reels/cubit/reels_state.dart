import 'package:equatable/equatable.dart';
import 'package:jolutrip_app/features/reels/data/data.dart';

abstract class ReelsState extends Equatable {
  const ReelsState();

  @override
  List<Object?> get props => [];
}

class ReelsInitial extends ReelsState {}

class ReelsLoading extends ReelsState {}

class ReelsLoaded extends ReelsState {
  const ReelsLoaded(this.reels, {this.currentIndex = 0});
  final List<ReelModel> reels;
  final int currentIndex;

  @override
  List<Object?> get props => [reels, currentIndex];

  ReelsLoaded copyWith({List<ReelModel>? reels, int? currentIndex}) {
    return ReelsLoaded(
      reels ?? this.reels,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class ReelsError extends ReelsState {
  const ReelsError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
