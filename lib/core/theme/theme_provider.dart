/// Theme provider for managing app theme
///
/// This provider manages the current theme mode and notifies listeners
/// when the theme changes. It supports light, dark, and system themes.
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme provider class
class ThemeProvider extends ChangeNotifier {
  /// Current theme mode
  ThemeMode _themeMode = ThemeMode.system;

  /// SharedPreferences key for theme mode
  static const String _themeKey = 'theme_mode';

  /// Get current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Get current theme mode as string
  String get themeModeString {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Check if current theme is light
  bool get isLight => _themeMode == ThemeMode.light;

  /// Check if current theme is dark
  bool get isDark => _themeMode == ThemeMode.dark;

  /// Check if current theme is system
  bool get isSystem => _themeMode == ThemeMode.system;

  /// Initialize theme provider
  Future<void> initialize() async {
    await _loadThemeFromStorage();
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await _saveThemeToStorage();
      notifyListeners();
    }
  }

  /// Set theme mode from string
  Future<void> setThemeModeFromString(String theme) async {
    ThemeMode mode;
    switch (theme) {
      case 'light':
        mode = ThemeMode.light;
      case 'dark':
        mode = ThemeMode.dark;
      case 'system':
      default:
        mode = ThemeMode.system;
    }
    await setThemeMode(mode);
  }

  /// Toggle between light and dark themes
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  /// Load theme from storage
  Future<void> _loadThemeFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString(_themeKey);
      if (themeString != null) {
        await setThemeModeFromString(themeString);
      }
    } catch (e) {
      // If loading fails, use system theme as default
      _themeMode = ThemeMode.system;
    }
  }

  /// Save theme to storage
  Future<void> _saveThemeToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, themeModeString);
    } catch (e) {
      // If saving fails, continue without error
      // Theme will still work for current session
    }
  }

  /// Get theme display name
  String getThemeDisplayName(String theme) {
    switch (theme) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      case 'system':
        return 'System';
      default:
        return 'System';
    }
  }
}
