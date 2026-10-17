import 'package:flutter/material.dart';
import 'colors.dart';

/// Design System Shadow Tokens
/// 
/// Soft, subtle shadows for elevation without heavy blur
/// Compatible with both light and dark themes
class AppShadows {
  AppShadows._();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ELEVATION LEVELS (Light Theme)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  /// No shadow
  static List<BoxShadow> none = const [];
  
  /// Elevation 1 - Subtle lift (e.g., resting cards)
  static List<BoxShadow> elevation1Light = [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.04),
      blurRadius: 2,
      offset: const Offset(0, 1),
      spreadRadius: 0,
    ),
  ];
  
  /// Elevation 2 - Light lift (e.g., hovering cards, chips)
  static List<BoxShadow> elevation2Light = [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.06),
      blurRadius: 4,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  /// Elevation 3 - Moderate lift (e.g., floating action button)
  static List<BoxShadow> elevation3Light = [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.02),
      blurRadius: 2,
      offset: const Offset(0, 1),
      spreadRadius: 0,
    ),
  ];
  
  /// Elevation 4 - High lift (e.g., dialogs, modals)
  static List<BoxShadow> elevation4Light = [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.10),
      blurRadius: 12,
      offset: const Offset(0, 6),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  /// Elevation 5 - Maximum lift (e.g., bottom sheets, navigation drawer)
  static List<BoxShadow> elevation5Light = [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.06),
      blurRadius: 6,
      offset: const Offset(0, 3),
      spreadRadius: 0,
    ),
  ];

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ELEVATION LEVELS (Dark Theme)
  // Lighter shadows with more spread for visibility on dark backgrounds
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  /// Elevation 1 - Subtle lift (dark theme)
  static List<BoxShadow> elevation1Dark = [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.20),
      blurRadius: 3,
      offset: const Offset(0, 1),
      spreadRadius: 0,
    ),
  ];
  
  /// Elevation 2 - Light lift (dark theme)
  static List<BoxShadow> elevation2Dark = [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.24),
      blurRadius: 5,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  /// Elevation 3 - Moderate lift (dark theme)
  static List<BoxShadow> elevation3Dark = [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.28),
      blurRadius: 10,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.12),
      blurRadius: 3,
      offset: const Offset(0, 1),
      spreadRadius: 0,
    ),
  ];
  
  /// Elevation 4 - High lift (dark theme)
  static List<BoxShadow> elevation4Dark = [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.32),
      blurRadius: 14,
      offset: const Offset(0, 6),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.16),
      blurRadius: 5,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  /// Elevation 5 - Maximum lift (dark theme)
  static List<BoxShadow> elevation5Dark = [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.36),
      blurRadius: 18,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.20),
      blurRadius: 7,
      offset: const Offset(0, 3),
      spreadRadius: 0,
    ),
  ];

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SEMANTIC SHADOWS (named by usage)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  /// Card shadow (light theme)
  static List<BoxShadow> get cardLight => elevation2Light;
  
  /// Card shadow (dark theme)
  static List<BoxShadow> get cardDark => elevation2Dark;
  
  /// Button shadow (light theme)
  static List<BoxShadow> get buttonLight => elevation1Light;
  
  /// Button shadow (dark theme)
  static List<BoxShadow> get buttonDark => elevation1Dark;
  
  /// FAB shadow (light theme)
  static List<BoxShadow> get fabLight => elevation3Light;
  
  /// FAB shadow (dark theme)
  static List<BoxShadow> get fabDark => elevation3Dark;
  
  /// Modal shadow (light theme)
  static List<BoxShadow> get modalLight => elevation4Light;
  
  /// Modal shadow (dark theme)
  static List<BoxShadow> get modalDark => elevation4Dark;
  
  /// Drawer shadow (light theme)
  static List<BoxShadow> get drawerLight => elevation5Light;
  
  /// Drawer shadow (dark theme)
  static List<BoxShadow> get drawerDark => elevation5Dark;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // UTILITY METHODS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  /// Get shadow for elevation level based on theme brightness
  static List<BoxShadow> forElevation(int level, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    switch (level) {
      case 0:
        return none;
      case 1:
        return isDark ? elevation1Dark : elevation1Light;
      case 2:
        return isDark ? elevation2Dark : elevation2Light;
      case 3:
        return isDark ? elevation3Dark : elevation3Light;
      case 4:
        return isDark ? elevation4Dark : elevation4Light;
      case 5:
        return isDark ? elevation5Dark : elevation5Light;
      default:
        return isDark ? elevation2Dark : elevation2Light;
    }
  }
  
  /// Get card shadow based on theme brightness
  static List<BoxShadow> card(Brightness brightness) {
    return brightness == Brightness.dark ? cardDark : cardLight;
  }
  
  /// Get button shadow based on theme brightness
  static List<BoxShadow> button(Brightness brightness) {
    return brightness == Brightness.dark ? buttonDark : buttonLight;
  }
  
  /// Get FAB shadow based on theme brightness
  static List<BoxShadow> fab(Brightness brightness) {
    return brightness == Brightness.dark ? fabDark : fabLight;
  }
  
  /// Get modal shadow based on theme brightness
  static List<BoxShadow> modal(Brightness brightness) {
    return brightness == Brightness.dark ? modalDark : modalLight;
  }
  
  /// Get drawer shadow based on theme brightness
  static List<BoxShadow> drawer(Brightness brightness) {
    return brightness == Brightness.dark ? drawerDark : drawerLight;
  }
}

