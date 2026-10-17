/// Design System Spacing Tokens
/// 
/// 8pt grid system (multiples of 4 and 8)
/// Base unit: 8px
class AppSpacing {
  AppSpacing._();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SPACING SCALE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  /// 4px - Micro spacing (gaps between tightly related elements)
  static const double xs = 4.0;
  
  /// 8px - Small spacing (1x base unit)
  static const double sm = 8.0;
  
  /// 12px - Compact spacing (1.5x base unit)
  static const double md = 12.0;
  
  /// 16px - Default spacing (2x base unit)
  static const double lg = 16.0;
  
  /// 20px - Comfortable spacing (2.5x base unit)
  static const double xl = 20.0;
  
  /// 24px - Spacious spacing (3x base unit)
  static const double xxl = 24.0;
  
  /// 32px - Large section spacing (4x base unit)
  static const double xxxl = 32.0;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SEMANTIC SPACING (named by usage)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  /// Gap between list items
  static const double listItemGap = lg; // 16
  
  /// Padding inside cards
  static const double cardPadding = lg; // 16
  
  /// Padding for screen edges
  static const double screenPadding = lg; // 16
  
  /// Spacing between form fields
  static const double formFieldGap = md; // 12
  
  /// Spacing between sections
  static const double sectionGap = xxl; // 24
  
  /// Padding for buttons
  static const double buttonPaddingVertical = md; // 12
  static const double buttonPaddingHorizontal = xl; // 20
  
  /// Padding for inputs
  static const double inputPaddingVertical = md; // 12
  static const double inputPaddingHorizontal = lg; // 16
  
  /// Gap between icon and text in buttons
  static const double iconTextGap = sm; // 8
  
  /// AppBar height
  static const double appBarHeight = 56.0;
  
  /// Bottom navigation bar height
  static const double bottomNavBarHeight = 80.0;
  
  /// FAB size
  static const double fabSize = 56.0;
  
  /// Minimum touch target size (accessibility)
  static const double minTouchTarget = 48.0;
}

