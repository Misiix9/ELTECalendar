// File: lib/models/semester.dart
// Purpose: Semester management according to specification
// Step: 2.1 - Data Models

/// Simple date range class for semester periods
class SemesterDateRange {
  final DateTime start;
  final DateTime end;
  
  const SemesterDateRange({required this.start, required this.end});
}

/// Semester model following the technical specification
/// Format: YYYY/YY/N where N is 1 or 2
/// Logic: Sept-Jan = 1st semester, Feb-June = 2nd semester
class Semester {
  final int startYear;    // Starting year (e.g., 2025)
  final int endYear;      // Ending year (e.g., 2026) 
  final int number;       // Semester number (1 or 2)

  const Semester({
    required this.startYear,
    required this.endYear,
    required this.number,
  }) : assert(number == 1 || number == 2, 'Semester number must be 1 or 2');

  /// Create semester from string format (e.g., "2025/26/1")
  factory Semester.fromString(String semesterStr) {
    final parts = semesterStr.split('/');
    if (parts.length != 3) {
      throw ArgumentError('Invalid semester format. Expected YYYY/YY/N');
    }

    final startYear = int.parse(parts[0]);
    final shortEndYear = int.parse(parts[1]);
    final endYear = 2000 + shortEndYear; // Convert YY to YYYY
    final number = int.parse(parts[2]);

    return Semester(
      startYear: startYear,
      endYear: endYear,
      number: number,
    );
  }

  /// Get current semester based on current date
  /// Sept-Jan = 1st semester, Feb-June = 2nd semester
  factory Semester.current() {
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    if (currentMonth >= 9) {
      // September onwards = start of new academic year (1st semester)
      return Semester(
        startYear: currentYear,
        endYear: currentYear + 1,
        number: 1,
      );
    } else if (currentMonth >= 2) {
      // February to August = 2nd semester of current academic year
      return Semester(
        startYear: currentYear - 1,
        endYear: currentYear,
        number: 2,
      );
    } else {
      // January = 1st semester continues
      return Semester(
        startYear: currentYear - 1,
        endYear: currentYear,
        number: 1,
      );
    }
  }

  /// Get next semester
  Semester get next {
    if (number == 1) {
      // Next is 2nd semester of same academic year
      return Semester(
        startYear: startYear,
        endYear: endYear,
        number: 2,
      );
    } else {
      // Next is 1st semester of next academic year
      return Semester(
        startYear: startYear + 1,
        endYear: endYear + 1,
        number: 1,
      );
    }
  }

  /// Get previous semester
  Semester get previous {
    if (number == 2) {
      // Previous is 1st semester of same academic year
      return Semester(
        startYear: startYear,
        endYear: endYear,
        number: 1,
      );
    } else {
      // Previous is 2nd semester of previous academic year
      return Semester(
        startYear: startYear - 1,
        endYear: endYear - 1,
        number: 2,
      );
    }
  }

  /// Convert to string format YYYY/YY/N
  @override
  String toString() {
    final shortEndYear = endYear.toString().substring(2);
    return '$startYear/$shortEndYear/$number';
  }

  /// Get display name with current indicator
  String toDisplayString() {
    final semesterName = number == 1 ? '1. félév' : '2. félév';
    final isCurrent = this == Semester.current();
    
    if (isCurrent) {
      return '${toString()} - $semesterName (jelenlegi)';
    } else {
      return '${toString()} - $semesterName';
    }
  }

  /// Get academic year string (e.g., "2025/2026")
  String get academicYear => '$startYear/$endYear';

  /// Check if this semester is currently active
  bool get isCurrent => this == Semester.current();

  /// Get date range for this semester
  SemesterDateRange get dateRange {
    if (number == 1) {
      // 1st semester: September to January
      return SemesterDateRange(
        start: DateTime(startYear, 9, 1),
        end: DateTime(endYear, 1, 31),
      );
    } else {
      // 2nd semester: February to June
      return SemesterDateRange(
        start: DateTime(startYear, 2, 1),
        end: DateTime(startYear, 6, 30),
      );
    }
  }

  /// Check if a date falls within this semester
  bool containsDate(DateTime date) {
    final range = dateRange;
    return date.isAfter(range.start.subtract(const Duration(days: 1))) &&
           date.isBefore(range.end.add(const Duration(days: 1)));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Semester &&
        other.startYear == startYear &&
        other.endYear == endYear &&
        other.number == number;
  }

  @override
  int get hashCode => startYear.hashCode ^ endYear.hashCode ^ number.hashCode;
}
