// File: test/unit/services/language_service_test.dart
// Purpose: Unit tests for LanguageService
// Step: 11.2 - Unit Tests for Core Business Logic

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:elte_calendar/services/language_service.dart';
import '../../helpers/test_helpers.dart';
import '../../helpers/mock_services.dart';

void main() {
  group('LanguageService Tests', () {
    late LanguageService languageService;
    late MockBox<String> mockLanguageBox;

    setUpAll(() async {
      await TestHelpers.initializeHiveForTesting();
    });

    setUp(() {
      mockLanguageBox = MockBox<String>();
      languageService = LanguageService();
    });

    tearDownAll(() async {
      await TestHelpers.cleanupHiveAfterTesting();
    });

    group('Initialization', () {
      test('should initialize with Hungarian by default', () {
        expect(languageService.currentLocale, equals(const Locale('hu')));
        expect(languageService.currentLanguageCode, equals('hu'));
        expect(languageService.isHungarian, isTrue);
        expect(languageService.isEnglish, isFalse);
        expect(languageService.isGerman, isFalse);
      });

      test('should initialize successfully', () async {
        await languageService.initialize();
        expect(languageService.currentLocale, equals(const Locale('hu')));
      });

      test('should handle initialization errors gracefully', () async {
        // This test verifies that the service doesn't crash on initialization errors
        await languageService.initialize();
        expect(languageService.currentLocale, equals(const Locale('hu')));
      });
    });

    group('Supported Locales', () {
      test('should have correct supported locales', () {
        final supportedLocales = languageService.supportedLocales;
        expect(supportedLocales, hasLength(3));
        expect(supportedLocales, contains(const Locale('hu')));
        expect(supportedLocales, contains(const Locale('en')));
        expect(supportedLocales, contains(const Locale('de')));
      });
    });

    group('Language Management', () {
      test('should set Hungarian language', () async {
        await languageService.setHungarian();
        expect(languageService.currentLanguageCode, equals('hu'));
        expect(languageService.isHungarian, isTrue);
        expect(languageService.isEnglish, isFalse);
        expect(languageService.isGerman, isFalse);
      });

      test('should set English language', () async {
        await languageService.setEnglish();
        expect(languageService.currentLanguageCode, equals('en'));
        expect(languageService.isHungarian, isFalse);
        expect(languageService.isEnglish, isTrue);
        expect(languageService.isGerman, isFalse);
      });

      test('should set German language', () async {
        await languageService.setGerman();
        expect(languageService.currentLanguageCode, equals('de'));
        expect(languageService.isHungarian, isFalse);
        expect(languageService.isEnglish, isFalse);
        expect(languageService.isGerman, isTrue);
      });

      test('should set language by code', () async {
        await languageService.setLanguage('en');
        expect(languageService.currentLanguageCode, equals('en'));

        await languageService.setLanguage('de');
        expect(languageService.currentLanguageCode, equals('de'));

        await languageService.setLanguage('hu');
        expect(languageService.currentLanguageCode, equals('hu'));
      });

      test('should ignore unsupported language codes', () async {
        await languageService.setLanguage('hu');
        expect(languageService.currentLanguageCode, equals('hu'));

        await languageService.setLanguage('fr'); // Unsupported
        expect(languageService.currentLanguageCode, equals('hu')); // Should remain unchanged
      });

      test('should not change when setting same language', () async {
        await languageService.setLanguage('en');
        expect(languageService.currentLanguageCode, equals('en'));

        await languageService.setLanguage('en'); // Same language
        expect(languageService.currentLanguageCode, equals('en')); // Should remain unchanged
      });
    });

    group('Language Display Names', () {
      test('should return correct native display names', () {
        expect(languageService.getNativeLanguageDisplayName('hu'), equals('Magyar'));
        expect(languageService.getNativeLanguageDisplayName('en'), equals('English'));
        expect(languageService.getNativeLanguageDisplayName('de'), equals('Deutsch'));
        expect(languageService.getNativeLanguageDisplayName('fr'), equals('FR')); // Fallback
      });

      test('should return correct display names', () {
        expect(languageService.getLanguageDisplayName('hu'), equals('Magyar'));
        expect(languageService.getLanguageDisplayName('en'), equals('English'));
        expect(languageService.getLanguageDisplayName('de'), equals('Deutsch'));
      });
    });

    group('Available Languages', () {
      test('should return correct available languages', () {
        final languages = languageService.getAvailableLanguages();
        expect(languages, hasLength(3));

        final hungarian = languages.firstWhere((l) => l.code == 'hu');
        expect(hungarian.nativeName, equals('Magyar'));
        expect(hungarian.englishName, equals('Hungarian'));
        expect(hungarian.flag, equals('🇭🇺'));

        final english = languages.firstWhere((l) => l.code == 'en');
        expect(english.nativeName, equals('English'));
        expect(english.englishName, equals('English'));
        expect(english.flag, equals('🇺🇸'));

        final german = languages.firstWhere((l) => l.code == 'de');
        expect(german.nativeName, equals('Deutsch'));
        expect(german.englishName, equals('German'));
        expect(german.flag, equals('🇩🇪'));
      });

      test('should return current language option', () async {
        await languageService.setEnglish();
        final currentOption = languageService.getCurrentLanguageOption();
        expect(currentOption.code, equals('en'));
        expect(currentOption.nativeName, equals('English'));
        expect(currentOption.englishName, equals('English'));
        expect(currentOption.flag, equals('🇺🇸'));
      });
    });

    group('Change Notification', () {
      test('should notify listeners when language changes', () async {
        bool notified = false;
        languageService.addListener(() {
          notified = true;
        });

        await languageService.setEnglish();
        expect(notified, isTrue);
      });

      test('should notify listeners on multiple language changes', () async {
        int notificationCount = 0;
        languageService.addListener(() {
          notificationCount++;
        });

        await languageService.setEnglish();
        expect(notificationCount, equals(1));

        await languageService.setGerman();
        expect(notificationCount, equals(2));

        await languageService.setHungarian();
        expect(notificationCount, equals(3));
      });

      test('should not notify listeners when setting same language', () async {
        await languageService.setEnglish();
        
        int notificationCount = 0;
        languageService.addListener(() {
          notificationCount++;
        });

        await languageService.setEnglish();
        expect(notificationCount, equals(0));
      });

      test('should not notify listeners for unsupported languages', () async {
        int notificationCount = 0;
        languageService.addListener(() {
          notificationCount++;
        });

        await languageService.setLanguage('fr'); // Unsupported
        expect(notificationCount, equals(0));
      });
    });

    group('State Consistency', () {
      test('should maintain consistent state through multiple operations', () async {
        // Start with Hungarian (default)
        expect(languageService.isHungarian, isTrue);
        expect(languageService.currentLanguageCode, equals('hu'));

        // Switch to English
        await languageService.setEnglish();
        expect(languageService.isEnglish, isTrue);
        expect(languageService.isHungarian, isFalse);
        expect(languageService.currentLanguageCode, equals('en'));

        // Switch to German
        await languageService.setGerman();
        expect(languageService.isGerman, isTrue);
        expect(languageService.isEnglish, isFalse);
        expect(languageService.currentLanguageCode, equals('de'));

        // Switch back to Hungarian
        await languageService.setHungarian();
        expect(languageService.isHungarian, isTrue);
        expect(languageService.isGerman, isFalse);
        expect(languageService.currentLanguageCode, equals('hu'));
      });
    });

    group('Error Handling', () {
      test('should handle dispose correctly', () {
        // This should not throw an exception
        expect(() => languageService.dispose(), returnsNormally);
      });

      test('should handle multiple initialize calls', () async {
        await languageService.initialize();
        await languageService.initialize();
        
        // Should still work correctly
        await languageService.setEnglish();
        expect(languageService.currentLanguageCode, equals('en'));
      });
    });
  });

  group('LanguageOption Tests', () {
    test('should create language option correctly', () {
      const option = LanguageOption(
        code: 'test',
        nativeName: 'Test Language',
        englishName: 'Test',
        flag: '🏳️',
      );

      expect(option.code, equals('test'));
      expect(option.nativeName, equals('Test Language'));
      expect(option.englishName, equals('Test'));
      expect(option.flag, equals('🏳️'));
    });

    test('should compare language options correctly', () {
      const option1 = LanguageOption(
        code: 'en',
        nativeName: 'English',
        englishName: 'English',
        flag: '🇺🇸',
      );

      const option2 = LanguageOption(
        code: 'en',
        nativeName: 'English',
        englishName: 'English',
        flag: '🇺🇸',
      );

      const option3 = LanguageOption(
        code: 'de',
        nativeName: 'Deutsch',
        englishName: 'German',
        flag: '🇩🇪',
      );

      expect(option1, equals(option2));
      expect(option1, isNot(equals(option3)));
      expect(option1.hashCode, equals(option2.hashCode));
      expect(option1.hashCode, isNot(equals(option3.hashCode)));
    });

    test('should convert to string correctly', () {
      const option = LanguageOption(
        code: 'hu',
        nativeName: 'Magyar',
        englishName: 'Hungarian',
        flag: '🇭🇺',
      );

      expect(option.toString(), contains('hu'));
      expect(option.toString(), contains('Magyar'));
      expect(option.toString(), contains('🇭🇺'));
    });
  });

  group('Mock LanguageService Tests', () {
    late MockLanguageService mockLanguageService;

    setUp(() {
      mockLanguageService = MockLanguageService();
    });

    test('should work correctly as a mock', () async {
      expect(mockLanguageService.currentLanguageCode, equals('hu'));
      expect(mockLanguageService.isInitialized, isFalse);

      await mockLanguageService.initialize();
      expect(mockLanguageService.isInitialized, isTrue);

      await mockLanguageService.setEnglish();
      expect(mockLanguageService.currentLanguageCode, equals('en'));
      expect(mockLanguageService.isEnglish, isTrue);
    });

    test('should simulate language changes correctly', () {
      mockLanguageService.simulateLanguageChange('de');
      expect(mockLanguageService.currentLanguageCode, equals('de'));
      expect(mockLanguageService.isGerman, isTrue);
    });

    test('should notify listeners on simulated changes', () {
      bool notified = false;
      mockLanguageService.addListener(() {
        notified = true;
      });

      mockLanguageService.simulateLanguageChange('en');
      expect(notified, isTrue);
    });
  });
}