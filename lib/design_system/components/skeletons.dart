import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import '../theme/spacing.dart';
import '../theme/radius.dart';

/// Design System Skeleton Loaders
/// 
/// Loading placeholders with shimmer effect:
/// - AppSkeleton - Base skeleton box
/// - AppSkeletonList - List skeleton
/// - AppSkeletonCard - Card skeleton
/// - AppSkeletonText - Text line skeleton

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BASE SKELETON
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;

  const AppSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colors.surfaceVariant,
      highlightColor: context.colors.surfaceElevated,
      child: Container(
        width: width,
        height: height ?? 16,
        margin: margin,
        decoration: BoxDecoration(
          color: context.colors.surfaceVariant,
          borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.sm),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TEXT LINE SKELETON
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppSkeletonText extends StatelessWidget {
  final double? width;
  final double height;
  final EdgeInsetsGeometry? margin;

  const AppSkeletonText({
    super.key,
    this.width,
    this.height = 14,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      width: width,
      height: height,
      borderRadius: AppRadius.xs,
      margin: margin,
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CIRCULAR SKELETON (avatar, icon)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppSkeletonCircle extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry? margin;

  const AppSkeletonCircle({
    super.key,
    this.size = 48,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colors.surfaceVariant,
      highlightColor: context.colors.surfaceElevated,
      child: Container(
        width: size,
        height: size,
        margin: margin,
        decoration: BoxDecoration(
          color: context.colors.surfaceVariant,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CARD SKELETON
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppSkeletonCard extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const AppSkeletonCard({
    super.key,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          AppSkeletonText(
            width: 200,
            height: 20,
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          ),
          // Subtitle
          AppSkeletonText(
            width: 150,
            height: 14,
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
          ),
          // Body lines
          AppSkeletonText(
            width: double.infinity,
            height: 14,
            margin: const EdgeInsets.only(bottom: AppSpacing.xs),
          ),
          AppSkeletonText(
            width: double.infinity,
            height: 14,
            margin: const EdgeInsets.only(bottom: AppSpacing.xs),
          ),
          AppSkeletonText(
            width: 250,
            height: 14,
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LIST TILE SKELETON
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppSkeletonListTile extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;
  final bool hasSubtitle;
  final EdgeInsetsGeometry? margin;

  const AppSkeletonListTile({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.hasSubtitle = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      margin: margin,
      child: Row(
        children: [
          if (hasLeading) ...[
            const AppSkeletonCircle(size: 48),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonText(
                  width: 180,
                  height: 16,
                  margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                ),
                if (hasSubtitle)
                  AppSkeletonText(
                    width: 120,
                    height: 14,
                  ),
              ],
            ),
          ),
          if (hasTrailing) ...[
            const SizedBox(width: AppSpacing.md),
            const AppSkeletonCircle(size: 24),
          ],
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LIST SKELETON (multiple items)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppSkeletonList extends StatelessWidget {
  final int itemCount;
  final bool hasLeading;
  final bool hasTrailing;
  final bool hasSubtitle;
  final EdgeInsetsGeometry? itemMargin;

  const AppSkeletonList({
    super.key,
    this.itemCount = 5,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.hasSubtitle = true,
    this.itemMargin,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return AppSkeletonListTile(
          hasLeading: hasLeading,
          hasTrailing: hasTrailing,
          hasSubtitle: hasSubtitle,
          margin: itemMargin ?? const EdgeInsets.only(bottom: AppSpacing.sm),
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GRID SKELETON
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppSkeletonGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double aspectRatio;

  const AppSkeletonGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.aspectRatio = 1.2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemBuilder: (context, index) {
        return AppSkeleton(
          borderRadius: AppRadius.card,
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FORM SKELETON
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppSkeletonForm extends StatelessWidget {
  final int fieldCount;

  const AppSkeletonForm({
    super.key,
    this.fieldCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(fieldCount, (index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            AppSkeletonText(
              width: 100,
              height: 14,
              margin: const EdgeInsets.only(bottom: AppSpacing.xs),
            ),
            // Input field
            AppSkeleton(
              width: double.infinity,
              height: 48,
              borderRadius: AppRadius.input,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            ),
          ],
        );
      }),
    );
  }
}

