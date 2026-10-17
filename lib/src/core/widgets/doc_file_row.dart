import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import '../../../design_system/tokens/colors.dart' as design_colors;
import '../../../design_system/tokens/typography.dart';

/// Строка "выбрать PDF" + статус уже выбранного/загруженного файла, для
/// deal_file/resolution_file. В edit-форме fileUrl — ссылка с сервера
/// (файл грузится сразу при выборе). В create-форме fileUrl приходит как
/// локальный путь до сабмита (файл ещё не отправлен, только выбран).
class DocFileRow extends StatelessWidget {
  final String label;
  final String? fileUrl;
  final bool isUploading;
  final VoidCallback onTap;

  const DocFileRow({
    super.key,
    required this.label,
    required this.fileUrl,
    required this.isUploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              fileUrl != null ? "$label — tanlangan" : label,
              style: AppTypography.bodyMedium(context).copyWith(
                color: fileUrl != null
                    ? design_colors.AppColors.success
                    : context.colors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          if (isUploading)
            SizedBox(
              height: 20.h,
              width: 20.h,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          else
            TextButton(
              onPressed: onTap,
              child: Text(fileUrl != null ? "Almashtirish" : "Yuklash"),
            ),
        ],
      ),
    );
  }
}
