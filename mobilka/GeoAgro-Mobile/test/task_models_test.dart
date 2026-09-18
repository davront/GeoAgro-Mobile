import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:agro_employee_public/src/data/model/task/task_models.dart';
import 'package:agro_employee_public/src/data/model/task/task_status.dart';

const _listJson = '''
{
  "count": 42,
  "next": "http://host/api/tasks/?page=2",
  "previous": null,
  "results": [
    {
      "id": 12,
      "title": "Перепроверить плантацию",
      "status": "in_progress",
      "status_display": "В работе",
      "deadline": "2026-10-01T18:00:00+05:00",
      "is_overdue": false,
      "created_at": "2026-09-17T10:20:31+05:00",
      "assigner": { "id": 3, "username": "head_r1", "first_name": "Алишер", "last_name": "Каримов" },
      "executor": { "id": 8, "username": "agronom5", "first_name": "Бек", "last_name": "Юсупов" },
      "district": { "id": 5, "name": "Зарбдор", "region": 5, "region_name": "Jizzakh" },
      "plantation": 104
    }
  ]
}
''';

const _detailJson = '''
{
  "id": 12,
  "title": "Перепроверить плантацию",
  "status": "done",
  "status_display": "Выполнена, ожидает проверки",
  "deadline": "2026-10-01T18:00:00+05:00",
  "is_overdue": false,
  "created_at": "2026-09-17T10:20:31+05:00",
  "assigner": { "id": 3, "username": "head_r1", "first_name": "Алишер", "last_name": "Каримов" },
  "executor": { "id": 8, "username": "agronom5", "first_name": "Бек", "last_name": "Юсупов" },
  "district": { "id": 5, "name": "Зарбдор", "region": 5, "region_name": "Jizzakh" },
  "plantation": {
    "id": 104,
    "district_name": "Зарбдор",
    "moderation_status": "rejected",
    "is_rejected": true,
    "total_area": 12.5
  },
  "description": "Площадь не сходится",
  "file": "http://host/media/tasks/akt.pdf",
  "result_comment": "Площадь исправил",
  "review_comment": null,
  "started_at": "2026-09-17T11:02:00+05:00",
  "completed_at": "2026-09-18T09:14:00+05:00",
  "reviewed_at": null,
  "updated_at": "2026-09-18T09:14:00+05:00"
}
''';

void main() {
  group('TasksListResponse', () {
    test('разбирает пагинацию и элементы списка', () {
      final response = TasksListResponse.fromJson(
          jsonDecode(_listJson) as Map<String, dynamic>);

      expect(response.count, 42);
      expect(response.hasNext, isTrue);
      expect(response.results, hasLength(1));

      final task = response.results.first;
      expect(task.id, 12);
      expect(task.title, "Перепроверить плантацию");
      expect(task.status, TaskStatus.inProgress);
      expect(task.isOverdue, isFalse);
      expect(task.deadline?.toUtc(), DateTime.utc(2026, 10, 1, 13));
      expect(task.createdAt?.toUtc(), DateTime.utc(2026, 9, 17, 5, 20, 31));
      expect(task.assigner?.displayName, "Алишер Каримов");
      expect(task.executor?.id, 8);
      expect(task.district?.name, "Зарбдор");
      expect(task.plantationId, 104);
    });

    test('пустой последней страницы: hasNext false', () {
      final response = TasksListResponse.fromJson({
        "count": 0,
        "next": null,
        "previous": null,
        "results": <dynamic>[],
      });

      expect(response.results, isEmpty);
      expect(response.hasNext, isFalse);
    });
  });

  group('TaskDetail', () {
    test('разбирает карточку с объектом плантации', () {
      final task =
          TaskDetail.fromJson(jsonDecode(_detailJson) as Map<String, dynamic>);

      expect(task.status, TaskStatus.done);
      expect(task.description, "Площадь не сходится");
      expect(task.file, "http://host/media/tasks/akt.pdf");
      expect(task.resultComment, "Площадь исправил");
      expect(task.reviewComment, isNull);
      expect(task.startedAt?.toUtc(), DateTime.utc(2026, 9, 17, 6, 2));
      expect(task.completedAt?.toUtc(), DateTime.utc(2026, 9, 18, 4, 14));
      expect(task.reviewedAt, isNull);

      expect(task.plantation?.id, 104);
      expect(task.plantation?.moderationStatus, "rejected");
      expect(task.plantation?.isRejected, isTrue);
      expect(task.plantation?.totalArea, 12.5);
      expect(task.plantationId, 104);
    });

    test('карточка без плантации, файла и дедлайна', () {
      final task = TaskDetail.fromJson({
        "id": 7,
        "title": "Hisobot",
        "status": "new",
        "status_display": "Новая",
        "deadline": null,
        "is_overdue": false,
        "created_at": "2026-09-17T10:20:31+05:00",
        "assigner": null,
        "executor": null,
        "district": null,
        "plantation": null,
        "description": null,
        "file": null,
        "result_comment": null,
        "review_comment": null,
      });

      expect(task.status, TaskStatus.newTask);
      expect(task.deadline, isNull);
      expect(task.plantation, isNull);
      expect(task.plantationId, isNull);
      expect(task.hasFile, isFalse);
    });

    test('неизвестный статус деградирует в new, а не роняет разбор', () {
      final task = TaskDetail.fromJson({
        "id": 1,
        "title": "X",
        "status": "archived",
        "is_overdue": false,
      });

      expect(task.status, TaskStatus.newTask);
    });
  });

  group('TaskUserRef.displayName', () {
    test('без имени и фамилии подставляет username', () {
      final user = TaskUserRef.fromJson({
        "id": 8,
        "username": "agronom5",
        "first_name": "",
        "last_name": "",
      });

      expect(user.displayName, "agronom5");
    });
  });

  group('TaskStats', () {
    test('добирает нулями отсутствующие статусы и считает активные', () {
      final stats = TaskStats.fromJson({
        "total": 37,
        "overdue": 4,
        "by_status": {
          "new": 12,
          "in_progress": 9,
          "done": 6,
          "accepted": 8,
          "rejected": 2,
        },
      });

      expect(stats.total, 37);
      expect(stats.overdue, 4);
      expect(stats.countOf(TaskStatus.done), 6);
      expect(stats.activeCount, 12 + 9 + 2);
    });

    test('пустой by_status даёт нули по всем статусам', () {
      final stats = TaskStats.fromJson({"total": 0, "overdue": 0});

      for (final status in TaskStatus.values) {
        expect(stats.countOf(status), 0);
      }
      expect(stats.activeCount, 0);
    });
  });
}
