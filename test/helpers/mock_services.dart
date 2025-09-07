// File: test/helpers/mock_services.dart
// Purpose: Mock services for testing the ELTE Calendar app
// Step: 11.1 - Mock Services Implementation

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:elte_calendar/services/theme_service.dart';
import 'package:elte_calendar/services/language_service.dart';
import 'package:elte_calendar/services/auth_service.dart';
import 'package:elte_calendar/models/user_model.dart';

/// Mock implementation of ThemeService for testing
class MockThemeService extends ChangeNotifier implements ThemeService {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isInitialized = false;

  @override
  ThemeMode get themeMode => _themeMode;

  @override
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
    notifyListeners();
  }

  @override
  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;
    _themeMode = themeMode;
    notifyListeners();
  }

  @override
  Future<void> toggleTheme() async {
    final newThemeMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await setThemeMode(newThemeMode);
  }

  @override
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }

  @override
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }

  @override
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  @override
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

  // Test helper methods
  void simulateThemeChange(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }
}

/// Mock implementation of LanguageService for testing
class MockLanguageService extends ChangeNotifier implements LanguageService {
  Locale _currentLocale = const Locale('hu');
  bool _isInitialized = false;

  @override
  Locale get currentLocale => _currentLocale;

  @override
  String get currentLanguageCode => _currentLocale.languageCode;

  @override
  bool get isHungarian => _currentLocale.languageCode == 'hu';

  @override
  bool get isEnglish => _currentLocale.languageCode == 'en';

  @override
  bool get isGerman => _currentLocale.languageCode == 'de';

  @override
  List<Locale> get supportedLocales => const [
    Locale('hu'),
    Locale('en'),
    Locale('de'),
  ];

  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
    notifyListeners();
  }

  @override
  Future<void> setLanguage(String languageCode) async {
    if (_currentLocale.languageCode == languageCode) return;
    if (!_isLanguageSupported(languageCode)) return;
    
    _currentLocale = Locale(languageCode);
    notifyListeners();
  }

  @override
  Future<void> setHungarian() async {
    await setLanguage('hu');
  }

  @override
  Future<void> setEnglish() async {
    await setLanguage('en');
  }

  @override
  Future<void> setGerman() async {
    await setLanguage('de');
  }

  bool _isLanguageSupported(String languageCode) {
    return supportedLocales.any((locale) => locale.languageCode == languageCode);
  }

  @override
  String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'hu': return 'Magyar';
      case 'en': return 'English';
      case 'de': return 'Deutsch';
      default: return languageCode.toUpperCase();
    }
  }

  @override
  String getNativeLanguageDisplayName(String languageCode) {
    return getLanguageDisplayName(languageCode);
  }

  @override
  List<LanguageOption> getAvailableLanguages() {
    return [
      const LanguageOption(
        code: 'hu',
        nativeName: 'Magyar',
        englishName: 'Hungarian',
        flag: '🇭🇺',
      ),
      const LanguageOption(
        code: 'en',
        nativeName: 'English',
        englishName: 'English',
        flag: '🇺🇸',
      ),
      const LanguageOption(
        code: 'de',
        nativeName: 'Deutsch',
        englishName: 'German',
        flag: '🇩🇪',
      ),
    ];
  }

  @override
  LanguageOption getCurrentLanguageOption() {
    return getAvailableLanguages()
        .firstWhere((option) => option.code == _currentLocale.languageCode);
  }

  // Test helper methods
  void simulateLanguageChange(String languageCode) {
    _currentLocale = Locale(languageCode);
    notifyListeners();
  }
}

/// Mock implementation of AuthService for testing
class MockAuthService extends ChangeNotifier {
  StudentUser? _currentUser;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  StudentUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasUser => _currentUser != null;

  Future<void> initialize() async {
    _isInitialized = true;
    notifyListeners();
  }

  Future<StudentUser?> signInWithEmailAndPassword(String email, String password) async {
    _setLoading(true);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock successful login
    if (email == 'test@example.com' && password == 'testpassword123') {
      _currentUser = StudentUser(
        uid: 'test-uid-123',
        email: email,
        displayName: 'Test User',
        emailVerified: true,
        createdAt: DateTime.now(),
        currentSemester: '2024/25/1',
      );
      _errorMessage = null;
    } else {
      _errorMessage = 'Invalid email or password';
      _currentUser = null;
    }
    
    _setLoading(false);
    return _currentUser;
  }

  Future<StudentUser?> createUserWithEmailAndPassword(String email, String password) async {
    _setLoading(true);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock successful registration
    _currentUser = StudentUser(
      uid: 'new-test-uid-123',
      email: email,
      displayName: 'New User',
      emailVerified: false,
      createdAt: DateTime.now(),
      currentSemester: '2024/25/1',
    );
    _errorMessage = null;
    
    _setLoading(false);
    return _currentUser;
  }

  Future<void> signOut() async {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    _errorMessage = null;
    _setLoading(false);
  }

  Future<void> sendEmailVerification() async {
    _setLoading(true);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    _setLoading(false);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Test helper methods
  void simulateUserLogin(StudentUser user) {
    _currentUser = user;
    _errorMessage = null;
    notifyListeners();
  }

  void simulateUserLogout() {
    _currentUser = null;
    notifyListeners();
  }

  void simulateError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Additional mock methods 
  Future<StudentUser?> signInWithGoogle() async {
    return signInWithEmailAndPassword('google@example.com', 'password');
  }

  Future<StudentUser?> signInWithApple() async {
    return signInWithEmailAndPassword('apple@example.com', 'password');
  }
}

/// Mock implementation of Hive Box for testing
class MockBox<T> implements Box<T> {
  final Map<String, T> _data = {};
  bool _isOpen = true;

  @override
  Future<int> add(T value) async {
    final key = _data.length;
    _data[key.toString()] = value;
    return key;
  }

  @override
  Future<int> clear() async {
    final count = _data.length;
    _data.clear();
    return count;
  }

  @override
  Future<void> close() async {
    _isOpen = false;
  }

  @override
  Future<void> delete(dynamic key) async {
    _data.remove(key.toString());
  }

  @override
  T? get(dynamic key, {T? defaultValue}) {
    return _data[key.toString()] ?? defaultValue;
  }

  @override
  bool get isOpen => _isOpen;

  @override
  Iterable get keys => _data.keys;

  @override
  int get length => _data.length;

  @override
  String get name => 'mock_box';

  @override
  String? get path => null;

  @override
  Future<void> put(dynamic key, T value) async {
    _data[key.toString()] = value;
  }

  @override
  Iterable<T> get values => _data.values;

  // Additional required properties
  @override
  bool get isEmpty => _data.isEmpty;

  @override
  bool get isNotEmpty => _data.isNotEmpty;

  @override
  dynamic keyAt(int index) {
    return keys.elementAt(index);
  }

  @override
  Future<void> flush() async {
    // Mock implementation - no-op
  }

  @override
  Iterable<T> valuesBetween({dynamic startKey, dynamic endKey}) {
    // Simple mock implementation
    return values;
  }

  // Implement other required methods with minimal functionality
  @override
  Future<Iterable<int>> addAll(Iterable<T> values) async {
    final keys = <int>[];
    for (final value in values) {
      final key = await add(value);
      keys.add(key);
    }
    return keys;
  }

  @override
  Future<Iterable<int>> addAllWithKeys(Map<dynamic, T> entries) async {
    final keys = <int>[];
    for (final entry in entries.entries) {
      await put(entry.key, entry.value);
      keys.add(entry.key as int);
    }
    return keys;
  }

  @override
  T? getAt(int index) {
    final key = keys.elementAt(index);
    return _data[key.toString()];
  }

  @override
  Map<dynamic, T> toMap() => Map.from(_data);

  @override
  bool containsKey(dynamic key) => _data.containsKey(key.toString());

  @override
  Future<void> deleteAll(Iterable keys) async {
    for (final key in keys) {
      await delete(key);
    }
  }

  @override
  Future<void> deleteAt(int index) async {
    final key = keys.elementAt(index);
    await delete(key);
  }

  @override
  Future<void> putAll(Map entries) async {
    for (final entry in entries.entries) {
      await put(entry.key, entry.value as T);
    }
  }

  @override
  Future<void> putAt(int index, T value) async {
    final key = keys.elementAt(index);
    await put(key, value);
  }

  // Stream and advanced functionality - minimal implementation
  @override
  Stream<BoxEvent> watch({dynamic key}) {
    throw UnimplementedError('MockBox.watch not implemented');
  }

  @override
  Future<void> compact() async {}

  @override
  Future<void> deleteFromDisk() async {}

  @override
  bool get lazy => false;
}