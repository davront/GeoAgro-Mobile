import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import '../../vm/detail_vm.dart';
import 'fruit_bottom_shit_widget.dart.dart';

class FruitButton extends ConsumerWidget {
  const FruitButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var textStyle = TextStyle(
      fontSize: 16.sp,
      color: context.colors.textPrimary,
    );
    var text = Text(
      "Maydon haqida ma'lumotlar",
      style: textStyle,
    );
    return MaterialButton(
      height: 56.h,
      minWidth: MediaQuery.of(context).size.width,
      color: context.colors.surfaceVariant,
      elevation: context.colors.isDark ? 0 : 1,
      padding: REdgeInsets.symmetric(horizontal: 20.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: context.colors.isDark
            ? BorderSide(color: context.colors.border, width: 1)
            : BorderSide.none,
      ),
      onPressed: () async {
        final detailVm = ref.read(detailVM);
        // Reset switch and form values before opening
        ref.read(detailVm.switchFenced.notifier).state = false;
        detailVm.resetFields(ref);

        await detailVm.getFruit();
        if (!context.mounted) return;
        await showModalBottomSheet(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16.r),
            ),
          ),
          backgroundColor: context.colors.surface,
          context: context,
          isScrollControlled: true,
          builder: (context) {
            final detailVm = ref.read(detailVM);
            return FractionallySizedBox(
              heightFactor: 0.9,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: FruitBottomShitWidget(detailVm: detailVm),
                ),
              ),
            );
          },
        );

        // If sheet dismissed (tap outside or drag), clear values and switch
        ref.read(detailVm.switchFenced.notifier).state = false;
        detailVm.resetFields(ref);
      },
      child: text,
    );
  }
}
