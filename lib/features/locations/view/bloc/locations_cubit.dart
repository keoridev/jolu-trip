import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/core/usecases/usecase.dart';
import 'package:jolutrip_app/features/locations/domain/entities/location_entity.dart';
import 'package:jolutrip_app/features/locations/domain/usecases/get_locations.dart';

class LocationsState {
  final List<LocationEntity> locations;
  final bool isLoading;
  final String? error;

  const LocationsState({
    this.locations = const [],
    this.isLoading = false,
    this.error,
  });

  LocationsState copyWith({
    List<LocationEntity>? locations,
    bool? isLoading,
    String? error,
  }) {
    return LocationsState(
      locations: locations ?? this.locations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LocationsCubit extends Cubit<LocationsState> {
  final GetLocationsUseCase getLocationsUseCase;

  LocationsCubit({required this.getLocationsUseCase})
    : super(const LocationsState());

  Future<void> loadLocations() async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await getLocationsUseCase(NoParams());

    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (locations) =>
          emit(state.copyWith(isLoading: false, locations: locations)),
    );
  }
}
