// File: lib/main.dart
// Purpose: Main entry point for the ELTE Calendar application with complete authentication flow
// Step: 2.2 - Complete Authentication System Implementation

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'config/firebase_config.dart';
import 'config/theme_config.dart';
import 'config/localization_config.dart';
import 'services/auth_service.dart';
import 'services/firebase_service.dart';
import 'services/semester_service.dart';
import 'services/calendar_service.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';
import 'services/language_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/calendar/calendar_main_screen.dart';
import 'screens/import/excel_import_screen.dart';
import 'screens/settings/semester_management_screen.dart';
import 'screens/settings/settings_main_screen.dart';
import 'screens/courses/course_list_screen.dart';
import 'screens/courses/course_edit_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'widgets/common_widgets/auth_wrapper.dart';
import 'widgets/navigation/navigation_wrapper.dart';

/// Main application entry point
/// Initializes Firebase, Hive local storage, and app configuration
void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Hive for local storage
    await Hive.initFlutter();
    
    // Register Hive adapters for custom objects
    // Note: Adapters will be generated when running 'dart run build_runner build'
    // Hive.registerAdapter(StudentUserAdapter());
    // Hive.registerAdapter(CourseAdapter());
    // Hive.registerAdapter(ScheduleSlotAdapter());
    
    // Run the application
    runApp(const ELTECalendarApp());
  } catch (error) {
    // Log initialization errors
    debugPrint('Error initializing app: $error');
    
    // Run app with error state
    runApp(ErrorApp(error: error.toString()));
  }
}

/// Main application widget with proper configuration and providers
class ELTECalendarApp extends StatefulWidget {
  const ELTECalendarApp({super.key});

  @override
  State<ELTECalendarApp> createState() => _ELTECalendarAppState();
}

class _ELTECalendarAppState extends State<ELTECalendarApp> {
  late AuthService _authService;
  late FirebaseService _firebaseService;
  late SemesterService _semesterService;
  late CalendarService _calendarService;
  late NotificationService _notificationService;
  late ThemeService _themeService;
  late LanguageService _languageService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  /// Initialize all required services
  Future<void> _initializeServices() async {
    try {
      debugPrint('Starting service initialization...');
      
      _authService = AuthService();
      _firebaseService = FirebaseService();
      _semesterService = SemesterService();
      _calendarService = CalendarService(_firebaseService, _authService, _semesterService);
      _notificationService = NotificationService(_authService, _firebaseService, _calendarService, _semesterService);
      _themeService = ThemeService();
      _languageService = LanguageService();

      // Initialize services with timeout to prevent hanging
      await Future.wait([
        _firebaseService.initialize().timeout(const Duration(seconds: 10)),
        _semesterService.initialize().timeout(const Duration(seconds: 5)),
        _themeService.initialize().timeout(const Duration(seconds: 5)),
        _languageService.initialize().timeout(const Duration(seconds: 5)),
      ]);
      
      // Initialize auth service separately with timeout
      await _authService.initialize().timeout(const Duration(seconds: 15));
      
      debugPrint('All services initialized successfully');

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Failed to initialize services: $e');
      // Continue with app startup even if some services fail
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: AuthLoadingScreen(),
        debugShowCheckedModeBanner: false,
      );
    }

    return MultiProvider(
      providers: [
        // Authentication service provider
        ChangeNotifierProvider.value(value: _authService),
        
        // Firebase service provider
        Provider.value(value: _firebaseService),
        
        // Semester management service provider
        ChangeNotifierProvider.value(value: _semesterService),
        
        // Calendar service provider
        ChangeNotifierProvider.value(value: _calendarService),
        
        // Notification service provider
        ChangeNotifierProvider.value(value: _notificationService),
        
        // Theme service provider
        ChangeNotifierProvider.value(value: _themeService),
        
        // Language service provider
        ChangeNotifierProvider.value(value: _languageService),
        
        // TODO: Add other service providers as they are implemented
        // - ExcelParserService
      ],
      child: Consumer2<ThemeService, LanguageService>(
        builder: (context, themeService, languageService, child) => MaterialApp(
          // Application metadata
          title: 'ELTE Calendar',
          debugShowCheckedModeBanner: false,
          
          // Theme configuration using ThemeService
          theme: ThemeConfig.lightTheme,
          darkTheme: ThemeConfig.darkTheme,
          themeMode: themeService.themeMode, // Use ThemeService for theme management
          
          // Localization configuration
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: languageService.currentLocale, // Use LanguageService for dynamic locale
        
        // Authentication wrapper handles routing based on auth state
        home: const AuthWrapper(),
        
        // Route configuration with all authentication screens
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/email-verification': (context) => const EmailVerificationScreen(),
          '/calendar': (context) => const AuthGuard(child: NavigationWrapper(child: CalendarMainScreen(), currentIndex: 0)),
          '/import': (context) => const AuthGuard(child: NavigationWrapper(child: ExcelImportScreen(), currentIndex: 0)),
          '/semester-management': (context) => const AuthGuard(child: NavigationWrapper(child: SemesterManagementScreen(), currentIndex: 3)),
          '/settings': (context) => const AuthGuard(child: NavigationWrapper(child: SettingsMainScreen(), currentIndex: 3)),
          '/courses': (context) => const AuthGuard(child: NavigationWrapper(child: CourseListScreen(), currentIndex: 1)),
          '/course-create': (context) => const AuthGuard(child: NavigationWrapper(child: CourseEditScreen(), currentIndex: 1)),
          '/notifications': (context) => const AuthGuard(child: NavigationWrapper(child: NotificationsScreen(), currentIndex: 2)),
          // TODO: Add additional routes as screens are implemented
        },
        
        // Initial route
        initialRoute: '/',
        
        // Error handling for route navigation
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const AuthWrapper(),
          );
        },
        
        // Global navigation observer for debugging
        navigatorObservers: [
          if (kDebugMode) AuthNavigationObserver(),
        ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _authService.dispose();
    _calendarService.dispose();
    super.dispose();
  }
}

/// Navigation observer for debugging authentication flows
class AuthNavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    debugPrint('Navigated to: ${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    debugPrint('Popped from: ${route.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    debugPrint('Replaced ${oldRoute?.settings.name} with ${newRoute?.settings.name}');
  }
}

/// Error application widget shown when initialization fails
class ErrorApp extends StatelessWidget {
  final String? error;
  
  const ErrorApp({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ELTE Calendar - Error',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFFF4F4F4),
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[700],
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to initialize ELTE Calendar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please check your internet connection and try again.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF060605),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Restart the application
                  main();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF03284F),
                  foregroundColor: const Color(0xFFF4F4F4),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}