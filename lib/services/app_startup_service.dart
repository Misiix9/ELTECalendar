// File: lib/services/app_startup_service.dart
// Purpose: Coordinates application startup and service initialization
// Step: 12.1 - Performance Optimization

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_service.dart';
import 'auth_service.dart';
import 'theme_service.dart';
import 'language_service.dart';
import 'semester_service.dart';
import 'calendar_service.dart';
import 'notification_service.dart';
import 'image_cache_service.dart';
import 'analytics_service.dart';

/// Manages application startup sequence and service initialization
class AppStartupService extends ChangeNotifier {
  static const String _logTag = 'AppStartupService';
  
  // Services
  late FirebaseService _firebaseService;
  late AuthService _authService;
  late ThemeService _themeService;
  late LanguageService _languageService;
  late SemesterService _semesterService;
  late CalendarService _calendarService;
  late NotificationService _notificationService;
  late ImageCacheService _imageCacheService;
  late AnalyticsService _analyticsService;
  
  // State tracking
  bool _isInitialized = false;
  bool _isInitializing = false;
  double _initializationProgress = 0.0;
  String _currentStep = '';
  String? _lastError;
  
  // Timing for performance monitoring
  DateTime? _startTime;
  final Map<String, Duration> _serviceInitTimes = {};
  
  /// Getters
  bool get isInitialized => _isInitialized;
  bool get isInitializing => _isInitializing;
  double get initializationProgress => _initializationProgress;
  String get currentStep => _currentStep;
  String? get lastError => _lastError;
  bool get hasError => _lastError != null;
  
  /// Service getters
  FirebaseService get firebaseService => _firebaseService;
  AuthService get authService => _authService;
  ThemeService get themeService => _themeService;
  LanguageService get languageService => _languageService;
  SemesterService get semesterService => _semesterService;
  CalendarService get calendarService => _calendarService;
  NotificationService get notificationService => _notificationService;
  ImageCacheService get imageCacheService => _imageCacheService;
  AnalyticsService get analyticsService => _analyticsService;
  
  /// Get initialization timing data
  Map<String, Duration> get serviceInitTimes => Map.unmodifiable(_serviceInitTimes);
  
  /// Get total initialization time
  Duration? get totalInitTime {
    if (_startTime == null) return null;
    return DateTime.now().difference(_startTime!);
  }
  
  /// Initialize all application services
  Future<bool> initializeApp() async {
    if (_isInitialized || _isInitializing) return _isInitialized;
    
    _isInitializing = true;
    _initializationProgress = 0.0;
    _lastError = null;
    _startTime = DateTime.now();
    notifyListeners();
    
    try {
      debugPrint('$_logTag: Starting app initialization...');
      
      // Step 1: Initialize Hive (0-10%)
      await _initializeStep(
        'Initializing local storage...',
        () => _initializeHive(),
        0.1,
      );
      
      // Step 2: Initialize Firebase (10-30%)
      await _initializeStep(
        'Connecting to Firebase...',
        () => _initializeFirebase(),
        0.3,
      );
      
      // Step 3: Initialize independent services in parallel (30-60%)
      await _initializeStep(
        'Loading app preferences...',
        () => _initializeIndependentServices(),
        0.6,
      );
      
      // Step 4: Initialize dependent services (60-80%)
      await _initializeStep(
        'Setting up user authentication...',
        () => _initializeDependentServices(),
        0.8,
      );
      
      // Step 5: Initialize complex services (80-95%)
      await _initializeStep(
        'Loading user data...',
        () => _initializeComplexServices(),
        0.95,
      );
      
      // Step 6: Final setup (95-100%)
      await _initializeStep(
        'Finishing setup...',
        () => _finalizeInitialization(),
        1.0,
      );
      
      _isInitialized = true;
      debugPrint('$_logTag: App initialization completed in ${totalInitTime}');
      
      // Log timing data in debug mode
      if (kDebugMode) {
        _logServiceTimes();
      }
      
      // Track app startup completion
      _trackStartupCompletion();
      
      return true;
      
    } catch (error, stackTrace) {
      _lastError = error.toString();
      debugPrint('$_logTag: Initialization failed: $error');
      debugPrint('$_logTag: Stack trace: $stackTrace');
      return false;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }
  
  /// Initialize a single step with progress tracking
  Future<void> _initializeStep(
    String stepDescription,
    Future<void> Function() stepFunction,
    double targetProgress,
  ) async {
    _currentStep = stepDescription;
    debugPrint('$_logTag: $stepDescription');
    notifyListeners();
    
    final stopwatch = Stopwatch()..start();
    
    try {
      await stepFunction();
      _initializationProgress = targetProgress;
      
      stopwatch.stop();
      debugPrint('$_logTag: Completed "$stepDescription" in ${stopwatch.elapsed}');
      
    } catch (error) {
      stopwatch.stop();
      debugPrint('$_logTag: Failed "$stepDescription" after ${stopwatch.elapsed}: $error');
      rethrow;
    } finally {
      notifyListeners();
    }
  }
  
  /// Initialize Hive local storage
  Future<void> _initializeHive() async {
    final stopwatch = Stopwatch()..start();
    
    await Hive.initFlutter();
    // Register Hive adapters when they're generated
    // TODO: Uncomment when adapters are available
    // Hive.registerAdapter(StudentUserAdapter());
    // Hive.registerAdapter(CourseAdapter());
    // Hive.registerAdapter(ScheduleSlotAdapter());
    
    stopwatch.stop();
    _serviceInitTimes['Hive'] = stopwatch.elapsed;
  }
  
  /// Initialize Firebase services
  Future<void> _initializeFirebase() async {
    final stopwatch = Stopwatch()..start();
    
    _firebaseService = FirebaseService();
    await _firebaseService.initialize()
        .timeout(const Duration(seconds: 15));
    
    stopwatch.stop();
    _serviceInitTimes['Firebase'] = stopwatch.elapsed;
  }
  
  /// Initialize services that don't depend on others (parallel)
  Future<void> _initializeIndependentServices() async {
    final stopwatch = Stopwatch()..start();
    
    // Initialize theme, language, image cache, and analytics services in parallel
    _themeService = ThemeService();
    _languageService = LanguageService();
    _imageCacheService = ImageCacheService();
    _analyticsService = AnalyticsService();
    
    await Future.wait([
      _themeService.initialize()
          .timeout(const Duration(seconds: 5))
          .catchError((error) => debugPrint('$_logTag: ThemeService init failed: $error')),
      _languageService.initialize()
          .timeout(const Duration(seconds: 5))
          .catchError((error) => debugPrint('$_logTag: LanguageService init failed: $error')),
      _imageCacheService.initialize()
          .timeout(const Duration(seconds: 5))
          .catchError((error) => debugPrint('$_logTag: ImageCacheService init failed: $error')),
      _analyticsService.initialize()
          .timeout(const Duration(seconds: 10))
          .catchError((error) => debugPrint('$_logTag: AnalyticsService init failed: $error')),
    ]);
    
    stopwatch.stop();
    _serviceInitTimes['Independent Services'] = stopwatch.elapsed;
  }
  
  /// Initialize services that depend on Firebase
  Future<void> _initializeDependentServices() async {
    final stopwatch = Stopwatch()..start();
    
    // Auth service depends on Firebase
    _authService = AuthService();
    await _authService.initialize()
        .timeout(const Duration(seconds: 20));
    
    // Semester service can initialize independently
    _semesterService = SemesterService();
    await _semesterService.initialize()
        .timeout(const Duration(seconds: 5));
    
    stopwatch.stop();
    _serviceInitTimes['Dependent Services'] = stopwatch.elapsed;
  }
  
  /// Initialize complex services that depend on multiple others
  Future<void> _initializeComplexServices() async {
    final stopwatch = Stopwatch()..start();
    
    // Calendar service depends on Firebase, Auth, and Semester services
    _calendarService = CalendarService(
      _firebaseService,
      _authService,
      _semesterService,
    );
    
    // Notification service depends on Auth, Firebase, Calendar, and Semester services
    _notificationService = NotificationService(
      _authService,
      _firebaseService,
      _calendarService,
      _semesterService,
    );
    
    // Initialize notification service only (calendar service doesn't need async init)
    await _notificationService.initialize()
        .timeout(const Duration(seconds: 5));
    
    stopwatch.stop();
    _serviceInitTimes['Complex Services'] = stopwatch.elapsed;
  }
  
  /// Finalize initialization
  Future<void> _finalizeInitialization() async {
    final stopwatch = Stopwatch()..start();
    
    // Any final setup tasks
    await Future.delayed(const Duration(milliseconds: 100)); // Brief pause for UI
    
    stopwatch.stop();
    _serviceInitTimes['Finalization'] = stopwatch.elapsed;
  }
  
  /// Log service initialization times
  void _logServiceTimes() {
    debugPrint('$_logTag: Service initialization times:');
    _serviceInitTimes.forEach((service, duration) {
      debugPrint('$_logTag:   $service: ${duration.inMilliseconds}ms');
    });
    debugPrint('$_logTag:   Total: ${totalInitTime?.inMilliseconds}ms');
  }
  
  /// Track startup completion to analytics
  void _trackStartupCompletion() {
    if (_analyticsService != null && _analyticsService.isInitialized) {
      _analyticsService.logEvent(
        'app_startup',
        parameters: {
          'total_duration_ms': totalInitTime?.inMilliseconds ?? 0,
          'service_count': _serviceInitTimes.length,
          'success': true,
        },
      );
      
      // Track individual service initialization times
      _serviceInitTimes.forEach((service, duration) {
        _analyticsService.logEvent(
          'service_init',
          parameters: {
            'service_name': service,
            'duration_ms': duration.inMilliseconds,
          },
        );
      });
    }
  }
  
  /// Retry initialization
  Future<bool> retry() async {
    debugPrint('$_logTag: Retrying initialization...');
    _isInitialized = false;
    _lastError = null;
    _serviceInitTimes.clear();
    return await initializeApp();
  }
  
  /// Check if a specific service is available
  bool isServiceAvailable(String serviceName) {
    switch (serviceName.toLowerCase()) {
      case 'firebase':
        return _isInitialized && _firebaseService != null;
      case 'auth':
        return _isInitialized && _authService != null;
      case 'theme':
        return _isInitialized && _themeService != null;
      case 'language':
        return _isInitialized && _languageService != null;
      case 'semester':
        return _isInitialized && _semesterService != null;
      case 'calendar':
        return _isInitialized && _calendarService != null;
      case 'notification':
        return _isInitialized && _notificationService != null;
      case 'imagecache':
        return _isInitialized && _imageCacheService != null;
      case 'analytics':
        return _isInitialized && _analyticsService != null;
      default:
        return false;
    }
  }
  
  /// Get initialization statistics
  Map<String, dynamic> getInitializationStats() {
    return {
      'isInitialized': _isInitialized,
      'totalTime': totalInitTime?.inMilliseconds,
      'serviceTimes': _serviceInitTimes.map(
        (key, value) => MapEntry(key, value.inMilliseconds),
      ),
      'lastError': _lastError,
      'progress': _initializationProgress,
    };
  }
  
  @override
  void dispose() {
    debugPrint('$_logTag: Disposing startup service');
    // Don't dispose the actual services here, they should be managed by the app
    super.dispose();
  }
  
  @override
  String toString() {
    return 'AppStartupService{initialized: $_isInitialized, '
           'initializing: $_isInitializing, progress: $_initializationProgress}';
  }
}