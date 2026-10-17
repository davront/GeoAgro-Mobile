import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agro_employee_public/design_system/tokens/colors.dart' as design_colors;
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import 'package:agro_employee_public/design_system/tokens/typography.dart';

class CustomSwitchCard extends StatelessWidget {
  final String label;
  final bool switchValue;
  final Function(bool) onChanged;
  final List<Widget> childWidgets;

  const CustomSwitchCard({
    super.key,
    required this.label,
    required this.switchValue,
    required this.onChanged,
    this.childWidgets = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: context.colors.surfaceVariant,
            border: context.colors.cardBorder,
            boxShadow: context.colors.cardShadow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyLarge(context).copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              Switch(
                value: switchValue,
                onChanged: onChanged,
                activeThumbColor: design_colors.AppColors.accentGreen,
                activeTrackColor:
                    design_colors.AppColors.accentGreen.withValues(alpha: 0.5),
                inactiveThumbColor: context.colors.textSecondary,
                inactiveTrackColor: context.colors.surfaceVariant,
              ),
            ],
          ),
        ),
        if (switchValue) ...childWidgets,
      ],
    );
  }
}
