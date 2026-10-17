import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:agro_employee_public/design_system/tokens/colors.dart' as design_colors;
import 'package:agro_employee_public/design_system/tokens/radii.dart';
import 'package:agro_employee_public/design_system/tokens/spacing.dart';
import 'package:agro_employee_public/design_system/tokens/typography.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';

class FermerCreatePageInputWidget extends StatelessWidget {
  final String hintText;
  final TextEditingController textEditingController;
  final TextInputType textInputType;
  final int? maxLength;
  const FermerCreatePageInputWidget({
    super.key,
    required this.hintText,
    required this.textEditingController,
    this.textInputType = TextInputType.text,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textEditingController,
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      onEditingComplete: () {
        log(textEditingController.text);
        FocusScope.of(context).nextFocus();
      },
      style: AppTypography.body(context).copyWith(
        color: context.colors.textPrimary,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: design_colors.AppColors.accentGreen,
      keyboardType: textInputType,
      maxLength: maxLength,
      decoration: InputDecoration(
        filled: true,
        fillColor: context.colors.surfaceVariant,
        counterText: '',
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: context.colors.isDark
                ? context.colors.border
                : context.colors.border.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(AppRadii.input),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: context.colors.isDark
                ? context.colors.border
                : context.colors.border.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(AppRadii.input),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: design_colors.AppColors.accentGreen,
            width: 1.8,
          ),
          borderRadius: BorderRadius.circular(AppRadii.input),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: context.colors.border),
          borderRadius: BorderRadius.circular(AppRadii.input),
        ),
        hintText: hintText,
        hintStyle: AppTypography.bodySmall(context).copyWith(
          color: context.colors.textTertiary,
          fontSize: 14.sp,
        ),
      ),
    );
  }
}
