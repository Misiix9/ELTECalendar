// File: lib/services/language_service.dart
// Purpose: Language management service for switching between Hungarian, English, and German
// Step: 10.4 - Dynamic Language Switching Implementation

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../config/localization_config.dart';

/// Service for managing language settings and preferences
class LanguageService extends ChangeNotifier {
  static const String _languageBoxName = 'language_settings';
  static const String _languageCodeKey = 'language_code';
  
  Box<String>? _languageBox;
  Locale _currentLocale = const Locale('hu'); // Default to Hungarian
  
  /// Current locale
  Locale get currentLocale => _currentLocale;
  
  /// Current language code
  String get currentLanguageCode => _currentLocale.languageCode;
  
  /// Whether the current language is Hungarian
  bool get isHungarian => _currentLocale.languageCode == 'hu';
  
  /// Whether the current language is English
  bool get isEnglish => _currentLocale.languageCode == 'en';
  
  /// Whether the current language is German
  bool get isGerman => _currentLocale.languageCode == 'de';
  
  /// Get all supported locales
  List<Locale> get supportedLocales => AppLocalizations.supportedLocales;
  
  /// Initialize the language service
  Future<void> initialize() async {
    try {
      _languageBox = await Hive.openBox<String>(_languageBoxName);
      
      // Load saved language preference
      final savedLanguageCode = _languageBox?.get(_languageCodeKey);
      if (savedLanguageCode != null) {
        _currentLocale = _parseLocale(savedLanguageCode);
      } else {
        // Default to Hungarian if no preference is saved
        _currentLocale = const Locale('hu');
      }
      
      debugPrint('LanguageService: Initialized with locale: ${_currentLocale.languageCode}');
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to initialize language service: $e');
      // Use default Hungarian language if initialization fails
      _currentLocale = const Locale('hu');
    }
  }
  
  /// Set language and save preference
  Future<void> setLanguage(String languageCode) async {
    if (_currentLocale.languageCode == languageCode) return;
    
    // Validate language code is supported
    if (!_isLanguageSupported(languageCode)) {
      debugPrint('LanguageService: Unsupported language code: $languageCode');
      return;
    }
    
    _currentLocale = Locale(languageCode);
    
    try {
      await _languageBox?.put(_languageCodeKey, languageCode);
      debugPrint('LanguageService: Language changed to: $languageCode');
    } catch (e) {
      debugPrint('Failed to save language preference: $e');
    }
    
    notifyListeners();
  }
  
  /// Set Hungarian language
  Future<void> setHungarian() async {
    await setLanguage('hu');
  }
  
  /// Set English language
  Future<void> setEnglish() async {
    await setLanguage('en');
  }
  
  /// Set German language
  Future<void> setGerman() async {
    await setLanguage('de');
  }
  
  /// Parse locale from language code string
  Locale _parseLocale(String languageCode) {
    if (_isLanguageSupported(languageCode)) {
      return Locale(languageCode);
    }
    return const Locale('hu'); // Default fallback
  }
  
  /// Check if language code is supported
  bool _isLanguageSupported(String languageCode) {
    return AppLocalizations.supportedLocales
        .any((locale) => locale.languageCode == languageCode);
  }
  
  /// Get language display name in current language
  String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'hu':
        return _getLocalizedLanguageName('hungarian');
      case 'en':
        return _getLocalizedLanguageName('english');
      case 'de':
        return _getLocalizedLanguageName('german');
      default:
        return languageCode.toUpperCase();
    }
  }
  
  /// Get language display name in its native form
  String getNativeLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'hu':
        return 'Magyar';
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      default:
        return languageCode.toUpperCase();
    }
  }
  
  /// Get localized language name (requires localization strings to be added)
  String _getLocalizedLanguageName(String languageKey) {
    // For now, return native names
    switch (languageKey) {
      case 'hungarian':
        return 'Magyar';
      case 'english':
        return 'English';
      case 'german':
        return 'Deutsch';
      default:
        return languageKey;
    }
  }
  
  /// Get all available languages with their native names
  List<LanguageOption> getAvailableLanguages() {
    return [
      LanguageOption(
        code: 'hu',
        nativeName: 'Magyar',
        englishName: 'Hungarian',
        flag: '🇭🇺',
      ),
      LanguageOption(
        code: 'en',
        nativeName: 'English',
        englishName: 'English',
        flag: '🇺🇸',
      ),
      LanguageOption(
        code: 'de',
        nativeName: 'Deutsch',
        englishName: 'German',
        flag: '🇩🇪',
      ),
    ];
  }
  
  /// Get current language option
  LanguageOption getCurrentLanguageOption() {
    return getAvailableLanguages()
        .firstWhere((option) => option.code == _currentLocale.languageCode);
  }
  
  /// Dispose of resources
  @override
  void dispose() {
    _languageBox?.close();
    super.dispose();
  }
  
  @override
  String toString() {
    return 'LanguageService{currentLocale: $_currentLocale}';
  }
}

/// Language option data class
class LanguageOption {
  final String code;
  final String nativeName;
  final String englishName;
  final String flag;
  
  const LanguageOption({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.flag,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageOption &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
  
  @override
  String toString() {
    return 'LanguageOption{code: $code, nativeName: $nativeName, flag: $flag}';
  }
}