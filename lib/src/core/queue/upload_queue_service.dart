import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../data/model/queue/queue_item_model.dart';
import '../../data/model/response/api_response.dart';
import '../../data/repository/app_repository_impl.dart';
import '../storage/upload_queue_store.dart';
import '../utils/network_utils.dart';

/// App-scoped очередь офлайн-загрузок create/edit плантации. Хранит
/// задачи на диске (переживает kill процесса), слушает восстановление
/// сети и отправляет задачи по одной по порядку постановки.
///
/// GPS/antifraud-проверка НЕ повторяется здесь — `QueueItem.userLocation`
/// и `requestBody` уже содержат снапшот, собранный на месте в момент
/// enqueue (см. detail_vm.dart/edit_vm.dart). Эта очередь только
/// переигрывает уже готовый payload, когда появляется сеть.
class UploadQueueService extends ChangeNotifier {
  UploadQueueService({
    required Connectivity connectivity,
    required AppRepositoryImpl repo,
  })  : _connectivity = connectivity,
        _repo = repo;

  final Connectivity _connectivity;
  final AppRepositoryImpl _repo;
  final _uuid = const Uuid();

  List<QueueItem> _items = [];
  List<QueueItem> get items => List.unmodifiable(_items);

  int get pendingCount => _items
      .where((i) =>
          i.status == QueueItemStatus.queued ||
          i.status == QueueItemStatus.uploading ||
          i.status == QueueItemStatus.failed)
      .length;

  StreamSubscription<List<ConnectivityResult>>? _connSub;
  bool _isProcessing = false;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    final raw = await UploadQueueStore.instance.readAll();
    _items = raw
        .map((e) {
          try {
            return QueueItem.fromJson(e);
          } catch (err) {
            developer
                .log('UploadQueueService: dropping corrupt queue item: $err');
            return null;
          }
        })
        .whereType<QueueItem>()
        .toList();
    notifyListeners();

    _connSub = _connectivity.onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online) unawaited(processQueue());
    });

    // На случай если сеть уже есть при старте приложения — попробовать
    // сразу, не дожидаясь события смены состояния.
    if (await NetworkUtils.hasInternetConnection()) {
      unawaited(processQueue());
    }
  }

  Future<void> _persistAndNotify() async {
    await UploadQueueStore.instance
        .writeAll(_items.map((e) => e.toJson()).toList());
    notifyListeners();
  }

  Future<QueueItem> enqueueCreate({
    required int farmerId,
    String? displayLabel,
    required Map<String, dynamic> requestBody,
    Map<String, double>? userLocation,
    required List<String> imagePaths,
    DateTime? collectedAt,
  }) async {
    final images = await _copyImagesToStableDir(imagePaths);
    final item = QueueItem(
      id: _uuid.v4(),
      type: QueueItemType.createPlantation,
      farmerId: farmerId,
      displayLabel: displayLabel,
      requestBody: requestBody,
      userLocation: userLocation,
      images: images,
      collectedAt: collectedAt ?? DateTime.now(),
    );
    _items.add(item);
    await _persistAndNotify();
    unawaited(processQueue());
    return item;
  }

  Future<QueueItem> enqueueEdit({
    required int plantationId,
    required int farmerId,
    String? displayLabel,
    required Map<String, dynamic> requestBody,
    Map<String, double>? userLocation,
    List<String> newImagePaths = const [],
    DateTime? collectedAt,
  }) async {
    final images = await _copyImagesToStableDir(newImagePaths);
    final item = QueueItem(
      id: _uuid.v4(),
      type: QueueItemType.editPlantation,
      plantationId: plantationId,
      farmerId: farmerId,
      displayLabel: displayLabel,
      requestBody: requestBody,
      userLocation: userLocation,
      images: images,
      collectedAt: collectedAt ?? DateTime.now(),
    );
    _items.add(item);
    await _persistAndNotify();
    unawaited(processQueue());
    return item;
  }

  /// Отдельная лёгкая запись только для одного фото Edit-flow, снятого
  /// офлайн (EditVM.pickImage сейчас аплоадит немедленно; офлайн — кладёт
  /// в очередь одну фотографию, не дожидаясь общего "Сохранить").
  Future<QueueItem> enqueuePhotoOnly({
    required int plantationId,
    required int farmerId,
    String? displayLabel,
    required String imagePath,
    int? cardId,
  }) async {
    final images = await _copyImagesToStableDir([imagePath], cardId: cardId);
    final item = QueueItem(
      id: _uuid.v4(),
      type: QueueItemType.editPlantation,
      plantationId: plantationId,
      farmerId: farmerId,
      displayLabel: displayLabel,
      requestBody: const {},
      images: images,
      collectedAt: DateTime.now(),
    );
    _items.add(item);
    await _persistAndNotify();
    unawaited(processQueue());
    return item;
  }

  Future<List<QueuedImage>> _copyImagesToStableDir(
    List<String> paths, {
    int? cardId,
  }) async {
    if (paths.isEmpty) return const [];
    final result = <QueuedImage>[];
    for (final path in paths) {
      // copyToStableDir возвращает исходный путь как fallback при ошибке
      // копирования — здесь это бесполезно (тот путь мог уже исчезнуть к
      // моменту фактической отправки), поэтому такой элемент просто
      // пропускаем вместо того чтобы класть заведомо волатильный путь в
      // очередь.
      final destPath = await UploadQueueStore.instance
          .copyToStableDir(path, prefix: '${result.length}_');
      if (destPath == path) {
        developer.log('UploadQueueService: skipping image $path — copy failed');
        continue;
      }
      result.add(QueuedImage(localPath: destPath, cardId: cardId));
    }
    return result;
  }

  bool _isSuccess(ApiResponse response) =>
      response.statusCode == 200 || response.statusCode == 201;

  Future<void> processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;
    try {
      final pending = _items
          .where((i) =>
              i.status == QueueItemStatus.queued ||
              i.status == QueueItemStatus.uploading)
          .toList();
      for (final item in pending) {
        await _sendOne(item);
      }
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> retryNow(String itemId) async {
    final item = _items.where((i) => i.id == itemId).firstOrNull;
    if (item == null) return;
    if (item.status == QueueItemStatus.done) return;
    item.status = QueueItemStatus.queued;
    await _persistAndNotify();
    unawaited(processQueue());
  }

  Future<void> deleteItem(String itemId) async {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index == -1) return;
    final item = _items.removeAt(index);
    await _deleteImages(item);
    await _persistAndNotify();
  }

  Future<void> _sendOne(QueueItem item) async {
    // "uploading" — только in-memory статус для UI, не пишем на диск:
    // если процесс убьют ровно в этот момент, лучше чтобы запись осталась
    // "queued" (будет ретраена при следующем processQueue), чем застряла
    // в "uploading" навсегда без единого реального запроса в полёте.
    item.status = QueueItemStatus.uploading;
    item.attemptCount++;
    item.lastAttemptAt = DateTime.now();
    notifyListeners();

    try {
      if (item.type == QueueItemType.createPlantation) {
        await _sendCreate(item);
      } else {
        await _sendEdit(item);
      }
    } catch (e) {
      _markFailed(item, e.toString());
    }
    await _persistAndNotify();
  }

  Future<void> _sendCreate(QueueItem item) async {
    final response = await _repo.postCreatePlantationWithImages(
      body: item.requestBody,
      image: item.images.map((i) => i.localPath).toList(),
    );
    if (!_isSuccess(response)) {
      _markFailed(item, _extractError(response));
      return;
    }
    item.status = QueueItemStatus.done;
    item.lastError = null;

    final createdId = _extractCreatedId(response);
    if (createdId != null) {
      item.plantationId = createdId;
    }
    final loc = item.userLocation;
    if (createdId != null && loc != null) {
      unawaited(_repo.sendUserLocation(
        plantationId: createdId,
        latitude: loc['latitude']!,
        longitude: loc['longitude']!,
      ));
    }
    await _deleteImages(item);
  }

  Future<void> _sendEdit(QueueItem item) async {
    // requestBody может быть пустым для photo-only записей (см.
    // enqueuePhotoOnly) — тогда PATCH пропускается, грузятся только фото.
    if (item.requestBody.isNotEmpty) {
      final response = await _repo.editPlantation(
        id: item.plantationId!,
        body: item.requestBody,
      );
      if (!_isSuccess(response)) {
        _markFailed(item, _extractError(response));
        return;
      }
    }

    var allUploaded = true;
    for (final img in item.images.where((i) => !i.uploaded)) {
      final resp = await _repo.postPlantationImage(
        id: item.plantationId!,
        filePath: img.localPath,
      );
      if (_isSuccess(resp)) {
        img.uploaded = true;
      } else {
        allUploaded = false;
      }
    }

    if (allUploaded) {
      item.status = QueueItemStatus.done;
      item.lastError = null;
      await _deleteImages(item);
    } else {
      _markFailed(item, 'Ba\'zi rasmlarni yuklab bo\'lmadi');
    }
  }

  void _markFailed(QueueItem item, String? error) {
    item.status = QueueItemStatus.failed;
    item.lastError = error;
  }

  String? _extractError(ApiResponse response) {
    final data = response.data;
    if (data is Map) {
      return (data['message'] ?? data['detail'] ?? data.toString()).toString();
    }
    return data?.toString();
  }

  int? _extractCreatedId(ApiResponse response) {
    final data = response.data;
    if (data is Map) {
      final id = data['id'];
      if (id is int) return id;
    }
    return null;
  }

  Future<void> _deleteImages(QueueItem item) async {
    for (final img in item.images) {
      try {
        final file = File(img.localPath);
        if (await file.exists()) await file.delete();
      } catch (e) {
        developer.log('UploadQueueService: failed to delete image: $e');
      }
    }
  }

  @override
  void dispose() {
    _connSub?.cancel();
    super.dispose();
  }
}
