import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agro_employee_public/design_system/tokens/colors.dart' as design_colors;
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import 'package:agro_employee_public/design_system/tokens/typography.dart';

class GenericDropWidget<T> extends StatelessWidget {
  final String labelText;
  final List<T> items;
  final T? selectedItem;
  final bool isLoading;
  final Function(T?) onChanged;
  final String Function(T) itemLabel;

  const GenericDropWidget({
    super.key,
    required this.labelText,
    required this.items,
    required this.selectedItem,
    required this.isLoading,
    required this.onChanged,
    required this.itemLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          labelText,
          style: AppTypography.bodyLarge(context).copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: context.colors.textPrimary,
          ),
        ),
        Container(
          height: 50.h,
          width: MediaQuery.of(context).size.width * 0.3,
          padding: REdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: context.colors.surfaceVariant,
            borderRadius: BorderRadius.circular(8.r),
            border: context.colors.isDark
                ? Border.all(color: context.colors.border)
                : Border.all(color: context.colors.border.withValues(alpha: 0.5)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  isExpanded: true,
                  value: selectedItem,
                  dropdownColor: context.colors.surface,
                  style: AppTypography.bodyLarge(context).copyWith(
                    fontSize: 14.sp,
                    color: context.colors.textPrimary,
                  ),
                  hint: Text(
                    "Tanlang:",
                    style: AppTypography.bodyMedium(context).copyWith(
                      color: context.colors.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: context.colors.textPrimary,
                  ),
                  items: items.map((T item) {
                    return DropdownMenuItem<T>(
                      value: item,
                      child: Text(
                        itemLabel(item),
                        style: AppTypography.bodyLarge(context).copyWith(
                          fontSize: 14.sp,
                          color: context.colors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
              if (isLoading)
                SizedBox(
                  height: 10.h,
                  width: 10.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: design_colors.AppColors.accentGreen,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
