import 'dart:developer' as developer;
import 'dart:io';

import 'atomic_json_file_store.dart';

/// Персистентное хранилище очереди офлайн-загрузок плантаций.
///
/// Один JSON-файл (`upload_queue.json`) в app documents directory —
/// объём ожидается единицы-десятки записей на юзера, полноценная БД
/// избыточна. Atomic-write/lock механика — в [AtomicJsonFileStore].
class UploadQueueStore extends AtomicJsonFileStore {
  UploadQueueStore._();

  static final UploadQueueStore instance = UploadQueueStore._();

  static const String _queueFileName = 'upload_queue.json';
  static const String _imagesDirName = 'queued_images';

  Future<File> _queueFile() async {
    final dir = await documentsDir();
    return File('${dir.path}/$_queueFileName');
  }

  /// Директория для постоянных копий выбранных фото. Создаётся при первом
  /// обращении.
  Future<Directory> imagesDir() async {
    final dir = await documentsDir();
    final imagesDir = Directory('${dir.path}/$_imagesDirName');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir;
  }

  /// Копирует выбранное фото в стабильную app-owned директорию —
  /// временный путь от image_picker (особенно с камеры на некоторых
  /// Android-устройствах) не гарантированно переживает paused/kill, пока
  /// юзер ходит по плантации фотографировать. При ошибке копирования
  /// возвращает исходный путь как fallback — лучше рискованный путь, чем
  /// вообще потерять фото.
  Future<String> copyToStableDir(String sourcePath,
      {String prefix = ''}) async {
    try {
      final dir = await imagesDir();
      final ext = sourcePath.contains('.') ? sourcePath.split('.').last : 'jpg';
      final destPath =
          '${dir.path}/$prefix${DateTime.now().microsecondsSinceEpoch}.$ext';
      await File(sourcePath).copy(destPath);
      return destPath;
    } catch (e) {
      developer.log('UploadQueueStore.copyToStableDir failed: $e');
      return sourcePath;
    }
  }

  /// Читает все записи очереди. Возвращает `[]`, если файла нет или он
  /// повреждён (не роняет вызывающий код на битом JSON).
  Future<List<Map<String, dynamic>>> readAll() {
    return locked(() async {
      final decoded = await readJson(await _queueFile());
      if (decoded is! List) return <Map<String, dynamic>>[];
      return decoded.whereType<Map<String, dynamic>>().toList();
    });
  }

  /// Перезаписывает весь файл очереди атомарно.
  Future<void> writeAll(List<Map<String, dynamic>> items) {
    return locked(() async {
      try {
        await writeAtomic(await _queueFile(), items);
      } catch (e) {
        developer.log('UploadQueueStore.writeAll failed: $e');
      }
    });
  }
}
