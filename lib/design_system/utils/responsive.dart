import 'package:flutter/material.dart';

/// Responsive Design Utilities
///
/// Provides breakpoints and utilities for responsive layouts
/// Breakpoints follow Material Design guidelines
class Responsive {
  Responsive._();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // BREAKPOINTS (Material Design 3)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Compact (phones in portrait) - up to 600dp
  static const double compact = 600;

  /// Medium (tablets in portrait, phones in landscape) - 600-840dp
  static const double medium = 840;

  /// Expanded (tablets in landscape, desktops) - 840-1200dp
  static const double expanded = 1200;

  /// Large (large tablets, desktops) - 1200-1600dp
  static const double large = 1600;

  /// Extra large (large desktops) - 1600dp+
  static const double extraLarge = 1600;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDTH CLASS CHECKS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Is compact width? (phones in portrait)
  static bool isCompact(BuildContext context) {
    return MediaQuery.of(context).size.width < compact;
  }

  /// Is medium width? (tablets in portrait, phones in landscape)
  static bool isMedium(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= compact && width < expanded;
  }

  /// Is expanded width? (tablets in landscape, small desktops)
  static bool isExpanded(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= expanded && width < large;
  }

  /// Is large width? (large tablets, desktops)
  static bool isLarge(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= large && width < extraLarge;
  }

  /// Is extra large width? (large desktops)
  static bool isExtraLarge(BuildContext context) {
    return MediaQuery.of(context).size.width >= extraLarge;
  }

  /// Is mobile device? (compact width class)
  static bool isMobile(BuildContext context) => isCompact(context);

  /// Is tablet device? (medium or expanded width class)
  static bool isTablet(BuildContext context) {
    return isMedium(context) || isExpanded(context);
  }

  /// Is desktop device? (large or extra large width class)
  static bool isDesktop(BuildContext context) {
    return isLarge(context) || isExtraLarge(context);
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // LAYOUT HELPERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Get number of columns for grid layouts
  /// - Mobile: 1 column (list)
  /// - Tablet portrait (medium): 2 columns
  /// - Tablet landscape (expanded): 3 columns
  /// - Desktop: 4 columns
  static int getGridColumns(BuildContext context) {
    if (isCompact(context)) return 2;
    if (isMedium(context)) return 2;
    if (isExpanded(context)) return 3;
    if (isLarge(context)) return 4;
    return 4;
  }

  /// Get child aspect ratio for grid layouts
  static double getGridAspectRatio(BuildContext context) {
    if (isCompact(context)) return 1.0;
    if (isMedium(context)) return 1.2;
    if (isExpanded(context)) return 1.2;
    return 1.3;
  }

  /// Get horizontal padding for screens
  static double getScreenPadding(BuildContext context) {
    if (isCompact(context)) return 16.0;
    if (isMedium(context)) return 24.0;
    if (isExpanded(context)) return 32.0;
    return 48.0;
  }

  /// Get maximum content width for centered layouts
  static double getMaxContentWidth(BuildContext context) {
    if (isCompact(context)) return double.infinity;
    if (isMedium(context)) return 720;
    if (isExpanded(context)) return 960;
    return 1200;
  }

  /// Should use list or grid view?
  /// - Mobile: always list
  /// - Tablet: grid if preferred
  /// - Desktop: grid
  static bool shouldUseGrid(BuildContext context, {bool preferGrid = true}) {
    if (isCompact(context)) return false;
    if (isMedium(context)) return preferGrid;
    return true;
  }

  /// Should show sidebar navigation?
  /// - Mobile: false (use bottom nav or drawer)
  /// - Tablet: depends on orientation and preference
  /// - Desktop: true
  static bool shouldShowSidebar(BuildContext context) {
    return isExpanded(context) || isLarge(context) || isExtraLarge(context);
  }

  /// Get font scale factor for responsive typography
  static double getFontScale(BuildContext context) {
    if (isCompact(context)) return 1.0;
    if (isMedium(context)) return 1.1;
    if (isExpanded(context)) return 1.15;
    return 1.2;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // VALUE HELPERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Get responsive value based on width class
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isCompact(context)) return mobile;
    if (isMedium(context) || isExpanded(context)) return tablet ?? mobile;
    return desktop ?? tablet ?? mobile;
  }

  /// Get screen width
  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get safe area padding
  static EdgeInsets safeArea(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Is landscape orientation?
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Is portrait orientation?
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
}
