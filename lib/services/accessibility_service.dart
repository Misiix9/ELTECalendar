// File: lib/services/accessibility_service.dart
// Purpose: Accessibility service for improved app accessibility
// Step: 12.7 - Final UI Polish and Accessibility Improvements

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app accessibility features
class AccessibilityService extends ChangeNotifier {
  static final AccessibilityService _instance = AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  static const String _logTag = 'AccessibilityService';
  
  // Preferences keys
  static const String _highContrastKey = 'accessibility_high_contrast';
  static const String _largeTextKey = 'accessibility_large_text';
  static const String _reducedMotionKey = 'accessibility_reduced_motion';
  static const String _screenReaderKey = 'accessibility_screen_reader';
  static const String _hapticFeedbackKey = 'accessibility_haptic_feedback';
  
  // State
  SharedPreferences? _prefs;
  bool _isInitialized = false;
  
  // Accessibility settings
  bool _highContrastEnabled = false;
  bool _largeTextEnabled = false;
  bool _reducedMotionEnabled = false;
  bool _screenReaderOptimized = false;
  bool _hapticFeedbackEnabled = true;
  
  // System accessibility detection
  late MediaQueryData _currentMediaQuery;
  
  /// Getters
  bool get isInitialized => _isInitialized;
  bool get highContrastEnabled => _highContrastEnabled;
  bool get largeTextEnabled => _largeTextEnabled;
  bool get reducedMotionEnabled => _reducedMotionEnabled;
  bool get screenReaderOptimized => _screenReaderOptimized;
  bool get hapticFeedbackEnabled => _hapticFeedbackEnabled;
  
  /// Get current text scale factor
  double get textScaleFactor {
    if (!_isInitialized) return 1.0;
    
    double systemScale = _currentMediaQuery.textScaleFactor;
    if (_largeTextEnabled) {
      systemScale = (systemScale * 1.3).clamp(1.0, 3.0);
    }
    return systemScale;
  }
  
  /// Get animation duration (reduced if motion is disabled)
  Duration getAnimationDuration(Duration original) {
    if (_reducedMotionEnabled) {
      return Duration(milliseconds: (original.inMilliseconds * 0.1).round());
    }
    return original;
  }
  
  /// Initialize accessibility service
  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;
    
    try {
      debugPrint('$_logTag: Initializing accessibility service...');
      
      _prefs = await SharedPreferences.getInstance();
      _updateMediaQuery(MediaQuery.of(context));
      
      // Load saved preferences
      await _loadPreferences();
      
      // Detect system accessibility features
      _detectSystemAccessibilityFeatures();
      
      _isInitialized = true;
      debugPrint('$_logTag: Accessibility service initialized');
      
    } catch (e) {
      debugPrint('$_logTag: Failed to initialize: $e');
    }
  }
  
  /// Update media query data
  void updateMediaQuery(MediaQueryData mediaQuery) {
    _updateMediaQuery(mediaQuery);
    notifyListeners();
  }
  
  void _updateMediaQuery(MediaQueryData mediaQuery) {
    _currentMediaQuery = mediaQuery;
  }
  
  /// Load accessibility preferences
  Future<void> _loadPreferences() async {
    if (_prefs == null) return;
    
    _highContrastEnabled = _prefs!.getBool(_highContrastKey) ?? false;
    _largeTextEnabled = _prefs!.getBool(_largeTextKey) ?? false;
    _reducedMotionEnabled = _prefs!.getBool(_reducedMotionKey) ?? false;
    _screenReaderOptimized = _prefs!.getBool(_screenReaderKey) ?? false;
    _hapticFeedbackEnabled = _prefs!.getBool(_hapticFeedbackKey) ?? true;
  }
  
  /// Detect system accessibility features
  void _detectSystemAccessibilityFeatures() {
    if (!_isInitialized) return;
    
    // Check for high contrast
    final bool systemHighContrast = _currentMediaQuery.highContrast;
    if (systemHighContrast && !_highContrastEnabled) {
      _setHighContrast(true, savePreference: false);
    }
    
    // Check for reduced motion
    final bool systemReducedMotion = _currentMediaQuery.disableAnimations;
    if (systemReducedMotion && !_reducedMotionEnabled) {
      _setReducedMotion(true, savePreference: false);
    }
    
    // Check for large text
    final double systemTextScale = _currentMediaQuery.textScaleFactor;
    if (systemTextScale > 1.2 && !_largeTextEnabled) {
      _setLargeText(true, savePreference: false);
    }
    
    // Check for screen reader
    final bool systemBoldText = _currentMediaQuery.boldText;
    if (systemBoldText && !_screenReaderOptimized) {
      _setScreenReaderOptimized(true, savePreference: false);
    }
  }
  
  /// Enable/disable high contrast mode
  Future<void> setHighContrast(bool enabled) async {
    await _setHighContrast(enabled, savePreference: true);
  }
  
  Future<void> _setHighContrast(bool enabled, {bool savePreference = true}) async {
    if (_highContrastEnabled == enabled) return;
    
    _highContrastEnabled = enabled;
    
    if (savePreference && _prefs != null) {
      await _prefs!.setBool(_highContrastKey, enabled);
    }
    
    debugPrint('$_logTag: High contrast ${enabled ? 'enabled' : 'disabled'}');
    notifyListeners();
  }
  
  /// Enable/disable large text mode
  Future<void> setLargeText(bool enabled) async {
    await _setLargeText(enabled, savePreference: true);
  }
  
  Future<void> _setLargeText(bool enabled, {bool savePreference = true}) async {
    if (_largeTextEnabled == enabled) return;
    
    _largeTextEnabled = enabled;
    
    if (savePreference && _prefs != null) {
      await _prefs!.setBool(_largeTextKey, enabled);
    }
    
    debugPrint('$_logTag: Large text ${enabled ? 'enabled' : 'disabled'}');
    notifyListeners();
  }
  
  /// Enable/disable reduced motion
  Future<void> setReducedMotion(bool enabled) async {
    await _setReducedMotion(enabled, savePreference: true);
  }
  
  Future<void> _setReducedMotion(bool enabled, {bool savePreference = true}) async {
    if (_reducedMotionEnabled == enabled) return;
    
    _reducedMotionEnabled = enabled;
    
    if (savePreference && _prefs != null) {
      await _prefs!.setBool(_reducedMotionKey, enabled);
    }
    
    debugPrint('$_logTag: Reduced motion ${enabled ? 'enabled' : 'disabled'}');
    notifyListeners();
  }
  
  /// Enable/disable screen reader optimization
  Future<void> setScreenReaderOptimized(bool enabled) async {
    await _setScreenReaderOptimized(enabled, savePreference: true);
  }
  
  Future<void> _setScreenReaderOptimized(bool enabled, {bool savePreference = true}) async {
    if (_screenReaderOptimized == enabled) return;
    
    _screenReaderOptimized = enabled;
    
    if (savePreference && _prefs != null) {
      await _prefs!.setBool(_screenReaderKey, enabled);
    }
    
    debugPrint('$_logTag: Screen reader optimization ${enabled ? 'enabled' : 'disabled'}');
    notifyListeners();
  }
  
  /// Enable/disable haptic feedback
  Future<void> setHapticFeedback(bool enabled) async {
    if (_hapticFeedbackEnabled == enabled) return;
    
    _hapticFeedbackEnabled = enabled;
    
    if (_prefs != null) {
      await _prefs!.setBool(_hapticFeedbackKey, enabled);
    }
    
    debugPrint('$_logTag: Haptic feedback ${enabled ? 'enabled' : 'disabled'}');
    notifyListeners();
  }
  
  /// Provide haptic feedback
  void provideFeedback(HapticFeedbackType type) {
    if (!_hapticFeedbackEnabled) return;
    
    switch (type) {
      case HapticFeedbackType.lightImpact:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.mediumImpact:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavyImpact:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selectionClick:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.vibrate:
        HapticFeedback.vibrate();
        break;
    }
  }
  
  /// Get color scheme based on accessibility settings
  ColorScheme getAccessibleColorScheme(ColorScheme original, bool isDarkMode) {
    if (!_highContrastEnabled) return original;
    
    // High contrast color adjustments
    if (isDarkMode) {
      return original.copyWith(
        primary: Colors.white,
        onPrimary: Colors.black,
        secondary: Colors.yellow,
        onSecondary: Colors.black,
        surface: Colors.black,
        onSurface: Colors.white,
        background: Colors.black,
        onBackground: Colors.white,
        error: Colors.red.shade300,
        onError: Colors.black,
      );
    } else {
      return original.copyWith(
        primary: Colors.black,
        onPrimary: Colors.white,
        secondary: Colors.blue.shade900,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
        background: Colors.white,
        onBackground: Colors.black,
        error: Colors.red.shade900,
        onError: Colors.white,
      );
    }
  }
  
  /// Get text theme with accessibility adjustments
  TextTheme getAccessibleTextTheme(TextTheme original) {
    if (!_largeTextEnabled && !_screenReaderOptimized) return original;
    
    double scaleFactor = 1.0;
    FontWeight fontWeight = FontWeight.normal;
    
    if (_largeTextEnabled) {
      scaleFactor = 1.3;
    }
    
    if (_screenReaderOptimized) {
      fontWeight = FontWeight.w600;
    }
    
    return original.copyWith(
      displayLarge: original.displayLarge?.copyWith(
        fontSize: (original.displayLarge?.fontSize ?? 32) * scaleFactor,
        fontWeight: fontWeight,
        height: 1.4,
      ),
      displayMedium: original.displayMedium?.copyWith(
        fontSize: (original.displayMedium?.fontSize ?? 28) * scaleFactor,
        fontWeight: fontWeight,
        height: 1.4,
      ),
      displaySmall: original.displaySmall?.copyWith(
        fontSize: (original.displaySmall?.fontSize ?? 24) * scaleFactor,
        fontWeight: fontWeight,
        height: 1.4,
      ),
      headlineLarge: original.headlineLarge?.copyWith(
        fontSize: (original.headlineLarge?.fontSize ?? 22) * scaleFactor,
        fontWeight: fontWeight,
        height: 1.4,
      ),
      headlineMedium: original.headlineMedium?.copyWith(
        fontSize: (original.headlineMedium?.fontSize ?? 20) * scaleFactor,
        fontWeight: fontWeight,
        height: 1.4,
      ),
      headlineSmall: original.headlineSmall?.copyWith(
        fontSize: (original.headlineSmall?.fontSize ?? 18) * scaleFactor,
        fontWeight: fontWeight,
        height: 1.4,
      ),
      bodyLarge: original.bodyLarge?.copyWith(
        fontSize: (original.bodyLarge?.fontSize ?? 16) * scaleFactor,
        fontWeight: fontWeight,
        height: 1.5,
      ),
      bodyMedium: original.bodyMedium?.copyWith(
        fontSize: (original.bodyMedium?.fontSize ?? 14) * scaleFactor,
        fontWeight: fontWeight,
        height: 1.5,
      ),
      bodySmall: original.bodySmall?.copyWith(
        fontSize: (original.bodySmall?.fontSize ?? 12) * scaleFactor,
        fontWeight: fontWeight,
        height: 1.5,
      ),
      labelLarge: original.labelLarge?.copyWith(
        fontSize: (original.labelLarge?.fontSize ?? 14) * scaleFactor,
        fontWeight: fontWeight,
        height: 1.4,
      ),
      labelMedium: original.labelMedium?.copyWith(
        fontSize: (original.labelMedium?.fontSize ?? 12) * scaleFactor,
        fontWeight: fontWeight,
        height: 1.4,
      ),
      labelSmall: original.labelSmall?.copyWith(
        fontSize: (original.labelSmall?.fontSize ?? 10) * scaleFactor,
        fontWeight: fontWeight,
        height: 1.4,
      ),
    );
  }
  
  /// Check if accessibility features are enabled
  bool hasAccessibilityFeaturesEnabled() {
    return _highContrastEnabled ||
           _largeTextEnabled ||
           _reducedMotionEnabled ||
           _screenReaderOptimized;
  }
  
  /// Get accessibility summary
  Map<String, bool> getAccessibilitySettings() {
    return {
      'highContrast': _highContrastEnabled,
      'largeText': _largeTextEnabled,
      'reducedMotion': _reducedMotionEnabled,
      'screenReaderOptimized': _screenReaderOptimized,
      'hapticFeedback': _hapticFeedbackEnabled,
    };
  }
  
  /// Reset all accessibility settings to default
  Future<void> resetToDefaults() async {
    await Future.wait([
      setHighContrast(false),
      setLargeText(false),
      setReducedMotion(false),
      setScreenReaderOptimized(false),
      setHapticFeedback(true),
    ]);
    
    debugPrint('$_logTag: Reset all accessibility settings to defaults');
  }
}