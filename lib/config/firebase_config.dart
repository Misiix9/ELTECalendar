// File: lib/config/firebase_config.dart
// Purpose: Firebase configuration and options
// Step: 1.1 - Initialize Flutter Project

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase configuration options for different platforms
/// This file will need to be updated with actual Firebase project credentials
/// after creating the Firebase project in Step 1.2
class DefaultFirebaseOptions {
  static String? _optionalEnv(String key) {
    final value = String.fromEnvironment(key);
    return value.isEmpty ? null : value;
  }

  static String _requireEnv(String key) {
    final value = String.fromEnvironment(key);
    if (value.isEmpty) {
      throw UnsupportedError(
        'Missing required Firebase config value: $key. '
        'Provide it via --dart-define.',
      );
    }
    return value;
  }

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
  static FirebaseOptions get web => FirebaseOptions(
    apiKey: _requireEnv('FIREBASE_WEB_API_KEY'),
    authDomain: _requireEnv('FIREBASE_WEB_AUTH_DOMAIN'),
    projectId: _requireEnv('FIREBASE_WEB_PROJECT_ID'),
    storageBucket: _requireEnv('FIREBASE_WEB_STORAGE_BUCKET'),
    messagingSenderId: _requireEnv('FIREBASE_WEB_MESSAGING_SENDER_ID'),
    appId: _requireEnv('FIREBASE_WEB_APP_ID'),
    // Optional for projects not using Analytics on web.
    measurementId: _optionalEnv('FIREBASE_WEB_MEASUREMENT_ID'),
  );

  /// Android platform configuration
  static FirebaseOptions get android => FirebaseOptions(
    apiKey: _requireEnv('FIREBASE_ANDROID_API_KEY'),
    appId: _requireEnv('FIREBASE_ANDROID_APP_ID'),
    messagingSenderId: _requireEnv('FIREBASE_ANDROID_MESSAGING_SENDER_ID'),
    projectId: _requireEnv('FIREBASE_ANDROID_PROJECT_ID'),
    storageBucket: _requireEnv('FIREBASE_ANDROID_STORAGE_BUCKET'),
  );

  /// iOS platform configuration
  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: _requireEnv('FIREBASE_IOS_API_KEY'),
    appId: _requireEnv('FIREBASE_IOS_APP_ID'),
    messagingSenderId: _requireEnv('FIREBASE_IOS_MESSAGING_SENDER_ID'),
    projectId: _requireEnv('FIREBASE_IOS_PROJECT_ID'),
    storageBucket: _requireEnv('FIREBASE_IOS_STORAGE_BUCKET'),
    iosBundleId: _requireEnv('FIREBASE_IOS_BUNDLE_ID'),
  );

  /// macOS platform configuration
  static FirebaseOptions get macos => FirebaseOptions(
    apiKey: _requireEnv('FIREBASE_MACOS_API_KEY'),
    appId: _requireEnv('FIREBASE_MACOS_APP_ID'),
    messagingSenderId: _requireEnv('FIREBASE_MACOS_MESSAGING_SENDER_ID'),
    projectId: _requireEnv('FIREBASE_MACOS_PROJECT_ID'),
    storageBucket: _requireEnv('FIREBASE_MACOS_STORAGE_BUCKET'),
    iosBundleId: _requireEnv('FIREBASE_MACOS_BUNDLE_ID'),
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
      'storageBucket': options.storageBucket ?? '',
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
