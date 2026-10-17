import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'spacing.dart';
import 'radius.dart';

class AppTheme {
  AppTheme._();

 
  static ThemeData get light {
    final colorScheme = _lightColorScheme;
    
    return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
      colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.lightBackground,
    
      // Typography
      textTheme: _textTheme(colorScheme),
      
      // AppBar
      appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightOnBackground,
      elevation: 0,
        scrolledUnderElevation: 0,
      centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: AppColors.lightOnBackground,
          letterSpacing: 0,
        ),
        iconTheme: IconThemeData(
          color: AppColors.lightOnBackground,
          size: 24,
        ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    
      // Cards
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      elevation: 0,
        shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circular(AppRadius.card),
          side: BorderSide(
            color: AppColors.lightOutline,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Input fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.inputPaddingHorizontal,
          vertical: AppSpacing.inputPaddingVertical,
        ),
      border: OutlineInputBorder(
          borderRadius: AppRadius.circular(AppRadius.input),
          borderSide: BorderSide(
            color: AppColors.lightOutline,
            width: 1.5,
          ),
      ),
      enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.circular(AppRadius.input),
          borderSide: BorderSide(
            color: AppColors.lightOutline,
            width: 1.5,
          ),
      ),
      focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.circular(AppRadius.input),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2.0,
          ),
      ),
      errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.circular(AppRadius.input),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.circular(AppRadius.input),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.circular(AppRadius.input),
          borderSide: BorderSide(
            color: AppColors.lightOutlineVariant,
            width: 1.0,
          ),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: AppColors.lightOnSurfaceVariant,
          letterSpacing: 0.15,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.lightOnSurfaceVariant,
          letterSpacing: 0.4,
        ),
        floatingLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.primary,
          letterSpacing: 0.4,
        ),
        errorStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: AppColors.error,
          letterSpacing: 0.4,
        ),
        helperStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: AppColors.lightOnSurfaceVariant,
          letterSpacing: 0.4,
        ),
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.buttonPaddingVertical,
          ),
          minimumSize: const Size(88, AppSpacing.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.circular(AppRadius.button),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.4,
            letterSpacing: 0.1,
          ),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.buttonPaddingVertical,
          ),
          minimumSize: const Size(88, AppSpacing.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.circular(AppRadius.button),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.4,
            letterSpacing: 0.1,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
          minimumSize: const Size(88, AppSpacing.minTouchTarget),
        shape: RoundedRectangleBorder(
            borderRadius: AppRadius.circular(AppRadius.button),
        ),
          textStyle: GoogleFonts.inter(
          fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.4,
            letterSpacing: 0.1,
          ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.buttonPaddingVertical,
          ),
          minimumSize: const Size(88, AppSpacing.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.circular(AppRadius.button),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.4,
            letterSpacing: 0.1,
          ),
        ),
      ),
      
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.lightOnSurface,
          minimumSize: const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          iconSize: 24,
        ),
      ),
      
      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circular(AppRadius.fab),
        ),
        iconSize: 24,
      ),
      
      // Bottom Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.primaryContainer,
        elevation: 0,
        height: AppSpacing.bottomNavBarHeight,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.4,
              color: AppColors.primary,
              letterSpacing: 0.5,
            );
          }
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.4,
            color: AppColors.lightOnSurfaceVariant,
            letterSpacing: 0.5,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.primary,
              size: 24,
            );
          }
          return const IconThemeData(
            color: AppColors.lightOnSurfaceVariant,
            size: 24,
          );
        }),
      ),
      
      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSurfaceVariant,
        selectedColor: AppColors.primaryContainer,
        deleteIconColor: AppColors.lightOnSurfaceVariant,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.lightOnSurface,
          letterSpacing: 0.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circular(AppRadius.chip),
          side: BorderSide(
            color: AppColors.lightOutline,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.lightOutlineVariant,
        thickness: 1,
        space: 1,
      ),
      
      // ListTile
      listTileTheme: ListTileThemeData(
        tileColor: AppColors.lightSurface,
        selectedTileColor: AppColors.primaryContainer,
        textColor: AppColors.lightOnSurface,
        iconColor: AppColors.lightOnSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        minLeadingWidth: 24,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circular(AppRadius.card),
        ),
      ),
      
      // Drawer
      drawerTheme: DrawerThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 1,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(),
      ),
      
      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circular(AppRadius.modal),
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: AppColors.lightOnSurface,
          letterSpacing: 0,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.6,
          color: AppColors.lightOnSurfaceVariant,
          letterSpacing: 0.15,
        ),
      ),
      
      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.top(AppRadius.bottomSheet),
        ),
      ),
      
      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightOnSurface,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.6,
          color: AppColors.lightSurface,
          letterSpacing: 0.25,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circular(AppRadius.sm),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Progress indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.lightOutlineVariant,
        circularTrackColor: AppColors.lightOutlineVariant,
      ),
      
      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.lightOutlineVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.lightOutline;
        }),
      ),
      
      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.white),
        side: const BorderSide(
          color: AppColors.lightOutline,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circular(4),
        ),
      ),
      
      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.lightOutline;
        }),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // DARK THEME
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static ThemeData get dark {
    final colorScheme = _darkColorScheme;
    
    return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
      colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.darkBackground,
    
      // Typography
      textTheme: _textTheme(colorScheme),
      
      // AppBar
      appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkOnBackground,
      elevation: 0,
        scrolledUnderElevation: 0,
      centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: AppColors.darkOnBackground,
          letterSpacing: 0,
        ),
        iconTheme: IconThemeData(
          color: AppColors.darkOnBackground,
          size: 24,
        ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    
      // Cards
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 0,
        shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circular(AppRadius.card),
          side: BorderSide(
            color: AppColors.darkOutline,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Input fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.inputPaddingHorizontal,
          vertical: AppSpacing.inputPaddingVertical,
        ),
      border: OutlineInputBorder(
          borderRadius: AppRadius.circular(AppRadius.input),
          borderSide: BorderSide(
            color: AppColors.darkOutline,
            width: 1.5,
          ),
      ),
      enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.circular(AppRadius.input),
          borderSide: BorderSide(
            color: AppColors.darkOutline,
            width: 1.5,
          ),
      ),
      focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.circular(AppRadius.input),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2.0,
          ),
      ),
      errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.circular(AppRadius.input),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.circular(AppRadius.input),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.circular(AppRadius.input),
          borderSide: BorderSide(
            color: AppColors.darkOutlineVariant,
            width: 1.0,
          ),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: AppColors.darkOnSurfaceVariant,
          letterSpacing: 0.15,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.darkOnSurfaceVariant,
          letterSpacing: 0.4,
        ),
        floatingLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.primary,
          letterSpacing: 0.4,
        ),
        errorStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: AppColors.error,
          letterSpacing: 0.4,
        ),
        helperStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: AppColors.darkOnSurfaceVariant,
          letterSpacing: 0.4,
        ),
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.buttonPaddingVertical,
          ),
          minimumSize: const Size(88, AppSpacing.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.circular(AppRadius.button),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.4,
            letterSpacing: 0.1,
          ),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.buttonPaddingVertical,
          ),
          minimumSize: const Size(88, AppSpacing.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.circular(AppRadius.button),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.4,
            letterSpacing: 0.1,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
          minimumSize: const Size(88, AppSpacing.minTouchTarget),
        shape: RoundedRectangleBorder(
            borderRadius: AppRadius.circular(AppRadius.button),
        ),
          textStyle: GoogleFonts.inter(
          fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.4,
            letterSpacing: 0.1,
          ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.buttonPaddingVertical,
          ),
          minimumSize: const Size(88, AppSpacing.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.circular(AppRadius.button),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.4,
            letterSpacing: 0.1,
          ),
        ),
      ),
      
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.darkOnSurface,
          minimumSize: const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          iconSize: 24,
        ),
      ),
      
      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circular(AppRadius.fab),
        ),
        iconSize: 24,
      ),
      
      // Bottom Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.primaryContainerDark,
        elevation: 0,
        height: AppSpacing.bottomNavBarHeight,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.4,
              color: AppColors.primary,
              letterSpacing: 0.5,
            );
          }
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.4,
            color: AppColors.darkOnSurfaceVariant,
            letterSpacing: 0.5,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.primary,
              size: 24,
            );
          }
          return const IconThemeData(
            color: AppColors.darkOnSurfaceVariant,
            size: 24,
          );
        }),
      ),
      
      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        selectedColor: AppColors.primaryContainerDark,
        deleteIconColor: AppColors.darkOnSurfaceVariant,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.darkOnSurface,
          letterSpacing: 0.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circular(AppRadius.chip),
          side: BorderSide(
            color: AppColors.darkOutline,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.darkOutlineVariant,
        thickness: 1,
        space: 1,
      ),
      
      // ListTile
      listTileTheme: ListTileThemeData(
        tileColor: AppColors.darkSurface,
        selectedTileColor: AppColors.primaryContainerDark,
        textColor: AppColors.darkOnSurface,
        iconColor: AppColors.darkOnSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        minLeadingWidth: 24,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circular(AppRadius.card),
        ),
      ),
      
      // Drawer
      drawerTheme: DrawerThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 1,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(),
      ),
      
      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circular(AppRadius.modal),
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: AppColors.darkOnSurface,
          letterSpacing: 0,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.6,
          color: AppColors.darkOnSurfaceVariant,
          letterSpacing: 0.15,
        ),
      ),
      
      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.top(AppRadius.bottomSheet),
        ),
      ),
      
      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkOnSurface,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.6,
          color: AppColors.darkSurface,
          letterSpacing: 0.25,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circular(AppRadius.sm),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Progress indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.darkOutlineVariant,
        circularTrackColor: AppColors.darkOutlineVariant,
      ),
      
      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.darkOutlineVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.darkOutline;
        }),
      ),
      
      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.white),
        side: const BorderSide(
          color: AppColors.darkOutline,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circular(4),
        ),
      ),
      
      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.darkOutline;
        }),
    ),
  );
}

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // COLOR SCHEMES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static ColorScheme get _lightColorScheme => const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.primaryLight,
        onSecondary: AppColors.white,
        secondaryContainer: AppColors.primaryContainer,
        onSecondaryContainer: AppColors.primaryDark,
        tertiary: AppColors.info,
        onTertiary: AppColors.white,
        error: AppColors.error,
        onError: AppColors.white,
        errorContainer: AppColors.errorLight,
        onErrorContainer: AppColors.errorDark,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightOnSurface,
        surfaceContainerHighest: AppColors.lightSurfaceVariant,
        onSurfaceVariant: AppColors.lightOnSurfaceVariant,
        outline: AppColors.lightOutline,
        outlineVariant: AppColors.lightOutlineVariant,
        shadow: AppColors.black,
        scrim: AppColors.black,
        inverseSurface: AppColors.darkSurface,
        onInverseSurface: AppColors.darkOnSurface,
        inversePrimary: AppColors.primaryLight,
      );

  static ColorScheme get _darkColorScheme => const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        primaryContainer: AppColors.primaryContainerDark,
        onPrimaryContainer: AppColors.primaryLight,
        secondary: AppColors.primaryLight,
        onSecondary: AppColors.white,
        secondaryContainer: AppColors.primaryContainerDark,
        onSecondaryContainer: AppColors.primaryLight,
        tertiary: AppColors.info,
        onTertiary: AppColors.white,
        error: AppColors.error,
        onError: AppColors.white,
        errorContainer: AppColors.errorDark,
        onErrorContainer: AppColors.errorLight,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        surfaceContainerHighest: AppColors.darkSurfaceVariant,
        onSurfaceVariant: AppColors.darkOnSurfaceVariant,
        outline: AppColors.darkOutline,
        outlineVariant: AppColors.darkOutlineVariant,
        shadow: AppColors.black,
        scrim: AppColors.black,
        inverseSurface: AppColors.lightSurface,
        onInverseSurface: AppColors.lightOnSurface,
        inversePrimary: AppColors.primaryDark,
      );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TEXT THEME
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static TextTheme _textTheme(ColorScheme colorScheme) {
    return TextTheme(
      // Display
      displayLarge: GoogleFonts.inter(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: colorScheme.onSurface,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: colorScheme.onSurface,
        letterSpacing: -0.25,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: colorScheme.onSurface,
        letterSpacing: 0,
      ),
      
      // Headline
      headlineLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: colorScheme.onSurface,
        letterSpacing: 0,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: colorScheme.onSurface,
        letterSpacing: 0,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: colorScheme.onSurface,
        letterSpacing: 0,
      ),
      
      // Body
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: colorScheme.onSurface,
        letterSpacing: 0.15,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: colorScheme.onSurfaceVariant,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: colorScheme.onSurfaceVariant,
        letterSpacing: 0.4,
      ),
      
      // Label
      labelLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: colorScheme.onPrimary,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: colorScheme.onSurface,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: colorScheme.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );
  }
}
