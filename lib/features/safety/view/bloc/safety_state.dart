import 'package:equatable/equatable.dart';
import 'package:jolutrip_app/features/safety/data/models/model.dart';

abstract class SafetyState extends Equatable {
  const SafetyState();

  @override
  List<Object?> get props => [];
}

class SafetyInitial extends SafetyState {}

class SafetyLoading extends SafetyState {}

class SafetyLocationLoaded extends SafetyState {
  final GpsCoordinates? coordinates;
  final bool isLoading;

  const SafetyLocationLoaded({this.coordinates, this.isLoading = false});

  @override
  List<Object?> get props => [coordinates, isLoading];
}

class SafetyLocationLoading extends SafetyState {
  final GpsCoordinates? previousCoords;
  const SafetyLocationLoading({this.previousCoords});

  @override
  List<Object?> get props => [previousCoords];
}

class SafetyError extends SafetyState {
  final String message;
  const SafetyError(this.message);

  @override
  List<Object?> get props => [message];
}
