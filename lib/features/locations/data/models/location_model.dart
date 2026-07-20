import 'package:jolutrip_app/features/locations/domain/entities/location_entity.dart';

class LocationModel {
  final String id;
  final String name;

  const LocationModel({required this.id, required this.name});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  LocationEntity toEntity() => LocationEntity(id: id, name: name);
}
