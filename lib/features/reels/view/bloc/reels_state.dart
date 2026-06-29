import 'package:equatable/equatable.dart';
import 'package:jolutrip_app/features/reels/data/models/model.dart';

abstract class ReelsState extends Equatable {
  const ReelsState();
  @override
  List<Object?> get props => [];
}

class ReelsInitial extends ReelsState {
  const ReelsInitial();
}

class ReelsLoading extends ReelsState {
  const ReelsLoading();
}

class ReelsLoaded extends ReelsState {
  final List<ReelModel> reels;
  final int currentIndex;

  const ReelsLoaded({
    required this.reels,
    this.currentIndex = 0,
  });

  ReelsLoaded copyWith({
    List<ReelModel>? reels,
    int? currentIndex,
  }) {
    return ReelsLoaded(
      reels: reels ?? this.reels,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object?> get props => [reels, currentIndex];
}

class ReelsError extends ReelsState {
  final String message;
  const ReelsError(this.message);
  @override
  List<Object?> get props => [message];
}
