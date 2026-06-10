import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/features/location-detail/bloc/location_detail_state.dart';
import 'package:jolutrip_app/features/location-detail/domain/domain.dart';

class LocationDetailCubit extends Cubit<LocationDetailState> {
  final LocationDetailRepository _repository;

  LocationDetailCubit(this._repository) : super(LocationDetailInitial());

  Future<void> loadLocationDetail(String locationId) async {
    emit(LocationDetailLoading());
    try {
      final location = await _repository.getLocationDetail(locationId);
      emit(LocationDetailLoaded(location));
    } catch (e) {
      emit(
        LocationDetailError('Не удалось загрузить локацию: ${e.toString()}'),
      );
    }
  }
}
