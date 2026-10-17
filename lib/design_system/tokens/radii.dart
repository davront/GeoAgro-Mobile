/// Border radius tokens
/// Apple/Notion inspired - subtle rounded corners
class AppRadii {
  AppRadii._();

  static const double none = 0.0;
  static const double sm = 8.0;   // Small (chips)
  static const double md = 16.0;  // Medium (cards, buttons, inputs)
  static const double lg = 20.0;  // Large (modals, sheets)
  static const double xl = 28.0;  // Extra large (special cases)
  static const double full = 9999.0; // Full circle

  // Specific use cases
  static const double button = sm;
  static const double input = sm;
  static const double card = md;
  static const double modal = lg;
}

