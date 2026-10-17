import 'package:flutter/material.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/radius.dart';
import '../theme/typography.dart';

/// Design System Chips and Badges
///
/// Small UI elements for status, filters, and tags:
/// - AppChip - Filter/choice chip
/// - AppBadge - Notification badge
/// - AppStatusChip - Status indicator (success, warning, error)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CHIP
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool selected;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? labelColor;

  const AppChip({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.onDelete,
    this.selected = false,
    this.backgroundColor,
    this.selectedColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    if (onTap != null) {
      // Filter chip (selectable)
      return FilterChip(
        label: Text(label),
        avatar: icon != null ? Icon(icon, size: 18) : null,
        selected: selected,
        onSelected: (_) => onTap?.call(),
        backgroundColor: backgroundColor ?? context.colors.surfaceVariant,
        selectedColor: selectedColor ?? AppColors.primaryContainer,
        labelStyle: AppTypography.labelMedium(context).copyWith(
          color: labelColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      );
    }

    if (onDelete != null) {
      // Input chip (deletable)
      return InputChip(
        label: Text(label),
        avatar: icon != null ? Icon(icon, size: 18) : null,
        onDeleted: onDelete,
        backgroundColor: backgroundColor ?? context.colors.surfaceVariant,
        labelStyle: AppTypography.labelMedium(context).copyWith(
          color: labelColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      );
    }

    // Simple chip (display only)
    return Chip(
      label: Text(label),
      avatar: icon != null ? Icon(icon, size: 18) : null,
      backgroundColor: backgroundColor ?? context.colors.surfaceVariant,
      labelStyle: AppTypography.labelMedium(context).copyWith(
        color: labelColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BADGE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppBadge extends StatelessWidget {
  final Widget child;
  final String? label;
  final int? count;
  final bool showBadge;
  final Color? backgroundColor;
  final Color? textColor;
  final double? size;
  final Alignment alignment;

  const AppBadge({
    super.key,
    required this.child,
    this.label,
    this.count,
    this.showBadge = true,
    this.backgroundColor,
    this.textColor,
    this.size,
    this.alignment = Alignment.topRight,
  });

  @override
  Widget build(BuildContext context) {
    if (!showBadge || (label == null && count == null && count != 0)) {
      return child;
    }

    return Badge(
      label: label != null
          ? Text(label!)
          : (count != null && count! > 0)
              ? Text(count! > 99 ? '99+' : count.toString())
              : null,
      isLabelVisible:
          showBadge && (label != null || (count != null && count! > 0)),
      backgroundColor: backgroundColor ?? AppColors.error,
      textColor: textColor ?? AppColors.white,
      alignment: alignment,
      child: child,
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STATUS CHIP
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum AppStatusType {
  success,
  warning,
  error,
  info,
  pending,
  neutral,
}

class AppStatusChip extends StatelessWidget {
  final String label;
  final AppStatusType type;
  final IconData? icon;
  final bool showIcon;

  const AppStatusChip({
    super.key,
    required this.label,
    required this.type,
    this.icon,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(type);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.badge),
        border: Border.all(
          color: config.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              icon ?? config.icon,
              size: 14,
              color: config.iconColor,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: AppTypography.labelSmall(context).copyWith(
              color: config.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(AppStatusType type) {
    switch (type) {
      case AppStatusType.success:
        return _StatusConfig(
          backgroundColor: AppColors.success.withValues(alpha: 0.1),
          borderColor: AppColors.success.withValues(alpha: 0.3),
          textColor: AppColors.successDark,
          iconColor: AppColors.success,
          icon: Icons.check_circle_outline,
        );
      case AppStatusType.warning:
        return _StatusConfig(
          backgroundColor: AppColors.warning.withValues(alpha: 0.1),
          borderColor: AppColors.warning.withValues(alpha: 0.3),
          textColor: AppColors.warningDark,
          iconColor: AppColors.warning,
          icon: Icons.warning_amber_outlined,
        );
      case AppStatusType.error:
        return _StatusConfig(
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          borderColor: AppColors.error.withValues(alpha: 0.3),
          textColor: AppColors.errorDark,
          iconColor: AppColors.error,
          icon: Icons.error_outline,
        );
      case AppStatusType.info:
        return _StatusConfig(
          backgroundColor: AppColors.info.withValues(alpha: 0.1),
          borderColor: AppColors.info.withValues(alpha: 0.3),
          textColor: AppColors.infoDark,
          iconColor: AppColors.info,
          icon: Icons.info_outline,
        );
      case AppStatusType.pending:
        return _StatusConfig(
          backgroundColor: AppColors.warning.withValues(alpha: 0.1),
          borderColor: AppColors.warning.withValues(alpha: 0.3),
          textColor: AppColors.warningDark,
          iconColor: AppColors.warning,
          icon: Icons.schedule_outlined,
        );
      case AppStatusType.neutral:
        return _StatusConfig(
          backgroundColor: AppColors.lightOutlineVariant,
          borderColor: AppColors.lightOutline,
          textColor: AppColors.lightOnSurface,
          iconColor: AppColors.lightOnSurfaceVariant,
          icon: Icons.circle_outlined,
        );
    }
  }
}

class _StatusConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;
  final IconData icon;

  _StatusConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
    required this.icon,
  });
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAG (compact chip for categories, tags)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppTag extends StatelessWidget {
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const AppTag({
    super.key,
    required this.label,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;

    final container = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(
          color: effectiveColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall(context).copyWith(
          color: effectiveColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        child: container,
      );
    }

    return container;
  }
}
