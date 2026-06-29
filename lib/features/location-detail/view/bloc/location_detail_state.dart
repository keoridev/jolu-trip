import 'package:equatable/equatable.dart';
import 'package:jolutrip_app/features/location-detail/domain/entities/entities.dart';

abstract class LocationDetailState extends Equatable {
  const LocationDetailState();

  @override
  List<Object?> get props => [];
}

class LocationDetailInitial extends LocationDetailState {}

class LocationDetailLoading extends LocationDetailState {}

class LocationDetailLoaded extends LocationDetailState {
  final LocationDetailEntity location;

  const LocationDetailLoaded(this.location);

  @override
  List<Object?> get props => [location];
}

class LocationDetailError extends LocationDetailState {
  final String message;

  const LocationDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
