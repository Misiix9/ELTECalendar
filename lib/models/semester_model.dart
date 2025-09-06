// File: lib/models/semester_model.dart
// Purpose: Semester data model following specification
// Step: 5.2 - Semester Model Implementation

import 'package:hive/hive.dart';

part 'semester_model.g.dart';

/// Semester model representing an academic semester
@HiveType(typeId: 3)
class Semester {
  @HiveField(0)
  final String id; // Format: YYYY/YY/N (e.g., 2024/25/1)

  @HiveField(1)
  final int academicYearStart; // e.g., 2024

  @HiveField(2)
  final int academicYearEnd; // e.g., 2025

  @HiveField(3)
  final int semesterNumber; // 1 or 2

  @HiveField(4)
  final bool isCurrent;

  @HiveField(5)
  final DateTime startDate;

  @HiveField(6)
  final DateTime endDate;

  const Semester({
    required this.id,
    required this.academicYearStart,
    required this.academicYearEnd,
    required this.semesterNumber,
    required this.isCurrent,
    required this.startDate,
    required this.endDate,
  });

  /// Get display name for the semester
  String get displayName {
    final semesterName = semesterNumber == 1 ? '1st Semester' : '2nd Semester';
    final yearRange = '$academicYearStart/${academicYearEnd.toString().substring(2)}';
    
    if (isCurrent) {
      return '$yearRange $semesterName (current)';
    } else {
      return '$yearRange $semesterName';
    }
  }

  /// Get short display name
  String get shortDisplayName {
    return '$academicYearStart/${academicYearEnd.toString().substring(2)}/$semesterNumber';
  }

  /// Get semester name only (1st/2nd Semester)
  String get semesterName {
    return semesterNumber == 1 ? '1st Semester' : '2nd Semester';
  }

  /// Get academic year range (e.g., "2024/25")
  String get academicYearRange {
    return '$academicYearStart/${academicYearEnd.toString().substring(2)}';
  }

  /// Check if this semester is active (current date falls within)
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate.subtract(const Duration(days: 1))) &&
           now.isBefore(endDate.add(const Duration(days: 1)));
  }

  /// Check if this semester is in the past
  bool get isPast {
    final now = DateTime.now();
    return now.isAfter(endDate);
  }

  /// Check if this semester is in the future
  bool get isFuture {
    final now = DateTime.now();
    return now.isBefore(startDate);
  }

  /// Get semester duration in days
  int get durationInDays {
    return endDate.difference(startDate).inDays;
  }

  /// Get semester duration in weeks (approximate)
  int get durationInWeeks {
    return (durationInDays / 7).round();
  }

  /// Get progress of the semester (0.0 - 1.0)
  double get progress {
    final now = DateTime.now();
    
    if (now.isBefore(startDate)) {
      return 0.0;
    }
    
    if (now.isAfter(endDate)) {
      return 1.0;
    }
    
    final totalDuration = endDate.difference(startDate).inDays;
    final elapsedDuration = now.difference(startDate).inDays;
    
    return (elapsedDuration / totalDuration).clamp(0.0, 1.0);
  }

  /// Get days remaining in semester
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) {
      return 0;
    }
    return endDate.difference(now).inDays;
  }

  /// Get current academic week within semester
  int? get currentAcademicWeek {
    final now = DateTime.now();
    
    if (!isActive) {
      return null;
    }
    
    final daysDifference = now.difference(startDate).inDays;
    return (daysDifference / 7).floor() + 1;
  }

  /// Create copy with updated values
  Semester copyWith({
    String? id,
    int? academicYearStart,
    int? academicYearEnd,
    int? semesterNumber,
    bool? isCurrent,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Semester(
      id: id ?? this.id,
      academicYearStart: academicYearStart ?? this.academicYearStart,
      academicYearEnd: academicYearEnd ?? this.academicYearEnd,
      semesterNumber: semesterNumber ?? this.semesterNumber,
      isCurrent: isCurrent ?? this.isCurrent,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  /// Convert to JSON for storage/transmission
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'academicYearStart': academicYearStart,
      'academicYearEnd': academicYearEnd,
      'semesterNumber': semesterNumber,
      'isCurrent': isCurrent,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      id: json['id'] as String,
      academicYearStart: json['academicYearStart'] as int,
      academicYearEnd: json['academicYearEnd'] as int,
      semesterNumber: json['semesterNumber'] as int,
      isCurrent: json['isCurrent'] as bool,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Semester && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Semester{id: $id, displayName: $displayName, isCurrent: $isCurrent, isActive: $isActive}';
  }
}

/// Semester comparison utilities
class SemesterComparator {
  /// Compare two semesters chronologically
  static int compare(Semester a, Semester b) {
    // First compare by academic year start
    final yearComparison = a.academicYearStart.compareTo(b.academicYearStart);
    if (yearComparison != 0) return yearComparison;
    
    // Then by semester number
    return a.semesterNumber.compareTo(b.semesterNumber);
  }

  /// Check if semester A comes before semester B
  static bool isBefore(Semester a, Semester b) {
    return compare(a, b) < 0;
  }

  /// Check if semester A comes after semester B
  static bool isAfter(Semester a, Semester b) {
    return compare(a, b) > 0;
  }

  /// Get the next semester after the given semester
  static Semester getNext(Semester semester) {
    if (semester.semesterNumber == 1) {
      // Next is second semester of same academic year
      return Semester(
        id: '${semester.academicYearStart}/${semester.academicYearEnd.toString().substring(2)}/2',
        academicYearStart: semester.academicYearStart,
        academicYearEnd: semester.academicYearEnd,
        semesterNumber: 2,
        isCurrent: false,
        startDate: DateTime(semester.academicYearStart + 1, 2, 1), // February
        endDate: DateTime(semester.academicYearStart + 1, 7, 0), // End of June
      );
    } else {
      // Next is first semester of next academic year
      final nextAcademicYearStart = semester.academicYearStart + 1;
      final nextAcademicYearEnd = nextAcademicYearStart + 1;
      
      return Semester(
        id: '$nextAcademicYearStart/${nextAcademicYearEnd.toString().substring(2)}/1',
        academicYearStart: nextAcademicYearStart,
        academicYearEnd: nextAcademicYearEnd,
        semesterNumber: 1,
        isCurrent: false,
        startDate: DateTime(nextAcademicYearStart, 9, 1), // September
        endDate: DateTime(nextAcademicYearStart + 1, 2, 0), // End of January
      );
    }
  }

  /// Get the previous semester before the given semester
  static Semester getPrevious(Semester semester) {
    if (semester.semesterNumber == 2) {
      // Previous is first semester of same academic year
      return Semester(
        id: '${semester.academicYearStart}/${semester.academicYearEnd.toString().substring(2)}/1',
        academicYearStart: semester.academicYearStart,
        academicYearEnd: semester.academicYearEnd,
        semesterNumber: 1,
        isCurrent: false,
        startDate: DateTime(semester.academicYearStart, 9, 1), // September
        endDate: DateTime(semester.academicYearStart + 1, 2, 0), // End of January
      );
    } else {
      // Previous is second semester of previous academic year
      final prevAcademicYearStart = semester.academicYearStart - 1;
      final prevAcademicYearEnd = prevAcademicYearStart + 1;
      
      return Semester(
        id: '$prevAcademicYearStart/${prevAcademicYearEnd.toString().substring(2)}/2',
        academicYearStart: prevAcademicYearStart,
        academicYearEnd: prevAcademicYearEnd,
        semesterNumber: 2,
        isCurrent: false,
        startDate: DateTime(prevAcademicYearStart + 1, 2, 1), // February
        endDate: DateTime(prevAcademicYearStart + 1, 7, 0), // End of June
      );
    }
  }
}

/// Extension methods for List<Semester>
extension SemesterListExtensions on List<Semester> {
  /// Sort semesters chronologically
  void sortChronologically() {
    sort(SemesterComparator.compare);
  }

  /// Get current semester from list
  Semester? get current {
    try {
      return firstWhere((semester) => semester.isCurrent);
    } catch (e) {
      return null;
    }
  }

  /// Get active semester (current date falls within)
  Semester? get active {
    try {
      return firstWhere((semester) => semester.isActive);
    } catch (e) {
      return null;
    }
  }

  /// Filter past semesters
  List<Semester> get past {
    return where((semester) => semester.isPast).toList();
  }

  /// Filter future semesters
  List<Semester> get future {
    return where((semester) => semester.isFuture).toList();
  }

  /// Get semester by ID
  Semester? byId(String id) {
    try {
      return firstWhere((semester) => semester.id == id);
    } catch (e) {
      return null;
    }
  }
}