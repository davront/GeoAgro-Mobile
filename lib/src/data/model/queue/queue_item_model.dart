enum QueueItemType {
  createPlantation,
  editPlantation;

  static QueueItemType fromName(String? name) => QueueItemType.values
      .firstWhere((e) => e.name == name, orElse: () => createPlantation);
}

enum QueueItemStatus {
  queued,
  uploading,
  failed,
  done;

  static QueueItemStatus fromName(String? name) => QueueItemStatus.values
      .firstWhere((e) => e.name == name, orElse: () => queued);
}

/// Одна фотография в очереди: путь уже скопирован в стабильную
/// app-owned директорию (см. `UploadQueueStore.imagesDir`), не временный
/// путь от image_picker.
class QueuedImage {
  final String localPath;
  final int? cardId;
  bool uploaded;

  QueuedImage({
    required this.localPath,
    this.cardId,
    this.uploaded = false,
  });

  factory QueuedImage.fromJson(Map<String, dynamic> json) => QueuedImage(
        localPath: json["local_path"] as String,
        cardId: json["card_id"] as int?,
        uploaded: json["uploaded"] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        "local_path": localPath,
        "card_id": cardId,
        "uploaded": uploaded,
      };
}

/// Конверт офлайн-очереди create/edit плантации. `requestBody` — уже
/// готовое тело запроса (Garden.toJson() для create, _buildPatchBody()
/// для edit), собранное и провалидированное (включая fail-closed
/// geo-проверку) в момент постановки в очередь, на месте. `userLocation`
/// хранится отдельно для create — эндпоинт создания игнорирует
/// user_location в multipart body, точка досылается отдельным PATCH
/// после успешного создания (см. detail_vm.dart sendUserLocation).
class QueueItem {
  final String id;
  final QueueItemType type;
  QueueItemStatus status;
  int? plantationId;
  final int farmerId;
  final String? displayLabel;
  final Map<String, dynamic> requestBody;
  final Map<String, double>? userLocation;
  final List<QueuedImage> images;
  final DateTime collectedAt;
  int attemptCount;
  String? lastError;
  DateTime? lastAttemptAt;

  QueueItem({
    required this.id,
    required this.type,
    this.status = QueueItemStatus.queued,
    this.plantationId,
    required this.farmerId,
    this.displayLabel,
    required this.requestBody,
    this.userLocation,
    this.images = const [],
    required this.collectedAt,
    this.attemptCount = 0,
    this.lastError,
    this.lastAttemptAt,
  });

  factory QueueItem.fromJson(Map<String, dynamic> json) => QueueItem(
        id: json["id"] as String,
        type: QueueItemType.fromName(json["type"] as String?),
        status: QueueItemStatus.fromName(json["status"] as String?),
        plantationId: json["plantation_id"] as int?,
        farmerId: json["farmer_id"] as int? ?? 0,
        displayLabel: json["display_label"] as String?,
        requestBody:
            Map<String, dynamic>.from(json["request_body"] as Map? ?? {}),
        userLocation: json["user_location"] == null
            ? null
            : Map<String, double>.from(
                (json["user_location"] as Map).map(
                  (k, v) => MapEntry(k as String, (v as num).toDouble()),
                ),
              ),
        images: (json["images"] as List<dynamic>? ?? [])
            .map((e) => QueuedImage.fromJson(e as Map<String, dynamic>))
            .toList(),
        collectedAt: DateTime.parse(json["collected_at"] as String),
        attemptCount: json["attempt_count"] as int? ?? 0,
        lastError: json["last_error"] as String?,
        lastAttemptAt: json["last_attempt_at"] == null
            ? null
            : DateTime.parse(json["last_attempt_at"] as String),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type.name,
        "status": status.name,
        "plantation_id": plantationId,
        "farmer_id": farmerId,
        "display_label": displayLabel,
        "request_body": requestBody,
        "user_location": userLocation,
        "images": images.map((e) => e.toJson()).toList(),
        "collected_at": collectedAt.toIso8601String(),
        "attempt_count": attemptCount,
        "last_error": lastError,
        "last_attempt_at": lastAttemptAt?.toIso8601String(),
      };
}
