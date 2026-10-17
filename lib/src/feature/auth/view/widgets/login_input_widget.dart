import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import 'package:agro_employee_public/design_system/tokens/colors.dart'
    as design_colors;

class LoginInputWidget extends StatelessWidget {
  final String hintText;
  final String validatorText;
  final TextEditingController textEditingController;
  const LoginInputWidget(
      {super.key,
      required this.hintText,
      required this.textEditingController,
      required this.validatorText});

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
      validator: (value) {
        if (value!.isNotEmpty) {
          return null;
        } else {
          return validatorText;
        }
      },
      style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500),
      cursorColor: context.colors.textPrimary,
      decoration: InputDecoration(
        contentPadding: REdgeInsets.only(top: 8, bottom: 8, left: 16),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.colors.border),
          borderRadius: BorderRadius.circular(8.r),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.colors.textSecondary),
          borderRadius: BorderRadius.circular(8.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.colors.textSecondary),
          borderRadius: BorderRadius.circular(8.r),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: design_colors.AppColors.error),
          borderRadius: BorderRadius.circular(8.r),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: context.colors.textSecondary),
          borderRadius: BorderRadius.circular(8.r),
        ),
        hintText: hintText,
        hintStyle:
            TextStyle(color: context.colors.textTertiary, fontSize: 16.sp),
      ),
    );
  }
}
