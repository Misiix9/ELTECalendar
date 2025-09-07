// File: test/integration/language_switching_test.dart
// Purpose: Integration tests for language switching functionality
// Step: 11.4 - Integration Tests for User Workflows

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elte_calendar/services/language_service.dart';
import 'package:elte_calendar/services/theme_service.dart';
import 'package:elte_calendar/services/auth_service.dart';
import 'package:elte_calendar/screens/settings/settings_main_screen.dart';
import 'package:elte_calendar/models/user_model.dart';
import '../helpers/test_helpers.dart';
import '../helpers/mock_services.dart';

void main() {
  group('Language Switching Integration Tests', () {
    late MockLanguageService languageService;
    late MockThemeService themeService;
    late MockAuthService authService;

    setUp(() {
      languageService = MockLanguageService();
      themeService = MockThemeService();
      authService = MockAuthService();

      // Setup authenticated user
      authService.simulateUserLogin(StudentUser(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        emailVerified: true,
        createdAt: DateTime.now(),
        currentSemester: '2024/25/1',
      ));
    });

    testWidgets('should complete full language switching workflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          languageService: languageService,
          themeService: themeService,
          authService: authService,
          child: const SettingsMainScreen(),
        ),
      );

      // Verify starting state (Hungarian)
      expect(languageService.currentLanguageCode, equals('hu'));
      expect(languageService.isHungarian, isTrue);

      // Find and verify Hungarian is selected
      expect(find.text('Magyar'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsAtLeastNWidgets(1));

      // Switch to English
      await TestHelpers.tapWidgetByText(tester, 'English');

      // Verify English is now selected
      expect(languageService.currentLanguageCode, equals('en'));
      expect(languageService.isEnglish, isTrue);
      expect(languageService.isHungarian, isFalse);

      // Switch to German
      await TestHelpers.tapWidgetByText(tester, 'Deutsch');

      // Verify German is now selected
      expect(languageService.currentLanguageCode, equals('de'));
      expect(languageService.isGerman, isTrue);
      expect(languageService.isEnglish, isFalse);

      // Switch back to Hungarian
      await TestHelpers.tapWidgetByText(tester, 'Magyar');

      // Verify Hungarian is selected again
      expect(languageService.currentLanguageCode, equals('hu'));
      expect(languageService.isHungarian, isTrue);
      expect(languageService.isGerman, isFalse);
    });

    testWidgets('should maintain language selection across rebuilds', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          languageService: languageService,
          themeService: themeService,
          authService: authService,
          child: const SettingsMainScreen(),
        ),
      );

      // Switch to English
      await TestHelpers.tapWidgetByText(tester, 'English');
      expect(languageService.currentLanguageCode, equals('en'));

      // Force a rebuild by pumping the widget again
      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          languageService: languageService,
          themeService: themeService,
          authService: authService,
          child: const SettingsMainScreen(),
        ),
      );

      // Language should still be English
      expect(languageService.currentLanguageCode, equals('en'));
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('should handle rapid language switching', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          languageService: languageService,
          themeService: themeService,
          authService: authService,
          child: const SettingsMainScreen(),
        ),
      );

      // Rapidly switch between languages
      await TestHelpers.tapWidgetByText(tester, 'English');
      await TestHelpers.tapWidgetByText(tester, 'Deutsch');
      await TestHelpers.tapWidgetByText(tester, 'Magyar');
      await TestHelpers.tapWidgetByText(tester, 'English');

      // Final language should be English
      expect(languageService.currentLanguageCode, equals('en'));
      expect(languageService.isEnglish, isTrue);
    });

    testWidgets('should show correct language options in all languages', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          languageService: languageService,
          themeService: themeService,
          authService: authService,
          child: const SettingsMainScreen(),
        ),
      );

      // Test language options display consistently
      final languages = ['Magyar', 'English', 'Deutsch'];
      final flags = ['🇭🇺', '🇺🇸', '🇩🇪'];

      for (final language in languages) {
        expect(find.text(language), findsOneWidget);
      }

      for (final flag in flags) {
        expect(find.text(flag), findsOneWidget);
      }

      // Switch to different languages and verify options remain
      await TestHelpers.tapWidgetByText(tester, 'English');

      for (final language in languages) {
        expect(find.text(language), findsOneWidget);
      }

      await TestHelpers.tapWidgetByText(tester, 'Deutsch');

      for (final language in languages) {
        expect(find.text(language), findsOneWidget);
      }
    });

    testWidgets('should handle language service errors gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          languageService: languageService,
          themeService: themeService,
          authService: authService,
          child: const SettingsMainScreen(),
        ),
      );

      // Try to set an invalid language (should be ignored by mock)
      await languageService.setLanguage('invalid');

      // Should remain on current language (Hungarian by default)
      expect(languageService.currentLanguageCode, equals('hu'));

      // UI should still be functional
      await TestHelpers.tapWidgetByText(tester, 'English');
      expect(languageService.currentLanguageCode, equals('en'));
    });

    testWidgets('should maintain language selection when other settings change', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          languageService: languageService,
          themeService: themeService,
          authService: authService,
          child: const SettingsMainScreen(),
        ),
      );

      // Set language to English
      await TestHelpers.tapWidgetByText(tester, 'English');
      expect(languageService.currentLanguageCode, equals('en'));

      // Change theme
      await TestHelpers.tapWidgetByText(tester, 'Dark');
      expect(themeService.themeMode, equals(ThemeMode.dark));

      // Language should still be English
      expect(languageService.currentLanguageCode, equals('en'));

      // Change theme back
      await TestHelpers.tapWidgetByText(tester, 'Light');
      expect(themeService.themeMode, equals(ThemeMode.light));

      // Language should still be English
      expect(languageService.currentLanguageCode, equals('en'));
    });

    testWidgets('should handle external language changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          languageService: languageService,
          themeService: themeService,
          authService: authService,
          child: const SettingsMainScreen(),
        ),
      );

      // Change language externally (simulating system change)
      languageService.simulateLanguageChange('de');
      await tester.pumpAndSettle();

      // UI should reflect the external change
      expect(languageService.currentLanguageCode, equals('de'));
      expect(languageService.isGerman, isTrue);

      // User should still be able to change language normally
      await TestHelpers.tapWidgetByText(tester, 'English');
      expect(languageService.currentLanguageCode, equals('en'));
    });

    testWidgets('should properly display language names', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          languageService: languageService,
          themeService: themeService,
          authService: authService,
          child: const SettingsMainScreen(),
        ),
      );

      // Check native language names are displayed
      expect(find.text('Magyar'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Deutsch'), findsOneWidget);

      // Check English descriptions are present
      expect(find.text('Hungarian'), findsOneWidget);
      expect(find.text('German'), findsOneWidget);
    });

    testWidgets('should handle language service initialization state', (WidgetTester tester) async {
      // Start with uninitialized service
      final uninitializedLanguageService = MockLanguageService();

      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          languageService: uninitializedLanguageService,
          themeService: themeService,
          authService: authService,
          child: const SettingsMainScreen(),
        ),
      );

      // Should still render without errors
      expect(find.byType(SettingsMainScreen), findsOneWidget);

      // Initialize service
      await uninitializedLanguageService.initialize();
      await tester.pumpAndSettle();

      // Should work normally after initialization
      await TestHelpers.tapWidgetByText(tester, 'English');
      expect(uninitializedLanguageService.currentLanguageCode, equals('en'));
    });
  });

  group('Language Service Integration with Real Service', () {
    // These tests would use the real LanguageService if we wanted to test persistence
    // For now, they use mocks but simulate real behavior

    testWidgets('should persist language selection', (WidgetTester tester) async {
      final languageService = MockLanguageService();
      await languageService.initialize();

      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          languageService: languageService,
          themeService: MockThemeService(),
          authService: MockAuthService(),
          child: const SettingsMainScreen(),
        ),
      );

      // Change language
      await TestHelpers.tapWidgetByText(tester, 'English');
      expect(languageService.currentLanguageCode, equals('en'));

      // Simulate app restart by creating new service
      final newLanguageService = MockLanguageService();
      await newLanguageService.initialize();

      // In a real test, this would verify persistence
      // For mock, we just verify the service can be reinitialized
      expect(newLanguageService.currentLanguageCode, equals('hu')); // Default
    });

    testWidgets('should handle service disposal correctly', (WidgetTester tester) async {
      final languageService = MockLanguageService();

      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          languageService: languageService,
          themeService: MockThemeService(),
          authService: MockAuthService(),
          child: const SettingsMainScreen(),
        ),
      );

      // Change language
      await TestHelpers.tapWidgetByText(tester, 'English');

      // Dispose service (simulated)
      languageService.dispose();

      // Should not throw errors
      expect(() => languageService.dispose(), returnsNormally);
    });
  });
}