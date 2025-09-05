// File: lib/main.dart
// Purpose: Main entry point for the ELTE Calendar application
// Step: 1.1 - Initialize Flutter Project

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'config/firebase_config.dart';
import 'config/theme_config.dart';
import 'config/localization_config.dart';
import 'services/auth_service.dart';
import 'services/semester_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/calendar/calendar_main_screen.dart';

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
    // TODO: Register Course and ScheduleSlot adapters when models are created
    
    // Run the application
    runApp(const ELTECalendarApp());
  } catch (error) {
    // Log initialization errors
    debugPrint('Error initializing app: $error');
    
    // Run app with error state
    runApp(const ErrorApp());
  }
}

/// Main application widget with proper configuration and providers
class ELTECalendarApp extends StatelessWidget {
  const ELTECalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Authentication service provider
        ChangeNotifierProvider(create: (_) => AuthService()),
        
        // Semester management service provider
        ChangeNotifierProvider(create: (_) => SemesterService()),
        
        // TODO: Add other service providers as they are implemented
        // - ExcelParserService
        // - NotificationService
        // - CalendarService
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          return MaterialApp(
            // Application metadata
            title: 'ELTE Calendar',
            debugShowCheckedModeBanner: false,
            
            // Theme configuration using specified color palette
            theme: ThemeConfig.lightTheme,
            darkTheme: ThemeConfig.darkTheme,
            themeMode: ThemeMode.system, // Respect system theme preference
            
            // Localization configuration
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('hu'), // Default to Hungarian
            
            // Initial route based on authentication state
            home: FutureBuilder<bool>(
              future: authService.isLoggedIn(),
              builder: (context, snapshot) {
                // Show loading indicator while checking auth state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    backgroundColor: Color(0xFF03284F), // Primary dark blue
                    body: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFC6A882), // Gold accent
                      ),
                    ),
                  );
                }
                
                // Navigate based on authentication state
                if (snapshot.data == true) {
                  return const CalendarMainScreen();
                } else {
                  return const LoginScreen();
                }
              },
            ),
            
            // Route configuration
            routes: {
              '/login': (context) => const LoginScreen(),
              '/calendar': (context) => const CalendarMainScreen(),
              // TODO: Add additional routes as screens are implemented
            },
            
            // Error handling for route navigation
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              );
            },
          );
        },
      ),
    );
  }
}

/// Error application widget shown when initialization fails
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

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