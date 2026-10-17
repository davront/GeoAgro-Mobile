import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../localization/app_strings.dart';
import '../../../../core/utils/thousands_separator_input_formatter.dart';
import '../../../../core/widgets/year_wheel_picker.dart';
import 'package:agro_employee_public/design_system/tokens/colors.dart'
    as design_colors;
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import 'package:agro_employee_public/design_system/tokens/spacing.dart';
import 'package:agro_employee_public/design_system/tokens/typography.dart';
import 'package:agro_employee_public/design_system/tokens/radii.dart';

import '../../vm/detail_vm.dart';
import 'detail_dropdown_widget.dart';
import 'detail_text_fild_widget.dart';
import 'switch_card_widget.dart';

class AddSubsidiyaBottomShit extends ConsumerWidget {
  final DetailVM detailVm;

  const AddSubsidiyaBottomShit({super.key, required this.detailVm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailVm = ref.watch(detailVM);
    final isEfficiency = ref.watch(detailVm.switchEfficiency);
    final textStyle = AppTypography.headlineMedium(context).copyWith(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: context.colors.textPrimary,
    );

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: (MediaQuery.of(context).padding.bottom > 0
                ? MediaQuery.of(context).padding.bottom
                : AppSpacing.lg) +
            AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadii.modal),
          topRight: Radius.circular(AppRadii.modal),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
          Text("Subsidiya qo`shish va to`ldirish", style: textStyle),
          SizedBox(height: AppSpacing.lg.h),
          // Год — выбор колёсиком
          YearWheelPicker(
            label: "Subsidiya ajratilgan yil",
            hint: "Yilni tanlang",
            selectedYear: detailVm.selectedDate3?.year,
            onYearSelected: (year) {
              detailVm.setSelectedDate3(DateTime(year));
            },
          ),
          CustomTextFieldWithLabel(
            controller: detailVm.subsidiyaContract,
            onTextChanged: detailVm.setSubsidiyaConract,
            hintText: "subsidiya shartnoma raqami kiriting",
            label: "Subsidiya shartnoma raqami",
          ),
          CustomTextFieldWithLabel(
            controller: detailVm.subsidiyaAmount,
            onTextChanged: detailVm.setSubsidiyaAmount,
            hintText: "ajratilgan subsidiya miqdori",
            keyboardType: TextInputType.number,
            label: "Ajratilgan subsidiya miqdori",
            suffixText: "so'm",
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              ThousandsSeparatorInputFormatter(),
            ],
          ),
          DropdownWithLabel(
            items: AppLocalizedMaps.subsidyTypes,
            hint: "subsidiya ajratilgan yo`nalish kiriting",
            selectedValue: detailVm.selectedSubsidyType,
            label: "Subsidiya ajratilgan yo`nalish",
            onChanged: (value) {
              detailVm.setSubsidyType(value);
            },
          ),
          SizedBox(height: AppSpacing.lg.h),
          CustomSwitchCard(
            label: "Subsidiya samaradormi",
            switchValue: isEfficiency,
            onChanged: (value) {
              ref.read(detailVm.switchEfficiency.notifier).state = value;
            },
          ),
          SizedBox(height: AppSpacing.lg.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () {
                    detailVm.resetSubsudy();
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    backgroundColor: Colors.red.withValues(alpha: 0.15),
                    foregroundColor: Colors.red,
                  ),
                  child: Text(
                    "Bekor qilish",
                    style: AppTypography.labelLarge(context).copyWith(
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    final errorMessage = _validate(detailVm);
                    if (errorMessage != null) {
                      _showError(context, errorMessage);
                      return;
                    }
                    detailVm.addSubsidiyaList(ref);
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    backgroundColor: design_colors.AppColors.accentGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    "Qo'shish",
                    style: AppTypography.labelLarge(context).copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  String? _validate(DetailVM vm) {
    if (vm.selectedDate3 == null) {
      return "Subsidiya ajratilgan yilni kiriting";
    }
    if (vm.subsidiyaContract.text.trim().isEmpty) {
      return "Subsidiya shartnoma raqamini kiriting";
    }
    // Проверка дубликата номера договора
    final contractNum = vm.subsidiyaContract.text.trim();
    final hasDuplicate = vm.selectedSubsidy.any(
      (s) => s.contractNumber == contractNum,
    );
    if (hasDuplicate) {
      return "Bu shartnoma raqami allaqachon qo'shilgan. Shartnoma raqami bir xil bo'lishi mumkin emas";
    }
    if (vm.subsidiyaAmount.text.trim().isEmpty) {
      return "Ajratilgan subsidiya miqdorini kiriting";
    }
    if (vm.selectedSubsidyType == null) {
      return "Subsidiya turini tanlang";
    }
    return null;
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: design_colors.AppColors.darkSurfaceVariant,
        title: Text(
          "Xatolik",
          style: AppTypography.headlineMedium(context).copyWith(
            color: design_colors.AppColors.darkTextPrimary,
          ),
        ),
        content: Text(
          message,
          style: AppTypography.bodyMedium(context).copyWith(
            color: design_colors.AppColors.darkTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
