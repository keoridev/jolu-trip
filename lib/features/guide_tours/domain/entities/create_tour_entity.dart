import 'package:equatable/equatable.dart';
import 'package:jolutrip_app/features/guide_tours/domain/entities/itinerary_day_entity.dart';

class CreateTourEntity extends Equatable {
  final String title;
  final String locationId;
  final String departureAt;
  final int durationDays;
  final int totalSeats;
  final int minSeats;
  final int pricePerSeat;
  final String? promoVideoUrl;
  final List<String> includedServices;
  final List<String> gearRequirements;
  final List<ItineraryDayEntity> itinerary;

  const CreateTourEntity({
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

  CreateTourEntity copyWith({
    String? title,
    String? locationId,
    String? departureAt,
    int? durationDays,
    int? totalSeats,
    int? minSeats,
    int? pricePerSeat,
    String? promoVideoUrl,
    List<String>? includedServices,
    List<String>? gearRequirements,
    List<ItineraryDayEntity>? itinerary,
  }) => CreateTourEntity(
    title: title ?? this.title,
    locationId: locationId ?? this.locationId,
    departureAt: departureAt ?? this.departureAt,
    durationDays: durationDays ?? this.durationDays,
    totalSeats: totalSeats ?? this.totalSeats,
    minSeats: minSeats ?? this.minSeats,
    pricePerSeat: pricePerSeat ?? this.pricePerSeat,
    promoVideoUrl: promoVideoUrl ?? this.promoVideoUrl,
    includedServices: includedServices ?? this.includedServices,
    gearRequirements: gearRequirements ?? this.gearRequirements,
    itinerary: itinerary ?? this.itinerary,
  );

  @override
  List<Object?> get props => [
    title,
    locationId,
    departureAt,
    durationDays,
    totalSeats,
    minSeats,
    pricePerSeat,
    promoVideoUrl,
    includedServices,
    gearRequirements,
    itinerary,
  ];
}
