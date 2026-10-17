import 'package:flutter/material.dart';

/// Design System Border Radius Tokens
/// 
/// Consistent rounded corners across the application
/// Scale: 8, 12, 16, 20, 28
class AppRadius {
  AppRadius._();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // RADIUS SCALE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  /// No radius (sharp corners)
  static const double none = 0.0;
  
  /// 8px - Extra small (chips, small buttons)
  static const double xs = 8.0;
  
  /// 12px - Small (inputs, compact cards)
  static const double sm = 12.0;
  
  /// 16px - Medium (default cards, buttons)
  static const double md = 16.0;
  
  /// 20px - Large (prominent cards)
  static const double lg = 20.0;
  
  /// 28px - Extra large (modals, bottom sheets)
  static const double xl = 28.0;
  
  /// Fully rounded (circular/pill shapes)
  static const double full = 9999.0;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SEMANTIC RADIUS (named by usage)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  /// Button radius
  static const double button = md; // 16
  
  /// Input field radius
  static const double input = md; // 16
  
  /// Card radius
  static const double card = md; // 16
  
  /// Chip radius
  static const double chip = xs; // 8
  
  /// Badge radius
  static const double badge = full; // pill shape
  
  /// Modal/dialog radius
  static const double modal = xl; // 28
  
  /// Bottom sheet radius
  static const double bottomSheet = xl; // 28
  
  /// FAB radius
  static const double fab = lg; // 20
  
  /// Avatar radius
  static const double avatar = full; // circular

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // BORDER RADIUS HELPERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  /// Get BorderRadius for given radius value
  static BorderRadius circular(double radius) => BorderRadius.circular(radius);
  
  /// Top-only radius (for bottom sheets, modals)
  static BorderRadius top(double radius) => BorderRadius.vertical(
        top: Radius.circular(radius),
      );
  
  /// Bottom-only radius
  static BorderRadius bottom(double radius) => BorderRadius.vertical(
        bottom: Radius.circular(radius),
      );
  
  /// Left-only radius
  static BorderRadius left(double radius) => BorderRadius.horizontal(
        left: Radius.circular(radius),
      );
  
  /// Right-only radius
  static BorderRadius right(double radius) => BorderRadius.horizontal(
        right: Radius.circular(radius),
      );
  
  /// Custom radius for each corner
  static BorderRadius only({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) =>
      BorderRadius.only(
        topLeft: Radius.circular(topLeft),
        topRight: Radius.circular(topRight),
        bottomLeft: Radius.circular(bottomLeft),
        bottomRight: Radius.circular(bottomRight),
      );
}

