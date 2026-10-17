import 'package:flutter/material.dart';

import '../tokens/colors.dart' as tokens;

/// Тонкая обёртка поверх design_system/tokens/colors.dart — раньше это
/// был отдельный набор констант с собственными hex-значениями (error/info/
/// warning отличались от tokens/colors.dart), из-за чего одна и та же
/// плантация могла выглядеть разными оттенками на разных экранах в
/// зависимости от того, какой из двух файлов импортирован. Теперь все
/// значения берутся из tokens/colors.dart — единственного источника.
class AppColors {
  AppColors._();

  static const Color primary = tokens.AppColors.accentGreen;
  static const Color primaryDark = tokens.AppColors.accentGreenDark;
  static const Color primaryLight = tokens.AppColors.accentGreenLight;
  static const Color primaryContainer = Color(0xFFD1FAE5);
  static const Color primaryContainerDark = Color(0xFF0F4A2B);

  static const Color lightBackground = tokens.AppColors.lightBackground;
  static const Color lightSurface = tokens.AppColors.lightSurface;
  static const Color lightSurfaceVariant = tokens.AppColors.lightSurfaceVariant;
  static const Color lightSurfaceElevated =
      tokens.AppColors.lightSurfaceElevated;
  static const Color lightOnBackground = tokens.AppColors.lightTextPrimary;
  static const Color lightOnSurface = tokens.AppColors.lightTextPrimary;
  static const Color lightOnSurfaceVariant = tokens.AppColors.lightTextTertiary;
  static const Color lightOutline = tokens.AppColors.lightMuted;
  static const Color lightOutlineVariant = tokens.AppColors.lightBorder;

  static const Color darkBackground = tokens.AppColors.darkBackground;
  static const Color darkSurface = tokens.AppColors.darkSurfaceVariant;
  static const Color darkSurfaceVariant = tokens.AppColors.darkSurfaceElevated;
  static const Color darkSurfaceElevated = tokens.AppColors.darkMuted;
  static const Color darkOnBackground = tokens.AppColors.darkTextPrimary;
  static const Color darkOnSurface = tokens.AppColors.darkTextPrimary;
  static const Color darkOnSurfaceVariant = tokens.AppColors.darkTextTertiary;
  static const Color darkOutline = tokens.AppColors.darkBorder;
  static const Color darkOutlineVariant = tokens.AppColors.darkDivider;

  static const Color success = tokens.AppColors.success;
  static const Color successLight = tokens.AppColors.accentGreenLight;
  static const Color successDark = tokens.AppColors.accentGreenDark;

  static const Color error = tokens.AppColors.error;
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFB91C1C);

  static const Color warning = tokens.AppColors.warning;
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFB45309);

  static const Color info = tokens.AppColors.info;
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF0C4A6E);

  static const Color white = tokens.AppColors.white;
  static const Color black = tokens.AppColors.black;

  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  static Color lightOverlay(double opacity) =>
      lightOnBackground.withValues(alpha: opacity);
  static Color darkOverlay(double opacity) =>
      darkOnBackground.withValues(alpha: opacity);

  static const Color accentGreen = primary;
  static const Color darkTextPrimary = darkOnBackground;
  static const Color darkTextSecondary = darkOnSurfaceVariant;
  static const Color darkTextTertiary = darkOnSurfaceVariant;
  static const Color darkBorder = darkOutline;
  static const Color darkDivider = darkOutlineVariant;
  static const Color darkHighlight = darkSurfaceElevated;
}
