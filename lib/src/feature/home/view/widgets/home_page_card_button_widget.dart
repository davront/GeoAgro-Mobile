import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/style/app_colors.dart';

class HomePageCardButton extends StatelessWidget {
  final Icon icon;
  final String string;
  final Color bgColor;
  final VoidCallback ontap;
  const HomePageCardButton({super.key, required this.icon, required this.string, required this.bgColor, required this.ontap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      child: ElevatedButton.icon(
        onPressed: ontap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        label: Text(
          string,
          style: TextStyle(color: AppColors.white, fontSize: 16.sp, fontWeight: FontWeight.w500, letterSpacing: 0.4),
        ),
        icon: icon,
      ),
    );
  }
}
