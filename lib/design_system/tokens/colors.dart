import 'package:flutter/material.dart';

/// Color tokens for the application
/// Dark theme by default with #16A34A green accent
class AppColors {
  AppColors._();

  // ===== DARK THEME (DEFAULT) =====
  static const Color darkBackground = Color(0xFF021024); // Deep Navy Blue
  static const Color darkSurface = Color(0xFF051933); // Navy surface
  static const Color darkSurfaceVariant =
      Color(0xFF1E293B); // Slate-800 (cards)
  static const Color darkTextPrimary = Color(0xFFF9FAFB); // Slate-50
  static const Color darkTextSecondary = Color(0xFFE2E8F0); // Slate-200
  static const Color darkTextTertiary = Color(0xFF94A3B8); // Slate-400
  static const Color darkBorder = Color(0xFF2D3A4D); // Subtle navy-slate border
  static const Color darkDivider = Color(0xFF27324A); // Navy divider
  static const Color darkSurfaceElevated =
      Color(0xFF283548); // Chips on cards (slightly lighter)
  static const Color darkMuted = Color(0xFF334155); // Slate-700
  static const Color darkHighlight = Color(0xFF0B1120); // Deep navy

  // ===== ACCENT COLOR (Green #16A34A) =====
  static const Color accentGreen = Color(0xFF16A34A); // Primary accent
  static const Color accentGreenLight =
      Color(0xFF34D399); // Tailwind emerald-400
  static const Color accentGreenDark =
      Color(0xFF0F7A36); // Tailwind emerald-800

  // ===== SEMANTIC COLORS =====
  // Приглушённые (не iOS-системные) тона — прежние #FF9500/#FF3B30/#007AFF
  // были рассчитаны Apple под алерты на белом фоне и выглядели слишком
  // ярко/кричаще на картах и статусных чипах в B2B agro-приложении.
  static const Color success = Color(0xFF16A34A); // Same as accent
  static const Color warning = Color(0xFFD97706); // Amber-600
  static const Color error = Color(0xFFDC2626); // Red-600
  static const Color info = Color(0xFF0369A1); // Sky-700

  // ===== CHART / STATISTICS COLORS =====
  static const Color chartBlue = Color(0xFF38BDF8); // Sky-400
  static const Color chartRed = Color(0xFFF87171); // Red-400
  static const Color chartTeal = Color(0xFF06B6D4); // Cyan-500
  static const Color chartPurple = Color(0xFF8B5CF6); // Violet-500
  static const Color chartEmerald = Color(0xFF10B981); // Emerald-500
  static const Color chartMint = Color(0xFF38E3A8); // Custom mint

  // ===== LEGACY COLORS (still referenced; remove once call sites migrate) =====
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color c1E1E1E = Color(0xFF1E1E1E);
  static const Color c1E1E1E70 = Color.fromRGBO(30, 30, 30, 0.7);
  static const Color c1E1E1E90 = Color.fromRGBO(30, 30, 30, 0.9);
  static const Color c28A745 = Color(0xFF28A745);

  // ===== LIGHT THEME =====
  static const Color lightBackground = Color(0xFFF2F2F7); // iOS system gray 6
  static const Color lightSurface = Color(0xFFFFFFFF); // White
  static const Color lightSurfaceVariant = Color(0xFFFFFFFF); // White cards
  static const Color lightTextPrimary = Color(0xFF1C1C1E); // iOS label
  static const Color lightTextSecondary =
      Color(0xFF3C3C43); // iOS secondary label
  static const Color lightTextTertiary =
      Color(0xFF8E8E93); // iOS tertiary label
  static const Color lightBorder = Color(0xFFE5E5EA); // iOS separator
  static const Color lightDivider = Color(0xFFC6C6C8); // iOS opaque separator
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF); // White
  static const Color lightMuted = Color(0xFFD1D1D6); // iOS gray 4
  static const Color lightHighlight = Color(0xFFE5E5EA); // iOS gray 5

  // iOS Blue (for accents in some areas)
  static const Color accentBlue = Color(0xFF0369A1);
  static const Color accentBlueDark = Color(0xFF0C4A6E);
}
