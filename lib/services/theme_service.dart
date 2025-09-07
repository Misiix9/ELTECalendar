// File: lib/services/theme_service.dart
// Purpose: Theme management service for switching between light and dark modes
// Step: Theme Management System Implementation

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// Service for managing theme settings and preferences
class ThemeService extends ChangeNotifier {
  static const String _themeBoxName = 'theme_settings';
  static const String _themeModeKey = 'theme_mode';
  
  Box<String>? _themeBox;
  ThemeMode _themeMode = ThemeMode.light; // Default to light mode
  
  /// Current theme mode
  ThemeMode get themeMode => _themeMode;
  
  /// Whether the current theme is dark
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  /// Initialize the theme service
  Future<void> initialize() async {
    try {
      _themeBox = await Hive.openBox<String>(_themeBoxName);
      
      // Load saved theme mode
      final savedThemeMode = _themeBox?.get(_themeModeKey);
      if (savedThemeMode != null) {
        _themeMode = _parseThemeMode(savedThemeMode);
      } else {
        // Default to light mode if no preference is saved
        _themeMode = ThemeMode.light;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to initialize theme service: $e');
      // Use default light theme if initialization fails
      _themeMode = ThemeMode.light;
    }
  }
  
  /// Set theme mode and save preference
  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;
    
    _themeMode = themeMode;
    
    try {
      await _themeBox?.put(_themeModeKey, _themeMode.name);
    } catch (e) {
      debugPrint('Failed to save theme preference: $e');
    }
    
    notifyListeners();
  }
  
  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newThemeMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await setThemeMode(newThemeMode);
  }
  
  /// Set light theme
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }
  
  /// Set dark theme
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }
  
  /// Set system theme (follows device setting)
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }
  
  /// Parse theme mode from string
  ThemeMode _parseThemeMode(String themeModeString) {
    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }
  
  /// Get theme mode display name
  String getThemeModeDisplayName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
  
  /// Dispose of resources
  @override
  void dispose() {
    _themeBox?.close();
    super.dispose();
  }
}
