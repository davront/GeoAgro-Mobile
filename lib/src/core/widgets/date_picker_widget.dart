import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CustomDatePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final void Function(DateTime) onDateSelected;
  final String? label;
  final String? hintText;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;
  final bool isRequired;
  final String? errorText;

  const CustomDatePicker({
    super.key,
    this.selectedDate,
    required this.onDateSelected,
    this.label,
    this.hintText,
    this.firstDate,
    this.lastDate,
    this.initialDate,
    this.isRequired = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
        ],
        GestureDetector(
          onTap: () => _showDatePicker(context),
          child: Container(
            padding: REdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: errorText != null 
                    ? Colors.red 
                    : const Color(0x1E1E1E16),
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                        : hintText ?? "Санани танланг...",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: selectedDate != null 
                          ? Colors.black87 
                          : Colors.grey[600],
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today, 
                  color: Colors.grey, 
                  size: 24.sp,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: 4.h),
          Text(
            errorText!,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final today = DateTime.now();
    final initial = initialDate ?? selectedDate ?? today;
    final first = firstDate ?? DateTime(1900);
    final last = lastDate ?? today; // По умолчанию ограничиваем до сегодняшнего дня
    
    final adjustedInitial = initial.isAfter(last) ? last : initial;
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: adjustedInitial,
      firstDate: first,
      lastDate: last,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.green,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      onDateSelected(pickedDate);
    }
  }
}

// Виджет для выбора года
class YearPickerWidget extends StatelessWidget {
  final int? selectedYear;
  final void Function(int) onYearSelected;
  final String? label;
  final int? minYear;
  final int? maxYear;

  const YearPickerWidget({
    super.key,
    this.selectedYear,
    required this.onYearSelected,
    this.label,
    this.minYear,
    this.maxYear,
  });

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final min = minYear ?? currentYear - 50;
    final max = maxYear ?? currentYear + 10;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
        ],
        GestureDetector(
          onTap: () => _showYearPicker(context, min, max),
          child: Container(
            padding: REdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0x1E1E1E16)),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedYear?.toString() ?? "Йилни танланг...",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: selectedYear != null 
                        ? Colors.black87 
                        : Colors.grey[600],
                  ),
                ),
                Icon(
                  Icons.calendar_today, 
                  color: Colors.grey, 
                  size: 24.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showYearPicker(BuildContext context, int min, int max) async {
    final years = List.generate(max - min + 1, (index) => min + index);
    
    final selectedYear = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Йилни танланг'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300.h,
          child: ListView.builder(
            itemCount: years.length,
            itemBuilder: (context, index) {
              final year = years[index];
              return ListTile(
                title: Text(year.toString()),
                selected: year == this.selectedYear,
                onTap: () => Navigator.of(context).pop(year),
              );
            },
          ),
        ),
      ),
    );
    
    if (selectedYear != null) {
      onYearSelected(selectedYear);
    }
  }
} 