// File: lib/services/calendar_service.dart
// Purpose: Calendar service for managing calendar state and course display
// Step: 4.1 - Calendar Service Implementation

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../models/course_type.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../services/semester_service.dart';

/// Calendar view types as specified
enum CalendarViewType { daily, weekly, monthly }

/// Service for managing calendar state and course data
class CalendarService extends ChangeNotifier {
  final FirebaseService _firebaseService;
  final AuthService _authService;
  final SemesterService _semesterService;

  // Calendar state
  CalendarViewType _currentView = CalendarViewType.weekly;
  DateTime _selectedDate = DateTime.now();
  String? _currentSemester;
  List<Course> _courses = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Cache for performance
  final Map<String, List<Course>> _courseCache = {};

  CalendarService(this._firebaseService, this._authService, this._semesterService) {
    _currentSemester = _semesterService.currentSemester?.id;
    debugPrint('🏗️ CalendarService: Initialized with current semester: $_currentSemester');
    debugPrint('🏗️ CalendarService: Available semesters: ${_semesterService.availableSemesters.map((s) => s.id).toList()}');
    _loadCoursesForCurrentSemester();
  }

  // Getters
  CalendarViewType get currentView => _currentView;
  DateTime get selectedDate => _selectedDate;
  String? get currentSemester => _currentSemester;
  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Change calendar view type
  void setViewType(CalendarViewType viewType) {
    if (_currentView != viewType) {
      _currentView = viewType;
      notifyListeners();
    }
  }

  /// Change selected date
  void setSelectedDate(DateTime date) {
    if (_selectedDate != date) {
      _selectedDate = date;
      notifyListeners();
    }
  }

  /// Change current semester
  Future<void> setCurrentSemester(String? semesterId) async {
    if (_currentSemester != semesterId) {
      _currentSemester = semesterId;
      await _loadCoursesForCurrentSemester();
      notifyListeners();
    }
  }

  /// Navigate to today
  void goToToday() {
    setSelectedDate(DateTime.now());
  }

  /// Navigate to previous period (day/week/month)
  void goToPrevious() {
    switch (_currentView) {
      case CalendarViewType.daily:
        setSelectedDate(_selectedDate.subtract(const Duration(days: 1)));
        break;
      case CalendarViewType.weekly:
        setSelectedDate(_selectedDate.subtract(const Duration(days: 7)));
        break;
      case CalendarViewType.monthly:
        setSelectedDate(DateTime(_selectedDate.year, _selectedDate.month - 1, _selectedDate.day));
        break;
    }
  }

  /// Navigate to next period (day/week/month)
  void goToNext() {
    switch (_currentView) {
      case CalendarViewType.daily:
        setSelectedDate(_selectedDate.add(const Duration(days: 1)));
        break;
      case CalendarViewType.weekly:
        setSelectedDate(_selectedDate.add(const Duration(days: 7)));
        break;
      case CalendarViewType.monthly:
        setSelectedDate(DateTime(_selectedDate.year, _selectedDate.month + 1, _selectedDate.day));
        break;
    }
  }

  /// Get courses for a specific date
  List<Course> getCoursesForDate(DateTime date) {
    final weekday = date.weekday;
    debugPrint('📅 CalendarService: Getting courses for date ${date.toIso8601String()} (weekday: $weekday)');
    debugPrint('📅 CalendarService: Total courses available: ${_courses.length}');
    
    final coursesForDate = _courses.where((course) {
      final hasSlotForDay = course.scheduleSlots.any((slot) => slot.dayOfWeek == weekday);
      if (hasSlotForDay) {
        debugPrint('📅 CalendarService: Course ${course.courseName} has slot for weekday $weekday');
        for (final slot in course.scheduleSlots) {
          if (slot.dayOfWeek == weekday) {
            debugPrint('📅 CalendarService: - Slot: ${slot.startTime} - ${slot.endTime}');
          }
        }
      }
      return hasSlotForDay;
    }).toList();
    
    debugPrint('📅 CalendarService: Found ${coursesForDate.length} courses for date');
    return coursesForDate;
  }

  /// Get courses for a specific week
  Map<DateTime, List<Course>> getCoursesForWeek(DateTime weekStart) {
    final weekCourses = <DateTime, List<Course>>{};
    
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      weekCourses[date] = getCoursesForDate(date);
    }
    
    return weekCourses;
  }

  /// Get courses for a specific month
  Map<DateTime, List<Course>> getCoursesForMonth(DateTime monthStart) {
    final monthCourses = <DateTime, List<Course>>{};
    
    // Get all days in the month
    final daysInMonth = DateTime(monthStart.year, monthStart.month + 1, 0).day;
    
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(monthStart.year, monthStart.month, i);
      final coursesForDay = getCoursesForDate(date);
      if (coursesForDay.isNotEmpty) {
        monthCourses[date] = coursesForDay;
      }
    }
    
    return monthCourses;
  }

  /// Get course schedule slots for a specific date
  List<ScheduleSlot> getScheduleSlotsForDate(DateTime date) {
    final weekday = date.weekday;
    final List<ScheduleSlot> slots = [];
    
    debugPrint('📅 CalendarService: Getting schedule slots for date ${date.toIso8601String()} (weekday: $weekday)');
    
    for (final course in _courses) {
      final courseSlots = course.scheduleSlots
          .where((slot) => slot.dayOfWeek == weekday)
          .map((slot) => slot.copyWith(
            courseId: course.id,
            displayColor: course.displayColor,
          ));
      
      if (courseSlots.isNotEmpty) {
        debugPrint('📅 CalendarService: Adding ${courseSlots.length} slots for course ${course.courseName}');
      }
      
      slots.addAll(courseSlots);
    }
    
    // Sort by start time
    slots.sort((a, b) => a.startTime.compareTo(b.startTime));
    
    debugPrint('📅 CalendarService: Total slots for date: ${slots.length}');
    return slots;
  }

  /// Check if a date is today
  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  /// Check if a date is in the current week
  bool isCurrentWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Check if a date is in the current month
  bool isCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Get the start of the week for a given date
  DateTime getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  /// Get the start of the month for a given date
  DateTime getMonthStart(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get current time as TimeOfDay
  TimeOfDay getCurrentTime() {
    return TimeOfDay.now();
  }

  /// Check if current time is within a schedule slot
  bool isCurrentTimeInSlot(ScheduleSlot slot) {
    if (!isToday(_selectedDate)) return false;
    
    final now = getCurrentTime();
    return now.isAfter(slot.startTime) && now.isBefore(slot.endTime);
  }

  /// Get next upcoming class today
  ScheduleSlot? getNextClassToday() {
    final todaySlots = getScheduleSlotsForDate(_selectedDate);
    final currentTime = getCurrentTime();
    
    for (final slot in todaySlots) {
      if (slot.startTime.isAfter(currentTime)) {
        return slot;
      }
    }
    
    return null;
  }

  /// Load courses for current semester
  Future<void> _loadCoursesForCurrentSemester() async {
    if (_currentSemester == null) {
      debugPrint('📅 CalendarService: No current semester set, clearing courses');
      _courses = [];
      _errorMessage = null;
      return;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final user = _authService.currentUser;
      if (user == null) {
        debugPrint('❌ CalendarService: User not authenticated');
        throw Exception('User not authenticated');
      }

      debugPrint('📅 CalendarService: Loading courses for user ${user.uid}, semester $_currentSemester');

      // Check cache first
      final cacheKey = '${user.uid}_$_currentSemester';
      if (_courseCache.containsKey(cacheKey)) {
        _courses = _courseCache[cacheKey]!;
        debugPrint('📅 CalendarService: Loaded ${_courses.length} courses from cache');
        _setLoading(false);
        return;
      }

      // Load from Firebase
      final courses = await _firebaseService.getCourses(user.uid, _currentSemester!);
      
      // Cache the results
      _courseCache[cacheKey] = courses;
      _courses = courses;
      
      debugPrint('📅 CalendarService: Loaded ${courses.length} courses from Firebase for semester $_currentSemester');

    } catch (e) {
      debugPrint('❌ CalendarService: Error loading courses: $e');
      _errorMessage = e.toString();
      _courses = [];
    } finally {
      _setLoading(false);
      // Ensure listeners are notified even if there was an error
      notifyListeners();
    }
  }

  /// Refresh courses from Firebase
  Future<void> refreshCourses() async {
    debugPrint('🔄 CalendarService: Starting course refresh');
    debugPrint('🔄 CalendarService: Current semester: $_currentSemester');
    
    // Clear cache
    if (_currentSemester != null) {
      final user = _authService.currentUser;
      if (user != null) {
        final cacheKey = '${user.uid}_$_currentSemester';
        _courseCache.remove(cacheKey);
        debugPrint('🔄 CalendarService: Cleared cache for key: $cacheKey');
      }
    }
    
    await _loadCoursesForCurrentSemester();
    debugPrint('🔄 CalendarService: Course refresh completed. Current course count: ${_courses.length}');
    notifyListeners();
  }

  /// Add or update a course
  Future<void> saveCourse(Course course) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      if (_currentSemester == null) {
        throw Exception('No semester selected');
      }

      // Save to Firebase
      await _firebaseService.saveCourse(user.uid, course);
      
      // Update local state
      final index = _courses.indexWhere((c) => c.id == course.id);
      if (index != -1) {
        _courses[index] = course;
      } else {
        _courses.add(course);
      }

      // Update cache
      final cacheKey = '${user.uid}_$_currentSemester';
      _courseCache[cacheKey] = List.from(_courses);
      
      notifyListeners();
      debugPrint('Course saved: ${course.name}');
      
    } catch (e) {
      debugPrint('Error saving course: $e');
      rethrow;
    }
  }

  /// Delete a course
  Future<void> deleteCourse(String courseId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      if (_currentSemester == null) {
        throw Exception('No semester selected');
      }

      // Delete from Firebase
      await _firebaseService.deleteCourse(user.uid, courseId);
      
      // Update local state
      _courses.removeWhere((course) => course.id == courseId);

      // Update cache
      final cacheKey = '${user.uid}_$_currentSemester';
      _courseCache[cacheKey] = List.from(_courses);
      
      notifyListeners();
      debugPrint('Course deleted: $courseId');
      
    } catch (e) {
      debugPrint('Error deleting course: $e');
      rethrow;
    }
  }

  /// Get course by ID
  Course? getCourseById(String courseId) {
    debugPrint('📅 CalendarService: Looking for course with ID: $courseId');
    try {
      final course = _courses.firstWhere((course) => course.id == courseId);
      debugPrint('📅 CalendarService: Found course: ${course.courseName}');
      return course;
    } catch (e) {
      debugPrint('❌ CalendarService: Course with ID $courseId not found');
      debugPrint('📅 CalendarService: Available course IDs: ${_courses.map((c) => c.id).toList()}');
      return null;
    }
  }

  /// Search courses by query
  List<Course> searchCourses(String query) {
    if (query.isEmpty) return _courses;
    
    final lowercaseQuery = query.toLowerCase();
    return _courses.where((course) {
      return course.courseName.toLowerCase().contains(lowercaseQuery) ||
             course.courseCode.toLowerCase().contains(lowercaseQuery) ||
             course.instructors.any((instructor) => 
               instructor.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  /// Filter courses by type
  List<Course> filterCoursesByType(CourseType? type) {
    if (type == null) return _courses;
    return _courses.where((course) => course.type == type).toList();
  }

  /// Get course statistics
  Map<String, dynamic> getCourseStatistics() {
    if (_courses.isEmpty) {
      return {
        'totalCourses': 0,
        'totalCredits': 0,
        'hoursPerWeek': 0.0,
        'coursesByType': <String, int>{},
      };
    }

    final totalCredits = _courses.fold<int>(
      0, 
      (sum, course) => sum + course.credits,
    );

    double totalWeeklyMinutes = 0;
    for (final course in _courses) {
      for (final slot in course.scheduleSlots) {
        final startMinutes = slot.startTime.hour * 60 + slot.startTime.minute;
        final endMinutes = slot.endTime.hour * 60 + slot.endTime.minute;
        totalWeeklyMinutes += endMinutes - startMinutes;
      }
    }
    final hoursPerWeek = totalWeeklyMinutes / 60;

    final coursesByType = <String, int>{};
    for (final course in _courses) {
      final typeName = CourseType.fromString(course.type)?.displayName ?? course.type;
      coursesByType[typeName] = (coursesByType[typeName] ?? 0) + 1;
    }

    return {
      'totalCourses': _courses.length,
      'totalCredits': totalCredits,
      'hoursPerWeek': hoursPerWeek,
      'coursesByType': coursesByType,
    };
  }

  /// Set loading state
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Clear cache
  void clearCache() {
    _courseCache.clear();
  }

  /// Get formatted title for current view
  String getFormattedTitle() {
    switch (_currentView) {
      case CalendarViewType.daily:
        return _formatDayTitle(_selectedDate);
      case CalendarViewType.weekly:
        final weekStart = getWeekStart(_selectedDate);
        final weekEnd = weekStart.add(const Duration(days: 6));
        return '${_formatDayTitle(weekStart)} - ${_formatDayTitle(weekEnd)}';
      case CalendarViewType.monthly:
        return _formatMonthTitle(_selectedDate);
    }
  }

  /// Format day title
  String _formatDayTitle(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    if (isToday(date)) {
      return 'Today, ${months[date.month - 1]} ${date.day}';
    }
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Format month title
  String _formatMonthTitle(DateTime date) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                   'July', 'August', 'September', 'October', 'November', 'December'];
    
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  void dispose() {
    clearCache();
    super.dispose();
  }
}