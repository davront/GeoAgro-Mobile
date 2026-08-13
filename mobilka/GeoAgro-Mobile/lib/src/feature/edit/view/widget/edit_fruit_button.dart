import 'package:agro_employee_public/src/feature/edit/view/widget/edit_fruit_bottom_shit.dart';
import 'package:agro_employee_public/src/feature/edit/vm/edit_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';

class EditFruitButton extends ConsumerStatefulWidget {
  const EditFruitButton({super.key});

  @override
  ConsumerState<EditFruitButton> createState() => _EditFruitButtonState();
}

class _EditFruitButtonState extends ConsumerState<EditFruitButton> {
  bool _isOpening = false;

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(
      fontSize: 16.sp,
      color: context.colors.textPrimary,
    );
    var text = _isOpening
        ? SizedBox(
            height: 20.h,
            width: 20.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: context.colors.textPrimary,
            ),
          )
        : Text(
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
      // Мева ро'йхати юкланаётганда (секин интернетда сезиларли вақт)
      // тугма ҳеч нарса кўрсатмасди — create formadagi FruitButton bilan
      // bir xil muammo (fruit_button.dart).
      onPressed: _isOpening
          ? null
          : () async {
              final vm = ref.read(editVm);
              // Reset switch and form values before opening
              ref.read(switchFenced.notifier).state = false;
              vm.resetFields(ref);

              setState(() => _isOpening = true);
              await vm.getFruit();
              if (!mounted) return;
              setState(() => _isOpening = false);
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
                  return FractionallySizedBox(
                    heightFactor: 0.9,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: EditFruitBottomShit(viewModelm: vm),
                      ),
                    ),
                  );
                },
              );

              // If sheet dismissed (tap outside or drag), clear values and switch
              ref.read(switchFenced.notifier).state = false;
              vm.resetFields(ref);
            },
      child: text,
    );
  }
}
