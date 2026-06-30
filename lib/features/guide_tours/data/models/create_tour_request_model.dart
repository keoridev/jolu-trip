import 'package:equatable/equatable.dart';

class ItineraryDayModel extends Equatable {
  final int day;
  final String description;

  const ItineraryDayModel({required this.day, required this.description});

  factory ItineraryDayModel.fromJson(Map<String, dynamic> json) {
    return ItineraryDayModel(
      day: json['day'] as int,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'day': day,
    'description': description,
  };

  @override
  List<Object?> get props => [day, description];
}

class CreateTourRequestModel extends Equatable {
  final String title;
  final String locationId;
  final String departureAt;
  final int durationDays;
  final int totalSeats;
  final int minSeats;
  final double pricePerSeat;
  final String? promoVideoUrl;
  final List<String> includedServices;
  final List<String> gearRequirements;
  final List<ItineraryDayModel> itinerary;

  const CreateTourRequestModel({
    required this.title,
    required this.locationId,
    required this.departureAt,
    required this.durationDays,
    required this.totalSeats,
    required this.minSeats,
    required this.pricePerSeat,
    this.promoVideoUrl,
    this.includedServices = const [],
    this.gearRequirements = const [],
    this.itinerary = const [],
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'location_id': locationId,
    'departure_at': departureAt,
    'duration_days': durationDays,
    'total_seats': totalSeats,
    'min_seats': minSeats,
    'price_per_seat': pricePerSeat,
    if (promoVideoUrl != null) 'promo_video_url': promoVideoUrl,
    'included_services': includedServices,
    'gear_requirements': gearRequirements,
    'itinerary': itinerary.map((e) => e.toJson()).toList(),
    'status': 'draft',
  };

  @override
  List<Object?> get props => [
    title, locationId, departureAt, durationDays, totalSeats,
    minSeats, pricePerSeat, promoVideoUrl, includedServices,
    gearRequirements, itinerary,
  ];
}