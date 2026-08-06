import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import '../../../design_system/tokens/typography.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? subMessage;
  final VoidCallback? onRefresh;

  const EmptyStateWidget({
    super.key,
    this.message = "Ma'lumot topilmadi",
    this.subMessage,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/svg/last_transaction.svg',
              width: 200.w,
              height: 200.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body(context).copyWith(
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 18.sp,
              ),
            ),
            if (subMessage != null) ...[
              SizedBox(height: 8.h),
              Text(
                subMessage!,
                textAlign: TextAlign.center,
                style: AppTypography.caption(context).copyWith(
                  color: context.colors.textTertiary,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
