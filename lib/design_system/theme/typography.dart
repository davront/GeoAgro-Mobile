import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design System Typography
///
/// Uses Inter font family with Material 3 type scale
/// Scale: 12, 14, 16, 18, 20, 24, 28, 34
/// Weights: 400 (regular), 500 (medium), 600 (semibold), 700 (bold)
/// Line heights: 1.2 (tight), 1.4 (normal), 1.6 (relaxed)
class AppTypography {
  AppTypography._();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // FONT FAMILY
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Body font family (Inter)
  static String get fontFamily => GoogleFonts.inter().fontFamily ?? 'Inter';

  /// Display font family (Plus Jakarta Sans) — used for hero titles and page headers
  static String get fontFamilyDisplay =>
      GoogleFonts.plusJakartaSans().fontFamily ?? 'Plus Jakarta Sans';

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // FONT SIZES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const double fontSize12 = 12.0;
  static const double fontSize14 = 14.0;
  static const double fontSize16 = 16.0;
  static const double fontSize18 = 18.0;
  static const double fontSize20 = 20.0;
  static const double fontSize24 = 24.0;
  static const double fontSize28 = 28.0;
  static const double fontSize34 = 34.0;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // FONT WEIGHTS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // LINE HEIGHTS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.6;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TEXT STYLES (Material 3 Type Scale)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Display Large (34px, Bold, Tight) - Hero titles
  static TextStyle displayLarge(BuildContext context) =>
      GoogleFonts.plusJakartaSans(
        fontSize: fontSize34,
        fontWeight: bold,
        height: lineHeightTight,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: -0.5,
      );

  /// Display Medium (28px, Bold, Tight) - Page titles
  static TextStyle displayMedium(BuildContext context) =>
      GoogleFonts.plusJakartaSans(
        fontSize: fontSize28,
        fontWeight: bold,
        height: lineHeightTight,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: -0.25,
      );

  /// Display Small (24px, Semibold, Normal) - Section headers
  static TextStyle displaySmall(BuildContext context) =>
      GoogleFonts.plusJakartaSans(
        fontSize: fontSize24,
        fontWeight: semibold,
        height: lineHeightNormal,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: 0,
      );

  /// Headline Large (20px, Semibold, Normal) - Card titles
  static TextStyle headlineLarge(BuildContext context) => GoogleFonts.inter(
        fontSize: fontSize20,
        fontWeight: semibold,
        height: lineHeightNormal,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: 0,
      );

  /// Headline Medium (18px, Semibold, Normal) - List item titles
  static TextStyle headlineMedium(BuildContext context) => GoogleFonts.inter(
        fontSize: fontSize18,
        fontWeight: semibold,
        height: lineHeightNormal,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: 0,
      );

  /// Headline Small (16px, Semibold, Normal) - Emphasized text
  static TextStyle headlineSmall(BuildContext context) => GoogleFonts.inter(
        fontSize: fontSize16,
        fontWeight: semibold,
        height: lineHeightNormal,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: 0,
      );

  /// Body Large (16px, Regular, Relaxed) - Primary body text
  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.inter(
        fontSize: fontSize16,
        fontWeight: regular,
        height: lineHeightRelaxed,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: 0.15,
      );

  /// Body Medium (14px, Regular, Relaxed) - Secondary body text
  static TextStyle bodyMedium(BuildContext context) => GoogleFonts.inter(
        fontSize: fontSize14,
        fontWeight: regular,
        height: lineHeightRelaxed,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 0.25,
      );

  /// Body Small (12px, Regular, Normal) - Captions, helper text
  static TextStyle bodySmall(BuildContext context) => GoogleFonts.inter(
        fontSize: fontSize12,
        fontWeight: regular,
        height: lineHeightNormal,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 0.4,
      );

  /// Label Large (16px, Medium, Normal) - Button text
  static TextStyle labelLarge(BuildContext context) => GoogleFonts.inter(
        fontSize: fontSize16,
        fontWeight: medium,
        height: lineHeightNormal,
        color: Theme.of(context).colorScheme.onPrimary,
        letterSpacing: 0.1,
      );

  /// Label Medium (14px, Medium, Normal) - Secondary button text
  static TextStyle labelMedium(BuildContext context) => GoogleFonts.inter(
        fontSize: fontSize14,
        fontWeight: medium,
        height: lineHeightNormal,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: 0.5,
      );

  /// Label Small (12px, Medium, Normal) - Chips, badges
  static TextStyle labelSmall(BuildContext context) => GoogleFonts.inter(
        fontSize: fontSize12,
        fontWeight: medium,
        height: lineHeightNormal,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 0.5,
      );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SPECIALIZED TEXT STYLES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Input field text
  static TextStyle input(BuildContext context) => GoogleFonts.inter(
        fontSize: fontSize16,
        fontWeight: regular,
        height: lineHeightNormal,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: 0.15,
      );

  /// Input field label
  static TextStyle inputLabel(BuildContext context) => GoogleFonts.inter(
        fontSize: fontSize14,
        fontWeight: medium,
        height: lineHeightNormal,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 0.4,
      );

  /// Input field error
  static TextStyle inputError(BuildContext context) => GoogleFonts.inter(
        fontSize: fontSize12,
        fontWeight: regular,
        height: lineHeightNormal,
        color: Theme.of(context).colorScheme.error,
        letterSpacing: 0.4,
      );

  /// Input field helper text
  static TextStyle inputHelper(BuildContext context) => GoogleFonts.inter(
        fontSize: fontSize12,
        fontWeight: regular,
        height: lineHeightNormal,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 0.4,
      );

  /// AppBar title
  static TextStyle appBarTitle(BuildContext context) => GoogleFonts.inter(
        fontSize: fontSize20,
        fontWeight: semibold,
        height: lineHeightNormal,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: 0,
      );

  /// Tab label
  static TextStyle tabLabel(BuildContext context) => GoogleFonts.inter(
        fontSize: fontSize14,
        fontWeight: medium,
        height: lineHeightNormal,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: 0.5,
      );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // UTILITY METHODS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Get TextTheme for Material 3
  static TextTheme getTextTheme(BuildContext context) {
    return TextTheme(
      displayLarge: displayLarge(context),
      displayMedium: displayMedium(context),
      displaySmall: displaySmall(context),
      headlineLarge: headlineLarge(context),
      headlineMedium: headlineMedium(context),
      headlineSmall: headlineSmall(context),
      bodyLarge: bodyLarge(context),
      bodyMedium: bodyMedium(context),
      bodySmall: bodySmall(context),
      labelLarge: labelLarge(context),
      labelMedium: labelMedium(context),
      labelSmall: labelSmall(context),
    );
  }
}
