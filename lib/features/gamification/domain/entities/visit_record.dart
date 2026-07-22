class VisitRecord {
  final String id;
  final String locationId;
  final DateTime visitedAt;
  final String? note;
  final List<VisitPhoto> photos;
  final String? routeId;
  final bool isSynced;
  final String syncId;

  const VisitRecord({
    required this.id,
    required this.locationId,
    required this.visitedAt,
    this.note,
    this.photos = const [],
    this.routeId,
    this.isSynced = false,
    this.syncId = '',
  });

  VisitRecord copyWith({
    String? id,
    String? locationId,
    DateTime? visitedAt,
    String? note,
    List<VisitPhoto>? photos,
    String? routeId,
    bool? isSynced,
    String? syncId,
  }) {
    return VisitRecord(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      visitedAt: visitedAt ?? this.visitedAt,
      note: note ?? this.note,
      photos: photos ?? this.photos,
      routeId: routeId ?? this.routeId,
      isSynced: isSynced ?? this.isSynced,
      syncId: syncId ?? this.syncId,
    );
  }
}

class VisitPhoto {
  final String id;
  final String localPath;
  final String? remoteUrl;
  final bool synced;

  const VisitPhoto({
    required this.id,
    required this.localPath,
    this.remoteUrl,
    this.synced = false,
  });
}
