import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:agro_employee_public/design_system/components/buttons.dart';
import 'package:agro_employee_public/design_system/components/inputs.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';

import '../../../../../localization/app_strings.dart';
import '../../../../data/model/task/task_status.dart';

/// Спрашивает комментарий к действию исполнителя.
/// Возвращает текст, либо `null` если пользователь закрыл лист.
Future<String?> showTaskCommentSheet(
  BuildContext context, {
  required TaskAction action,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (context) => _TaskCommentSheet(action: action),
  );
}

class _TaskCommentSheet extends StatefulWidget {
  final TaskAction action;

  const _TaskCommentSheet({required this.action});

  @override
  State<_TaskCommentSheet> createState() => _TaskCommentSheetState();
}

class _TaskCommentSheetState extends State<_TaskCommentSheet> {
  final _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (widget.action.commentRequired && text.isEmpty) {
      setState(() => _errorText = AppStrings.taskCommentEmptyError);
      return;
    }
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.action.label,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
          16.verticalSpace,
          AppTextArea(
            controller: _controller,
            label: widget.action.commentRequired
                ? AppStrings.taskCommentRequired
                : AppStrings.taskComment,
            hint: AppStrings.taskCommentHint,
            errorText: _errorText,
            onChanged: (_) {
              if (_errorText != null) setState(() => _errorText = null);
            },
          ),
          20.verticalSpace,
          AppButton(
            text: AppStrings.taskCommentSend,
            isFullWidth: true,
            onPressed: _submit,
          ),
          8.verticalSpace,
          Center(
            child: AppButtonText(
              text: AppStrings.buttonCancel,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
