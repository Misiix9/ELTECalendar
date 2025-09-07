// File: lib/services/firebase_service.dart
// Purpose: Firebase Firestore and Storage service following specification
// Step: 2.1 - Firebase Service Implementation

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../models/course_model.dart';
import '../models/notification_model.dart';
import '../utils/constants.dart';

/// Firebase service for Firestore and Storage operations
/// Follows the technical specification database structure exactly
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Initialize Firebase service with offline persistence
  Future<void> initialize() async {
    try {
      // For mobile platforms, offline persistence is enabled by default
      // For web, we'll skip persistence setup due to API differences
      
      if (kDebugMode) {
        print('Firebase service initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize Firebase service: $e');
      }
      // Non-critical error, continue without persistence
    }
  }

  /// Save user profile to Firestore following specification structure
  /// users/{userId}/profile/profile
  Future<void> saveUserProfile(StudentUser user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .collection(AppConstants.profileSubcollection)
          .doc('profile')
          .set(user.toFirestore(), SetOptions(merge: true));

      if (kDebugMode) {
        print('User profile saved for ${user.uid}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save user profile: $e');
      }
      throw Exception('Failed to save user profile: $e');
    }
  }

  /// Get user profile from Firestore
  Future<StudentUser?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.profileSubcollection)
          .doc('profile')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        return StudentUser(
          uid: userId,
          email: data['email'] ?? '',
          displayName: data['displayName'] ?? '',
          emailVerified: data['emailVerified'] ?? false,
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          currentSemester: data['currentSemester'] ?? '',
          lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
          profileImageUrl: data['profileImageUrl'],
          preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
        );
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get user profile: $e');
      }
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Save courses for a semester following specification structure
  /// users/{userId}/semesters/{semesterId}/courses/{courseId}
  Future<void> saveCourses(String userId, String semesterId, List<Course> courses) async {
    try {
      debugPrint('🔥 FirebaseService: Starting to save ${courses.length} courses for user $userId, semester $semesterId');
      
      final batch = _firestore.batch();
      final semesterRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.semestersSubcollection)
          .doc(semesterId);

      // Clear existing courses for this semester (overwrite as specified)
      final existingCourses = await semesterRef
          .collection(AppConstants.coursesSubcollection)
          .get();

      debugPrint('🔥 FirebaseService: Deleting ${existingCourses.docs.length} existing courses');
      for (final doc in existingCourses.docs) {
        batch.delete(doc.reference);
      }

      // Add new courses
      for (final course in courses) {
        final courseRef = semesterRef
            .collection(AppConstants.coursesSubcollection)
            .doc(course.id);
        final courseData = course.toFirestore();
        debugPrint('🔥 FirebaseService: Adding course ${course.courseCode} - ${course.courseName}');
        debugPrint('🔥 FirebaseService: Course data keys: ${courseData.keys.toList()}');
        batch.set(courseRef, courseData);
      }

      // Update semester metadata
      batch.set(semesterRef, {
        'lastUpdated': FieldValue.serverTimestamp(),
        'courseCount': courses.length,
      }, SetOptions(merge: true));

      await batch.commit();
      debugPrint('🔥 FirebaseService: Successfully saved ${courses.length} courses for semester $semesterId');

      if (kDebugMode) {
        print('Saved ${courses.length} courses for semester $semesterId');
      }
    } catch (e) {
      debugPrint('❌ FirebaseService: Failed to save courses: $e');
      if (kDebugMode) {
        print('Failed to save courses: $e');
      }
      throw Exception('Failed to save courses: $e');
    }
  }

  /// Import courses to a specific semester (overwrites existing courses)
  /// Alias for saveCourses with import-specific logging
  Future<void> importCoursesToSemester(
    String userId, 
    String semesterId, 
    List<Course> courses
  ) async {
    try {
      if (kDebugMode) {
        print('Starting course import: ${courses.length} courses to semester $semesterId');
      }

      debugPrint('🚀 ImportCoursesToSemester: Starting import');
      debugPrint('🚀 ImportCoursesToSemester: User ID: $userId');
      debugPrint('🚀 ImportCoursesToSemester: Semester ID: $semesterId');
      debugPrint('🚀 ImportCoursesToSemester: Course count: ${courses.length}');

      // Use existing saveCourses method (which handles overwrite)
      await saveCourses(userId, semesterId, courses);

      // Log import success
      await _logImportActivity(userId, semesterId, courses.length);

      // Verify courses were saved by immediately reading them back
      debugPrint('🚀 ImportCoursesToSemester: Verifying import by reading back courses...');
      try {
        final savedCourses = await getCourses(userId, semesterId);
        debugPrint('🚀 ImportCoursesToSemester: Verification complete - found ${savedCourses.length} courses');
        for (final course in savedCourses) {
          debugPrint('🚀 ImportCoursesToSemester: Verified course: ${course.courseCode} - ${course.courseName}');
        }
      } catch (e) {
        debugPrint('❌ ImportCoursesToSemester: Verification failed: $e');
      }

      debugPrint('🚀 ImportCoursesToSemester: Import completed successfully');

      if (kDebugMode) {
        print('Successfully imported ${courses.length} courses to semester $semesterId');
      }
    } catch (e) {
      debugPrint('❌ ImportCoursesToSemester: Import failed: $e');
      if (kDebugMode) {
        print('Failed to import courses to semester: $e');
      }
      throw Exception('Failed to import courses: $e');
    }
  }

  /// Get courses for a specific semester
  Future<List<Course>> getCourses(String userId, String semesterId) async {
    try {
      debugPrint('🔍 FirebaseService: Loading courses for user $userId, semester $semesterId');
      
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.semestersSubcollection)
          .doc(semesterId)
          .collection(AppConstants.coursesSubcollection)
          .orderBy('courseCode')
          .get();

      debugPrint('🔍 FirebaseService: Found ${snapshot.docs.length} course documents');
      
      final courses = snapshot.docs
          .map((doc) {
            debugPrint('🔍 FirebaseService: Processing course doc ${doc.id}');
            final course = Course.fromFirestore(doc);
            debugPrint('🔍 FirebaseService: Loaded course: ${course.courseCode} - ${course.courseName}');
            return course;
          })
          .toList();

      debugPrint('🔍 FirebaseService: Successfully loaded ${courses.length} courses');
      return courses;
    } catch (e) {
      debugPrint('❌ FirebaseService: Failed to get courses: $e');
      if (kDebugMode) {
        print('Failed to get courses: $e');
      }
      throw Exception('Failed to get courses: $e');
    }
  }

  /// Get all semesters for a user
  Future<List<String>> getUserSemesters(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.semestersSubcollection)
          .orderBy('lastUpdated', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get user semesters: $e');
      }
      throw Exception('Failed to get user semesters: $e');
    }
  }

  /// Save a single course (create or update)
  Future<void> saveCourse(String userId, Course course) async {
    try {
      final semesterId = course.semester;
      if (semesterId == null) {
        throw Exception('Course must have a semester assigned');
      }

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.semestersSubcollection)
          .doc(semesterId)
          .collection(AppConstants.coursesSubcollection)
          .doc(course.id)
          .set(course.toFirestore(), SetOptions(merge: true));

      if (kDebugMode) {
        print('Saved course ${course.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save course: $e');
      }
      throw Exception('Failed to save course: $e');
    }
  }

  /// Update a single course
  Future<void> updateCourse(String userId, String semesterId, Course course) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.semestersSubcollection)
          .doc(semesterId)
          .collection(AppConstants.coursesSubcollection)
          .doc(course.id)
          .update(course.toFirestore());

      if (kDebugMode) {
        print('Updated course ${course.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update course: $e');
      }
      throw Exception('Failed to update course: $e');
    }
  }

  /// Delete a course by course ID (finds the semester automatically)
  Future<void> deleteCourse(String userId, String courseId) async {
    try {
      // Find which semester contains this course
      final userDoc = _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId);
      
      final semestersQuery = await userDoc
          .collection(AppConstants.semestersSubcollection)
          .get();

      for (final semesterDoc in semestersQuery.docs) {
        final courseDoc = await semesterDoc.reference
            .collection(AppConstants.coursesSubcollection)
            .doc(courseId)
            .get();
        
        if (courseDoc.exists) {
          await courseDoc.reference.delete();
          if (kDebugMode) {
            print('Deleted course $courseId from semester ${semesterDoc.id}');
          }
          return;
        }
      }
      
      throw Exception('Course $courseId not found in any semester');
    } catch (e) {
      if (kDebugMode) {
        print('Failed to delete course: $e');
      }
      throw Exception('Failed to delete course: $e');
    }
  }

  /// Delete a course from specific semester
  Future<void> deleteCourseFromSemester(String userId, String semesterId, String courseId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.semestersSubcollection)
          .doc(semesterId)
          .collection(AppConstants.coursesSubcollection)
          .doc(courseId)
          .delete();

      if (kDebugMode) {
        print('Deleted course $courseId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to delete course: $e');
      }
      throw Exception('Failed to delete course: $e');
    }
  }

  /// Upload Excel file to Firebase Storage
  /// Follows storage structure: excel-imports/{userId}/{semesterId}/{filename}
  Future<String> uploadExcelFile(
    String userId,
    String semesterId,
    List<int> fileBytes,
    String fileName,
  ) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = '${AppConstants.excelImportsPath}/$userId/$semesterId/${timestamp}_$fileName';
      
      final ref = _storage.ref().child(storagePath);
      
      final uploadTask = ref.putData(
        Uint8List.fromList(fileBytes),
        SettableMetadata(
          contentType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          customMetadata: {
            'userId': userId,
            'semesterId': semesterId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      if (kDebugMode) {
        print('Excel file uploaded successfully: $storagePath');
      }

      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to upload Excel file: $e');
      }
      throw Exception('Failed to upload Excel file: $e');
    }
  }

  /// Upload file to temporary storage for processing
  /// Follows storage structure: temp-uploads/{userId}/{filename}
  Future<String> uploadTempFile(
    String userId,
    List<int> fileBytes,
    String fileName,
  ) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = '${AppConstants.tempUploadsPath}/$userId/${timestamp}_$fileName';
      
      final ref = _storage.ref().child(storagePath);
      
      final uploadTask = ref.putData(
        Uint8List.fromList(fileBytes),
        SettableMetadata(
          contentType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          customMetadata: {
            'userId': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'temporary': 'true',
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Schedule cleanup after 24 hours (handled by Firebase Functions or cron job)
      _scheduleFileCleanup(storagePath);

      if (kDebugMode) {
        print('Temporary file uploaded: $storagePath');
      }

      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to upload temporary file: $e');
      }
      throw Exception('Failed to upload temporary file: $e');
    }
  }

  /// Delete temporary file
  Future<void> deleteTempFile(String filePath) async {
    try {
      await _storage.ref().child(filePath).delete();
      
      if (kDebugMode) {
        print('Deleted temporary file: $filePath');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to delete temporary file: $e');
      }
      // Non-critical error, don't throw
    }
  }

  /// Schedule file cleanup (placeholder - would be implemented with Cloud Functions)
  void _scheduleFileCleanup(String filePath) {
    // This would typically be handled by Firebase Cloud Functions
    // For now, just log the scheduling
    if (kDebugMode) {
      print('Scheduled cleanup for: $filePath');
    }
  }

  /// Search courses across all semesters
  Future<List<Course>> searchCourses(String userId, String query) async {
    try {
      // Get all user semesters
      final semesters = await getUserSemesters(userId);
      final allCourses = <Course>[];

      // Search in each semester
      for (final semesterId in semesters) {
        final courses = await getCourses(userId, semesterId);
        final filteredCourses = courses.where((course) {
          final searchText = query.toLowerCase();
          return course.courseName.toLowerCase().contains(searchText) ||
                 course.courseCode.toLowerCase().contains(searchText) ||
                 course.classCode.toLowerCase().contains(searchText) ||
                 course.instructors.any((instructor) => 
                   instructor.toLowerCase().contains(searchText));
        }).toList();
        
        allCourses.addAll(filteredCourses);
      }

      return allCourses;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to search courses: $e');
      }
      throw Exception('Failed to search courses: $e');
    }
  }

  /// Get courses by type across all semesters
  Future<List<Course>> getCoursesByType(String userId, String courseType) async {
    try {
      final semesters = await getUserSemesters(userId);
      final coursesByType = <Course>[];

      for (final semesterId in semesters) {
        final snapshot = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .collection(AppConstants.semestersSubcollection)
            .doc(semesterId)
            .collection(AppConstants.coursesSubcollection)
            .where('classType', isEqualTo: courseType)
            .get();

        final courses = snapshot.docs
            .map((doc) => Course.fromFirestore(doc))
            .toList();
        
        coursesByType.addAll(courses);
      }

      return coursesByType;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get courses by type: $e');
      }
      throw Exception('Failed to get courses by type: $e');
    }
  }

  /// Update user preferences
  Future<void> updateUserPreferences(String userId, Map<String, dynamic> preferences) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.profileSubcollection)
          .doc('profile')
          .update({
        'preferences': preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('Updated user preferences');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update user preferences: $e');
      }
      throw Exception('Failed to update user preferences: $e');
    }
  }

  /// Delete all user data (for account deletion)
  Future<void> deleteUserData(String userId) async {
    try {
      final batch = _firestore.batch();

      // Delete user profile
      final profileRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.profileSubcollection)
          .doc('profile');
      batch.delete(profileRef);

      // Delete all semesters and their courses
      final semestersSnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.semestersSubcollection)
          .get();

      for (final semesterDoc in semestersSnapshot.docs) {
        // Delete all courses in this semester
        final coursesSnapshot = await semesterDoc.reference
            .collection(AppConstants.coursesSubcollection)
            .get();
        
        for (final courseDoc in coursesSnapshot.docs) {
          batch.delete(courseDoc.reference);
        }
        
        // Delete semester document
        batch.delete(semesterDoc.reference);
      }

      // Delete user document
      batch.delete(_firestore.collection(AppConstants.usersCollection).doc(userId));

      await batch.commit();

      // Delete user files from storage
      await _deleteUserStorageFiles(userId);

      if (kDebugMode) {
        print('Deleted all user data for $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to delete user data: $e');
      }
      throw Exception('Failed to delete user data: $e');
    }
  }

  /// Delete user files from Firebase Storage
  Future<void> _deleteUserStorageFiles(String userId) async {
    try {
      // Delete Excel imports
      final excelImportsRef = _storage.ref().child('${AppConstants.excelImportsPath}/$userId');
      await _deleteStorageFolder(excelImportsRef);

      // Delete temporary uploads
      final tempUploadsRef = _storage.ref().child('${AppConstants.tempUploadsPath}/$userId');
      await _deleteStorageFolder(tempUploadsRef);

      // Delete profile images
      final profileImagesRef = _storage.ref().child('${AppConstants.profileImagesPath}/$userId');
      await _deleteStorageFolder(profileImagesRef);

      if (kDebugMode) {
        print('Deleted storage files for user $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to delete user storage files: $e');
      }
      // Non-critical error, don't throw
    }
  }

  /// Helper method to delete a storage folder and all its contents
  Future<void> _deleteStorageFolder(Reference folderRef) async {
    try {
      final listResult = await folderRef.listAll();
      
      // Delete all files in the folder
      for (final fileRef in listResult.items) {
        await fileRef.delete();
      }
      
      // Recursively delete subfolders
      for (final subfolder in listResult.prefixes) {
        await _deleteStorageFolder(subfolder);
      }
    } catch (e) {
      // Folder might not exist, which is fine
      if (kDebugMode) {
        print('Could not delete storage folder: $e');
      }
    }
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    try {
      final semesters = await getUserSemesters(userId);
      int totalCourses = 0;
      int totalHours = 0;
      final courseTypes = <String, int>{};

      for (final semesterId in semesters) {
        final courses = await getCourses(userId, semesterId);
        totalCourses += courses.length;
        
        for (final course in courses) {
          totalHours += course.weeklyHours;
          courseTypes[course.classType] = (courseTypes[course.classType] ?? 0) + 1;
        }
      }

      return {
        'totalSemesters': semesters.length,
        'totalCourses': totalCourses,
        'totalWeeklyHours': totalHours,
        'coursesByType': courseTypes,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get user statistics: $e');
      }
      throw Exception('Failed to get user statistics: $e');
    }
  }

  /// Check if service is online
  Future<bool> isOnline() async {
    try {
      await _firestore.enableNetwork();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Force sync offline changes
  Future<void> syncOfflineChanges() async {
    try {
      await _firestore.enableNetwork();
      await _firestore.waitForPendingWrites();
      
      if (kDebugMode) {
        print('Offline changes synced successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to sync offline changes: $e');
      }
      throw Exception('Failed to sync offline changes: $e');
    }
  }

  /// Log import activity for analytics and debugging
  Future<void> _logImportActivity(String userId, String semesterId, int courseCount) async {
    try {
      await _firestore
          .collection('import_logs')
          .add({
        'userId': userId,
        'semesterId': semesterId,
        'courseCount': courseCount,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'excel_import',
      });
    } catch (e) {
      // Log errors are non-critical, don't throw
      if (kDebugMode) {
        print('Failed to log import activity: $e');
      }
    }
  }

  /// Get user notifications
  Future<List<AppNotification>> getUserNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      return snapshot.docs
          .map((doc) => AppNotification.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get user notifications: $e');
      }
      return [];
    }
  }

  /// Save user notifications
  Future<void> saveUserNotifications(String userId, List<AppNotification> notifications) async {
    try {
      final batch = _firestore.batch();
      final userNotificationsRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('notifications');

      // Clear existing notifications
      final existingDocs = await userNotificationsRef.get();
      for (final doc in existingDocs.docs) {
        batch.delete(doc.reference);
      }

      // Add new notifications
      for (final notification in notifications.take(100)) { // Keep only last 100
        final docRef = userNotificationsRef.doc(notification.id);
        batch.set(docRef, notification.toFirestore());
      }

      await batch.commit();

      if (kDebugMode) {
        print('Saved ${notifications.length} notifications for user $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save user notifications: $e');
      }
      throw Exception('Failed to save user notifications: $e');
    }
  }

  /// Get user notification preferences
  Future<Map<String, bool>?> getUserNotificationPreferences(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      final data = doc.data();
      if (data != null && data.containsKey('notificationPreferences')) {
        return Map<String, bool>.from(data['notificationPreferences'] as Map);
      }

      return null; // Will use defaults
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get notification preferences: $e');
      }
      return null;
    }
  }

  /// Save user notification preferences
  Future<void> saveUserNotificationPreferences(String userId, Map<String, bool> preferences) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'notificationPreferences': preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('Saved notification preferences for user $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save notification preferences: $e');
      }
      throw Exception('Failed to save notification preferences: $e');
    }
  }
}