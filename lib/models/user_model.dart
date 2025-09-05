// File: lib/models/user_model.dart
// Purpose: User data model following specification structure
// Step: 2.1 - User Data Model

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'course_model.dart';

part 'user_model.g.dart';

/// Student user model following the technical specification exactly
/// Structure: users/{userId}/profile/ and users/{userId}/semesters/
@HiveType(typeId: 0)
class StudentUser {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String displayName;

  @HiveField(3)
  final bool emailVerified;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final String currentSemester;

  @HiveField(6)
  final Map<String, List<Course>> semesters;

  @HiveField(7)
  final DateTime? lastLoginAt;

  @HiveField(8)
  final String? profileImageUrl;

  @HiveField(9)
  final Map<String, dynamic> preferences;

  /// Constructor following specification requirements
  const StudentUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.emailVerified,
    required this.createdAt,
    required this.currentSemester,
    this.semesters = const {},
    this.lastLoginAt,
    this.profileImageUrl,
    this.preferences = const {},
  });

  /// Create user from Firebase Auth User and additional data
  factory StudentUser.fromAuth({
    required String uid,
    required String email,
    required String displayName,
    required bool emailVerified,
    String? currentSemester,
    String? profileImageUrl,
    Map<String, dynamic>? preferences,
  }) {
    return StudentUser(
      uid: uid,
      email: email,
      displayName: displayName,
      emailVerified: emailVerified,
      createdAt: DateTime.now(),
      currentSemester: currentSemester ?? _calculateCurrentSemester(),
      profileImageUrl: profileImageUrl,
      preferences: preferences ?? _defaultPreferences(),
    );
  }

  /// Create user from Firestore document
  factory StudentUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return StudentUser(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      emailVerified: data['emailVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      currentSemester: data['currentSemester'] ?? _calculateCurrentSemester(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      profileImageUrl: data['profileImageUrl'],
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      semesters: _parseSemestersFromFirestore(data['semesters']),
    );
  }

  /// Convert to Firestore document format
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'emailVerified': emailVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'currentSemester': currentSemester,
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'profileImageUrl': profileImageUrl,
      'preferences': preferences,
      // Note: semesters are stored as subcollection, not in profile document
    };
  }

  /// Create copy with updated values
  StudentUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    bool? emailVerified,
    DateTime? createdAt,
    String? currentSemester,
    Map<String, List<Course>>? semesters,
    DateTime? lastLoginAt,
    String? profileImageUrl,
    Map<String, dynamic>? preferences,
  }) {
    return StudentUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      currentSemester: currentSemester ?? this.currentSemester,
      semesters: semesters ?? this.semesters,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferences: preferences ?? this.preferences,
    );
  }

  /// Get courses for specific semester
  List<Course> getCoursesForSemester(String semesterId) {
    return semesters[semesterId] ?? [];
  }

  /// Get all courses across all semesters
  List<Course> getAllCourses() {
    final allCourses = <Course>[];
    for (final courses in semesters.values) {
      allCourses.addAll(courses);
    }
    return allCourses;
  }

  /// Check if user has courses for current semester
  bool get hasCurrentSemesterCourses {
    return semesters.containsKey(currentSemester) && 
           semesters[currentSemester]!.isNotEmpty;
  }

  /// Get user preference value with default
  T getPreference<T>(String key, T defaultValue) {
    return preferences.containsKey(key) ? preferences[key] as T : defaultValue;
  }

  /// Update user preference
  StudentUser updatePreference(String key, dynamic value) {
    final newPreferences = Map<String, dynamic>.from(preferences);
    newPreferences[key] = value;
    return copyWith(preferences: newPreferences);
  }

  /// Calculate current semester based on date
  static String _calculateCurrentSemester() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    
    // Sept-Jan = 1st semester, Feb-June = 2nd semester
    if (month >= 9 || month <= 1) {
      // First semester
      final academicYear = month >= 9 ? year : year - 1;
      return '$academicYear/${(academicYear + 1).toString().substring(2)}/1';
    } else {
      // Second semester
      return '$year/${year.toString().substring(2)}/2';
    }
  }

  /// Default user preferences
  static Map<String, dynamic> _defaultPreferences() {
    return {
      'language': 'hu', // Hungarian as default per specification
      'theme': 'system',
      'notificationsEnabled': true,
      'reminderMinutes': 15,
      'calendarView': 'Weekly',
      'showWeekends': false,
      'enableOfflineMode': true,
    };
  }

  /// Parse semesters data from Firestore (if stored in profile doc)
  static Map<String, List<Course>> _parseSemestersFromFirestore(dynamic semestersData) {
    if (semestersData == null) return {};
    
    final Map<String, List<Course>> result = {};
    
    if (semestersData is Map<String, dynamic>) {
      semestersData.forEach((semesterId, coursesData) {
        if (coursesData is List) {
          result[semesterId] = coursesData
              .map((courseData) => Course.fromJson(courseData as Map<String, dynamic>))
              .toList();
        }
      });
    }
    
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is StudentUser &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        other.emailVerified == emailVerified;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        emailVerified.hashCode;
  }

  @override
  String toString() {
    return 'StudentUser{uid: $uid, email: $email, displayName: $displayName, emailVerified: $emailVerified}';
  }
}

/// User preferences constants
class UserPreferences {
  static const String language = 'language';
  static const String theme = 'theme';
  static const String notificationsEnabled = 'notificationsEnabled';
  static const String reminderMinutes = 'reminderMinutes';
  static const String calendarView = 'calendarView';
  static const String showWeekends = 'showWeekends';
  static const String enableOfflineMode = 'enableOfflineMode';
  static const String lastSyncTime = 'lastSyncTime';
  static const String autoImportExcel = 'autoImportExcel';
  static const String exportFormat = 'exportFormat';
}

/// Authentication provider types
enum AuthProviderType {
  email,
  google,
  apple,
}

/// User authentication state
enum UserAuthState {
  unknown,
  authenticated,
  unauthenticated,
  emailNotVerified,
}

/// Extension for AuthProviderType
extension AuthProviderTypeExtension on AuthProviderType {
  String get name {
    switch (this) {
      case AuthProviderType.email:
        return 'email';
      case AuthProviderType.google:
        return 'google.com';
      case AuthProviderType.apple:
        return 'apple.com';
    }
  }
}

/// User profile validation
class UserProfileValidator {
  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  /// Validate display name
  static bool isValidDisplayName(String displayName) {
    return displayName.trim().isNotEmpty && displayName.length >= 2;
  }

  /// Validate password strength
  static bool isValidPassword(String password) {
    return password.length >= 6; // Firebase minimum requirement
  }

  /// Validate complete user profile
  static List<String> validateUserProfile(StudentUser user) {
    final errors = <String>[];
    
    if (!isValidEmail(user.email)) {
      errors.add('Invalid email format');
    }
    
    if (!isValidDisplayName(user.displayName)) {
      errors.add('Display name must be at least 2 characters');
    }
    
    return errors;
  }
}