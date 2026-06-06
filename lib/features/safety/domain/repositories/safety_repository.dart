import 'package:jolutrip_app/features/safety/data/models/models.dart';

abstract class SafetyRepository {
  Future<GpsCoordinates?> getCurrentLocation();
  Future<bool> hasLocationPermission();
  Future<void> requestLocationPermission();
}
