import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';

class LoginTitleTextWidget extends StatelessWidget {
  const LoginTitleTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary),
          children: const [
            TextSpan(
              text: "Qishloq xo'jaligi vazirligi huzuridagi\n",
            ),
            TextSpan(
              text: "Agrosanoatni\n",
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
            TextSpan(
              text: "rivojlantirish agentligi",
            ),
          ],
        ),
      ),
    );
  }
}
