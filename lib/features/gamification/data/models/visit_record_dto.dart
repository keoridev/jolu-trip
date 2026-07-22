import 'package:jolutrip_app/features/gamification/domain/entities/entities.dart';

class VisitRecordDto {
  final String id;
  final String locationId;
  final String visitedAt;
  final String? note;
  final List<Map<String, dynamic>> photos;
  final String? routeId;
  final bool isSynced;
  final String syncId;

  VisitRecordDto({
    required this.id,
    required this.locationId,
    required this.visitedAt,
    this.note,
    this.photos = const [],
    this.routeId,
    this.isSynced = false,
    this.syncId = '',
  });

  factory VisitRecordDto.fromEntity(VisitRecord entity) {
    return VisitRecordDto(
      id: entity.id,
      locationId: entity.locationId,
      visitedAt: entity.visitedAt.toIso8601String(),
      note: entity.note,
      photos: entity.photos
          .map(
            (p) => {
              'id': p.id,
              'localPath': p.localPath,
              'remoteUrl': p.remoteUrl,
              'synced': p.synced,
            },
          )
          .toList(),
      routeId: entity.routeId,
      isSynced: entity.isSynced,
      syncId: entity.syncId,
    );
  }

  VisitRecord toEntity() {
    return VisitRecord(
      id: id,
      locationId: locationId,
      visitedAt: DateTime.parse(visitedAt),
      note: note,
      photos: photos
          .map(
            (p) => VisitPhoto(
              id: p['id'] as String,
              localPath: p['localPath'] as String,
              remoteUrl: p['remoteUrl'] as String?,
              synced: p['synced'] as bool? ?? false,
            ),
          )
          .toList(),
      routeId: routeId,
      isSynced: isSynced,
      syncId: syncId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'locationId': locationId,
      'visitedAt': visitedAt,
      'note': note,
      'photos': photos,
      'routeId': routeId,
      'isSynced': isSynced,
      'syncId': syncId,
    };
  }

  factory VisitRecordDto.fromJson(Map<String, dynamic> json) {
    return VisitRecordDto(
      id: json['id'] as String,
      locationId: json['locationId'] as String,
      visitedAt: json['visitedAt'] as String,
      note: json['note'] as String?,
      photos: (json['photos'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>(),
      routeId: json['routeId'] as String?,
      isSynced: json['isSynced'] as bool? ?? false,
      syncId: json['syncId'] as String? ?? '',
    );
  }
}
