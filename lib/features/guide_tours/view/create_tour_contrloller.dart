import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jolutrip_app/features/guide_tours/domain/entities/create_tour_entity.dart';
import 'package:jolutrip_app/features/guide_tours/domain/entities/itinerary_day_entity.dart';

/// Контроллер состояния создания тура.
///
/// Хранит все данные формы и логику валидации.
/// Передаётся через Provider/ InheritedWidget в дочерние виджеты.
class CreateTourController extends ChangeNotifier {
  // === Step 1: Основное ===
  final titleController = TextEditingController();
  String? selectedLocationId;
  String? selectedLocationName;
  DateTime? departureDate;
  int durationDays = 1;

  // === Step 2: Детали ===
  final priceController = TextEditingController();
  final totalSeatsController = TextEditingController();
  final minSeatsController = TextEditingController(text: '1');
  final List<String> includedServices = [];
  final List<String> gearRequirements = [];
  final serviceController = TextEditingController();
  final gearController = TextEditingController();

  // === Step 3: Маршрут ===
  final List<ItineraryDayEntity> itinerary = [];
  final itineraryDescController = TextEditingController();
  int currentDayNumber = 1;

  // === Видео ===
  XFile? selectedVideo;
  double uploadProgress = 0;

  // === Валидация ===
  bool canGoNext(int step) {
    switch (step) {
      case 0:
        return titleController.text.trim().isNotEmpty &&
            selectedLocationId != null &&
            departureDate != null;
      case 1:
        return priceController.text.isNotEmpty &&
            totalSeatsController.text.isNotEmpty;
      case 2:
        return itinerary.isNotEmpty;
      default:
        return false;
    }
  }

  List<String> getValidationErrors(int step) {
    final messages = <String>[];
    switch (step) {
      case 0:
        if (titleController.text.trim().isEmpty)
          messages.add('• Название тура');
        if (selectedLocationId == null) messages.add('• Локация');
        if (departureDate == null) messages.add('• Дата отправления');
      case 1:
        if (priceController.text.isEmpty) messages.add('• Цена');
        if (totalSeatsController.text.isEmpty)
          messages.add('• Количество мест');
      case 2:
        if (itinerary.isEmpty) messages.add('• Хотя бы один день маршрута');
    }
    return messages;
  }

  // === Actions ===
  void setLocation(String id, String name) {
    selectedLocationId = id;
    selectedLocationName = name;
    notifyListeners();
  }

  void setDate(DateTime date) {
    departureDate = date;
    notifyListeners();
  }

  void changeDuration(int delta) {
    final newValue = durationDays + delta;
    if (newValue >= 1) {
      durationDays = newValue;
      notifyListeners();
    }
  }

  void addService(String value) {
    if (value.trim().isNotEmpty) {
      includedServices.add(value.trim());
      notifyListeners();
    }
  }

  void removeService(int index) {
    includedServices.removeAt(index);
    notifyListeners();
  }

  void addGear(String value) {
    if (value.trim().isNotEmpty) {
      gearRequirements.add(value.trim());
      notifyListeners();
    }
  }

  void removeGear(int index) {
    gearRequirements.removeAt(index);
    notifyListeners();
  }

  void addDay(String description) {
    if (description.trim().isNotEmpty) {
      itinerary.add(
        ItineraryDayEntity(
          day: currentDayNumber,
          description: description.trim(),
        ),
      );
      itinerary.sort((a, b) => a.day.compareTo(b.day));
      currentDayNumber = itinerary.length + 1;
      notifyListeners();
    }
  }

  void setVideo(XFile? video) {
    selectedVideo = video;
    notifyListeners();
  }

  void setUploadProgress(double progress) {
    uploadProgress = progress;
    notifyListeners();
  }

  CreateTourEntity toEntity({String? promoVideoKey}) {
    return CreateTourEntity(
      title: titleController.text.trim(),
      locationId: selectedLocationId!,
      departureAt: departureDate!.toUtc().toIso8601String(),
      durationDays: durationDays,
      totalSeats: int.parse(totalSeatsController.text),
      minSeats: int.parse(minSeatsController.text),
      pricePerSeat: double.parse(priceController.text),
      includedServices: List.from(includedServices),
      gearRequirements: List.from(gearRequirements),
      itinerary: List.from(itinerary),
      promoVideoUrl: promoVideoKey,
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    totalSeatsController.dispose();
    minSeatsController.dispose();
    serviceController.dispose();
    gearController.dispose();
    itineraryDescController.dispose();
    super.dispose();
  }
}
