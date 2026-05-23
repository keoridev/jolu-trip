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
  const ReelsLoaded(this.reels, {this.currentIndex = 0, this.isPlaying = true});
  final List<ReelModel> reels;
  final int currentIndex;
  final bool isPlaying;

  @override
  List<Object?> get props => [reels, currentIndex, isPlaying];

  ReelsLoaded copyWith({
    List<ReelModel>? reels,
    int? currentIndex,
    bool? isPlaying,
  }) {
    return ReelsLoaded(
      reels ?? this.reels,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

class ReelsError extends ReelsState {
  const ReelsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
