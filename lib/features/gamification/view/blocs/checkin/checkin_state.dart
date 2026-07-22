import 'package:equatable/equatable.dart';
import 'package:jolutrip_app/features/gamification/domain/entities/entities.dart';

sealed class CheckinState extends Equatable {
  const CheckinState();

  @override
  List<Object?> get props => [];
}

class CheckinIdle extends CheckinState {
  const CheckinIdle();
}

class CheckinValidating extends CheckinState {
  const CheckinValidating();
}

class CheckinSuccess extends CheckinState {
  final VisitRecord visit;
  final List<Stamp> newStamps;
  final bool isFirstVisit;
  final String locationName;

  const CheckinSuccess({
    required this.visit,
    required this.newStamps,
    required this.locationName,
    this.isFirstVisit = false,
  });

  @override
  List<Object?> get props => [visit, newStamps, isFirstVisit, locationName];
}

class CheckinFailure extends CheckinState {
  final String message;

  const CheckinFailure(this.message);

  @override
  List<Object?> get props => [message];
}
