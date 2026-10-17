import 'package:flutter/material.dart';

/// Typography tokens
/// Apple/Notion inspired - clean, readable fonts
class AppTypography {
  AppTypography._();

  // Font families
  static const String fontFamily = 'Inter'; // Body text
  static const String fontFamilyDisplay = 'Plus Jakarta Sans'; // Headlines

  // Font sizes
  static const double fontSizeXs = 12.0;
  static const double fontSizeSm = 14.0;
  static const double fontSizeBase = 16.0;
  static const double fontSizeLg = 18.0;
  static const double fontSizeXl = 20.0;
  static const double fontSize2xl = 24.0;
  static const double fontSize3xl = 28.0;
  static const double fontSize4xl = 34.0;

  // Font weights
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Line heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.6;

  // Text styles
  static TextStyle headline1(BuildContext context) => TextStyle(
        fontSize: fontSize4xl,
        fontWeight: bold,
        height: lineHeightTight,
        fontFamily: fontFamilyDisplay,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle headline2(BuildContext context) => TextStyle(
        fontSize: fontSize3xl,
        fontWeight: bold,
        height: lineHeightTight,
        fontFamily: fontFamilyDisplay,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle headline3(BuildContext context) => TextStyle(
        fontSize: fontSize2xl,
        fontWeight: semibold,
        height: lineHeightNormal,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle title(BuildContext context) => TextStyle(
        fontSize: fontSizeXl,
        fontWeight: semibold,
        height: lineHeightNormal,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle bodyLarge(BuildContext context) => TextStyle(
        fontSize: fontSizeBase,
        fontWeight: regular,
        height: lineHeightNormal,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle body(BuildContext context) => TextStyle(
        fontSize: fontSizeBase,
        fontWeight: regular,
        height: lineHeightNormal,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
        fontSize: fontSizeSm,
        fontWeight: regular,
        height: lineHeightNormal,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );

  static TextStyle caption(BuildContext context) => TextStyle(
        fontSize: fontSizeXs,
        fontWeight: regular,
        height: lineHeightNormal,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );

  static TextStyle button(BuildContext context) => TextStyle(
        fontSize: fontSizeBase,
        fontWeight: semibold,
        height: lineHeightNormal,
        color: Theme.of(context).colorScheme.onPrimary,
      );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ALIASES (compatibility with theme/typography names)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Input field text (16px, Regular)
  static TextStyle input(BuildContext context) => TextStyle(
        fontSize: fontSizeBase,
        fontWeight: regular,
        height: lineHeightNormal,
        color: Theme.of(context).colorScheme.onSurface,
      );

  /// Headline Medium (18px, Semibold)
  static TextStyle headlineMedium(BuildContext context) => TextStyle(
        fontSize: fontSizeLg,
        fontWeight: semibold,
        height: lineHeightNormal,
        color: Theme.of(context).colorScheme.onSurface,
      );

  /// Headline Small (16px, Semibold) — emphasized text
  static TextStyle headlineSmall(BuildContext context) => TextStyle(
        fontSize: fontSizeBase,
        fontWeight: semibold,
        height: lineHeightNormal,
        color: Theme.of(context).colorScheme.onSurface,
      );

  /// Body Medium (14px, Regular) — alias for bodySmall
  static TextStyle bodyMedium(BuildContext context) => bodySmall(context);

  /// Label Large (16px, Medium) — alias for button
  static TextStyle labelLarge(BuildContext context) => button(context);
}
