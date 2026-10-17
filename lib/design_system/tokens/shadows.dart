import 'package:flutter/material.dart';

/// Shadow tokens
/// Apple/Notion inspired - subtle, soft shadows
class AppShadows {
  AppShadows._();

  // Light theme shadows
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0A000000), // 4% opacity
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x0F000000), // 6% opacity
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x14000000), // 8% opacity
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  // Dark theme shadows (subtle glow effect)
  static const List<BoxShadow> darkSm = [
    BoxShadow(
      color: Color(0x14000000), // 8% opacity
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> darkMd = [
    BoxShadow(
      color: Color(0x1A000000), // 10% opacity
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> darkLg = [
    BoxShadow(
      color: Color(0x24000000), // 14% opacity
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
}

