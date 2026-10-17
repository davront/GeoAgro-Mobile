import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agro_employee_public/design_system/tokens/colors.dart'
    as design_colors;
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import 'package:agro_employee_public/design_system/tokens/radii.dart';
import 'package:agro_employee_public/design_system/tokens/spacing.dart';
import 'package:agro_employee_public/design_system/tokens/typography.dart';
import 'package:agro_employee_public/src/core/routes/app_route_names.dart';
import 'package:agro_employee_public/src/data/model/farmer/farmer_list_model.dart';
import 'package:agro_employee_public/src/feature/fermers/view/pages/fermers_page.dart';

class FermerPageCardWidget extends ConsumerWidget {
  final FarmerModel fermerModel;
  final VoidCallback onPressed;
  const FermerPageCardWidget(
      {super.key, required this.onPressed, required this.fermerModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      button: true,
      label: "Fermer kartasi",
      child: GestureDetector(
        onTap: () {
          debugPrint(
            'FermerPageCardWidget: Card tapped for farmer: ${fermerModel.name}',
          );
          onPressed();
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.colors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: context.colors.cardBorder,
            boxShadow: context.colors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                fermerModel.name ?? "Noma'lum fermer",
                                style: AppTypography.title(context).copyWith(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  color: context.colors.textPrimary,
                                  height: 1.25,
                                ),
                              ),
                            ),
                            SizedBox(width: AppSpacing.xs),
                            GestureDetector(
                              onTap: () {
                                _navigateToEditPage(context, ref);
                              },
                              child: Padding(
                                // Расширяет тап-зону вокруг маленькой иконки
                                // (сама иконка 22sp — ниже рекомендуемого
                                // 44dp минимума хитбокса), не увеличивая
                                // визуальный размер самой иконки.
                                padding: EdgeInsets.all(AppSpacing.sm),
                                child: Icon(
                                  Icons.edit_outlined,
                                  size: 22.sp,
                                  color: design_colors.AppColors.accentGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.xs.h),
                        if (fermerModel.inn != null) ...[
                          _InnChip(inn: fermerModel.inn.toString()),
                          SizedBox(height: AppSpacing.sm.h),
                        ],
                        Text(
                          fermerModel.address?.isNotEmpty == true
                              ? fermerModel.address!
                              : "Manzil ma'lum emas",
                          style: AppTypography.bodySmall(context).copyWith(
                            color: context.colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (fermerModel.createdBy != null) ...[
                SizedBox(height: AppSpacing.md.h),
                Divider(
                  height: 1,
                  color: context.colors.divider.withValues(alpha: 0.6),
                ),
                SizedBox(height: AppSpacing.sm.h),
                _InfoPill(
                  icon: Icons.person_outline,
                  title: "Yaratgan",
                  value:
                      "${fermerModel.createdBy!.fullName} (${fermerModel.createdBy!.username})",
                ),
                SizedBox(height: AppSpacing.md.h),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToEditPage(BuildContext context, WidgetRef ref) async {
    if (fermerModel.id == null) return;
    final result = await context.push<bool?>(
      "/${AppRouteNames.farmers}/${AppRouteNames.editFarmer}",
      extra: fermerModel.id,
    );
    if (result == true) {
      await ref.read(fermerPageVM).getFermers(isLoadMore: false);
    }
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoPill({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colors.isDark
            ? context.colors.surfaceElevated
            : context.colors.background,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: context.colors.isDark
            ? Border.all(color: context.colors.border)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: design_colors.AppColors.accentGreen,
          ),
          SizedBox(width: AppSpacing.sm.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppTypography.caption(context).copyWith(
                  color: context.colors.textTertiary,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: AppSpacing.xs / 2),
              Text(
                value,
                style: AppTypography.bodySmall(context).copyWith(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InnChip extends StatelessWidget {
  final String inn;

  const _InnChip({required this.inn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: design_colors.AppColors.accentGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: design_colors.AppColors.accentGreen.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "INN",
            style: AppTypography.caption(context).copyWith(
              color: design_colors.AppColors.accentGreen,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            inn,
            style: AppTypography.bodySmall(context).copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
