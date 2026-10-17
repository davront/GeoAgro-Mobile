import 'package:flutter/material.dart';
import 'colors.dart';

/// Theme-aware color accessor.
///
/// Usage: `context.colors.background` instead of `AppColors.darkBackground`.
/// Automatically selects the correct palette based on current [Brightness].
class AdaptiveColors {
  final bool isDark;

  AdaptiveColors.of(BuildContext context)
      : isDark = Theme.of(context).brightness == Brightness.dark;

  // ─── Backgrounds ──────────────────────────────────────────
  Color get background =>
      isDark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get surface =>
      isDark ? AppColors.darkSurface : AppColors.lightSurface;
  Color get surfaceVariant =>
      isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
  Color get surfaceElevated =>
      isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated;
  Color get highlight =>
      isDark ? AppColors.darkHighlight : AppColors.lightHighlight;

  // ─── Text ─────────────────────────────────────────────────
  Color get textPrimary =>
      isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get textSecondary =>
      isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get textTertiary =>
      isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;

  // ─── Borders & Dividers ───────────────────────────────────
  Color get border =>
      isDark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get divider =>
      isDark ? AppColors.darkDivider : AppColors.lightDivider;
  Color get muted =>
      isDark ? AppColors.darkMuted : AppColors.lightMuted;

  // ─── Card Decoration ──────────────────────────────────────
  /// Card shadow: soft elevation in light mode, none in dark mode.
  List<BoxShadow> get cardShadow => isDark
      ? const []
      : const [
          BoxShadow(
            color: Color(0x0A000000), // 4% black
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x0F000000), // 6% black
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ];

  /// Card border: visible in dark mode, subtle/none in light mode.
  Border? get cardBorder => isDark
      ? Border.all(color: border)
      : null;

  /// Inner divider color (inside cards): thinner in light, normal in dark.
  Color get cardDivider => isDark
      ? AppColors.darkDivider
      : const Color(0xFFF2F2F7); // iOS system gray 6

  // ─── Icon Tint ────────────────────────────────────────────
  /// Muted icon tint that adapts to theme.
  Color get iconSecondary => isDark
      ? AppColors.darkTextTertiary
      : const Color(0xFF8E8E93); // iOS gray
}

/// Extension on [BuildContext] for convenient access to [AdaptiveColors].
///
/// ```dart
/// // Before:
/// color: design_colors.AppColors.darkBackground
/// // After:
/// color: context.colors.background
/// ```
extension AdaptiveColorsExtension on BuildContext {
  AdaptiveColors get colors => AdaptiveColors.of(this);
}
