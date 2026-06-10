import 'package:jolutrip_app/features/location-detail/domain/entities/entities.dart';

class RoadsidePlaceModel extends RoadsidePlaceEntity {
  const RoadsidePlaceModel({
    required super.id,
    required super.name,
    required super.description,
    required super.category,
    required super.amenities,
    super.averageCheck,
    required super.photos,
    super.createdAt,
    super.updatedAt,
  });

  factory RoadsidePlaceModel.fromJson(Map<String, dynamic> json) {
    return RoadsidePlaceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      category: _parseCategory(json['category'] as String?),
      amenities:
          (json['amenities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      averageCheck: (json['average_check'] as num?)?.toDouble(),
      photos:
          (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  static PlaceCategory _parseCategory(String? value) {
    return switch (value) {
      'ethno_resort' => PlaceCategory.ethnoResort,
      'cafe' => PlaceCategory.cafe,
      'shop' => PlaceCategory.shop,
      'gas_station' => PlaceCategory.gasStation,
      'viewpoint' => PlaceCategory.viewpoint,
      'camping' => PlaceCategory.camping,
      _ => PlaceCategory.other,
    };
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': switch (category) {
      PlaceCategory.ethnoResort => 'ethno_resort',
      PlaceCategory.cafe => 'cafe',
      PlaceCategory.shop => 'shop',
      PlaceCategory.gasStation => 'gas_station',
      PlaceCategory.viewpoint => 'viewpoint',
      PlaceCategory.camping => 'camping',
      PlaceCategory.other => 'other',
    },
    'amenities': amenities,
    'average_check': averageCheck,
    'photos': photos,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
