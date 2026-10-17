import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';

class CustomInputLabelWidget extends StatelessWidget {
  final String text;
  const CustomInputLabelWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(text,
            style: TextStyle(
                fontSize: 16.sp,
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w500))
      ],
    );
  }
}
