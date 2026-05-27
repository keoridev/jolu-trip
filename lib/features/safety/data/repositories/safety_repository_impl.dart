import 'package:geolocator/geolocator.dart';
import 'package:jolutrip_app/features/safety/data/models/models.dart';
import 'package:jolutrip_app/features/safety/domain/repositories/safety_repository.dart';

class SafetyRepositoryImpl implements SafetyRepository {
  @override
  Future<GpsCoordinates?> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      return GpsCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> hasLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<void> requestLocationPermission() async {
    await Geolocator.requestPermission();
  }
}
