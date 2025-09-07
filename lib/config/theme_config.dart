// File: lib/config/theme_config.dart
// Purpose: Theme configuration with specified color palette
// Step: 1.1 - Initialize Flutter Project

import 'package:flutter/material.dart';

/// Theme configuration class containing light and dark theme definitions
/// Uses ONLY the specified color palette from the technical specification
class ThemeConfig {
  // Specified Color Palette (Use ONLY these colors)
  static const Color primaryDarkBlue = Color(0xFF03284F);
  static const Color goldAccent = Color(0xFFC6A882);
  static const Color lightBackground = Color(0xFFF4F4F4);
  static const Color darkTextElements = Color(0xFF060605);

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color scheme using specified palette
      colorScheme: const ColorScheme.light(
        primary: primaryDarkBlue,
        secondary: goldAccent,
        surface: lightBackground,
        onPrimary: lightBackground,
        onSecondary: darkTextElements,
        onSurface: darkTextElements,
        tertiary: goldAccent,
        onTertiary: darkTextElements,
        surfaceVariant: lightBackground,
        onSurfaceVariant: darkTextElements,
        outline: goldAccent,
        error: Color(0xFFBA1A1A),
        onError: lightBackground,
      ),
      
      // Scaffold background
      scaffoldBackgroundColor: lightBackground,
      
      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDarkBlue,
        foregroundColor: lightBackground,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: lightBackground,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
        iconTheme: IconThemeData(
          color: lightBackground,
        ),
        actionsIconTheme: IconThemeData(
          color: lightBackground,
        ),
      ),
      
      // Card theme for course cards and containers
      cardTheme: const CardThemeData(
        color: lightBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDarkBlue,
          foregroundColor: lightBackground,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDarkBlue,
          side: const BorderSide(color: primaryDarkBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryDarkBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      
      // Input decoration theme for forms
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryDarkBlue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryDarkBlue.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryDarkBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        labelStyle: const TextStyle(color: primaryDarkBlue),
        hintStyle: TextStyle(color: darkTextElements.withOpacity(0.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // Text themes
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: darkTextElements,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: darkTextElements,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        displaySmall: TextStyle(
          color: darkTextElements,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: primaryDarkBlue,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: darkTextElements,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: darkTextElements,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: darkTextElements,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: darkTextElements,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: darkTextElements,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: TextStyle(
          color: primaryDarkBlue,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: primaryDarkBlue,
        size: 24,
      ),
      
      // FloatingActionButton theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: goldAccent,
        foregroundColor: darkTextElements,
        elevation: 4,
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: primaryDarkBlue.withOpacity(0.2),
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color scheme using specified palette for dark mode
      colorScheme: const ColorScheme.dark(
        primary: primaryDarkBlue,
        secondary: goldAccent,
        surface: darkTextElements,
        onPrimary: lightBackground,
        onSecondary: lightBackground,
        onSurface: lightBackground,
        tertiary: goldAccent,
        onTertiary: lightBackground,
        surfaceVariant: primaryDarkBlue,
        onSurfaceVariant: lightBackground,
        outline: goldAccent,
        error: Color(0xFFFF5449),
        onError: darkTextElements,
      ),
      
      // Scaffold background
      scaffoldBackgroundColor: darkTextElements,
      
      // AppBar theme for dark mode
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDarkBlue,
        foregroundColor: lightBackground,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: lightBackground,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
        iconTheme: IconThemeData(
          color: lightBackground,
        ),
      ),
      
      // Card theme for dark mode
      cardTheme: const CardThemeData(
        color: primaryDarkBlue,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      
      // Button themes for dark mode
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldAccent,
          foregroundColor: darkTextElements,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: goldAccent,
          side: const BorderSide(color: goldAccent, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: goldAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      
      // Input decoration theme for dark mode
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: goldAccent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: goldAccent.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: goldAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        labelStyle: const TextStyle(color: goldAccent),
        hintStyle: TextStyle(color: lightBackground.withOpacity(0.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // Text themes for dark mode
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: lightBackground,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: lightBackground,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        displaySmall: TextStyle(
          color: lightBackground,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: goldAccent,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: lightBackground,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: lightBackground,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: lightBackground,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: lightBackground,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: lightBackground,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: TextStyle(
          color: goldAccent,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Icon theme for dark mode
      iconTheme: const IconThemeData(
        color: goldAccent,
        size: 24,
      ),
      
      // FloatingActionButton theme for dark mode
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: goldAccent,
        foregroundColor: darkTextElements,
        elevation: 4,
      ),
      
      // Divider theme for dark mode
      dividerTheme: DividerThemeData(
        color: goldAccent.withOpacity(0.2),
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Course type color mapping for calendar display
  static const Map<String, Color> courseTypeColors = {
    'Előadás': primaryDarkBlue,     // Lecture - Primary dark blue
    'Gyakorlat': goldAccent,        // Practice - Gold accent  
    'Labor': Color(0xFF4A5C73),     // Lab - Blend of both colors
  };

  /// Get color for course type with fallback
  static Color getCourseTypeColor(String courseType) {
    return courseTypeColors[courseType] ?? primaryDarkBlue;
  }

  /// Calendar-specific theme extensions
  static const Color currentTimeIndicator = Color(0xFFFF4444);  // Red for current time line
  static const Color currentDayHighlight = Color(0xFFFFF3CD);   // Light yellow for current day
  static const Color weekendBackground = Color(0xFFF8F9FA);     // Subtle gray for weekends
}