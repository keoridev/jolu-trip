import 'package:jolutrip_app/features/location-detail/domain/entities/entities.dart';

import 'roadside_place_model.dart';

class LocationDetailModel extends LocationDetailEntity {
  const LocationDetailModel({
    required super.id,
    required super.name,
    required super.shortDescription,
    required super.description,
    required super.videoUrl,
    required super.thumbnailUrl,
    required super.category,
    required super.hasInternet,
    required super.carRequirement,
    required super.travelDays,
    required super.travelHours,
    required super.travelMinutes,
    required super.priceStartsFrom,
    super.entryFee,
    required super.latitude,
    required super.longitude,
    required super.roadFeatures,
    required super.gearList,
    required super.roadsidePlaces,
  });

  factory LocationDetailModel.fromJson(Map<String, dynamic> json) {
    return LocationDetailModel(
      id: json['id'] as String,
      name: json['name'] as String,
      shortDescription: json['short_description'] as String? ?? '',
      description: json['description'] as String? ?? '',
      videoUrl: json['video_url'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      category: json['category'] as String? ?? '',
      hasInternet: json['has_internet'] as bool? ?? false,
      carRequirement: json['car_requirement'] as String? ?? '',
      travelDays: json['travel_days'] as int? ?? 0,
      travelHours: json['travel_hours'] as int? ?? 0,
      travelMinutes: json['travel_minutes'] as int? ?? 0,
      priceStartsFrom: (json['price_starts_from'] as num?)?.toDouble() ?? 0.0,
      entryFee: (json['entry_fee'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      roadFeatures:
          (json['road_features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      gearList:
          (json['gear_list'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      roadsidePlaces:
          (json['roadside_places'] as List<dynamic>?)
              ?.map(
                (e) => RoadsidePlaceModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'short_description': shortDescription,
    'description': description,
    'video_url': videoUrl,
    'thumbnail_url': thumbnailUrl,
    'category': category,
    'has_internet': hasInternet,
    'car_requirement': carRequirement,
    'travel_days': travelDays,
    'travel_hours': travelHours,
    'travel_minutes': travelMinutes,
    'price_starts_from': priceStartsFrom,
    'entry_fee': entryFee,
    'latitude': latitude,
    'longitude': longitude,
    'road_features': roadFeatures,
    'gear_list': gearList,
    'roadside_places': roadsidePlaces
        .map((p) => (p as RoadsidePlaceModel).toJson())
        .toList(),
  };
}
