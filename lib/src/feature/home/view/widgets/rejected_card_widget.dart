import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';

import 'package:agro_employee_public/design_system/tokens/colors.dart'
    as design_colors;
import '../../../../core/widgets/custom_card_widget.dart';
import '../../../../core/widgets/custom_driver.dart';
import '../../../../core/widgets/custom_list_tile_widget.dart';
import '../../../../data/model/plantation/plantations_list_model.dart';
import '../../../../core/setting/setup.dart';

class RejectedCardWidget extends StatelessWidget {
  final Result plantation;
  final VoidCallback onEdit;

  const RejectedCardWidget(
      {super.key, required this.plantation, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final canEdit =
        (plantation.createdById != null && plantation.createdById == userId) ||
            (plantation.createdByUsername != null &&
                username != null &&
                plantation.createdByUsername == username);
    return CustomCardWidget(
      horizontal: 16,
      vertical: 16,
      variant: CardVariant.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomListTileWidget(
              title: "Fermer",
              contextText: plantation.farmerName ?? "Noma'lum"),
          10.verticalSpace,
          const CustomDriver(),
          10.verticalSpace,
          CustomListTileWidget(
              title: "Yer maydoni", contextText: "${plantation.totalArea} ga"),
          10.verticalSpace,
          const CustomDriver(),
          10.verticalSpace,
          CustomListTileWidget(
              title: "ID", contextText: "${plantation.id ?? 'N/A'}"),
          10.verticalSpace,
          const CustomDriver(),
          10.verticalSpace,
          if ((plantation.moderationComments?.isNotEmpty ?? false)) ...[
            const CustomDriver(),
            10.verticalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tafsilot",
                  style: TextStyle(
                      fontSize: 16.sp,
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w600),
                ),
                10.verticalSpace,
                ...plantation.moderationComments!.map((comment) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "• ",
                          style: TextStyle(
                              fontSize: 15.sp,
                              color: context.colors.textSecondary,
                              fontWeight: FontWeight.w500),
                        ),
                        Expanded(
                          child: Text(
                            comment.text ?? '',
                            style: TextStyle(
                                fontSize: 15.sp,
                                color: context.colors.textSecondary,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ],
          16.verticalSpace,
          if (canEdit)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: design_colors.AppColors.accentGreen,
                  minimumSize: Size(double.infinity, 44.h),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                ),
                onPressed: onEdit,
                child: Text("Tahrirlash",
                    style: TextStyle(color: Colors.white, fontSize: 16.sp)),
              ),
            ),
        ],
      ),
    );
  }
}
