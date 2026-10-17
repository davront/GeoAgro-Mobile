import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../data/model/farmer/farmer_plantation_model.dart';
import '../../../../../design_system/theme/colors.dart' as design_colors;
import '../../../../../design_system/theme/spacing.dart';
import '../../../../../design_system/theme/radius.dart';
import '../../../../../design_system/theme/typography.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';

class FarmerPlantationCard extends StatelessWidget {
  final FarmerPlantation plantation;
  final VoidCallback? onTap;

  const FarmerPlantationCard({
    super.key,
    required this.plantation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: "Plantatsiya kartasi",
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: plantation.isChecked
                  ? design_colors.AppColors.primary
                  : (plantation.isRejected == true
                      ? design_colors.AppColors.error
                      : (!plantation.isChecked && plantation.isRejected != true
                          ? design_colors.AppColors.warning
                          : design_colors.AppColors.darkOutline)),
              width: (plantation.isChecked ||
                      plantation.isRejected == true ||
                      (!plantation.isChecked && plantation.isRejected != true))
                  ? 2
                  : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with ID and status
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.tag,
                          size: 20.sp,
                          color: design_colors.AppColors.primary,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            "ID: ${plantation.id}",
                            style:
                                AppTypography.headlineLarge(context).copyWith(
                              fontWeight: FontWeight.w700,
                              color: design_colors.AppColors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Показываем статус в зависимости от isChecked и isRejected
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: plantation.isChecked
                          ? design_colors.AppColors.success
                          : (plantation.isRejected == true
                              ? design_colors.AppColors.error
                              : design_colors.AppColors.warning),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.colors.border,
                        width: 1,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSpacing.md),

              // Stats row
              Row(
                children: [
                  // Fertility score
                  Expanded(
                    child: _buildStatItem(
                      context: context,
                      icon: Icons.eco,
                      label: "Unumdorlik",
                      value:
                          "${(plantation.fertilityScore ?? 0.0).toStringAsFixed(1)}%",
                      color: design_colors.AppColors.primary,
                    ),
                  ),

                  SizedBox(width: AppSpacing.md),

                  // Total area
                  Expanded(
                    child: _buildStatItem(
                      context: context,
                      icon: Icons.landscape,
                      label: "Maydon",
                      value: "${plantation.totalArea.toStringAsFixed(1)} ga",
                      color: design_colors.AppColors.info,
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSpacing.md),

              // Additional info row
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                children: [
                  // Coordinates count
                  if (plantation.coordinates.isNotEmpty)
                    _buildInfoChip(
                      context: context,
                      icon: Icons.location_on,
                      label: "${plantation.coordinates.length} ta koordinata",
                      color: design_colors.AppColors.darkOnSurfaceVariant,
                    ),

                  // District
                  if (plantation.districtName != null)
                    _buildInfoChip(
                      context: context,
                      icon: Icons.map,
                      label: plantation.districtName!,
                      color: design_colors.AppColors.darkOnSurfaceVariant,
                    ),

                  // Year established
                  if (plantation.gardenEstablishedYear != null)
                    _buildInfoChip(
                      context: context,
                      icon: Icons.calendar_today,
                      label: "Yil: ${plantation.gardenEstablishedYear}",
                      color: design_colors.AppColors.darkOnSurfaceVariant,
                    ),

                  // Is fertile
                  if (plantation.isFertile == true)
                    _buildInfoChip(
                      context: context,
                      icon: Icons.agriculture,
                      label: "Unumdor",
                      color: design_colors.AppColors.primary,
                    ),
                ],
              ),

              // Created by
              if (plantation.createdBy != null)
                Padding(
                  padding: EdgeInsets.only(top: AppSpacing.xs),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 14.sp,
                        color: design_colors.AppColors.darkOnSurfaceVariant,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          "Yaratgan: ${plantation.createdBy!.fullName} (${plantation.createdBy!.username})",
                          style: AppTypography.labelSmall(context).copyWith(
                            color: design_colors.AppColors.darkOnSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Created date
              if (plantation.createdAt != null)
                Padding(
                  padding: EdgeInsets.only(top: AppSpacing.xs),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14.sp,
                        color: design_colors.AppColors.darkOnSurfaceVariant,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          "Yaratilgan: ${_formatDate(plantation.createdAt!)}",
                          style: AppTypography.labelSmall(context).copyWith(
                            color: design_colors.AppColors.darkOnSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),

              // Moderated at
              if (plantation.moderatedAt != null)
                Padding(
                  padding: EdgeInsets.only(top: AppSpacing.xs),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified,
                        size: 14.sp,
                        color: design_colors.AppColors.primary,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          "Tasdiqlangan: ${_formatDate(plantation.moderatedAt!)}",
                          style: AppTypography.labelSmall(context).copyWith(
                            color: design_colors.AppColors.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),

              // Status info
              Padding(
                padding: EdgeInsets.only(top: AppSpacing.xs),
                child: Row(
                  children: [
                    Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: plantation.isChecked
                            ? design_colors.AppColors.success
                            : (plantation.isRejected == true
                                ? design_colors.AppColors.error
                                : design_colors.AppColors.warning),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.colors.border,
                          width: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('dd.MM.yyyy HH:mm');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildInfoChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14.sp,
          color: color,
        ),
        SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            label,
            style: AppTypography.labelSmall(context).copyWith(
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24.sp,
            color: color,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.bodyLarge(context).copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            label,
            style: AppTypography.labelSmall(context).copyWith(
              color: design_colors.AppColors.darkOnSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
