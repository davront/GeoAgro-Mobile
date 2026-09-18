import 'package:flutter/material.dart';

import 'package:agro_employee_public/design_system/components/chips_and_badges.dart';

import '../../../../../localization/app_strings.dart';
import '../../../../data/model/task/task_status.dart';

class TaskStatusChip extends StatelessWidget {
  final TaskStatus status;

  const TaskStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) => AppStatusChip(
        label: status.label,
        type: _typeFor(status),
        icon: _iconFor(status),
      );
}

class TaskOverdueChip extends StatelessWidget {
  const TaskOverdueChip({super.key});

  @override
  Widget build(BuildContext context) => const AppStatusChip(
        label: AppStrings.taskOverdue,
        type: AppStatusType.error,
        icon: Icons.alarm_outlined,
      );
}

AppStatusType _typeFor(TaskStatus status) {
  switch (status) {
    case TaskStatus.newTask:
      return AppStatusType.info;
    case TaskStatus.inProgress:
      return AppStatusType.pending;
    case TaskStatus.done:
      return AppStatusType.warning;
    case TaskStatus.accepted:
      return AppStatusType.success;
    case TaskStatus.rejected:
      return AppStatusType.error;
  }
}

IconData _iconFor(TaskStatus status) {
  switch (status) {
    case TaskStatus.newTask:
      return Icons.fiber_new_outlined;
    case TaskStatus.inProgress:
      return Icons.autorenew;
    case TaskStatus.done:
      return Icons.hourglass_bottom_outlined;
    case TaskStatus.accepted:
      return Icons.check_circle_outline;
    case TaskStatus.rejected:
      return Icons.undo_outlined;
  }
}
