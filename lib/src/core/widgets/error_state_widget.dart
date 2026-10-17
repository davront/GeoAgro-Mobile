import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:agro_employee_public/design_system/tokens/colors.dart'
    as design_colors;
import 'main_button.dart';

class ErrorStateWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onTap;
  const ErrorStateWidget(
      {super.key, required this.errorMessage, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: REdgeInsets.symmetric(horizontal: 16),
              child: Lottie.asset(
                'assets/lotties/error_lottie.json',
                width: 200.w,
                height: 200.h,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: REdgeInsets.symmetric(horizontal: 16),
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18.sp,
                    color: design_colors.AppColors.error,
                    fontWeight: FontWeight.w500),
              ),
            ),
            20.verticalSpace,
            Padding(
              padding: REdgeInsets.symmetric(horizontal: 60),
              child: MainButton(text: "Qayta urinib ko'ring", onTap: onTap),
            )
          ],
        ),
      ),
    );
  }
}
