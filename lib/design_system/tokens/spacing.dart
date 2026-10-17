/// Spacing tokens for consistent layout
/// Apple/Notion inspired - 8px base unit
class AppSpacing {
  AppSpacing._();

  // Base unit: 8px
  static const double xs = 4.0;   // 0.5x
  static const double sm = 8.0;   // 1x
  static const double md = 16.0;  // 2x
  static const double lg = 24.0;  // 3x
  static const double xl = 32.0;  // 4x
  static const double xxl = 40.0; // 5x
  static const double xxxl = 48.0; // 6x

  // Specific use cases
  static const double cardPadding = md;
  static const double screenPadding = md;
  static const double sectionSpacing = lg;
  static const double itemSpacing = sm;

  // Input field spacing
  static const double inputPaddingHorizontal = md; // 16
  static const double inputPaddingVertical = 12.0;
  static const double formFieldGap = md; // 16
}

