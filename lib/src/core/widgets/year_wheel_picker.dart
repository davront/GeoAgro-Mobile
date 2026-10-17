import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:agro_employee_public/design_system/tokens/colors.dart'
    as design_colors;
import 'package:agro_employee_public/design_system/tokens/typography.dart';
import 'package:agro_employee_public/design_system/tokens/radii.dart';

class YearWheelPicker extends StatelessWidget {
  final int? selectedYear;
  final ValueChanged<int> onYearSelected;
  final String label;
  final String hint;
  final int startYear;
  final int? endYear;

  const YearWheelPicker({
    super.key,
    this.selectedYear,
    required this.onYearSelected,
    this.label = "Yil",
    this.hint = "Yilni tanlang",
    this.startYear = 2000,
    this.endYear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: REdgeInsets.only(bottom: 8.h),
          child: Text(
            label,
            style: AppTypography.headlineSmall(context).copyWith(
              fontSize: 16.sp,
              color: design_colors.AppColors.darkTextPrimary,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _showYearPicker(context),
          child: Container(
            width: double.infinity,
            padding: REdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: design_colors.AppColors.darkSurfaceVariant,
              border: Border.all(color: design_colors.AppColors.darkBorder),
              borderRadius: BorderRadius.circular(AppRadii.input),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedYear != null ? selectedYear.toString() : hint,
                  style: AppTypography.bodyLarge(context).copyWith(
                    fontSize: 14.sp,
                    color: selectedYear != null
                        ? design_colors.AppColors.darkTextPrimary
                        : design_colors.AppColors.darkTextTertiary,
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  color: design_colors.AppColors.darkTextSecondary,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }

  void _showYearPicker(BuildContext context) {
    final currentYear = endYear ?? DateTime.now().year;
    final years = List.generate(
      currentYear - startYear + 1,
      (index) => startYear + index,
    );

    // Определяем начальный индекс
    int initialIndex = selectedYear != null
        ? years.indexOf(selectedYear!)
        : years.length - 1; // По умолчанию — текущий год
    if (initialIndex < 0) initialIndex = years.length - 1;

    int tempSelectedYear = selectedYear ?? currentYear;

    final scrollController = FixedExtentScrollController(
      initialItem: initialIndex,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: design_colors.AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: 300.h,
            child: Column(
              children: [
                // Заголовок с кнопками
                Padding(
                  padding: REdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          "Bekor qilish",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      Text(
                        "Yilni tanlang",
                        style: AppTypography.headlineMedium(context).copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: design_colors.AppColors.darkTextPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          onYearSelected(tempSelectedYear);
                          Navigator.pop(ctx);
                        },
                        child: Text(
                          "Tanlash",
                          style: TextStyle(
                            color: design_colors.AppColors.accentGreen,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: design_colors.AppColors.darkBorder,
                ),
                // Колёсико
                Expanded(
                  child: CupertinoPicker(
                    scrollController: scrollController,
                    itemExtent: 44.h,
                    magnification: 1.2,
                    squeeze: 1.0,
                    useMagnifier: true,
                    selectionOverlay: Container(
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          horizontal: BorderSide(
                            color: design_colors.AppColors.accentGreen
                                .withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    onSelectedItemChanged: (index) {
                      tempSelectedYear = years[index];
                    },
                    children: years
                        .map(
                          (year) => Center(
                            child: Text(
                              year.toString(),
                              style: TextStyle(
                                fontSize: 20.sp,
                                color:
                                    design_colors.AppColors.darkTextPrimary,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() => scrollController.dispose());
  }
}
