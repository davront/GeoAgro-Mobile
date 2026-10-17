import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import '../../../design_system/tokens/typography.dart';

/// Modern list tile widget with dark theme
class CustomListTileWidget extends StatelessWidget {
  final String title;
  final String contextText;
  
  const CustomListTileWidget({
    super.key,
    required this.title,
    required this.contextText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            title,
            style: AppTypography.body(context).copyWith(
              fontSize: 15.sp,
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          flex: 6,
          child: Text(
            contextText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body(context).copyWith(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 15.sp,
              height: 1.4,
            ),
            textAlign: TextAlign.left,
          ),
        )
      ],
    );
  }
}
