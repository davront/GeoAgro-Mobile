import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:agro_employee_public/design_system/components/cards.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import 'package:agro_employee_public/design_system/tokens/colors.dart'
    as design_colors;

import '../../../../core/utils/date_utils.dart' as app_date;
import '../../../../data/model/task/task_models.dart';
import 'task_status_chip.dart';

class TaskCardWidget extends StatelessWidget {
  final TaskListItem task;
  final VoidCallback onTap;

  const TaskCardWidget({super.key, required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final deadline = task.deadline;
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              8.horizontalSpace,
              TaskStatusChip(status: task.status),
            ],
          ),
          if (deadline != null) ...[
            8.verticalSpace,
            _MetaRow(
              icon: Icons.schedule_outlined,
              text: app_date.DateUtils.formatDateTime(deadline.toLocal()),
              color: task.isOverdue
                  ? design_colors.AppColors.error
                  : context.colors.textSecondary,
              bold: task.isOverdue,
            ),
          ],
          8.verticalSpace,
          Wrap(
            spacing: 12.w,
            runSpacing: 6.h,
            children: [
              if (task.assigner != null)
                _MetaRow(
                  icon: Icons.person_outline,
                  text: task.assigner!.displayName,
                  color: context.colors.textTertiary,
                ),
              if (task.district != null)
                _MetaRow(
                  icon: Icons.place_outlined,
                  text: task.district!.name,
                  color: context.colors.textTertiary,
                ),
              if (task.hasPlantation)
                _MetaRow(
                  icon: Icons.forest_outlined,
                  text: "№ ${task.plantationId}",
                  color: context.colors.textTertiary,
                ),
            ],
          ),
          if (task.isOverdue) ...[
            8.verticalSpace,
            const TaskOverdueChip(),
          ],
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool bold;

  const _MetaRow({
    required this.icon,
    required this.text,
    required this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: color),
        4.horizontalSpace,
        Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            color: color,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
