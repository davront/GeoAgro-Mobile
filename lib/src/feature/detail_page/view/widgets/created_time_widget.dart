import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import 'package:agro_employee_public/design_system/tokens/typography.dart';

class CreatedTime extends StatelessWidget {
  final DateTime? selectedDate;
  final void Function(DateTime) setSelectedDate;

  const CreatedTime({
    super.key,
    required this.selectedDate,
    required this.setSelectedDate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final today = DateTime.now();
        final initialDate = selectedDate ?? today;
        final lastDate = today; // Ограничиваем до сегодняшнего дня
        final adjustedInitialDate =
            initialDate.isAfter(lastDate) ? lastDate : initialDate;
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: adjustedInitialDate,
          firstDate: DateTime(1900),
          lastDate: lastDate,
        );
        if (pickedDate != null) {
          setSelectedDate(pickedDate);
        }
      },
      child: Container(
        padding: REdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.colors.surfaceVariant,
          border: context.colors.isDark
              ? Border.all(color: context.colors.border)
              : Border.all(color: context.colors.border.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate != null
                  ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                  : "vaqtni kiriting...",
              style: AppTypography.bodyLarge(context).copyWith(
                fontSize: 16.sp,
                color: selectedDate != null
                    ? context.colors.textPrimary
                    : context.colors.textSecondary,
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: context.colors.textSecondary,
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }
}
