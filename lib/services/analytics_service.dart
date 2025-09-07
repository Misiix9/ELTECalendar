// File: lib/services/analytics_service.dart
// Purpose: App analytics and crash reporting service
// Step: 12.6 - Implement App Analytics and Crash Reporting

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Service for handling app analytics and crash reporting
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  static const String _logTag = 'AnalyticsService';
  
  // Firebase services
  FirebaseAnalytics? _analytics;
  FirebaseCrashlytics? _crashlytics;
  
  // State tracking
  bool _isInitialized = false;
  bool _analyticsEnabled = true;
  bool _crashlyticsEnabled = true;
  
  // Session tracking
  DateTime? _sessionStartTime;
  String? _currentScreen;
  final Map<String, dynamic> _sessionData = {};
  
  /// Getters
  bool get isInitialized => _isInitialized;
  bool get analyticsEnabled => _analyticsEnabled;
  bool get crashlyticsEnabled => _crashlyticsEnabled;
  FirebaseAnalytics? get analytics => _analytics;
  
  /// Initialize analytics and crashlytics
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      debugPrint('$_logTag: Initializing analytics services...');
      
      // Initialize Firebase Analytics
      await _initializeAnalytics();
      
      // Initialize Firebase Crashlytics
      await _initializeCrashlytics();
      
      // Start session tracking
      _startSession();
      
      _isInitialized = true;
      debugPrint('$_logTag: Analytics services initialized successfully');
      
    } catch (e, stackTrace) {
      debugPrint('$_logTag: Failed to initialize analytics: $e');
      debugPrint('$_logTag: Stack trace: $stackTrace');
      // Don't throw - analytics failure shouldn't crash the app
    }
  }
  
  /// Initialize Firebase Analytics
  Future<void> _initializeAnalytics() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      
      // Set default parameters
      await _analytics!.setDefaultParameters({
        'app_version': '1.0.0', // TODO: Get from package info
        'platform': defaultTargetPlatform.name,
        'debug_mode': kDebugMode,
      });
      
      // Set analytics collection enabled based on build mode
      await _analytics!.setAnalyticsCollectionEnabled(!kDebugMode);
      _analyticsEnabled = !kDebugMode;
      
      debugPrint('$_logTag: Firebase Analytics initialized');
      
    } catch (e) {
      debugPrint('$_logTag: Failed to initialize Firebase Analytics: $e');
      _analyticsEnabled = false;
    }
  }
  
  /// Initialize Firebase Crashlytics
  Future<void> _initializeCrashlytics() async {
    try {
      _crashlytics = FirebaseCrashlytics.instance;
      
      // Enable crashlytics collection based on build mode
      await _crashlytics!.setCrashlyticsCollectionEnabled(!kDebugMode);
      _crashlyticsEnabled = !kDebugMode;
      
      // Set up Flutter error handler
      if (_crashlyticsEnabled) {
        FlutterError.onError = (FlutterErrorDetails details) {
          // Log to console for development
          FlutterError.presentError(details);
          
          // Report to Crashlytics
          _crashlytics!.recordFlutterFatalError(details);
        };
        
        // Handle async errors
        PlatformDispatcher.instance.onError = (error, stackTrace) {
          _crashlytics!.recordError(error, stackTrace, fatal: true);
          return true;
        };
      }
      
      debugPrint('$_logTag: Firebase Crashlytics initialized');
      
    } catch (e) {
      debugPrint('$_logTag: Failed to initialize Firebase Crashlytics: $e');
      _crashlyticsEnabled = false;
    }
  }
  
  /// Start a new session
  void _startSession() {
    _sessionStartTime = DateTime.now();
    _sessionData.clear();
    
    logEvent(AnalyticsEvents.sessionStart);
  }
  
  /// End the current session
  void _endSession() {
    if (_sessionStartTime != null) {
      final sessionDuration = DateTime.now().difference(_sessionStartTime!);
      
      logEvent(AnalyticsEvents.sessionEnd, parameters: {
        'session_duration': sessionDuration.inSeconds,
        'screens_visited': _sessionData['screens_visited'] ?? 0,
        'actions_performed': _sessionData['actions_performed'] ?? 0,
      });
      
      _sessionStartTime = null;
    }
  }
  
  /// Log an analytics event
  Future<void> logEvent(
    String eventName, {
    Map<String, Object>? parameters,
  }) async {
    if (!_isInitialized || !_analyticsEnabled || _analytics == null) return;
    
    try {
      // Add common parameters
      final enhancedParameters = <String, Object>{
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'current_screen': _currentScreen ?? 'unknown',
        ...?parameters,
      };
      
      await _analytics!.logEvent(
        name: eventName,
        parameters: enhancedParameters,
      );
      
      // Track session activity
      _sessionData['actions_performed'] = 
          (_sessionData['actions_performed'] ?? 0) + 1;
      
      debugPrint('$_logTag: Logged event: $eventName');
      
    } catch (e) {
      debugPrint('$_logTag: Failed to log event $eventName: $e');
    }
  }
  
  /// Set current screen
  Future<void> setCurrentScreen(String screenName) async {
    if (!_isInitialized || !_analyticsEnabled || _analytics == null) return;
    
    try {
      _currentScreen = screenName;
      
      await _analytics!.logScreenView(
        screenName: screenName,
        screenClass: screenName,
      );
      
      // Track unique screens in session
      final screensVisited = Set<String>.from(
        _sessionData['visited_screens'] ?? <String>[],
      );
      screensVisited.add(screenName);
      _sessionData['visited_screens'] = screensVisited.toList();
      _sessionData['screens_visited'] = screensVisited.length;
      
      debugPrint('$_logTag: Set current screen: $screenName');
      
    } catch (e) {
      debugPrint('$_logTag: Failed to set screen $screenName: $e');
    }
  }
  
  /// Set user properties
  Future<void> setUserProperties(Map<String, String> properties) async {
    if (!_isInitialized || !_analyticsEnabled || _analytics == null) return;
    
    try {
      for (final entry in properties.entries) {
        await _analytics!.setUserProperty(
          name: entry.key,
          value: entry.value,
        );
      }
      
      debugPrint('$_logTag: Set user properties: ${properties.keys}');
      
    } catch (e) {
      debugPrint('$_logTag: Failed to set user properties: $e');
    }
  }
  
  /// Set user ID
  Future<void> setUserId(String? userId) async {
    if (!_isInitialized || !_analyticsEnabled || _analytics == null) return;
    
    try {
      await _analytics!.setUserId(id: userId);
      debugPrint('$_logTag: Set user ID: $userId');
      
    } catch (e) {
      debugPrint('$_logTag: Failed to set user ID: $e');
    }
  }
  
  /// Record a non-fatal error
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, dynamic>? additionalData,
    bool fatal = false,
  }) async {
    if (!_isInitialized || !_crashlyticsEnabled || _crashlytics == null) return;
    
    try {
      // Add additional context
      if (additionalData != null) {
        for (final entry in additionalData.entries) {
          await _crashlytics!.setCustomKey(entry.key, entry.value);
        }
      }
      
      // Set current screen context
      if (_currentScreen != null) {
        await _crashlytics!.setCustomKey('current_screen', _currentScreen!);
      }
      
      // Record the error
      await _crashlytics!.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
      
      debugPrint('$_logTag: Recorded error: ${error.toString()}');
      
    } catch (e) {
      debugPrint('$_logTag: Failed to record error: $e');
    }
  }
  
  /// Record a crash with additional context
  Future<void> recordCrash(
    dynamic error,
    StackTrace stackTrace, {
    String? reason,
    Map<String, dynamic>? additionalData,
  }) async {
    await recordError(
      error,
      stackTrace,
      reason: reason,
      additionalData: additionalData,
      fatal: true,
    );
  }
  
  /// Log custom message to crashlytics
  Future<void> log(String message) async {
    if (!_isInitialized || !_crashlyticsEnabled || _crashlytics == null) return;
    
    try {
      await _crashlytics!.log(message);
    } catch (e) {
      debugPrint('$_logTag: Failed to log message: $e');
    }
  }
  
  /// Enable/disable analytics collection
  Future<void> setAnalyticsEnabled(bool enabled) async {
    if (!_isInitialized || _analytics == null) return;
    
    try {
      await _analytics!.setAnalyticsCollectionEnabled(enabled);
      _analyticsEnabled = enabled;
      
      debugPrint('$_logTag: Analytics collection ${enabled ? 'enabled' : 'disabled'}');
      
    } catch (e) {
      debugPrint('$_logTag: Failed to set analytics collection: $e');
    }
  }
  
  /// Enable/disable crashlytics collection
  Future<void> setCrashlyticsEnabled(bool enabled) async {
    if (!_isInitialized || _crashlytics == null) return;
    
    try {
      await _crashlytics!.setCrashlyticsCollectionEnabled(enabled);
      _crashlyticsEnabled = enabled;
      
      debugPrint('$_logTag: Crashlytics collection ${enabled ? 'enabled' : 'disabled'}');
      
    } catch (e) {
      debugPrint('$_logTag: Failed to set crashlytics collection: $e');
    }
  }
  
  /// Get analytics observer for navigation tracking
  FirebaseAnalyticsObserver? getNavigatorObserver() {
    if (!_isInitialized || !_analyticsEnabled || _analytics == null) {
      return null;
    }
    
    return FirebaseAnalyticsObserver(analytics: _analytics!);
  }
  
  /// Get session statistics
  Map<String, dynamic> getSessionStats() {
    final now = DateTime.now();
    final sessionDuration = _sessionStartTime != null 
        ? now.difference(_sessionStartTime!)
        : Duration.zero;
    
    return {
      'session_start_time': _sessionStartTime?.millisecondsSinceEpoch,
      'session_duration_seconds': sessionDuration.inSeconds,
      'current_screen': _currentScreen,
      'screens_visited': _sessionData['screens_visited'] ?? 0,
      'actions_performed': _sessionData['actions_performed'] ?? 0,
      'analytics_enabled': _analyticsEnabled,
      'crashlytics_enabled': _crashlyticsEnabled,
    };
  }
  
  /// Test crash reporting (debug only)
  void testCrashReporting() {
    if (kDebugMode && _crashlyticsEnabled) {
      // This will cause a test crash
      throw Exception('Test crash from AnalyticsService');
    }
  }
  
  /// Clean up resources
  void dispose() {
    _endSession();
    debugPrint('$_logTag: Analytics service disposed');
  }
}

/// Predefined analytics events
class AnalyticsEvents {
  // App lifecycle
  static const String appOpen = 'app_open';
  static const String sessionStart = 'session_start';
  static const String sessionEnd = 'session_end';
  
  // Authentication
  static const String signIn = 'sign_in';
  static const String signUp = 'sign_up';
  static const String signOut = 'sign_out';
  static const String authError = 'auth_error';
  
  // Schedule management
  static const String scheduleImport = 'schedule_import';
  static const String scheduleImportSuccess = 'schedule_import_success';
  static const String scheduleImportError = 'schedule_import_error';
  static const String scheduleExport = 'schedule_export';
  static const String courseView = 'course_view';
  static const String courseEdit = 'course_edit';
  
  // Calendar interactions
  static const String calendarViewChange = 'calendar_view_change';
  static const String dateNavigation = 'date_navigation';
  static const String eventTap = 'event_tap';
  
  // Settings and preferences
  static const String themeChange = 'theme_change';
  static const String languageChange = 'language_change';
  static const String settingsView = 'settings_view';
  
  // Notifications
  static const String notificationScheduled = 'notification_scheduled';
  static const String notificationReceived = 'notification_received';
  static const String notificationTapped = 'notification_tapped';
  
  // Errors and crashes
  static const String error = 'error';
  static const String crashReported = 'crash_reported';
  
  // Performance
  static const String appStartup = 'app_startup';
  static const String serviceInit = 'service_init';
  static const String imageLoadTime = 'image_load_time';
}

/// Analytics parameter names
class AnalyticsParameters {
  static const String method = 'method';
  static const String success = 'success';
  static const String errorMessage = 'error_message';
  static const String errorCode = 'error_code';
  static const String duration = 'duration';
  static const String itemCount = 'item_count';
  static const String screenName = 'screen_name';
  static const String feature = 'feature';
  static const String value = 'value';
  static const String category = 'category';
}