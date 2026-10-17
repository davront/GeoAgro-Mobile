import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'app_theme.dart';

/// Theme mode storage key
const String _themeModeKey = 'theme_mode';

/// Theme provider for managing app theme
/// Default: Dark theme
class AppThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark; // Default to dark theme

  AppThemeProvider() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  /// Get current theme data based on theme mode and system brightness
  ThemeData getTheme(Brightness brightness) {
    if (_themeMode == ThemeMode.dark || 
        (_themeMode == ThemeMode.system && brightness == Brightness.dark)) {
      return AppTheme.dark;
    }
    return AppTheme.light;
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _saveThemeMode();
  }

  /// Load theme mode from storage
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_themeModeKey);
      if (savedMode != null) {
        switch (savedMode) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'system':
          default:
            _themeMode = ThemeMode.system;
            break;
        }
        notifyListeners();
      }
    } catch (e) {
      developer.log('Error loading theme mode: $e');
    }
  }

  /// Save theme mode to storage
  Future<void> _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String modeString;
      switch (_themeMode) {
        case ThemeMode.light:
          modeString = 'light';
          break;
        case ThemeMode.dark:
          modeString = 'dark';
          break;
        case ThemeMode.system:
          modeString = 'system';
          break;
      }
      await prefs.setString(_themeModeKey, modeString);
    } catch (e) {
      developer.log('Error saving theme mode: $e');
    }
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      // If system, toggle to light
      await setThemeMode(ThemeMode.light);
    }
  }
}

