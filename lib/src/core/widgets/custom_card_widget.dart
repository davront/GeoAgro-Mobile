import 'package:flutter/material.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import 'package:agro_employee_public/design_system/tokens/colors.dart'
    as design_colors;
import '../../../design_system/tokens/radii.dart';

enum CardVariant {
  standard,
  elevated,
  accent,
  notification,
  stat,
}

class CustomCardWidget extends StatelessWidget {
  final Widget child;
  final double horizontal;
  final double vertical;
  final Color? backgroundColor;
  final double? borderRadius;
  final CardVariant variant;

  const CustomCardWidget({
    super.key,
    required this.horizontal,
    required this.vertical,
    required this.child,
    this.backgroundColor,
    this.borderRadius,
    this.variant = CardVariant.standard,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = borderRadius ?? AppRadii.card;

    final BoxDecoration decoration;
    switch (variant) {
      case CardVariant.standard:
        decoration = BoxDecoration(
          color: backgroundColor ?? colors.surfaceVariant,
          borderRadius: BorderRadius.circular(radius),
          border: colors.cardBorder,
          boxShadow: colors.cardShadow,
        );
      case CardVariant.elevated:
        decoration = BoxDecoration(
          color: backgroundColor ?? colors.surface,
          borderRadius: BorderRadius.circular(radius),
          border: colors.cardBorder,
          boxShadow: [
            BoxShadow(
              color: const Color(0x0F000000),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            ...colors.cardShadow,
          ],
        );
      case CardVariant.accent:
        decoration = BoxDecoration(
          color: backgroundColor ?? colors.surfaceVariant,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: design_colors.AppColors.accentGreen.withValues(alpha: 0.3),
          ),
          boxShadow: colors.cardShadow,
        );
      case CardVariant.notification:
        decoration = BoxDecoration(
          color: backgroundColor ?? colors.surface,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: colors.cardBorder,
        );
      case CardVariant.stat:
        decoration = BoxDecoration(
          color: backgroundColor ?? colors.surfaceVariant,
          borderRadius: BorderRadius.circular(radius),
          border: colors.cardBorder,
          boxShadow: colors.cardShadow,
        );
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: decoration,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child: child,
      ),
    );
  }
}
