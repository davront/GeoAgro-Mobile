import 'package:flutter_test/flutter_test.dart';

import 'package:agro_employee_public/src/data/model/task/task_status.dart';

void main() {
  group('TaskStatus.fromApi', () {
    test('распознаёт все пять значений бэкенда', () {
      expect(TaskStatus.fromApi('new'), TaskStatus.newTask);
      expect(TaskStatus.fromApi('in_progress'), TaskStatus.inProgress);
      expect(TaskStatus.fromApi('done'), TaskStatus.done);
      expect(TaskStatus.fromApi('accepted'), TaskStatus.accepted);
      expect(TaskStatus.fromApi('rejected'), TaskStatus.rejected);
    });

    test('неизвестное или пустое значение даёт null', () {
      expect(TaskStatus.fromApi('archived'), isNull);
      expect(TaskStatus.fromApi(''), isNull);
      expect(TaskStatus.fromApi(null), isNull);
    });

    test('у каждого статуса непустая узбекская подпись', () {
      for (final status in TaskStatus.values) {
        expect(status.label, isNotEmpty);
      }
    });
  });

  group('executorActionsFor', () {
    test('new — можно взять в работу или сразу сдать', () {
      expect(
        executorActionsFor(TaskStatus.newTask),
        [TaskAction.start, TaskAction.submit],
      );
    });

    test('in_progress — только сдать', () {
      expect(executorActionsFor(TaskStatus.inProgress), [TaskAction.submit]);
    });

    test('rejected — вернуть в работу или сдать заново', () {
      expect(
        executorActionsFor(TaskStatus.rejected),
        [TaskAction.resume, TaskAction.submit],
      );
    });

    test('done и accepted — исполнителю делать нечего', () {
      expect(executorActionsFor(TaskStatus.done), isEmpty);
      expect(executorActionsFor(TaskStatus.accepted), isEmpty);
    });
  });

  group('TaskAction', () {
    test('сдача требует комментария, остальные действия — нет', () {
      expect(TaskAction.submit.commentRequired, isTrue);
      expect(TaskAction.start.commentRequired, isFalse);
      expect(TaskAction.resume.commentRequired, isFalse);
    });

    test('start и resume ведут в in_progress, submit — в done', () {
      expect(TaskAction.start.target, TaskStatus.inProgress);
      expect(TaskAction.resume.target, TaskStatus.inProgress);
      expect(TaskAction.submit.target, TaskStatus.done);
    });

    test('у каждого действия своя непустая подпись', () {
      final labels = TaskAction.values.map((a) => a.label).toSet();
      expect(labels.length, TaskAction.values.length);
      for (final action in TaskAction.values) {
        expect(action.label, isNotEmpty);
      }
    });
  });
}
