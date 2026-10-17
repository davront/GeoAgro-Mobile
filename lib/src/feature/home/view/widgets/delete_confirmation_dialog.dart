import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../design_system/theme/colors.dart' as design_colors;
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import '../../../../../design_system/theme/typography.dart';
import '../../../../../design_system/theme/spacing.dart';
import '../../../../../design_system/theme/radius.dart';

class DeleteConfirmationDialog extends StatefulWidget {
  final Function(String reason) onConfirm; // Changed to accept reason
  final VoidCallback onCancel;
  final bool isDeleting; // Added loading state parameter

  const DeleteConfirmationDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
    this.isDeleting = false, // Default to false
  });

  @override
  State<DeleteConfirmationDialog> createState() =>
      _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState extends State<DeleteConfirmationDialog> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reasonController.addListener(() {
      setState(() {}); // Rebuild to enable/disable button
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? context.colors.surface : Colors.white;
    final textColor = context.colors.textPrimary;
    final hintColor = context.colors.textSecondary;
    final borderColor = context.colors.border;
    final focusedBorderColor = isDark
        ? design_colors.AppColors.primary
        : design_colors.AppColors.accentGreen;
    final inputFillColor =
        isDark ? context.colors.surfaceVariant : Colors.white;

    return AlertDialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      title: Text(
        "O'chirishni tasdiqlash",
        style: AppTypography.headlineSmall(context).copyWith(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bog'ni o'chirishni tasdiqlaysizmi?",
              style: AppTypography.bodyLarge(context).copyWith(
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              "O'chirish sababi:",
              style: AppTypography.bodyMedium(context).copyWith(
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              style: AppTypography.bodyMedium(context).copyWith(
                color: textColor,
              ),
              decoration: InputDecoration(
                hintText: "Sababni kiriting...",
                hintStyle: AppTypography.bodyMedium(context).copyWith(
                  color: hintColor,
                ),
                filled: true,
                fillColor: inputFillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  borderSide: BorderSide(color: focusedBorderColor, width: 2),
                ),
                contentPadding: EdgeInsets.all(AppSpacing.md),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: widget.isDeleting ? null : widget.onCancel,
                style: FilledButton.styleFrom(
                  backgroundColor: design_colors.AppColors.error,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
                child: Text(
                  "Yo'q",
                  style: AppTypography.labelLarge(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton(
                onPressed:
                    widget.isDeleting || _reasonController.text.trim().isEmpty
                        ? null
                        : () => widget.onConfirm(_reasonController.text.trim()),
                style: FilledButton.styleFrom(
                  backgroundColor: design_colors.AppColors.accentGreen,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
                child: widget.isDeleting
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        "Ha",
                        style: AppTypography.labelLarge(context).copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
      actionsPadding: REdgeInsets.all(16),
    );
  }
}
