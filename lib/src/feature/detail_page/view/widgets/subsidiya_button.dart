import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';

class SubsidiyaButton<T> extends StatelessWidget {
  final T viewModel;
  final Widget? widget;

  const SubsidiyaButton({super.key, this.widget, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(
      fontSize: 16.sp,
      color: context.colors.textPrimary,
    );
    var text = Text("Subsidiya qo`shish va to`ldirish", style: textStyle);
    return Column(
      children: [
        SizedBox(height: 10.h),
        MaterialButton(
          height: 56.h,
          minWidth: MediaQuery.of(context).size.width,
          color: context.colors.surfaceVariant,
          elevation: context.colors.isDark ? 0 : 1,
          padding: REdgeInsets.symmetric(horizontal: 20.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
            side: context.colors.isDark
                ? BorderSide(color: context.colors.border, width: 1)
                : BorderSide.none,
          ),
          onPressed: () {
            showModalBottomSheet(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16.r),
                ),
              ),
              backgroundColor: context.colors.surface,
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return FractionallySizedBox(
                  heightFactor: 0.9,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: widget,
                    ),
                  ),
                );
              },
            );
          },
          child: text,
        ),
      ],
    );
  }
}
