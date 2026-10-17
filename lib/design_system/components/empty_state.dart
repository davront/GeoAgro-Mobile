import 'package:flutter/material.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import 'buttons.dart';

/// Design System Empty State Component
/// 
/// Display when no data is available
/// - Icon/illustration
/// - Title
/// - Description
/// - Call-to-action button

class AppEmptyState extends StatelessWidget {
  final Widget? icon;
  final IconData? iconData;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double? maxWidth;

  const AppEmptyState({
    super.key,
    this.icon,
    this.iconData,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.maxWidth = 400,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? 400),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon or illustration
              if (icon != null)
                icon!
              else if (iconData != null)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    size: 64,
                    color: isDark
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.lightOnSurfaceVariant,
                  ),
                ),

              const SizedBox(height: AppSpacing.xxl),

              // Title
              Text(
                title,
                style: AppTypography.headlineLarge(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              if (description != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  description!,
                  style: AppTypography.bodyLarge(context),
                  textAlign: TextAlign.center,
                ),
              ],

              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  text: actionLabel!,
                  onPressed: onAction,
                  icon: Icons.add,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Specialized empty states

class AppEmptyListState extends StatelessWidget {
  final String? title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyListState({
    super.key,
    this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      iconData: Icons.inbox_outlined,
      title: title ?? "Ro'yxat bo'sh",
      description: description ?? "Bu yerda hech narsa yo'q",
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

class AppEmptySearchState extends StatelessWidget {
  final String? query;
  final VoidCallback? onClear;

  const AppEmptySearchState({
    super.key,
    this.query,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      iconData: Icons.search_off_outlined,
      title: "Hech narsa topilmadi",
      description: query != null
          ? "\"$query\" bo'yicha natija topilmadi"
          : "Qidiruv natijalari mavjud emas",
      actionLabel: onClear != null ? "Tozalash" : null,
      onAction: onClear,
    );
  }
}

class AppNoDataState extends StatelessWidget {
  final String? message;
  final VoidCallback? onRefresh;

  const AppNoDataState({
    super.key,
    this.message,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      iconData: Icons.data_usage_outlined,
      title: "Ma'lumot yo'q",
      description: message ?? "Hozircha ma'lumotlar mavjud emas",
      actionLabel: onRefresh != null ? "Yangilash" : null,
      onAction: onRefresh,
    );
  }
}

