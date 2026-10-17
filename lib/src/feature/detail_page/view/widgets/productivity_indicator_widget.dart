import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:agro_employee_public/design_system/tokens/colors.dart'
    as design_colors;
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import 'package:agro_employee_public/design_system/tokens/typography.dart';

class ProductivityIndicator extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const ProductivityIndicator({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Banitet bali: ${value.toStringAsFixed(0)}",
          style: AppTypography.headlineSmall(context).copyWith(
            fontSize: 16.sp,
            color: context.colors.textPrimary,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: design_colors.AppColors.accentGreen,
                  inactiveTrackColor: context.colors.border,
                  thumbColor: design_colors.AppColors.accentGreen,
                  overlayColor:
                      design_colors.AppColors.accentGreen.withValues(alpha: 0.12),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: value,
                  min: 1,
                  max: 100,
                  divisions: 100,
                  label: value.toStringAsFixed(0),
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}
