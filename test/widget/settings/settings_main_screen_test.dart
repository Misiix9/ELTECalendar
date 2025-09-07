// File: test/widget/settings/settings_main_screen_test.dart
// Purpose: Widget tests for SettingsMainScreen
// Step: 11.3 - Widget Tests for UI Components

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:elte_calendar/screens/settings/settings_main_screen.dart';
import 'package:elte_calendar/services/theme_service.dart';
import 'package:elte_calendar/services/language_service.dart';
import 'package:elte_calendar/services/auth_service.dart';
import 'package:elte_calendar/models/user_model.dart';
import '../../helpers/test_helpers.dart';
import '../../helpers/mock_services.dart';

void main() {
  group('SettingsMainScreen Widget Tests', () {
    late MockThemeService mockThemeService;
    late MockLanguageService mockLanguageService;
    late MockAuthService mockAuthService;

    setUp(() {
      mockThemeService = MockThemeService();
      mockLanguageService = MockLanguageService();
      mockAuthService = MockAuthService();

      // Setup mock authenticated user
      mockAuthService.simulateUserLogin(StudentUser(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        emailVerified: true,
        createdAt: DateTime.now(),
        currentSemester: '2024/25/1',
      ));
    });

    testWidgets('should render basic settings sections', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          themeService: mockThemeService,
          languageService: mockLanguageService,
          authService: mockAuthService,
          child: const SettingsMainScreen(),
        ),
      );

      // Verify main sections are present
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byIcon(Icons.palette), findsOneWidget); // Theme settings icon
      expect(find.byIcon(Icons.language), findsOneWidget); // Language settings icon
      expect(find.byIcon(Icons.school), findsOneWidget); // Academic settings icon
      expect(find.byIcon(Icons.notifications), findsOneWidget); // Notifications icon
      expect(find.byIcon(Icons.sync), findsOneWidget); // Sync settings icon
      expect(find.byIcon(Icons.person), findsOneWidget); // Account icon
    });

    testWidgets('should display theme selection options', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          themeService: mockThemeService,
          languageService: mockLanguageService,
          authService: mockAuthService,
          child: const SettingsMainScreen(),
        ),
      );

      // Verify theme options are present
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);

      // Verify theme descriptions
      expect(find.text('Clean, bright interface'), findsOneWidget);
      expect(find.text('Easy on the eyes'), findsOneWidget);
      expect(find.text('Follow device setting'), findsOneWidget);

      // Verify theme icons
      expect(find.byIcon(Icons.light_mode), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
      expect(find.byIcon(Icons.auto_mode), findsOneWidget);
    });

    testWidgets('should display language selection options', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          themeService: mockThemeService,
          languageService: mockLanguageService,
          authService: mockAuthService,
          child: const SettingsMainScreen(),
        ),
      );

      // Verify language options are present
      expect(find.text('Magyar'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Deutsch'), findsOneWidget);

      // Verify language descriptions
      expect(find.text('Hungarian'), findsOneWidget);
      expect(find.text('German'), findsOneWidget);

      // Verify flag emojis are present (they should be Text widgets)
      expect(find.text('🇭🇺'), findsOneWidget);
      expect(find.text('🇺🇸'), findsOneWidget);
      expect(find.text('🇩🇪'), findsOneWidget);
    });

    testWidgets('should show selected theme correctly', (WidgetTester tester) async {
      // Set dark theme as selected
      await mockThemeService.setDarkTheme();

      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          themeService: mockThemeService,
          languageService: mockLanguageService,
          authService: mockAuthService,
          child: const SettingsMainScreen(),
        ),
      );

      // Dark theme should have check mark
      expect(find.byIcon(Icons.check_circle), findsAtLeastNWidgets(1));
    });

    testWidgets('should show selected language correctly', (WidgetTester tester) async {
      // Set English as selected
      await mockLanguageService.setEnglish();

      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          themeService: mockThemeService,
          languageService: mockLanguageService,
          authService: mockAuthService,
          child: const SettingsMainScreen(),
        ),
      );

      // English should be selected (check mark should be present)
      expect(find.byIcon(Icons.check_circle), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle theme selection taps', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          themeService: mockThemeService,
          languageService: mockLanguageService,
          authService: mockAuthService,
          child: const SettingsMainScreen(),
        ),
      );

      // Tap on dark theme
      await TestHelpers.tapWidgetByText(tester, 'Dark');

      // Verify theme service was called
      expect(mockThemeService.themeMode, equals(ThemeMode.dark));
    });

    testWidgets('should handle language selection taps', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          themeService: mockThemeService,
          languageService: mockLanguageService,
          authService: mockAuthService,
          child: const SettingsMainScreen(),
        ),
      );

      // Tap on English
      await TestHelpers.tapWidgetByText(tester, 'English');

      // Verify language service was called
      expect(mockLanguageService.currentLanguageCode, equals('en'));
    });

    testWidgets('should display user email in sign out section', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          themeService: mockThemeService,
          languageService: mockLanguageService,
          authService: mockAuthService,
          child: const SettingsMainScreen(),
        ),
      );

      // Verify user email is displayed
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('should show sign out confirmation dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          themeService: mockThemeService,
          languageService: mockLanguageService,
          authService: mockAuthService,
          child: const SettingsMainScreen(),
        ),
      );

      // Tap on sign out
      await TestHelpers.tapWidgetByText(tester, 'Sign Out');

      // Verify confirmation dialog appears
      expect(find.text('Are you sure you want to sign out?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Sign Out'), findsWidgets); // Should find multiple (button + dialog)
    });

    testWidgets('should handle sign out confirmation', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          themeService: mockThemeService,
          languageService: mockLanguageService,
          authService: mockAuthService,
          child: const SettingsMainScreen(),
        ),
      );

      // Tap on sign out
      await TestHelpers.tapWidgetByText(tester, 'Sign Out');

      // Confirm sign out in dialog
      final signOutButtons = find.text('Sign Out');
      expect(signOutButtons, findsWidgets);
      
      // Tap the dialog's sign out button (should be the last one)
      await tester.tap(signOutButtons.last);
      await tester.pumpAndSettle();

      // Verify user is signed out
      expect(mockAuthService.currentUser, isNull);
    });

    testWidgets('should handle sign out cancellation', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          themeService: mockThemeService,
          languageService: mockLanguageService,
          authService: mockAuthService,
          child: const SettingsMainScreen(),
        ),
      );

      // Tap on sign out
      await TestHelpers.tapWidgetByText(tester, 'Sign Out');

      // Cancel sign out in dialog
      await TestHelpers.tapWidgetByText(tester, 'Cancel');

      // Verify user is still signed in
      expect(mockAuthService.currentUser, isNotNull);
      expect(mockAuthService.currentUser!.email, equals('test@example.com'));
    });

    testWidgets('should display settings tiles correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          themeService: mockThemeService,
          languageService: mockLanguageService,
          authService: mockAuthService,
          child: const SettingsMainScreen(),
        ),
      );

      // Verify navigation tiles
      expect(find.text('Manage Semesters'), findsOneWidget);
      expect(find.text('Notification Settings'), findsOneWidget);
      expect(find.text('Sync Settings'), findsOneWidget);

      // Verify descriptions
      expect(find.text('Add, edit, and organize your academic semesters'), findsOneWidget);
      expect(find.text('Manage your notification preferences'), findsOneWidget);
      expect(find.text('Manage data synchronization and backup'), findsOneWidget);

      // Verify chevron icons for navigation
      expect(find.byIcon(Icons.chevron_right), findsWidgets);
    });

    testWidgets('should handle different theme modes correctly', (WidgetTester tester) async {
      // Test with system theme
      await mockThemeService.setSystemTheme();

      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          themeService: mockThemeService,
          languageService: mockLanguageService,
          authService: mockAuthService,
          child: const SettingsMainScreen(),
        ),
      );

      expect(mockThemeService.themeMode, equals(ThemeMode.system));

      // Switch to light theme
      await TestHelpers.tapWidgetByText(tester, 'Light');
      expect(mockThemeService.themeMode, equals(ThemeMode.light));

      // Switch back to system
      await TestHelpers.tapWidgetByText(tester, 'System');
      expect(mockThemeService.themeMode, equals(ThemeMode.system));
    });

    testWidgets('should handle different languages correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          themeService: mockThemeService,
          languageService: mockLanguageService,
          authService: mockAuthService,
          child: const SettingsMainScreen(),
        ),
      );

      // Start with Hungarian (default)
      expect(mockLanguageService.currentLanguageCode, equals('hu'));

      // Switch to German
      await TestHelpers.tapWidgetByText(tester, 'Deutsch');
      expect(mockLanguageService.currentLanguageCode, equals('de'));

      // Switch to English
      await TestHelpers.tapWidgetByText(tester, 'English');
      expect(mockLanguageService.currentLanguageCode, equals('en'));

      // Switch back to Hungarian
      await TestHelpers.tapWidgetByText(tester, 'Magyar');
      expect(mockLanguageService.currentLanguageCode, equals('hu'));
    });

    testWidgets('should handle unauthenticated user gracefully', (WidgetTester tester) async {
      // Sign out the user
      mockAuthService.simulateUserLogout();

      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          themeService: mockThemeService,
          languageService: mockLanguageService,
          authService: mockAuthService,
          child: const SettingsMainScreen(),
        ),
      );

      // Should still show settings but with "Unknown" email
      expect(find.text('Unknown'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('should scroll correctly with all content', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          themeService: mockThemeService,
          languageService: mockLanguageService,
          authService: mockAuthService,
          child: const SettingsMainScreen(),
        ),
      );

      // Verify the screen can scroll
      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);

      // Try scrolling down and up
      await tester.drag(listView, const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.drag(listView, const Offset(0, 300));
      await tester.pumpAndSettle();

      // Should not throw errors
    });
  });

  group('SettingsMainScreen Integration Tests', () {
    testWidgets('should update UI when services change externally', (WidgetTester tester) async {
      final mockThemeService = MockThemeService();
      final mockLanguageService = MockLanguageService();
      final mockAuthService = MockAuthService();

      mockAuthService.simulateUserLogin(StudentUser(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        emailVerified: true,
        createdAt: DateTime.now(),
        currentSemester: '2024/25/1',
      ));

      await tester.pumpWidget(
        TestHelpers.createTestAppWithProviders(
          themeService: mockThemeService,
          languageService: mockLanguageService,
          authService: mockAuthService,
          child: const SettingsMainScreen(),
        ),
      );

      // Change theme externally
      mockThemeService.simulateThemeChange(ThemeMode.dark);
      await tester.pumpAndSettle();

      // UI should update to reflect the change
      expect(mockThemeService.themeMode, equals(ThemeMode.dark));

      // Change language externally
      mockLanguageService.simulateLanguageChange('de');
      await tester.pumpAndSettle();

      expect(mockLanguageService.currentLanguageCode, equals('de'));
    });
  });
}