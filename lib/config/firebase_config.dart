// File: lib/config/firebase_config.dart
// Purpose: Firebase configuration and options
// Step: 1.1 - Initialize Flutter Project

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase configuration options for different platforms
/// This file will need to be updated with actual Firebase project credentials
/// after creating the Firebase project in Step 1.2
class DefaultFirebaseOptions {
  /// Current platform Firebase options
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// Web platform configuration
  /// TODO: Replace with actual Firebase project credentials
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'your-web-api-key',
    appId: 'your-web-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'elte-calendar',
    authDomain: 'elte-calendar.firebaseapp.com',
    storageBucket: 'elte-calendar.appspot.com',
    measurementId: 'your-measurement-id',
  );

  /// Android platform configuration
  /// TODO: Replace with actual Firebase project credentials
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-android-api-key',
    appId: 'your-android-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'elte-calendar',
    storageBucket: 'elte-calendar.appspot.com',
  );

  /// iOS platform configuration
  /// TODO: Replace with actual Firebase project credentials
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: 'your-ios-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'elte-calendar',
    storageBucket: 'elte-calendar.appspot.com',
    iosBundleId: 'com.elte.calendar',
  );

  /// macOS platform configuration
  /// TODO: Replace with actual Firebase project credentials
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'your-macos-api-key',
    appId: 'your-macos-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'elte-calendar',
    storageBucket: 'elte-calendar.appspot.com',
    iosBundleId: 'com.elte.calendar',
  );
}

/// Firebase configuration helper class
class FirebaseConfig {
  /// Initialize Firebase with error handling
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      // Enable offline persistence for Firestore
      // This will be configured when implementing Firestore service
      
      if (kDebugMode) {
        print('Firebase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Firebase: $e');
      }
      rethrow;
    }
  }

  /// Get Firebase project configuration info
  static Map<String, String> getProjectInfo() {
    final options = DefaultFirebaseOptions.currentPlatform;
    return {
      'projectId': options.projectId,
      'appId': options.appId,
      'storageBucket': options.storageBucket,
    };
  }
}

/// Firestore collection names constants
/// Following the structure defined in the technical specification
class FirestoreCollections {
  static const String users = 'users';
  static const String profile = 'profile';
  static const String semesters = 'semesters';
  static const String courses = 'courses';
}

/// Firestore security rules constants
/// Used for validation and error handling
class FirestoreRules {
  // Users can only access their own data
  static const String userDataRule = 'request.auth != null && request.auth.uid == userId';
  
  // Data validation rules
  static const List<String> requiredUserFields = [
    'email',
    'displayName', 
    'emailVerified',
    'createdAt',
  ];
  
  static const List<String> requiredCourseFields = [
    'courseCode',
    'courseName',
    'classCode', 
    'classType',
    'weeklyHours',
    'scheduleInfo',
    'instructors',
    'parsedSchedule',
  ];
}