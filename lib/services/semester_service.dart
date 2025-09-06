// File: lib/services/semester_service.dart
// Purpose: Complete semester management service following specification
// Step: 5.1 - Semester Management System Implementation

import 'package:flutter/foundation.dart';
import '../models/semester_model.dart';

/// Comprehensive semester management service
/// Handles semester calculation, validation, and management according to Hungarian academic calendar
class SemesterService extends ChangeNotifier {
  static const String _logTag = 'SemesterService';

  // Academic year constants (Hungarian system)
  static const int _firstSemesterStartMonth = 9;  // September
  static const int _firstSemesterEndMonth = 1;    // January
  static const int _secondSemesterStartMonth = 2; // February
  static const int _secondSemesterEndMonth = 6;   // June

  // State
  Semester? _currentSemester;
  List<Semester> _availableSemesters = [];
  String? _selectedSemesterId;

  // Getters
  Semester? get currentSemester => _currentSemester;
  List<Semester> get availableSemesters => _availableSemesters;
  String? get selectedSemesterId => _selectedSemesterId;
  Semester? get selectedSemester => 
    _availableSemesters.firstWhere((s) => s.id == _selectedSemesterId, orElse: () => _currentSemester!);

  /// Initialize the semester service
  Future<void> initialize() async {
    try {
      debugPrint('$_logTag: Initializing semester service');
      
      // Calculate current semester
      _currentSemester = _calculateCurrentSemester();
      
      // Generate available semesters (current and next)
      _availableSemesters = _generateAvailableSemesters();
      
      // Set current semester as selected by default
      _selectedSemesterId = _currentSemester!.id;
      
      debugPrint('$_logTag: Current semester: ${_currentSemester!.displayName}');
      debugPrint('$_logTag: Available semesters: ${_availableSemesters.length}');
      
      notifyListeners();
    } catch (e) {
      debugPrint('$_logTag: Error initializing semester service: $e');
      throw Exception('Failed to initialize semester service: $e');
    }
  }

  /// Calculate current semester based on current date
  Semester _calculateCurrentSemester() {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    // Determine academic year and semester number
    int academicYearStart;
    int semesterNumber;

    if (currentMonth >= _firstSemesterStartMonth || currentMonth <= _firstSemesterEndMonth) {
      // First semester (September - January)
      if (currentMonth >= _firstSemesterStartMonth) {
        // September - December: current academic year starts this year
        academicYearStart = currentYear;
      } else {
        // January: current academic year started last year
        academicYearStart = currentYear - 1;
      }
      semesterNumber = 1;
    } else {
      // Second semester (February - June)
      academicYearStart = currentYear - 1;
      semesterNumber = 2;
    }

    final academicYearEnd = academicYearStart + 1;
    final semesterId = '$academicYearStart/${academicYearEnd.toString().substring(2)}/$semesterNumber';
    
    return Semester(
      id: semesterId,
      academicYearStart: academicYearStart,
      academicYearEnd: academicYearEnd,
      semesterNumber: semesterNumber,
      isCurrent: true,
      startDate: _calculateSemesterStartDate(academicYearStart, semesterNumber),
      endDate: _calculateSemesterEndDate(academicYearStart, semesterNumber),
    );
  }

  /// Generate list of available semesters (current and next)
  List<Semester> _generateAvailableSemesters() {
    final semesters = <Semester>[];
    
    // Add current semester
    semesters.add(_currentSemester!);
    
    // Add next semester
    final nextSemester = _calculateNextSemester(_currentSemester!);
    semesters.add(nextSemester);
    
    return semesters;
  }

  /// Calculate next semester
  Semester _calculateNextSemester(Semester currentSemester) {
    int nextAcademicYearStart;
    int nextSemesterNumber;

    if (currentSemester.semesterNumber == 1) {
      // Next is second semester of same academic year
      nextAcademicYearStart = currentSemester.academicYearStart;
      nextSemesterNumber = 2;
    } else {
      // Next is first semester of next academic year
      nextAcademicYearStart = currentSemester.academicYearStart + 1;
      nextSemesterNumber = 1;
    }

    final nextAcademicYearEnd = nextAcademicYearStart + 1;
    final nextSemesterId = '$nextAcademicYearStart/${nextAcademicYearEnd.toString().substring(2)}/$nextSemesterNumber';

    return Semester(
      id: nextSemesterId,
      academicYearStart: nextAcademicYearStart,
      academicYearEnd: nextAcademicYearEnd,
      semesterNumber: nextSemesterNumber,
      isCurrent: false,
      startDate: _calculateSemesterStartDate(nextAcademicYearStart, nextSemesterNumber),
      endDate: _calculateSemesterEndDate(nextAcademicYearStart, nextSemesterNumber),
    );
  }

  /// Calculate semester start date
  DateTime _calculateSemesterStartDate(int academicYearStart, int semesterNumber) {
    if (semesterNumber == 1) {
      // First semester starts in September
      return DateTime(academicYearStart, _firstSemesterStartMonth, 1);
    } else {
      // Second semester starts in February of next calendar year
      return DateTime(academicYearStart + 1, _secondSemesterStartMonth, 1);
    }
  }

  /// Calculate semester end date
  DateTime _calculateSemesterEndDate(int academicYearStart, int semesterNumber) {
    if (semesterNumber == 1) {
      // First semester ends in January of next calendar year
      return DateTime(academicYearStart + 1, _firstSemesterEndMonth + 1, 0); // Last day of January
    } else {
      // Second semester ends in June of next calendar year
      return DateTime(academicYearStart + 1, _secondSemesterEndMonth + 1, 0); // Last day of June
    }
  }

  /// Set selected semester
  void setSelectedSemester(String semesterId) {
    if (_selectedSemesterId != semesterId && 
        _availableSemesters.any((s) => s.id == semesterId)) {
      _selectedSemesterId = semesterId;
      debugPrint('$_logTag: Selected semester changed to: $semesterId');
      notifyListeners();
    }
  }

  /// Check if a semester ID is valid
  bool isValidSemesterId(String semesterId) {
    // Format: YYYY/YY/N (e.g., 2024/25/1)
    final pattern = RegExp(r'^\d{4}/\d{2}/[12]$');
    if (!pattern.hasMatch(semesterId)) {
      return false;
    }

    final parts = semesterId.split('/');
    final startYear = int.parse(parts[0]);
    final endYear = int.parse('20${parts[1]}');
    final semester = int.parse(parts[2]);

    // Validate year sequence
    if (endYear != startYear + 1) {
      return false;
    }

    // Validate semester number
    if (semester != 1 && semester != 2) {
      return false;
    }

    return true;
  }

  /// Parse semester from string ID
  Semester? parseSemesterFromId(String semesterId) {
    if (!isValidSemesterId(semesterId)) {
      return null;
    }

    final parts = semesterId.split('/');
    final academicYearStart = int.parse(parts[0]);
    final academicYearEnd = int.parse('20${parts[1]}');
    final semesterNumber = int.parse(parts[2]);

    final isCurrentSem = _currentSemester?.id == semesterId;

    return Semester(
      id: semesterId,
      academicYearStart: academicYearStart,
      academicYearEnd: academicYearEnd,
      semesterNumber: semesterNumber,
      isCurrent: isCurrentSem,
      startDate: _calculateSemesterStartDate(academicYearStart, semesterNumber),
      endDate: _calculateSemesterEndDate(academicYearStart, semesterNumber),
    );
  }

  /// Get semester by ID
  Semester? getSemesterById(String semesterId) {
    try {
      return _availableSemesters.firstWhere((s) => s.id == semesterId);
    } catch (e) {
      return null;
    }
  }

  /// Get semester display name
  String getSemesterDisplayName(String semesterId) {
    final semester = getSemesterById(semesterId) ?? parseSemesterFromId(semesterId);
    return semester?.displayName ?? semesterId;
  }

  /// Check if a date falls within a semester
  bool isDateInSemester(DateTime date, String semesterId) {
    final semester = getSemesterById(semesterId) ?? parseSemesterFromId(semesterId);
    if (semester == null) return false;

    return date.isAfter(semester.startDate.subtract(const Duration(days: 1))) &&
           date.isBefore(semester.endDate.add(const Duration(days: 1)));
  }

  /// Get current academic week within semester
  int? getCurrentAcademicWeek(String semesterId) {
    final semester = getSemesterById(semesterId) ?? parseSemesterFromId(semesterId);
    if (semester == null) return null;

    final now = DateTime.now();
    if (!isDateInSemester(now, semesterId)) {
      return null;
    }

    final daysDifference = now.difference(semester.startDate).inDays;
    return (daysDifference / 7).floor() + 1;
  }

  /// Get semester progress (0.0 - 1.0)
  double getSemesterProgress(String semesterId) {
    final semester = getSemesterById(semesterId) ?? parseSemesterFromId(semesterId);
    if (semester == null) return 0.0;

    final now = DateTime.now();
    if (now.isBefore(semester.startDate)) {
      return 0.0;
    }

    if (now.isAfter(semester.endDate)) {
      return 1.0;
    }

    final totalDuration = semester.endDate.difference(semester.startDate).inDays;
    final elapsedDuration = now.difference(semester.startDate).inDays;

    return (elapsedDuration / totalDuration).clamp(0.0, 1.0);
  }

  /// Add custom semester (for importing historical data)
  void addCustomSemester(String semesterId) {
    if (!isValidSemesterId(semesterId)) {
      throw ArgumentError('Invalid semester ID format: $semesterId');
    }

    // Check if semester already exists
    if (_availableSemesters.any((s) => s.id == semesterId)) {
      return;
    }

    final semester = parseSemesterFromId(semesterId);
    if (semester != null) {
      _availableSemesters.add(semester);
      
      // Sort semesters by academic year and semester number
      _availableSemesters.sort((a, b) {
        final yearComparison = a.academicYearStart.compareTo(b.academicYearStart);
        if (yearComparison != 0) return yearComparison;
        return a.semesterNumber.compareTo(b.semesterNumber);
      });

      debugPrint('$_logTag: Added custom semester: ${semester.displayName}');
      notifyListeners();
    }
  }

  /// Remove custom semester (cannot remove current or next semester)
  bool removeCustomSemester(String semesterId) {
    // Cannot remove current or next semester
    if (semesterId == _currentSemester?.id) {
      return false;
    }

    final nextSemester = _calculateNextSemester(_currentSemester!);
    if (semesterId == nextSemester.id) {
      return false;
    }

    final removedCount = _availableSemesters.length;
    _availableSemesters.removeWhere((s) => s.id == semesterId);

    if (_availableSemesters.length < removedCount) {
      // If this was the selected semester, switch to current
      if (_selectedSemesterId == semesterId) {
        _selectedSemesterId = _currentSemester!.id;
      }
      
      debugPrint('$_logTag: Removed custom semester: $semesterId');
      notifyListeners();
      return true;
    }

    return false;
  }

  /// Get semester statistics
  Map<String, dynamic> getSemesterStats(String semesterId) {
    final semester = getSemesterById(semesterId) ?? parseSemesterFromId(semesterId);
    if (semester == null) {
      return <String, dynamic>{};
    }

    final now = DateTime.now();
    final progress = getSemesterProgress(semesterId);
    final currentWeek = getCurrentAcademicWeek(semesterId);
    final totalWeeks = semester.endDate.difference(semester.startDate).inDays ~/ 7;
    final daysRemaining = semester.endDate.difference(now).inDays;

    return {
      'semesterId': semesterId,
      'displayName': semester.displayName,
      'isCurrent': semester.isCurrent,
      'startDate': semester.startDate,
      'endDate': semester.endDate,
      'progress': progress,
      'currentWeek': currentWeek,
      'totalWeeks': totalWeeks,
      'daysRemaining': daysRemaining > 0 ? daysRemaining : 0,
      'isActive': isDateInSemester(now, semesterId),
    };
  }

  /// Refresh semester calculations (useful after date changes)
  void refreshSemesters() {
    final newCurrentSemester = _calculateCurrentSemester();
    
    if (_currentSemester?.id != newCurrentSemester.id) {
      debugPrint('$_logTag: Semester changed from ${_currentSemester?.id} to ${newCurrentSemester.id}');
      
      _currentSemester = newCurrentSemester;
      _availableSemesters = _generateAvailableSemesters();
      
      // Update selection if current was selected
      if (_selectedSemesterId == null || !_availableSemesters.any((s) => s.id == _selectedSemesterId)) {
        _selectedSemesterId = _currentSemester!.id;
      }
      
      notifyListeners();
    }
  }

  @override
  void dispose() {
    debugPrint('$_logTag: Disposing semester service');
    super.dispose();
  }
}