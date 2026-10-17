import 'package:agro_employee_public/src/feature/edit/vm/edit_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../localization/app_strings.dart';
import '../../../../core/utils/thousands_separator_input_formatter.dart';
import '../../../../core/widgets/year_wheel_picker.dart';
import '../../../detail_page/view/widgets/detail_dropdown_widget.dart';
import '../../../detail_page/view/widgets/detail_text_fild_widget.dart';
import '../../../detail_page/view/widgets/switch_card_widget.dart';
import 'package:agro_employee_public/design_system/tokens/colors.dart'
    as design_colors;
import 'package:agro_employee_public/design_system/tokens/spacing.dart';
import 'package:agro_employee_public/design_system/tokens/typography.dart';
import 'package:agro_employee_public/design_system/tokens/radii.dart';

class EditSubsidyBottomShit extends ConsumerWidget {
  final EditVM viewModel;

  const EditSubsidyBottomShit({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(editVm);
    final isEfficiency = ref.watch(switchEfficiency);
    final textStyle = AppTypography.headlineMedium(context).copyWith(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: design_colors.AppColors.darkTextPrimary,
    );

    // Получаем текущий год из контроллера для year wheel picker
    final yearText = vm.subsidiyaYear.text.trim();
    final currentSelectedYear = int.tryParse(yearText);

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
        color: design_colors.AppColors.darkSurface,
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
            selectedYear: currentSelectedYear,
            onYearSelected: (year) {
              vm.setSubsidiya(year.toString());
            },
          ),
          CustomTextFieldWithLabel(
            controller: vm.subsidiyaContract,
            onTextChanged: vm.setSubsidiyaContract,
            hintText: "subsidiya shartnoma raqami kiriting",
            label: "Subsidiya shartnoma raqami",
          ),
          CustomTextFieldWithLabel(
            controller: vm.subsidiyaAmount,
            onTextChanged: vm.setSubsidiyaAmount,
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
            selectedValue: vm.selectedEnergy,
            label: "Subsidiya ajratilgan yo`nalish",
            onChanged: (value) {
              vm.setEnergy(value);
            },
          ),
          SizedBox(height: AppSpacing.lg.h),
          CustomSwitchCard(
            label: "Subsidiya samaradormi",
            switchValue: isEfficiency,
            onChanged: (value) {
              ref.read(switchEfficiency.notifier).state = value;
            },
          ),
          SizedBox(height: AppSpacing.lg.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () {
                    vm.resetSubsudy();
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
                    final errorMessage = _validate(vm);
                    if (errorMessage != null) {
                      _showError(context, errorMessage);
                      return;
                    }
                    vm.addSubsidiyaList(ref);
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

  String? _validate(EditVM vm) {
    if (vm.subsidiyaYear.text.trim().isEmpty) {
      return "Subsidiya ajratilgan yilni kiriting";
    }
    if (vm.subsidiyaContract.text.trim().isEmpty) {
      return "Subsidiya shartnoma raqamini kiriting";
    }
    // Проверка дубликата номера договора
    final contractNum = vm.subsidiyaContract.text.trim();
    final hasDuplicate = vm.selectedEditSubsidy.any(
      (s) => s.contractNumber == contractNum,
    );
    if (hasDuplicate) {
      return "Bu shartnoma raqami allaqachon qo'shilgan. Shartnoma raqami bir xil bo'lishi mumkin emas";
    }
    if (vm.subsidiyaAmount.text.trim().isEmpty) {
      return "Ajratilgan subsidiya miqdorini kiriting";
    }
    if (vm.selectedEnergy == null) {
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
