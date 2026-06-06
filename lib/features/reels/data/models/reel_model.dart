class ReelModel {
  final String id;
  final String name;
  final String shortDescription;
  final String videoUrl;
  final String thumbnailUrl;
  final String category;
  final bool hasInternet;
  final String carRequirement;
  final String travelTimeFromCity;
  final double priceStartsFrom;

  ReelModel({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.category,
    required this.hasInternet,
    required this.carRequirement,
    required this.travelTimeFromCity,
    required this.priceStartsFrom,
  });

  factory ReelModel.fromJson(Map<String, dynamic> json) => ReelModel(
    id: json['id'] as String,
    name: json['name'] as String,
    shortDescription: json['short_description'] as String? ?? '',
    videoUrl: json['video_url'] as String? ?? '',
    thumbnailUrl: json['thumbnail_url'] as String? ?? '',
    category: json['category'] as String? ?? '',
    hasInternet: json['has_internet'] as bool? ?? false,
    carRequirement: json['car_requirement'] as String? ?? '',
    travelTimeFromCity: json['travel_time_from_city'] as String? ?? '',
    priceStartsFrom: (json['price_starts_from'] as num?)?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'short_description': shortDescription,
    'video_url': videoUrl,
    'thumbnail_url': thumbnailUrl,
    'category': category,
    'has_internet': hasInternet,
    'car_requirement': carRequirement,
    'travel_time_from_city': travelTimeFromCity,
    'price_starts_from': priceStartsFrom,
  };
}
