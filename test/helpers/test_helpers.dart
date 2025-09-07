// File: test/helpers/test_helpers.dart
// Purpose: Common test utilities and helpers for the ELTE Calendar app
// Step: 11.1 - Test Infrastructure Setup

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:elte_calendar/config/localization_config.dart';
import 'package:elte_calendar/config/theme_config.dart';
import 'package:elte_calendar/services/theme_service.dart';
import 'package:elte_calendar/services/language_service.dart';
import 'package:elte_calendar/services/auth_service.dart';
import 'mock_services.dart';

/// Test utilities for setting up widget tests with proper context
class TestHelpers {
  
  /// Initialize Hive for testing
  static Future<void> initializeHiveForTesting() async {
    Hive.init('./test/temp');
    // Register adapters if needed
    // TODO: Register Hive adapters when they're generated
  }

  /// Clean up Hive after testing
  static Future<void> cleanupHiveAfterTesting() async {
    await Hive.close();
  }

  /// Create a basic MaterialApp wrapper for widget testing
  static Widget createTestApp({
    required Widget child,
    Locale? locale,
    ThemeMode? themeMode,
  }) {
    return MaterialApp(
      locale: locale ?? const Locale('hu'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
      ],
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      themeMode: themeMode ?? ThemeMode.light,
      home: child,
    );
  }

  /// Create a test app with providers for service testing
  static Widget createTestAppWithProviders({
    required Widget child,
    ThemeService? themeService,
    LanguageService? languageService,
    AuthService? authService,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: themeService ?? MockThemeService(),
        ),
        ChangeNotifierProvider.value(
          value: languageService ?? MockLanguageService(),
        ),
        ChangeNotifierProvider.value(
          value: authService ?? MockAuthService(),
        ),
      ],
      child: Consumer2<ThemeService, LanguageService>(
        builder: (context, theme, language, _) => MaterialApp(
          locale: language.currentLocale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
          ],
          theme: ThemeConfig.lightTheme,
          darkTheme: ThemeConfig.darkTheme,
          themeMode: theme.themeMode,
          home: child,
        ),
      ),
    );
  }

  /// Create a full app setup for integration testing
  static Widget createFullTestApp({
    required Widget child,
    ThemeService? themeService,
    LanguageService? languageService,
    AuthService? authService,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: themeService ?? MockThemeService(),
        ),
        ChangeNotifierProvider.value(
          value: languageService ?? MockLanguageService(),
        ),
        ChangeNotifierProvider.value(
          value: authService ?? MockAuthService(),
        ),
      ],
      child: Consumer2<ThemeService, LanguageService>(
        builder: (context, theme, language, _) => MaterialApp(
          locale: language.currentLocale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
          ],
          theme: ThemeConfig.lightTheme,
          darkTheme: ThemeConfig.darkTheme,
          themeMode: theme.themeMode,
          home: child,
          routes: {
            '/login': (context) => const Scaffold(body: Text('Login Screen')),
            '/calendar': (context) => const Scaffold(body: Text('Calendar Screen')),
            '/settings': (context) => const Scaffold(body: Text('Settings Screen')),
          },
        ),
      ),
    );
  }

  /// Find widget by type with optional index
  static T findWidgetByType<T extends Widget>(WidgetTester tester, {int index = 0}) {
    final finder = find.byType(T);
    expect(finder, findsAtLeastNWidgets(index + 1));
    return tester.widget<T>(finder.at(index));
  }

  /// Find widget by key
  static T findWidgetByKey<T extends Widget>(WidgetTester tester, Key key) {
    final finder = find.byKey(key);
    expect(finder, findsOneWidget);
    return tester.widget<T>(finder);
  }

  /// Tap widget by type
  static Future<void> tapWidgetByType<T extends Widget>(
    WidgetTester tester, {
    int index = 0,
  }) async {
    final finder = find.byType(T);
    expect(finder, findsAtLeastNWidgets(index + 1));
    await tester.tap(finder.at(index));
    await tester.pumpAndSettle();
  }

  /// Tap widget by key
  static Future<void> tapWidgetByKey(WidgetTester tester, Key key) async {
    final finder = find.byKey(key);
    expect(finder, findsOneWidget);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Tap widget by text
  static Future<void> tapWidgetByText(WidgetTester tester, String text) async {
    final finder = find.text(text);
    expect(finder, findsOneWidget);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Enter text in a text field
  static Future<void> enterTextInField(
    WidgetTester tester,
    Key key,
    String text,
  ) async {
    final finder = find.byKey(key);
    expect(finder, findsOneWidget);
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// Verify text exists
  static void expectTextExists(String text) {
    expect(find.text(text), findsOneWidget);
  }

  /// Verify widget exists by type
  static void expectWidgetExists<T extends Widget>() {
    expect(find.byType(T), findsOneWidget);
  }

  /// Verify widget exists by key
  static void expectWidgetExistsByKey(Key key) {
    expect(find.byKey(key), findsOneWidget);
  }

  /// Verify widget does not exist
  static void expectWidgetNotExists<T extends Widget>() {
    expect(find.byType(T), findsNothing);
  }

  /// Wait for a condition to be true
  static Future<void> waitForCondition(
    WidgetTester tester,
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 5),
    Duration pollInterval = const Duration(milliseconds: 100),
  }) async {
    final stopwatch = Stopwatch()..start();
    
    while (!condition() && stopwatch.elapsed < timeout) {
      await tester.pump(pollInterval);
    }
    
    if (!condition()) {
      throw Exception('Condition not met within timeout: $timeout');
    }
  }

  /// Pump until animations are complete
  static Future<void> pumpUntilSettled(WidgetTester tester) async {
    await tester.pumpAndSettle();
  }

  /// Create a mock box for Hive testing
  static Box<T> createMockBox<T>() {
    return MockBox<T>();
  }

  /// Test constants
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'testpassword123';
  static const String testDisplayName = 'Test User';
  
  /// Common test timeouts
  static const Duration shortTimeout = Duration(milliseconds: 500);
  static const Duration mediumTimeout = Duration(seconds: 2);
  static const Duration longTimeout = Duration(seconds: 5);
}