import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import '../../../design_system/tokens/colors.dart' as design_colors;
import '../../../design_system/tokens/radii.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';

/// Modern text field with dark theme
class CustomTextField extends StatelessWidget {
  final String? label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool isRequired;
  final String? errorText;
  final bool enabled;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final VoidCallback? onTap;
  final bool readOnly;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final ValueChanged<String>? onSubmitted;

  const CustomTextField({
    super.key,
    this.label,
    required this.controller,
    this.onChanged,
    this.hintText,
    this.keyboardType,
    this.isRequired = false,
    this.errorText,
    this.enabled = true,
    this.maxLength,
    this.inputFormatters,
    this.textInputAction,
    this.onTap,
    this.readOnly = false,
    this.suffixIcon,
    this.prefixIcon,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: AppTypography.body(context).copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                  letterSpacing: 0.2,
                ),
              ),
              if (isRequired) ...[
                SizedBox(width: 4.w),
                Text(
                  '*',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: design_colors.AppColors.error,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: AppSpacing.xs),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType ?? TextInputType.text,
          enabled: enabled,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          textInputAction: textInputAction,
          onTap: onTap,
          readOnly: readOnly,
          onSubmitted: onSubmitted,
          style: AppTypography.body(context).copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: enabled
                ? context.colors.textPrimary
                : context.colors.textSecondary,
          ),
          cursorColor: design_colors.AppColors.accentGreen,
          decoration: InputDecoration(
            fillColor: enabled
                ? context.colors.surface
                : context.colors.surfaceVariant,
            filled: true,
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 16.sp,
              color: context.colors.textTertiary,
              fontWeight: FontWeight.w400,
            ),
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: errorText != null
                    ? design_colors.AppColors.error
                    : context.colors.isDark
                        ? context.colors.border
                        : context.colors.border.withValues(alpha: 0.5),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(AppRadii.input),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: errorText != null
                    ? design_colors.AppColors.error
                    : design_colors.AppColors.accentGreen,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(AppRadii.input),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: context.colors.isDark
                    ? context.colors.border
                    : context.colors.border.withValues(alpha: 0.3),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(AppRadii.input),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: design_colors.AppColors.error,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(AppRadii.input),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: design_colors.AppColors.error,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(AppRadii.input),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            counterText: '',
          ),
          onChanged: onChanged,
        ),
        if (errorText != null) ...[
          SizedBox(height: 4.h),
          Text(
            errorText!,
            style: TextStyle(
              fontSize: 12.sp,
              color: design_colors.AppColors.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

/// Qaror raqami uchun maydon (Decision Number Field)
class DecisionNumberField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool isRequired;

  const DecisionNumberField({
    super.key,
    required this.controller,
    this.onChanged,
    this.errorText,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: "Qaror raqamini kiriting",
      controller: controller,
      onChanged: onChanged,
      hintText: "Qaror raqami kiritilmagan",
      keyboardType: TextInputType.text,
      isRequired: isRequired,
      errorText: errorText,
      maxLength: 50,
      suffixIcon: Icon(
        Icons.description,
        color: context.colors.textSecondary,
        size: 20.sp,
      ),
    );
  }
}

/// Shartnoma raqami uchun maydon (Contract Number Field)
class ContractNumberField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool isRequired;

  const ContractNumberField({
    super.key,
    required this.controller,
    this.onChanged,
    this.errorText,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: "Shartnoma raqamini kiriting",
      controller: controller,
      onChanged: onChanged,
      hintText: "Shartnoma raqami kiritilmagan",
      keyboardType: TextInputType.text,
      isRequired: isRequired,
      errorText: errorText,
      maxLength: 50,
      suffixIcon: Icon(
        Icons.assignment,
        color: context.colors.textSecondary,
        size: 20.sp,
      ),
    );
  }
}

/// Raqamlar uchun maydon (Number Field)
class NumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final String? errorText;
  final bool isRequired;
  final bool allowDecimal;
  final String? suffix;

  const NumberField({
    super.key,
    required this.label,
    required this.controller,
    this.onChanged,
    this.hintText,
    this.errorText,
    this.isRequired = false,
    this.allowDecimal = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label,
      controller: controller,
      onChanged: onChanged,
      hintText: hintText,
      keyboardType: allowDecimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      isRequired: isRequired,
      errorText: errorText,
      inputFormatters: [
        if (!allowDecimal) FilteringTextInputFormatter.digitsOnly,
      ],
      suffixIcon: suffix != null
          ? Padding(
              padding: EdgeInsets.only(right: AppSpacing.md),
              child: Center(
                widthFactor: 1.0,
                child: Text(
                  suffix!,
                  style: TextStyle(
                    fontSize: 16.sp,
                  color: context.colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
