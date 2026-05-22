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
  const ReelsLoaded(this.reels);
  final List<ReelModel> reels;

  @override
  List<Object?> get props => [reels];
}

class ReelsError extends ReelsState {
  const ReelsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
