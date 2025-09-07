// File: lib/services/notification_service.dart
// Purpose: Comprehensive notification management system with course reminders
// Step: 7.1 - Notification Service Implementation

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/course_model.dart';
import '../models/notification_model.dart';
import 'auth_service.dart';
import 'firebase_service.dart';
import 'calendar_service.dart';
import 'semester_service.dart';

/// Comprehensive notification service handling push notifications, 
/// course reminders, and user notification preferences
class NotificationService extends ChangeNotifier {
  static const String _logTag = 'NotificationService';

  // Dependencies
  final AuthService _authService;
  final FirebaseService _firebaseService;
  final CalendarService _calendarService;
  final SemesterService _semesterService;

  // State
  bool _isInitialized = false;
  bool _notificationsEnabled = true;
  List<AppNotification> _notifications = [];
  Map<String, bool> _notificationPreferences = {};
  Timer? _reminderTimer;
  
  // Notification types
  static const String courseReminderType = 'course_reminder';
  static const String scheduleChangeType = 'schedule_change';
  static const String semesterUpdateType = 'semester_update';
  static const String importCompleteType = 'import_complete';
  static const String systemUpdateType = 'system_update';

  // Default preferences
  static const Map<String, bool> _defaultPreferences = {
    courseReminderType: true,
    scheduleChangeType: true,
    semesterUpdateType: true,
    importCompleteType: true,
    systemUpdateType: false,
  };

  // Constructor
  NotificationService(
    this._authService,
    this._firebaseService,
    this._calendarService,
    this._semesterService,
  );

  // Getters
  bool get isInitialized => _isInitialized;
  bool get notificationsEnabled => _notificationsEnabled;
  List<AppNotification> get notifications => _notifications;
  Map<String, bool> get notificationPreferences => _notificationPreferences;
  
  /// Get unread notifications count
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  
  /// Get recent notifications (last 24 hours)
  List<AppNotification> get recentNotifications {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return _notifications
        .where((n) => n.timestamp.isAfter(yesterday))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      debugPrint('$_logTag: Initializing notification service');

      // Load user preferences
      await _loadNotificationPreferences();
      
      // Load existing notifications
      await _loadNotifications();
      
      // Request notification permissions
      await _requestNotificationPermissions();
      
      // Set up listeners
      _setupListeners();
      
      // Start reminder timer
      _startReminderTimer();
      
      _isInitialized = true;
      debugPrint('$_logTag: Notification service initialized');
      notifyListeners();
      
    } catch (e) {
      debugPrint('$_logTag: Error initializing notification service: $e');
      throw Exception('Failed to initialize notification service: $e');
    }
  }

  /// Request notification permissions
  Future<bool> _requestNotificationPermissions() async {
    try {
      // TODO: Implement platform-specific notification permission request
      // For now, return true as permissions would be handled by platform
      debugPrint('$_logTag: Notification permissions requested');
      return true;
    } catch (e) {
      debugPrint('$_logTag: Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Load notification preferences from storage
  Future<void> _loadNotificationPreferences() async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        _notificationPreferences = Map.from(_defaultPreferences);
        return;
      }

      // Load from Firebase or local storage
      final prefs = await _firebaseService.getUserNotificationPreferences(user.uid);
      _notificationPreferences = prefs ?? Map.from(_defaultPreferences);
      
      debugPrint('$_logTag: Loaded notification preferences');
    } catch (e) {
      debugPrint('$_logTag: Error loading preferences, using defaults: $e');
      _notificationPreferences = Map.from(_defaultPreferences);
    }
  }

  /// Load existing notifications
  Future<void> _loadNotifications() async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        _notifications = [];
        return;
      }

      _notifications = await _firebaseService.getUserNotifications(user.uid);
      
      // Sort by timestamp (newest first)
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      debugPrint('$_logTag: Loaded ${_notifications.length} notifications');
    } catch (e) {
      debugPrint('$_logTag: Error loading notifications: $e');
      _notifications = [];
    }
  }

  /// Set up listeners for various app events
  void _setupListeners() {
    // Listen to calendar service for schedule changes
    _calendarService.addListener(_onCalendarChanged);
    
    // Listen to semester service for semester changes
    _semesterService.addListener(_onSemesterChanged);
    
    debugPrint('$_logTag: Event listeners set up');
  }

  /// Start reminder timer for course notifications
  void _startReminderTimer() {
    _reminderTimer?.cancel();
    
    // Check every minute for upcoming courses
    _reminderTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkUpcomingCourses();
    });
    
    debugPrint('$_logTag: Reminder timer started');
  }

  /// Check for upcoming courses and send reminders
  void _checkUpcomingCourses() {
    if (!_notificationsEnabled || !(_notificationPreferences[courseReminderType] ?? false)) {
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentTime = TimeOfDay.fromDateTime(now);
    
    // Get today's courses
    final todayCourses = _calendarService.getCoursesForDate(today);
    
    for (final course in todayCourses) {
      for (final slot in course.scheduleSlots) {
        if (slot.dayOfWeek == now.weekday) {
          // Check if course starts in 15 minutes
          final reminderTime = _subtractMinutes(slot.startTime, 15);
          
          if (_isTimeApproaching(currentTime, reminderTime, const Duration(minutes: 1))) {
            _sendCourseReminder(course, slot);
          }
        }
      }
    }
  }

  /// Send course reminder notification
  void _sendCourseReminder(Course course, ScheduleSlot slot) async {
    // Check if we already sent a reminder for this course today
    final notificationId = 'course_reminder_${course.id}_${DateTime.now().day}';
    
    if (_notifications.any((n) => n.id == notificationId)) {
      return; // Already sent today
    }

    final notification = AppNotification(
      id: notificationId,
      type: courseReminderType,
      title: 'Course Reminder',
      message: '${course.name} starts in 15 minutes${' at ${slot.location}'}',
      timestamp: DateTime.now(),
      isRead: false,
      data: {
        'courseId': course.id,
        'courseName': course.name,
        'startTime': '${slot.startTime.hour.toString().padLeft(2, '0')}:${slot.startTime.minute.toString().padLeft(2, '0')}',
        'location': slot.location,
      },
    );

    await _addNotification(notification);
    _showNotification(notification);
    
    debugPrint('$_logTag: Sent course reminder for ${course.name}');
  }

  /// Calendar changed event handler
  void _onCalendarChanged() {
    // Send schedule change notification if significant changes occurred
    _sendScheduleChangeNotification();
  }

  /// Semester changed event handler  
  void _onSemesterChanged() {
    final currentSemester = _semesterService.currentSemester;
    if (currentSemester != null) {
      _sendSemesterUpdateNotification(currentSemester.displayName);
    }
  }

  /// Send schedule change notification
  void _sendScheduleChangeNotification() async {
    if (!(_notificationPreferences[scheduleChangeType] ?? false)) {
      return;
    }

    final notification = AppNotification(
      id: 'schedule_change_${DateTime.now().millisecondsSinceEpoch}',
      type: scheduleChangeType,
      title: 'Schedule Updated',
      message: 'Your course schedule has been updated',
      timestamp: DateTime.now(),
      isRead: false,
    );

    await _addNotification(notification);
    _showNotification(notification);
  }

  /// Send semester update notification
  void _sendSemesterUpdateNotification(String semesterName) async {
    if (!(_notificationPreferences[semesterUpdateType] ?? false)) {
      return;
    }

    final notification = AppNotification(
      id: 'semester_update_${DateTime.now().millisecondsSinceEpoch}',
      type: semesterUpdateType,
      title: 'Semester Changed',
      message: 'Now viewing $semesterName',
      timestamp: DateTime.now(),
      isRead: false,
      data: {'semesterName': semesterName},
    );

    await _addNotification(notification);
    _showNotification(notification);
  }

  /// Send import complete notification
  Future<void> sendImportCompleteNotification(int courseCount) async {
    if (!(_notificationPreferences[importCompleteType] ?? false)) {
      return;
    }

    final notification = AppNotification(
      id: 'import_complete_${DateTime.now().millisecondsSinceEpoch}',
      type: importCompleteType,
      title: 'Import Complete',
      message: 'Successfully imported $courseCount course${courseCount != 1 ? 's' : ''}',
      timestamp: DateTime.now(),
      isRead: false,
      data: {'courseCount': courseCount},
    );

    await _addNotification(notification);
    _showNotification(notification);
  }

  /// Send system update notification
  Future<void> sendSystemNotification(String title, String message) async {
    if (!(_notificationPreferences[systemUpdateType] ?? false)) {
      return;
    }

    final notification = AppNotification(
      id: 'system_${DateTime.now().millisecondsSinceEpoch}',
      type: systemUpdateType,
      title: title,
      message: message,
      timestamp: DateTime.now(),
      isRead: false,
    );

    await _addNotification(notification);
    _showNotification(notification);
  }

  /// Add notification to list and save
  Future<void> _addNotification(AppNotification notification) async {
    _notifications.insert(0, notification);
    
    // Keep only the last 100 notifications
    if (_notifications.length > 100) {
      _notifications = _notifications.take(100).toList();
    }
    
    // Save to Firebase
    final user = _authService.currentUser;
    if (user != null) {
      try {
        await _firebaseService.saveUserNotifications(user.uid, _notifications);
      } catch (e) {
        debugPrint('$_logTag: Error saving notifications: $e');
      }
    }
    
    notifyListeners();
  }

  /// Show platform notification
  void _showNotification(AppNotification notification) {
    // TODO: Implement platform-specific notification display
    // For now, just log the notification
    debugPrint('$_logTag: Showing notification: ${notification.title} - ${notification.message}');
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      
      // Save to Firebase
      final user = _authService.currentUser;
      if (user != null) {
        try {
          await _firebaseService.saveUserNotifications(user.uid, _notifications);
        } catch (e) {
          debugPrint('$_logTag: Error saving notifications: $e');
        }
      }
      
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    
    // Save to Firebase
    final user = _authService.currentUser;
    if (user != null) {
      try {
        await _firebaseService.saveUserNotifications(user.uid, _notifications);
      } catch (e) {
        debugPrint('$_logTag: Error saving notifications: $e');
      }
    }
    
    notifyListeners();
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    
    // Save to Firebase
    final user = _authService.currentUser;
    if (user != null) {
      try {
        await _firebaseService.saveUserNotifications(user.uid, _notifications);
      } catch (e) {
        debugPrint('$_logTag: Error saving notifications: $e');
      }
    }
    
    notifyListeners();
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    _notifications.clear();
    
    // Save to Firebase
    final user = _authService.currentUser;
    if (user != null) {
      try {
        await _firebaseService.saveUserNotifications(user.uid, _notifications);
      } catch (e) {
        debugPrint('$_logTag: Error saving notifications: $e');
      }
    }
    
    notifyListeners();
  }

  /// Update notification preference
  Future<void> updateNotificationPreference(String type, bool enabled) async {
    _notificationPreferences[type] = enabled;
    
    // Save to Firebase
    final user = _authService.currentUser;
    if (user != null) {
      try {
        await _firebaseService.saveUserNotificationPreferences(user.uid, _notificationPreferences);
      } catch (e) {
        debugPrint('$_logTag: Error saving preferences: $e');
      }
    }
    
    notifyListeners();
  }

  /// Toggle notifications globally
  Future<void> toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    
    if (!enabled) {
      _reminderTimer?.cancel();
    } else {
      _startReminderTimer();
    }
    
    // Save preference
    await updateNotificationPreference('global_enabled', enabled);
    
    notifyListeners();
  }

  /// Get notification preferences display names
  static Map<String, String> getPreferenceDisplayNames() {
    return {
      courseReminderType: 'Course Reminders',
      scheduleChangeType: 'Schedule Changes',
      semesterUpdateType: 'Semester Updates',
      importCompleteType: 'Import Notifications',
      systemUpdateType: 'System Updates',
    };
  }

  /// Helper method to subtract minutes from TimeOfDay
  TimeOfDay _subtractMinutes(TimeOfDay time, int minutes) {
    final totalMinutes = time.hour * 60 + time.minute - minutes;
    if (totalMinutes < 0) {
      return TimeOfDay(hour: (24 + totalMinutes ~/ 60) % 24, minute: totalMinutes % 60);
    }
    return TimeOfDay(hour: totalMinutes ~/ 60, minute: totalMinutes % 60);
  }

  /// Helper method to check if current time is approaching target time
  bool _isTimeApproaching(TimeOfDay current, TimeOfDay target, Duration tolerance) {
    final currentMinutes = current.hour * 60 + current.minute;
    final targetMinutes = target.hour * 60 + target.minute;
    final toleranceMinutes = tolerance.inMinutes;
    
    return (currentMinutes >= targetMinutes - toleranceMinutes && 
            currentMinutes <= targetMinutes + toleranceMinutes);
  }

  /// Dispose resources
  @override
  void dispose() {
    _reminderTimer?.cancel();
    _calendarService.removeListener(_onCalendarChanged);
    _semesterService.removeListener(_onSemesterChanged);
    debugPrint('$_logTag: Notification service disposed');
    super.dispose();
  }
}