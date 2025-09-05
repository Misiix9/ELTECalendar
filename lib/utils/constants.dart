// File: lib/utils/constants.dart
// Purpose: Application constants and configuration values
// Step: 1.2 - Firebase Setup

/// Application constants following the technical specification
class AppConstants {
  // App information
  static const String appName = 'ELTE Calendar';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'University calendar application for ELTE students';
  
  // Color palette (matching theme_config.dart)
  static const String primaryDarkBlue = '#03284F';
  static const String goldAccent = '#C6A882';
  static const String lightBackground = '#F4F4F4';
  static const String darkTextElements = '#060605';
  
  // Firebase collection names (following specification structure)
  static const String usersCollection = 'users';
  static const String profileSubcollection = 'profile';
  static const String semestersSubcollection = 'semesters';
  static const String coursesSubcollection = 'courses';
  
  // Firebase Storage paths
  static const String excelImportsPath = 'excel-imports';
  static const String tempUploadsPath = 'temp-uploads';
  static const String profileImagesPath = 'profile-images';
  static const String publicAssetsPath = 'public';
  
  // Excel file requirements (Hungarian column headers as specified)
  static const List<String> requiredExcelColumns = [
    'Tárgy kódja',      // Course code
    'Tárgy neve',       // Course name
    'Kurzus kódja',     // Class code
    'Kurzus típusa',    // Class type
    'Óraszám:',         // Weekly hours
    'Órarend infó',     // Schedule info
    'Oktatók',          // Instructors
    // 'Várólista' is ignored as specified
  ];
  
  // Day abbreviation mapping (Hungarian to English)
  static const Map<String, String> dayAbbreviations = {
    'H': 'Monday',      // Hétfő
    'K': 'Tuesday',     // Kedd
    'SZE': 'Wednesday', // Szerda
    'CS': 'Thursday',   // Csütörtök
    'P': 'Friday',      // Péntek
    'SZ': 'Saturday',   // Szombat (only when after P)
  };
  
  // Day of week mapping (for DateTime compatibility)
  static const Map<String, int> dayOfWeekMapping = {
    'H': 1,     // Monday
    'K': 2,     // Tuesday
    'SZE': 3,   // Wednesday
    'CS': 4,    // Thursday
    'P': 5,     // Friday
    'SZ': 6,    // Saturday
  };
  
  // Course type translations
  static const Map<String, String> courseTypes = {
    'Előadás': 'Lecture',
    'Gyakorlat': 'Practice',
    'Labor': 'Laboratory',
  };
  
  // Semester calculation constants
  static const int firstSemesterStartMonth = 9;  // September
  static const int firstSemesterEndMonth = 1;    // January
  static const int secondSemesterStartMonth = 2; // February
  static const int secondSemesterEndMonth = 6;   // June
  
  // File upload limits
  static const int maxExcelFileSizeMB = 50;
  static const int maxImageFileSizeMB = 5;
  static const int maxTempFileRetentionHours = 24;
  
  // Calendar view settings
  static const List<String> calendarViewTypes = [
    'Daily',
    'Weekly', 
    'Monthly',
  ];
  
  // Notification settings
  static const List<int> reminderMinuteOptions = [5, 10, 15, 30, 60];
  static const int defaultReminderMinutes = 15;
  
  // Authentication settings
  static const bool requireEmailVerification = false; // Non-blocking as specified
  static const int passwordMinLength = 6;
  static const Duration authSessionTimeout = Duration(hours: 24);
  
  // Localization settings
  static const List<String> supportedLanguages = ['hu', 'en', 'de'];
  static const String defaultLanguage = 'hu'; // Hungarian as specified
  
  // Cache and storage settings
  static const String hiveBoxName = 'elte_calendar_box';
  static const String userPrefsKey = 'user_preferences';
  static const String cachedCoursesKey = 'cached_courses';
  static const String lastSyncKey = 'last_sync_timestamp';
  
  // Network and sync settings
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration syncInterval = Duration(minutes: 15);
  static const int maxRetryAttempts = 3;
  
  // Calendar display settings
  static const int calendarStartHour = 6;   // 6:00 AM
  static const int calendarEndHour = 22;    // 10:00 PM
  static const int timeSlotDurationMinutes = 15;
  
  // Excel parsing settings
  static const String scheduleInfoRegexPattern = r'([A-Z]{1,3}):(\d{1,2}:\d{2})-(\d{1,2}:\d{2})\(([^)]*)\)';
  static const String timeFormatPattern = r'^\d{1,2}:\d{2}$';
  
  // Error messages keys (for localization)
  static const String errorNetworkConnection = 'networkError';
  static const String errorAuthenticationFailed = 'authError';
  static const String errorPermissionDenied = 'permissionDenied';
  static const String errorFileNotFound = 'fileNotFound';
  static const String errorInvalidFormat = 'invalidFormat';
  static const String errorExcelParsing = 'excelParsingError';
  static const String errorFirebaseOperation = 'firebaseError';
  
  // Success messages keys (for localization)
  static const String successLogin = 'loginSuccess';
  static const String successRegistration = 'registrationSuccess';
  static const String successExcelImport = 'importSuccess';
  static const String successPasswordReset = 'passwordResetSuccess';
  static const String successDataSync = 'syncSuccess';
  
  // Validation patterns
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String courseCodePattern = r'^[A-Z0-9]{4,10}$';
  static const String timePattern = r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$';
  
  // Firebase emulator settings (for development)
  static const bool useEmulator = false; // Set to true for local development
  static const String emulatorHost = 'localhost';
  static const int firestoreEmulatorPort = 8080;
  static const int authEmulatorPort = 9099;
  static const int storageEmulatorPort = 9199;
  
  // Analytics and logging
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  static const bool enableDebugLogging = false; // Should be false in production
  
  // Feature flags
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = true;
  static const bool enableCalendarExport = true;
  static const bool enableDarkMode = true;
  
  // URLs and links
  static const String privacyPolicyUrl = 'https://elte-calendar.firebaseapp.com/privacy';
  static const String termsOfServiceUrl = 'https://elte-calendar.firebaseapp.com/terms';
  static const String supportEmailUrl = 'mailto:support@elte-calendar.com';
  static const String githubRepoUrl = 'https://github.com/elte/calendar-app';
}

/// Environment-specific configuration
class EnvironmentConfig {
  static const String environment = String.fromEnvironment('ENV', defaultValue: 'development');
  
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  static bool get isTesting => environment == 'testing';
  
  // Firebase project configuration based on environment
  static String get firebaseProjectId {
    switch (environment) {
      case 'production':
        return 'elte-calendar';
      case 'staging':
        return 'elte-calendar-staging';
      default:
        return 'elte-calendar-dev';
    }
  }
}