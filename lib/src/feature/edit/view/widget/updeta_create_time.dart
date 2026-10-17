import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import 'package:agro_employee_public/design_system/tokens/typography.dart';

class UpdetaCreateTime extends StatelessWidget {
  final DateTime? serverDate;
  final void Function(DateTime) setSelectedDate;
  final ValueNotifier<DateTime?> _selectedDateNotifier;

  UpdetaCreateTime({
    super.key,
    required this.serverDate,
    required this.setSelectedDate,
  }) : _selectedDateNotifier = ValueNotifier(serverDate);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final today = DateTime.now();
        final initialDate = _selectedDateNotifier.value ?? today;

        final pickedDate = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(), // Ограничиваем до сегодняшнего дня
        );

        if (pickedDate != null) {
          _selectedDateNotifier.value = pickedDate;
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
        child: ValueListenableBuilder<DateTime?>(
          valueListenable: _selectedDateNotifier,
          builder: (context, selectedDate, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? DateFormat('yyyy-MM-dd').format(selectedDate)
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
            );
          },
        ),
      ),
    );
  }
}
