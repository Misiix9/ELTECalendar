// File: lib/config/localization_config.dart  
// Purpose: Localization configuration for Hungarian, English, and German
// Step: 1.1 - Initialize Flutter Project

import 'package:flutter/widgets.dart';

/// Application localization configuration
/// Supports Hungarian (default), English, and German as specified
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  /// Get current instance from context
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// Supported locales as specified in requirements
  static const List<Locale> supportedLocales = [
    Locale('hu'),    // Hungarian (default)
    Locale('en'),    // English  
    Locale('de'),    // German
  ];

  /// Localization delegate
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// Localized strings map
  /// TODO: Replace with proper .arb files in production
  static const Map<String, Map<String, String>> _localizedStrings = {
    'hu': {
      // Authentication
      'login': 'Bejelentkezés',
      'register': 'Regisztráció', 
      'email': 'E-mail cím',
      'password': 'Jelszó',
      'confirmPassword': 'Jelszó megerősítése',
      'forgotPassword': 'Elfelejtett jelszó',
      'resetPassword': 'Jelszó visszaállítása',
      'signInWithGoogle': 'Bejelentkezés Google-lal',
      'signInWithApple': 'Bejelentkezés Apple-lel',
      'logout': 'Kijelentkezés',
      'emailVerification': 'E-mail megerősítés',
      'emailVerificationSent': 'Megerősítő e-mail elküldve',
      'signOut': 'Kijelentkezés',
      
      // Calendar
      'calendar': 'Naptár',
      'dailyView': 'Napi nézet',
      'weeklyView': 'Heti nézet', 
      'monthlyView': 'Havi nézet',
      'today': 'Ma',
      'currentTime': 'Jelenlegi idő',
      'noClassesToday': 'Ma nincs óra',
      'noClassesThisWeek': 'Ezen a héten nincs óra',
      
      // Course management
      'courses': 'Kurzusok',
      'addCourse': 'Kurzus hozzáadása',
      'editCourse': 'Kurzus szerkesztése',
      'deleteCourse': 'Kurzus törlése',
      'courseCode': 'Tárgy kódja',
      'courseName': 'Tárgy neve',
      'classCode': 'Kurzus kódja',
      'classType': 'Kurzus típusa',
      'weeklyHours': 'Heti óraszám',
      'instructor': 'Oktató',
      'location': 'Helyszín',
      'schedule': 'Órarend',
      
      // Course types
      'lecture': 'Előadás',
      'practice': 'Gyakorlat',
      'lab': 'Labor',
      
      // Days of week
      'monday': 'Hétfő',
      'tuesday': 'Kedd', 
      'wednesday': 'Szerda',
      'thursday': 'Csütörtök',
      'friday': 'Péntek',
      'saturday': 'Szombat',
      'sunday': 'Vasárnap',
      
      // Months  
      'january': 'Január',
      'february': 'Február',
      'march': 'Március',
      'april': 'Április',
      'may': 'Május',
      'june': 'Június',
      'july': 'Július',
      'august': 'Augusztus',
      'september': 'Szeptember',
      'october': 'Október',
      'november': 'November',
      'december': 'December',
      
      // Excel import
      'importExcel': 'Excel importálása',
      'selectFile': 'Fájl kiválasztása',
      'uploadFile': 'Fájl feltöltése',
      'parseExcel': 'Excel feldolgozása',
      'importSuccess': 'Import sikeres',
      'importError': 'Import hiba',
      'invalidFile': 'Érvénytelen fájl',
      'requiredColumns': 'Szükséges oszlopok hiányoznak',
      
      // Semester management
      'semester': 'Félév',
      'currentSemester': 'jelenlegi félév',
      'nextSemester': 'következő félév',
      'selectSemester': 'Félév kiválasztása',
      
      // Settings
      'settings': 'Beállítások',
      'language': 'Nyelv',
      'theme': 'Téma',
      'notifications': 'Értesítések',
      'exportCalendar': 'Naptár exportálása',
      'about': 'Névjegy',
      
      // Notifications
      'classReminder': 'Óra emlékeztető',
      'minutesBefore': 'perccel előtte',
      'dailySummary': 'Napi összefoglaló',
      
      // Theme and Settings
      'themeSettings': 'Téma beállítások',
      'academicSettings': 'Tanulmányi beállítások',
      'manageSemesters': 'Félévek kezelése',
      'manageSemestersDesc': 'Félévek hozzáadása, szerkesztése és rendezése',
      'notificationSettings': 'Értesítés beállítások',
      'notificationSettingsDesc': 'Értesítési beállítások kezelése',
      'syncSettings': 'Szinkronizálás és adatok',
      'syncSettingsDesc': 'Adatszinkronizálás és biztonsági másolat kezelése',
      'account': 'Fiók',
      
      // Language names
      'hungarian': 'Magyar',
      'english': 'Angol',
      'german': 'Német',
      
      // Common
      'save': 'Mentés',
      'cancel': 'Mégse',
      'delete': 'Törlés',
      'edit': 'Szerkesztés',
      'add': 'Hozzáadás',
      'close': 'Bezárás',
      'confirm': 'Megerősítés',
      'yes': 'Igen',
      'no': 'Nem',
      'ok': 'OK',
      'error': 'Hiba',
      'success': 'Sikeres',
      'loading': 'Betöltés...',
      'retry': 'Újra',
      
      // Error messages
      'networkError': 'Hálózati hiba',
      'authError': 'Hitelesítési hiba',
      'permissionDenied': 'Hozzáférés megtagadva',
      'fileNotFound': 'Fájl nem található',
      'invalidFormat': 'Érvénytelen formátum',
    },
    
    'en': {
      // Authentication
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'forgotPassword': 'Forgot Password',
      'resetPassword': 'Reset Password',
      'signInWithGoogle': 'Sign in with Google',
      'signInWithApple': 'Sign in with Apple',
      'logout': 'Logout',
      'emailVerification': 'Email Verification',
      'emailVerificationSent': 'Verification email sent',
      'signOut': 'Sign Out',
      
      // Calendar
      'calendar': 'Calendar',
      'dailyView': 'Daily View',
      'weeklyView': 'Weekly View',
      'monthlyView': 'Monthly View',
      'today': 'Today',
      'currentTime': 'Current Time',
      'noClassesToday': 'No classes today',
      'noClassesThisWeek': 'No classes this week',
      
      // Course management
      'courses': 'Courses',
      'addCourse': 'Add Course',
      'editCourse': 'Edit Course',
      'deleteCourse': 'Delete Course',
      'courseCode': 'Course Code',
      'courseName': 'Course Name',
      'classCode': 'Class Code',
      'classType': 'Class Type',
      'weeklyHours': 'Weekly Hours',
      'instructor': 'Instructor',
      'location': 'Location',
      'schedule': 'Schedule',
      
      // Course types
      'lecture': 'Lecture',
      'practice': 'Practice',
      'lab': 'Laboratory',
      
      // Days of week
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday',
      'sunday': 'Sunday',
      
      // Months
      'january': 'January',
      'february': 'February',
      'march': 'March',
      'april': 'April',
      'may': 'May',
      'june': 'June',
      'july': 'July',
      'august': 'August',
      'september': 'September',
      'october': 'October',
      'november': 'November',
      'december': 'December',
      
      // Excel import
      'importExcel': 'Import Excel',
      'selectFile': 'Select File',
      'uploadFile': 'Upload File',
      'parseExcel': 'Parse Excel',
      'importSuccess': 'Import Successful',
      'importError': 'Import Error',
      'invalidFile': 'Invalid File',
      'requiredColumns': 'Required columns missing',
      
      // Semester management
      'semester': 'Semester',
      'currentSemester': 'current semester',
      'nextSemester': 'next semester',
      'selectSemester': 'Select Semester',
      
      // Settings
      'settings': 'Settings',
      'language': 'Language',
      'theme': 'Theme',
      'notifications': 'Notifications',
      'exportCalendar': 'Export Calendar',
      'about': 'About',
      
      // Theme and Settings
      'themeSettings': 'Theme Settings',
      'academicSettings': 'Academic Settings',
      'manageSemesters': 'Manage Semesters',
      'manageSemestersDesc': 'Add, edit, and organize your academic semesters',
      'notificationSettings': 'Notification Settings',
      'notificationSettingsDesc': 'Manage your notification preferences',
      'syncSettings': 'Sync & Data',
      'syncSettingsDesc': 'Manage data synchronization and backup',
      'account': 'Account',
      
      // Language names
      'hungarian': 'Hungarian',
      'english': 'English',
      'german': 'German',
      
      // Notifications
      'classReminder': 'Class Reminder',
      'minutesBefore': 'minutes before',
      'dailySummary': 'Daily Summary',
      
      // Common
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'close': 'Close',
      'confirm': 'Confirm',
      'yes': 'Yes',
      'no': 'No',
      'ok': 'OK',
      'error': 'Error',
      'success': 'Success',
      'loading': 'Loading...',
      'retry': 'Retry',
      
      // Error messages
      'networkError': 'Network Error',
      'authError': 'Authentication Error',
      'permissionDenied': 'Permission Denied',
      'fileNotFound': 'File Not Found',
      'invalidFormat': 'Invalid Format',
    },
    
    'de': {
      // Authentication
      'login': 'Anmelden',
      'register': 'Registrieren',
      'email': 'E-Mail',
      'password': 'Passwort',
      'confirmPassword': 'Passwort bestätigen',
      'forgotPassword': 'Passwort vergessen',
      'resetPassword': 'Passwort zurücksetzen',
      'signInWithGoogle': 'Mit Google anmelden',
      'signInWithApple': 'Mit Apple anmelden',
      'logout': 'Abmelden',
      'emailVerification': 'E-Mail-Verifizierung',
      'emailVerificationSent': 'Bestätigungs-E-Mail gesendet',
      'signOut': 'Abmelden',
      
      // Calendar
      'calendar': 'Kalender',
      'dailyView': 'Tagesansicht',
      'weeklyView': 'Wochenansicht',
      'monthlyView': 'Monatsansicht',
      'today': 'Heute',
      'currentTime': 'Aktuelle Zeit',
      'noClassesToday': 'Heute keine Kurse',
      'noClassesThisWeek': 'Diese Woche keine Kurse',
      
      // Course management
      'courses': 'Kurse',
      'addCourse': 'Kurs hinzufügen',
      'editCourse': 'Kurs bearbeiten',
      'deleteCourse': 'Kurs löschen',
      'courseCode': 'Kurscode',
      'courseName': 'Kursname',
      'classCode': 'Klassencode',
      'classType': 'Kurstyp',
      'weeklyHours': 'Wöchentliche Stunden',
      'instructor': 'Dozent',
      'location': 'Ort',
      'schedule': 'Stundenplan',
      
      // Course types
      'lecture': 'Vorlesung',
      'practice': 'Übung',
      'lab': 'Labor',
      
      // Days of week
      'monday': 'Montag',
      'tuesday': 'Dienstag',
      'wednesday': 'Mittwoch',
      'thursday': 'Donnerstag',
      'friday': 'Freitag',
      'saturday': 'Samstag',
      'sunday': 'Sonntag',
      
      // Months
      'january': 'Januar',
      'february': 'Februar',
      'march': 'März',
      'april': 'April',
      'may': 'Mai',
      'june': 'Juni',
      'july': 'Juli',
      'august': 'August',
      'september': 'September',
      'october': 'Oktober',
      'november': 'November',
      'december': 'Dezember',
      
      // Excel import
      'importExcel': 'Excel importieren',
      'selectFile': 'Datei auswählen',
      'uploadFile': 'Datei hochladen',
      'parseExcel': 'Excel verarbeiten',
      'importSuccess': 'Import erfolgreich',
      'importError': 'Import-Fehler',
      'invalidFile': 'Ungültige Datei',
      'requiredColumns': 'Erforderliche Spalten fehlen',
      
      // Semester management
      'semester': 'Semester',
      'currentSemester': 'aktuelles Semester',
      'nextSemester': 'nächstes Semester',
      'selectSemester': 'Semester auswählen',
      
      // Settings
      'settings': 'Einstellungen',
      'language': 'Sprache',
      'theme': 'Design',
      'notifications': 'Benachrichtigungen',
      'exportCalendar': 'Kalender exportieren',
      'about': 'Über',
      
      // Theme and Settings
      'themeSettings': 'Design-Einstellungen',
      'academicSettings': 'Studieneinstellungen',
      'manageSemesters': 'Semester verwalten',
      'manageSemestersDesc': 'Hinzufügen, bearbeiten und organisieren Sie Ihre Studiensemester',
      'notificationSettings': 'Benachrichtigungseinstellungen',
      'notificationSettingsDesc': 'Verwalten Sie Ihre Benachrichtigungseinstellungen',
      'syncSettings': 'Synchronisation & Daten',
      'syncSettingsDesc': 'Datensynchronisation und Backup verwalten',
      'account': 'Konto',
      
      // Language names
      'hungarian': 'Ungarisch',
      'english': 'Englisch',
      'german': 'Deutsch',
      
      // Notifications
      'classReminder': 'Kurserinnerung',
      'minutesBefore': 'Minuten vorher',
      'dailySummary': 'Tägliche Zusammenfassung',
      
      // Common
      'save': 'Speichern',
      'cancel': 'Abbrechen',
      'delete': 'Löschen',
      'edit': 'Bearbeiten',
      'add': 'Hinzufügen',
      'close': 'Schließen',
      'confirm': 'Bestätigen',
      'yes': 'Ja',
      'no': 'Nein',
      'ok': 'OK',
      'error': 'Fehler',
      'success': 'Erfolgreich',
      'loading': 'Laden...',
      'retry': 'Wiederholen',
      
      // Error messages
      'networkError': 'Netzwerkfehler',
      'authError': 'Authentifizierungsfehler',
      'permissionDenied': 'Zugriff verweigert',
      'fileNotFound': 'Datei nicht gefunden',
      'invalidFormat': 'Ungültiges Format',
    },
  };

  /// Get localized string with fallback
  String getString(String key) {
    final languageMap = _localizedStrings[locale.languageCode];
    return languageMap?[key] ?? key;
  }

  // Commonly used strings with getters for easier access
  String get login => getString('login');
  String get register => getString('register');
  String get email => getString('email');
  String get password => getString('password');
  String get calendar => getString('calendar');
  String get courses => getString('courses');
  String get settings => getString('settings');
  String get save => getString('save');
  String get cancel => getString('cancel');
  String get loading => getString('loading');
  String get error => getString('error');
  String get success => getString('success');
}

/// Localization delegate implementation
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((supportedLocale) => supportedLocale.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}