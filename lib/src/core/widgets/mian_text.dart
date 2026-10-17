import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:agro_employee_public/design_system/theme/typography.dart';

class MainText extends StatelessWidget {
  final String text;

  const MainText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: AppTypography.headlineSmall(context).copyWith(
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}
