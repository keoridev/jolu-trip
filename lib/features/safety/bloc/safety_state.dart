import 'package:jolutrip_app/features/safety/data/models/models.dart';

abstract class SafetyState {
  const SafetyState();
}

class SafetyInitial extends SafetyState {}

class SafetyLoading extends SafetyState {}

class SafetyLocationLoaded extends SafetyState {
  final GpsCoordinates? coordinates;
  final bool isLoading;

  const SafetyLocationLoaded({this.coordinates, this.isLoading = false});

  SafetyLocationLoaded copyWith({
    GpsCoordinates? coordinates,
    bool? isLoading,
  }) {
    return SafetyLocationLoaded(
      coordinates: coordinates ?? this.coordinates,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SafetyError extends SafetyState {
  final String message;
  const SafetyError(this.message);
}
