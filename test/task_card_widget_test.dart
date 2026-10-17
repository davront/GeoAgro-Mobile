import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agro_employee_public/localization/app_strings.dart';
import 'package:agro_employee_public/src/data/model/task/task_models.dart';
import 'package:agro_employee_public/src/data/model/task/task_status.dart';
import 'package:agro_employee_public/src/feature/tasks/view/widgets/task_card_widget.dart';

TaskListItem _task({
  TaskStatus status = TaskStatus.newTask,
  bool isOverdue = false,
  DateTime? deadline,
  int? plantationId,
}) {
  return TaskListItem(
    id: 12,
    title: "Plantatsiyani qayta tekshirish",
    status: status,
    isOverdue: isOverdue,
    deadline: deadline,
    assigner: const TaskUserRef(
      id: 3,
      username: "head_r1",
      firstName: "Alisher",
      lastName: "Karimov",
    ),
    district: const TaskDistrictRef(id: 5, name: "Zarbdor"),
    plantationId: plantationId,
  );
}

Future<void> _pump(WidgetTester tester, TaskListItem task,
    {VoidCallback? onTap}) {
  return tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      child: MaterialApp(
        home: Scaffold(
          body: TaskCardWidget(task: task, onTap: onTap ?? () {}),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('показывает заголовок, статус, автора и район', (tester) async {
    await _pump(tester, _task());

    expect(find.text("Plantatsiyani qayta tekshirish"), findsOneWidget);
    expect(find.text(AppStrings.taskStatusNew), findsOneWidget);
    expect(find.text("Alisher Karimov"), findsOneWidget);
    expect(find.text("Zarbdor"), findsOneWidget);
  });

  testWidgets('дедлайн выводится в локальном формате', (tester) async {
    await _pump(
      tester,
      _task(deadline: DateTime(2026, 10, 1, 18)),
    );

    expect(find.text("01.10.2026 18:00"), findsOneWidget);
  });

  testWidgets('просроченная задача помечается отдельным чипом', (tester) async {
    await _pump(tester, _task(isOverdue: true));

    expect(find.text(AppStrings.taskOverdue), findsOneWidget);
  });

  testWidgets('без просрочки чипа «Muddati o\'tgan» нет', (tester) async {
    await _pump(tester, _task());

    expect(find.text(AppStrings.taskOverdue), findsNothing);
  });

  testWidgets('номер плантации показывается только когда она привязана',
      (tester) async {
    await _pump(tester, _task(plantationId: 104));
    expect(find.text("№ 104"), findsOneWidget);

    await _pump(tester, _task());
    expect(find.textContaining("№"), findsNothing);
  });

  testWidgets('нажатие по карточке вызывает onTap', (tester) async {
    var taps = 0;
    await _pump(tester, _task(), onTap: () => taps++);

    await tester.tap(find.byType(TaskCardWidget));
    await tester.pumpAndSettle();

    expect(taps, 1);
  });
}
