import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:agro_employee_public/design_system/tokens/colors.dart'
    as design_colors;
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import 'package:agro_employee_public/design_system/tokens/spacing.dart';
import 'package:agro_employee_public/design_system/tokens/typography.dart';
import 'package:agro_employee_public/design_system/tokens/radii.dart';

class DropdownWithLabel extends StatelessWidget {
  final String? label;
  final String? hint;
  final Map<int, String> items;
  final int? selectedValue;
  final void Function(int?) onChanged;
  final bool hasError;

  const DropdownWithLabel({
    super.key,
    this.label,
    this.hint,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          SizedBox(height: 16.h),
          Text(
            label!,
            style: AppTypography.headlineSmall(context).copyWith(
              fontSize: 16.sp,
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: 10.h),
        ],
        DropdownButtonFormField<int>(
          initialValue: selectedValue,
          style: AppTypography.input(context).copyWith(
            fontSize: 14.sp,
            color: context.colors.textPrimary,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 24.sp,
            color: context.colors.textSecondary,
          ),
          decoration: InputDecoration(
            hintText: hint ?? "Turni tanlang",
            filled: true,
            fillColor: context.colors.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.inputPaddingHorizontal,
              vertical: AppSpacing.inputPaddingVertical,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.input),
              borderSide: BorderSide(
                color: hasError
                    ? design_colors.AppColors.error
                    : context.colors.isDark
                        ? context.colors.border
                        : context.colors.border.withValues(alpha: 0.5),
                width: hasError ? 1.6 : 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.input),
              borderSide: BorderSide(
                color: hasError
                    ? design_colors.AppColors.error
                    : design_colors.AppColors.accentGreen,
                width: 1.6,
              ),
            ),
          ),
          dropdownColor: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadii.input),
          onChanged: onChanged,
          items: items.entries
              .map(
                (entry) => DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    style: AppTypography.bodyLarge(context).copyWith(
                      fontSize: 14.sp,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        SizedBox(height: AppSpacing.formFieldGap.h),
      ],
    );
  }
}
