import 'package:flutter_test/flutter_test.dart';

import 'package:agro_employee_public/src/data/model/queue/queue_item_model.dart';

void main() {
  test('старая запись очереди без named_files/comment читается', () {
    final item = QueueItem.fromJson({
      'id': 'a',
      'type': 'createPlantation',
      'farmer_id': 1,
      'request_body': {'district': '8'},
      'collected_at': '2026-10-17T10:00:00.000',
    });
    expect(item.namedFiles, isEmpty);
    expect(item.comment, isNull);
  });

  test('named_files и comment переживают сохранение на диск', () {
    final item = QueueItem(
      id: 'b',
      type: QueueItemType.createPlantation,
      farmerId: 1,
      requestBody: const {},
      namedFiles: const {'deal_file': '/q/deal_file_1.pdf'},
      comment: 'izoh',
      collectedAt: DateTime(2026, 10, 17),
    );
    final restored = QueueItem.fromJson(item.toJson());
    expect(restored.namedFiles, {'deal_file': '/q/deal_file_1.pdf'});
    expect(restored.comment, 'izoh');
  });
}
