import '../../../../data/model/plantation/new_plantation_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import '../../../../../design_system/tokens/typography.dart';

class AddFruitArea extends StatelessWidget {
  final List<FruitArea> selectedDetails;
  final List<FruitArea>? selectedDetails2;

  final void Function(int) removeDetailAt;

  const AddFruitArea({
    super.key,
    required this.selectedDetails,
    required this.removeDetailAt,
    this.selectedDetails2,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10.h),
        selectedDetails.isEmpty
            ? const SizedBox.shrink()
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    selectedDetails.length,
                    (index) {
                  final detail = selectedDetails[index];
                  final detail2 = selectedDetails2?[index];
                  return Container(
                    margin: EdgeInsets.only(right: 12.w),
                    constraints: BoxConstraints(
                      maxWidth: 280.w,
                      minWidth: 200.w,
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: context.colors.surfaceVariant,
                            borderRadius: BorderRadius.circular(16.r),
                            border: context.colors.cardBorder,
                            boxShadow: context.colors.cardShadow,
                          ),
                          padding: EdgeInsets.all(12.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8.h),
                              _buildRow(
                                context,
                                "Meva turi:",
                                detail2?.fruitName ?? detail2?.fruit?.toString() ?? "",
                              ),
                              SizedBox(height: 6.h),
                              _buildRow(
                                context,
                                "Meva navi:",
                                detail2?.varietyName ?? detail2?.variety?.toString() ?? "",
                              ),
                              if (detail.iqtisodiysamarasiz == true) ...[
                                SizedBox(height: 6.h),
                                _buildRow(
                                  context,
                                  "Iqtisodiy samarasiz maydon:",
                                  detail.economicInefficientArea?.toString() ?? "0.0",
                                ),
                              ] else ...[
                                SizedBox(height: 6.h),
                                _buildRow(
                                  context,
                                  "Payvand turi:",
                                  detail2?.rootstockName ?? detail2?.rootstock?.toString() ?? "",
                                ),
                                SizedBox(height: 6.h),
                                _buildRow(
                                  context,
                                  "Ekinlagan yil:",
                                  detail.plantedYear ?? "",
                                ),
                                SizedBox(height: 6.h),
                                _buildRow(
                                  context,
                                  "Maydon:",
                                  detail.area.toString(),
                                ),
                                SizedBox(height: 6.h),
                                _buildRow(
                                  context,
                                  "Ko'chat sxemasi:",
                                  detail.schema ?? "",
                                ),
                                SizedBox(height: 6.h),
                                _buildRow(
                                  context,
                                  "Meva maydoni ximoya to`siq bilan o`ralganmi:",
                                  detail.fenced == true ? 'Ha' : 'Yoq',
                                ),
                                SizedBox(height: 6.h),
                                _buildRow(
                                  context,
                                  "Kutilayotgan hosil miqdori: T",
                                  detail.weight == null
                                      ? '—'
                                      : detail.weight.toString(),
                                ),
                              ],
                              SizedBox(height: 8.h),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 4.w,
                          top: 4.h,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => removeDetailAt(index),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 16.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                    },
                  ),
                ),
              ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildRow(BuildContext context, String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 2,
          child: Text(
            label,
            style: AppTypography.bodyMedium(context).copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: context.colors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8.w),
        Flexible(
          flex: 3,
          child: Text(
            value != null && value.isNotEmpty ? value : "Noma'lum",
            textAlign: TextAlign.end,
            style: AppTypography.bodyMedium(context).copyWith(
              fontSize: 12.sp,
              color: context.colors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
