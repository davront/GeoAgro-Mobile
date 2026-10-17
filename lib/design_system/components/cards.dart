import 'package:flutter/material.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/radius.dart';
import '../theme/shadows.dart';

/// Design System Card Components
/// 
/// Material 3 card variants:
/// - AppCard - Base card (default elevated style)
/// - AppCardElevated - Elevated card with shadow
/// - AppCardFilled - Filled card with background color
/// - AppCardOutlined - Outlined card with border

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BASE CARD
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final double? borderRadius;
  final bool showBorder;
  final Color? borderColor;
  final double? elevation;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.color,
    this.borderRadius,
    this.showBorder = true,
    this.borderColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBorderColor = borderColor ??
        (isDark ? AppColors.darkOutline : AppColors.lightOutline);
    final effectiveRadius = borderRadius ?? AppRadius.card;

    final cardChild = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      return Card(
        margin: margin ?? EdgeInsets.zero,
        color: color,
        elevation: elevation ?? 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveRadius),
          side: showBorder
              ? BorderSide(color: effectiveBorderColor, width: 1)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(effectiveRadius),
          child: cardChild,
        ),
      );
    }

    return Card(
      margin: margin ?? EdgeInsets.zero,
      color: color,
      elevation: elevation ?? 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(effectiveRadius),
        side: showBorder
            ? BorderSide(color: effectiveBorderColor, width: 1)
            : BorderSide.none,
      ),
      child: cardChild,
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ELEVATED CARD (with shadow)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppCardElevated extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final double? borderRadius;
  final int elevation;

  const AppCardElevated({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.color,
    this.borderRadius,
    this.elevation = 2,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppRadius.card;
    final effectiveColor = color ?? context.colors.surface;

    final cardChild = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      child: child,
    );

    final container = Container(
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(effectiveRadius),
        boxShadow: AppShadows.forElevation(
          elevation,
          Theme.of(context).brightness,
        ),
      ),
      child: cardChild,
    );

    if (onTap != null || onLongPress != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(effectiveRadius),
          child: container,
        ),
      );
    }

    return container;
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FILLED CARD (tonal background)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppCardFilled extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? borderRadius;

  const AppCardFilled({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = context.colors.surfaceVariant;
    final effectiveRadius = borderRadius ?? AppRadius.card;

    final cardChild = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      child: child,
    );

    final container = Container(
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(effectiveRadius),
      ),
      child: cardChild,
    );

    if (onTap != null || onLongPress != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(effectiveRadius),
          child: container,
        ),
      );
    }

    return container;
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OUTLINED CARD (with border, no fill)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppCardOutlined extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? borderRadius;
  final Color? borderColor;
  final double borderWidth;

  const AppCardOutlined({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.borderColor,
    this.borderWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBorderColor = borderColor ??
        (isDark ? AppColors.darkOutline : AppColors.lightOutline);
    final effectiveRadius = borderRadius ?? AppRadius.card;

    final cardChild = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      child: child,
    );

    final container = Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(effectiveRadius),
        border: Border.all(
          color: effectiveBorderColor,
          width: borderWidth,
        ),
      ),
      child: cardChild,
    );

    if (onTap != null || onLongPress != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(effectiveRadius),
          child: container,
        ),
      );
    }

    return container;
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SPECIALIZED CARDS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Info card with colored accent border on left
class AppInfoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? accentColor;
  final double accentWidth;

  const AppInfoCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.accentColor,
    this.accentWidth = 4,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveAccentColor = accentColor ?? AppColors.primary;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border(
          left: BorderSide(
            color: effectiveAccentColor,
            width: accentWidth,
          ),
          top: BorderSide(
            color: isDark ? AppColors.darkOutline : AppColors.lightOutline,
            width: 1,
          ),
          right: BorderSide(
            color: isDark ? AppColors.darkOutline : AppColors.lightOutline,
            width: 1,
          ),
          bottom: BorderSide(
            color: isDark ? AppColors.darkOutline : AppColors.lightOutline,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
        child: child,
      ),
    );
  }
}

/// Summary card with title and content sections
class AppSummaryCard extends StatelessWidget {
  final String title;
  final Widget content;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const AppSummaryCard({
    super.key,
    required this.title,
    required this.content,
    this.trailing,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding,
      margin: margin,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          content,
        ],
      ),
    );
  }
}

/// Stat card with icon, value, and label
class AppStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? iconColor;
  final Color? valueColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const AppStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
    this.valueColor,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppCard(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      margin: margin,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 32,
            color: iconColor ?? theme.colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: theme.textTheme.displaySmall?.copyWith(
              color: valueColor ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

