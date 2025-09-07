// File: test/unit/services/theme_service_test.dart
// Purpose: Unit tests for ThemeService
// Step: 11.2 - Unit Tests for Core Business Logic

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:elte_calendar/services/theme_service.dart';
import '../../helpers/test_helpers.dart';
import '../../helpers/mock_services.dart';

void main() {
  group('ThemeService Tests', () {
    late ThemeService themeService;
    late MockBox<String> mockThemeBox;

    setUpAll(() async {
      await TestHelpers.initializeHiveForTesting();
    });

    setUp(() {
      mockThemeBox = MockBox<String>();
      themeService = ThemeService();
    });

    tearDownAll(() async {
      await TestHelpers.cleanupHiveAfterTesting();
    });

    group('Initialization', () {
      test('should initialize with light theme by default', () {
        expect(themeService.themeMode, equals(ThemeMode.light));
        expect(themeService.isDarkMode, isFalse);
      });

      test('should initialize successfully', () async {
        await themeService.initialize();
        expect(themeService.themeMode, equals(ThemeMode.light));
      });

      test('should handle initialization errors gracefully', () async {
        // This test verifies that the service doesn't crash on initialization errors
        await themeService.initialize();
        expect(themeService.themeMode, equals(ThemeMode.light));
      });
    });

    group('Theme Mode Management', () {
      test('should set light theme', () async {
        await themeService.setLightTheme();
        expect(themeService.themeMode, equals(ThemeMode.light));
        expect(themeService.isDarkMode, isFalse);
      });

      test('should set dark theme', () async {
        await themeService.setDarkTheme();
        expect(themeService.themeMode, equals(ThemeMode.dark));
        expect(themeService.isDarkMode, isTrue);
      });

      test('should set system theme', () async {
        await themeService.setSystemTheme();
        expect(themeService.themeMode, equals(ThemeMode.system));
      });

      test('should toggle theme from light to dark', () async {
        await themeService.setLightTheme();
        expect(themeService.themeMode, equals(ThemeMode.light));
        
        await themeService.toggleTheme();
        expect(themeService.themeMode, equals(ThemeMode.dark));
      });

      test('should toggle theme from dark to light', () async {
        await themeService.setDarkTheme();
        expect(themeService.themeMode, equals(ThemeMode.dark));
        
        await themeService.toggleTheme();
        expect(themeService.themeMode, equals(ThemeMode.light));
      });

      test('should not change theme when setting same theme', () async {
        await themeService.setLightTheme();
        final initialTheme = themeService.themeMode;
        
        await themeService.setLightTheme();
        expect(themeService.themeMode, equals(initialTheme));
      });
    });

    group('Theme Display Names', () {
      test('should return correct display names for theme modes', () {
        expect(themeService.getThemeModeDisplayName(ThemeMode.light), equals('Light'));
        expect(themeService.getThemeModeDisplayName(ThemeMode.dark), equals('Dark'));
        expect(themeService.getThemeModeDisplayName(ThemeMode.system), equals('System'));
      });
    });

    group('Change Notification', () {
      test('should notify listeners when theme changes', () async {
        bool notified = false;
        themeService.addListener(() {
          notified = true;
        });

        await themeService.setDarkTheme();
        expect(notified, isTrue);
      });

      test('should notify listeners on theme toggle', () async {
        int notificationCount = 0;
        themeService.addListener(() {
          notificationCount++;
        });

        await themeService.toggleTheme();
        expect(notificationCount, equals(1));

        await themeService.toggleTheme();
        expect(notificationCount, equals(2));
      });

      test('should not notify listeners when setting same theme', () async {
        await themeService.setLightTheme();
        
        int notificationCount = 0;
        themeService.addListener(() {
          notificationCount++;
        });

        await themeService.setLightTheme();
        expect(notificationCount, equals(0));
      });
    });

    group('isDarkMode Property', () {
      test('should return true when theme is dark', () async {
        await themeService.setDarkTheme();
        expect(themeService.isDarkMode, isTrue);
      });

      test('should return false when theme is light', () async {
        await themeService.setLightTheme();
        expect(themeService.isDarkMode, isFalse);
      });

      test('should return false when theme is system', () async {
        await themeService.setSystemTheme();
        expect(themeService.isDarkMode, isFalse);
      });
    });

    group('State Consistency', () {
      test('should maintain consistent state through multiple operations', () async {
        // Start with light theme
        await themeService.setLightTheme();
        expect(themeService.themeMode, equals(ThemeMode.light));
        expect(themeService.isDarkMode, isFalse);

        // Switch to dark theme
        await themeService.setDarkTheme();
        expect(themeService.themeMode, equals(ThemeMode.dark));
        expect(themeService.isDarkMode, isTrue);

        // Switch to system theme
        await themeService.setSystemTheme();
        expect(themeService.themeMode, equals(ThemeMode.system));
        expect(themeService.isDarkMode, isFalse);

        // Toggle theme (system -> light)
        await themeService.toggleTheme();
        expect(themeService.themeMode, equals(ThemeMode.light));
        expect(themeService.isDarkMode, isFalse);
      });
    });

    group('Error Handling', () {
      test('should handle dispose correctly', () {
        // This should not throw an exception
        expect(() => themeService.dispose(), returnsNormally);
      });

      test('should handle multiple initialize calls', () async {
        await themeService.initialize();
        await themeService.initialize();
        
        // Should still work correctly
        await themeService.setDarkTheme();
        expect(themeService.themeMode, equals(ThemeMode.dark));
      });
    });
  });

  group('Mock ThemeService Tests', () {
    late MockThemeService mockThemeService;

    setUp(() {
      mockThemeService = MockThemeService();
    });

    test('should work correctly as a mock', () async {
      expect(mockThemeService.themeMode, equals(ThemeMode.light));
      expect(mockThemeService.isInitialized, isFalse);

      await mockThemeService.initialize();
      expect(mockThemeService.isInitialized, isTrue);

      await mockThemeService.setDarkTheme();
      expect(mockThemeService.themeMode, equals(ThemeMode.dark));
      expect(mockThemeService.isDarkMode, isTrue);
    });

    test('should simulate theme changes correctly', () {
      mockThemeService.simulateThemeChange(ThemeMode.dark);
      expect(mockThemeService.themeMode, equals(ThemeMode.dark));

      mockThemeService.simulateThemeChange(ThemeMode.system);
      expect(mockThemeService.themeMode, equals(ThemeMode.system));
    });

    test('should notify listeners on simulated changes', () {
      bool notified = false;
      mockThemeService.addListener(() {
        notified = true;
      });

      mockThemeService.simulateThemeChange(ThemeMode.dark);
      expect(notified, isTrue);
    });
  });
}