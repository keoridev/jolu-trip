import 'package:equatable/equatable.dart';
import 'package:jolutrip_app/features/gamification/domain/entities/entities.dart';

sealed class StampsState extends Equatable {
  const StampsState();

  @override
  List<Object?> get props => [];
}

class StampsInitial extends StampsState {
  const StampsInitial();
}

class StampsLoading extends StampsState {
  const StampsLoading();
}

class StampsLoaded extends StampsState {
  final List<Stamp> stamps;
  final List<Collection> collections;
  final List<Stamp> lastEarnedStamps;
  final bool showAnimation;
  final String? travelerStatus;
  final int totalStamps;

  const StampsLoaded({
    required this.stamps,
    required this.collections,
    this.lastEarnedStamps = const [],
    this.showAnimation = false,
    this.travelerStatus,
    this.totalStamps = 0,
  });

  StampsLoaded copyWith({
    List<Stamp>? stamps,
    List<Collection>? collections,
    List<Stamp>? lastEarnedStamps,
    bool? showAnimation,
    String? travelerStatus,
    int? totalStamps,
  }) {
    return StampsLoaded(
      stamps: stamps ?? this.stamps,
      collections: collections ?? this.collections,
      lastEarnedStamps: lastEarnedStamps ?? this.lastEarnedStamps,
      showAnimation: showAnimation ?? this.showAnimation,
      travelerStatus: travelerStatus ?? this.travelerStatus,
      totalStamps: totalStamps ?? this.totalStamps,
    );
  }

  @override
  List<Object?> get props => [
    stamps,
    collections,
    lastEarnedStamps,
    showAnimation,
    travelerStatus,
    totalStamps,
  ];
}

class StampsError extends StampsState {
  final String message;

  const StampsError(this.message);

  @override
  List<Object?> get props => [message];
}
