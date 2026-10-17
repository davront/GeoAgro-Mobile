import 'dart:developer' as developer;
import 'dart:io';

import 'atomic_json_file_store.dart';

/// Персистентные черновики форм create/edit плантации. Отдельный от
/// `UploadQueueStore` жизненный цикл: черновик живёт до явного
/// сохранения/постановки в очередь, очередь — до успешной отправки на
/// сервер. Формат черновика — плоский снапшот UI-state (controllers,
/// switches, координаты), а не API request body: их нельзя однозначно
/// восстановить друг из друга (toJson() уже "схлопывает" switches в
/// конкретные значения). Atomic-write/lock механика — в
/// [AtomicJsonFileStore].
class DraftStore extends AtomicJsonFileStore {
  DraftStore._();

  static final DraftStore instance = DraftStore._();

  static const String _createDraftFileName = 'draft_create.json';

  Future<Map<String, dynamic>?> _readMap(File file) async {
    final decoded = await readJson(file);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  // ===== Create draft (единственный активный за раз) =====

  Future<File> _createDraftFile() async {
    final dir = await documentsDir();
    return File('${dir.path}/$_createDraftFileName');
  }

  Future<Map<String, dynamic>?> readCreateDraft() {
    return locked(() async => _readMap(await _createDraftFile()));
  }

  Future<void> writeCreateDraft(Map<String, dynamic> data) {
    return locked(() async {
      try {
        await writeAtomic(await _createDraftFile(), data);
      } catch (e) {
        developer.log('DraftStore.writeCreateDraft failed: $e');
      }
    });
  }

  Future<void> clearCreateDraft() {
    return locked(() async {
      try {
        final file = await _createDraftFile();
        if (await file.exists()) await file.delete();
      } catch (e) {
        developer.log('DraftStore.clearCreateDraft failed: $e');
      }
    });
  }

  // ===== Edit draft (один файл на редактируемую плантацию) =====

  Future<File> _editDraftFile(int plantationId) async {
    final dir = await documentsDir();
    return File('${dir.path}/draft_edit_$plantationId.json');
  }

  Future<Map<String, dynamic>?> readEditDraft(int plantationId) {
    return locked(() async => _readMap(await _editDraftFile(plantationId)));
  }

  Future<void> writeEditDraft(int plantationId, Map<String, dynamic> data) {
    return locked(() async {
      try {
        await writeAtomic(await _editDraftFile(plantationId), data);
      } catch (e) {
        developer.log('DraftStore.writeEditDraft failed: $e');
      }
    });
  }

  Future<void> clearEditDraft(int plantationId) {
    return locked(() async {
      try {
        final file = await _editDraftFile(plantationId);
        if (await file.exists()) await file.delete();
      } catch (e) {
        developer.log('DraftStore.clearEditDraft failed: $e');
      }
    });
  }
}
