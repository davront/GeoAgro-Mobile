import 'package:flutter/animation.dart';

/// Motion tokens for consistent animation timing.
///
/// Usage:
/// ```dart
/// AnimatedContainer(
///   duration: AppMotion.fast,
///   curve: AppMotion.easeOut,
/// )
/// ```
class AppMotion {
  AppMotion._();

  // ===== DURATIONS =====
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration entrance = Duration(milliseconds: 600);
  static const Duration shimmer = Duration(milliseconds: 1500);

  // ===== CURVES =====
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve spring = Curves.easeOutCubic;

  // ===== DEBOUNCE =====
  static const int debounceMs = 500;
}
