import 'package:equatable/equatable.dart';
import 'package:jolutrip_app/features/guide_tours/domain/entities/itinerary_day_entity.dart';

class CreateTourEntity extends Equatable {
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

  CreateTourEntity copyWith({String? promoVideoUrl}) => CreateTourEntity(
    title: title,
    locationId: locationId,
    departureAt: departureAt,
    durationDays: durationDays,
    totalSeats: totalSeats,
    minSeats: minSeats,
    pricePerSeat: pricePerSeat,
    promoVideoUrl: promoVideoUrl ?? this.promoVideoUrl,
    includedServices: includedServices,
    gearRequirements: gearRequirements,
    itinerary: itinerary,
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
