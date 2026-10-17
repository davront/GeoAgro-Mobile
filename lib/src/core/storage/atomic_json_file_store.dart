import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Общий примитив для файл-based JSON-хранилищ приложения (draft, upload
/// queue): доступ к app documents directory, атомарная запись через
/// temp-файл + rename (защита от битого файла при kill процесса
/// посреди записи), и сериализация конкурентных read-modify-write через
/// единый Future-хвост на инстанс. Конкретные хранилища (`DraftStore`,
/// `UploadQueueStore`) решают сами, что именно и в какие файлы писать —
/// этот класс не знает про их формат данных.
abstract class AtomicJsonFileStore {
  Future<void> _lockTail = Future.value();

  /// Сериализует конкурентные операции через один Future-хвост — без
  /// этого enqueue из UI и dequeue из фонового воркера могли бы
  /// перезаписать файл друг у друга.
  Future<T> locked<T>(Future<T> Function() action) {
    final result = _lockTail.then((_) => action());
    // Не даём отклонённому Future разорвать цепочку для последующих вызовов.
    _lockTail = result.then((_) => null, onError: (_) => null);
    return result;
  }

  Future<Directory> documentsDir() => getApplicationDocumentsDirectory();

  /// Атомарная запись JSON в файл: пишет во `.tmp`, затем `rename` —
  /// rename на той же ФС атомарен на Android/iOS.
  Future<void> writeAtomic(File file, Object data) async {
    final tmpFile = File('${file.path}.tmp');
    await tmpFile.writeAsString(jsonEncode(data), flush: true);
    await tmpFile.rename(file.path);
  }

  /// Читает и декодирует JSON-файл. Возвращает `null`, если файла нет,
  /// он пуст или содержимое повреждено — не роняет вызывающий код.
  Future<dynamic> readJson(File file) async {
    try {
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      if (content.trim().isEmpty) return null;
      return jsonDecode(content);
    } catch (e) {
      developer.log('AtomicJsonFileStore: failed to read ${file.path}: $e');
      return null;
    }
  }
}
