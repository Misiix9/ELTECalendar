// File: lib/models/course_model.dart
// Purpose: Course and schedule data models following specification
// Step: 2.1 - Data Models

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../utils/constants.dart';

part 'course_model.g.dart';

/// Course model following the technical specification exactly
/// Maps to Excel columns and Firestore structure
@HiveType(typeId: 1)
class Course {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String courseCode; // Tárgy kódja

  @HiveField(2)
  final String courseName; // Tárgy neve

  @HiveField(3)
  final String classCode; // Kurzus kódja

  @HiveField(4)
  final String classType; // Kurzus típusa (Előadás/Gyakorlat/Labor)

  @HiveField(5)
  final int weeklyHours; // Óraszám

  @HiveField(6)
  final String rawScheduleInfo; // Original Órarend infó

  @HiveField(7)
  final List<String> instructors; // Oktatók

  @HiveField(8)
  final List<ScheduleSlot> scheduleSlots; // Parsed schedule

  @HiveField(9)
  final DateTime? createdAt;

  @HiveField(10)
  final DateTime? updatedAt;

  @HiveField(11)
  final String? notes;

  const Course({
    required this.id,
    required this.courseCode,
    required this.courseName,
    required this.classCode,
    required this.classType,
    required this.weeklyHours,
    required this.rawScheduleInfo,
    required this.instructors,
    required this.scheduleSlots,
    this.createdAt,
    this.updatedAt,
    this.notes,
  });

  /// Create course from Excel row data following specification column mapping
  factory Course.fromExcelRow(Map<String, dynamic> excelRow) {
    final String rawSchedule = excelRow['Órarend infó']?.toString() ?? '';
    
    return Course(
      id: _generateCourseId(excelRow['Kurzus kódja']?.toString() ?? ''),
      courseCode: excelRow['Tárgy kódja']?.toString() ?? '',
      courseName: excelRow['Tárgy neve']?.toString() ?? '',
      classCode: excelRow['Kurzus kódja']?.toString() ?? '',
      classType: excelRow['Kurzus típusa']?.toString() ?? '',
      weeklyHours: _parseWeeklyHours(excelRow['Óraszám:']?.toString()),
      rawScheduleInfo: rawSchedule,
      instructors: _parseInstructors(excelRow['Oktatók']?.toString()),
      scheduleSlots: ScheduleSlot.parseScheduleInfo(rawSchedule),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create course from Firestore document
  factory Course.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Course(
      id: doc.id,
      courseCode: data['courseCode'] ?? '',
      courseName: data['courseName'] ?? '',
      classCode: data['classCode'] ?? '',
      classType: data['classType'] ?? '',
      weeklyHours: data['weeklyHours'] ?? 0,
      rawScheduleInfo: data['scheduleInfo'] ?? '',
      instructors: List<String>.from(data['instructors'] ?? []),
      scheduleSlots: (data['parsedSchedule'] as List<dynamic>?)
          ?.map((slot) => ScheduleSlot.fromJson(slot as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      notes: data['notes'],
    );
  }

  /// Create course from JSON (for local storage)
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? '',
      courseCode: json['courseCode'] ?? '',
      courseName: json['courseName'] ?? '',
      classCode: json['classCode'] ?? '',
      classType: json['classType'] ?? '',
      weeklyHours: json['weeklyHours'] ?? 0,
      rawScheduleInfo: json['rawScheduleInfo'] ?? '',
      instructors: List<String>.from(json['instructors'] ?? []),
      scheduleSlots: (json['scheduleSlots'] as List<dynamic>?)
          ?.map((slot) => ScheduleSlot.fromJson(slot as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      notes: json['notes'],
    );
  }

  /// Convert to Firestore document format
  Map<String, dynamic> toFirestore() {
    return {
      'courseCode': courseCode,
      'courseName': courseName,
      'classCode': classCode,
      'classType': classType,
      'weeklyHours': weeklyHours,
      'scheduleInfo': rawScheduleInfo,
      'instructors': instructors,
      'parsedSchedule': scheduleSlots.map((slot) => slot.toJson()).toList(),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
      'notes': notes,
    };
  }

  /// Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseCode': courseCode,
      'courseName': courseName,
      'classCode': classCode,
      'classType': classType,
      'weeklyHours': weeklyHours,
      'rawScheduleInfo': rawScheduleInfo,
      'instructors': instructors,
      'scheduleSlots': scheduleSlots.map((slot) => slot.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  /// Create copy with updated values
  Course copyWith({
    String? id,
    String? courseCode,
    String? courseName,
    String? classCode,
    String? classType,
    int? weeklyHours,
    String? rawScheduleInfo,
    List<String>? instructors,
    List<ScheduleSlot>? scheduleSlots,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
  }) {
    return Course(
      id: id ?? this.id,
      courseCode: courseCode ?? this.courseCode,
      courseName: courseName ?? this.courseName,
      classCode: classCode ?? this.classCode,
      classType: classType ?? this.classType,
      weeklyHours: weeklyHours ?? this.weeklyHours,
      rawScheduleInfo: rawScheduleInfo ?? this.rawScheduleInfo,
      instructors: instructors ?? this.instructors,
      scheduleSlots: scheduleSlots ?? this.scheduleSlots,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      notes: notes ?? this.notes,
    );
  }

  /// Get display color for course type
  Color get displayColor {
    switch (classType.toLowerCase()) {
      case 'előadás':
        return const Color(0xFF03284F); // Primary dark blue
      case 'gyakorlat':
        return const Color(0xFFC6A882); // Gold accent
      case 'labor':
        return const Color(0xFF4A5C73); // Blend of both
      default:
        return const Color(0xFF03284F); // Default to primary
    }
  }

  /// Convenience getters for backward compatibility with existing UI code
  String get name => courseName;
  String get code => courseCode;
  String get type => classType;
  int get credits => weeklyHours; // Map weeklyHours to credits for compatibility
  String? get description => notes; // Map notes to description
  String? get semester => null; // Will be handled by semester management

  /// Get formatted instructor names
  String get formattedInstructors {
    if (instructors.isEmpty) return 'No instructor';
    if (instructors.length == 1) return instructors.first;
    return '${instructors.first} (+${instructors.length - 1} more)';
  }

  /// Check if course has schedule conflicts with another course
  bool hasConflictWith(Course other) {
    for (final slot1 in scheduleSlots) {
      for (final slot2 in other.scheduleSlots) {
        if (slot1.conflictsWith(slot2)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Get next upcoming class
  ScheduleSlot? get nextUpcomingClass {
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    final currentTime = TimeOfDay.fromDateTime(now);

    // Find classes today that haven't started yet
    final todayClasses = scheduleSlots
        .where((slot) => slot.dayOfWeek == currentWeekday)
        .where((slot) => slot.startTime.isAfter(currentTime))
        .toList();

    if (todayClasses.isNotEmpty) {
      todayClasses.sort((a, b) => a.startTime.compareTo(b.startTime));
      return todayClasses.first;
    }

    // Find next class this week
    final upcomingClasses = scheduleSlots
        .where((slot) => slot.dayOfWeek > currentWeekday)
        .toList();

    if (upcomingClasses.isNotEmpty) {
      upcomingClasses.sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
      return upcomingClasses.first;
    }

    // If no classes this week, return first class of next week
    final nextWeekClasses = scheduleSlots.toList();
    if (nextWeekClasses.isNotEmpty) {
      nextWeekClasses.sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
      return nextWeekClasses.first;
    }

    return null;
  }

  /// Helper methods for Excel parsing
  static String _generateCourseId(String classCode) {
    return '${classCode}_${DateTime.now().millisecondsSinceEpoch}';
  }

  static int _parseWeeklyHours(String? hoursStr) {
    if (hoursStr == null) return 0;
    final cleaned = hoursStr.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(cleaned) ?? 0;
  }

  static List<String> _parseInstructors(String? instructorsStr) {
    if (instructorsStr == null || instructorsStr.trim().isEmpty) {
      return [];
    }
    
    return instructorsStr
        .split(RegExp(r'[,;]'))
        .map((instructor) => instructor.trim())
        .where((instructor) => instructor.isNotEmpty)
        .toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Course &&
        other.id == id &&
        other.courseCode == courseCode &&
        other.classCode == classCode;
  }

  @override
  int get hashCode => id.hashCode ^ courseCode.hashCode ^ classCode.hashCode;

  @override
  String toString() {
    return 'Course{id: $id, courseCode: $courseCode, courseName: $courseName, classType: $classType}';
  }
}

/// Schedule slot model for individual time periods
@HiveType(typeId: 2)
class ScheduleSlot {
  @HiveField(0)
  final int dayOfWeek; // 1-7 (Monday-Sunday)

  @HiveField(1)
  final TimeOfDay startTime;

  @HiveField(2)
  final TimeOfDay endTime;

  @HiveField(3)
  final String location;

  @HiveField(4)
  final String courseId; // Reference to parent course

  @HiveField(5)
  final Color displayColor; // Based on class type

  const ScheduleSlot({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.courseId,
    required this.displayColor,
  });

  /// Parse schedule info string according to specification format
  /// Format: DAY:HH:MM-HH:MM(Location); multiple sessions separated by semicolon
  static List<ScheduleSlot> parseScheduleInfo(String scheduleInfo) {
    final List<ScheduleSlot> slots = [];
    
    if (scheduleInfo.trim().isEmpty) return slots;
    
    // Split by semicolon for multiple sessions
    final sessions = scheduleInfo.split(';');
    
    for (final session in sessions) {
      final match = RegExp(AppConstants.scheduleInfoRegexPattern).firstMatch(session.trim());
      
      if (match != null) {
        final dayAbbr = match.group(1)!;
        final startTimeStr = match.group(2)!;
        final endTimeStr = match.group(3)!;
        final location = match.group(4)!.trim();
        
        final dayOfWeek = AppConstants.dayOfWeekMapping[dayAbbr];
        final startTime = _parseTimeOfDay(startTimeStr);
        final endTime = _parseTimeOfDay(endTimeStr);
        
        if (dayOfWeek != null && startTime != null && endTime != null) {
          slots.add(
            ScheduleSlot(
              dayOfWeek: dayOfWeek,
              startTime: startTime,
              endTime: endTime,
              location: location,
              courseId: '', // Will be set by parent course
              displayColor: const Color(0xFF03284F), // Default color
            ),
          );
        }
      }
    }
    
    return slots;
  }

  /// Create from JSON
  factory ScheduleSlot.fromJson(Map<String, dynamic> json) {
    return ScheduleSlot(
      dayOfWeek: json['dayOfWeek'] ?? 1,
      startTime: TimeOfDay(
        hour: json['startHour'] ?? 0,
        minute: json['startMinute'] ?? 0,
      ),
      endTime: TimeOfDay(
        hour: json['endHour'] ?? 0,
        minute: json['endMinute'] ?? 0,
      ),
      location: json['location'] ?? '',
      courseId: json['courseId'] ?? '',
      displayColor: Color(json['displayColor'] ?? 0xFF03284F),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'startHour': startTime.hour,
      'startMinute': startTime.minute,
      'endHour': endTime.hour,
      'endMinute': endTime.minute,
      'location': location,
      'courseId': courseId,
      'displayColor': displayColor.value,
    };
  }

  /// Create copy with updated values
  ScheduleSlot copyWith({
    int? dayOfWeek,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? location,
    String? courseId,
    Color? displayColor,
  }) {
    return ScheduleSlot(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      courseId: courseId ?? this.courseId,
      displayColor: displayColor ?? this.displayColor,
    );
  }

  /// Check if this slot conflicts with another slot
  bool conflictsWith(ScheduleSlot other) {
    if (dayOfWeek != other.dayOfWeek) return false;
    
    // Check for time overlap
    final thisStart = startTime.toMinutes();
    final thisEnd = endTime.toMinutes();
    final otherStart = other.startTime.toMinutes();
    final otherEnd = other.endTime.toMinutes();
    
    return thisStart < otherEnd && thisEnd > otherStart;
  }

  /// Get day name in Hungarian
  String get dayNameHu {
    switch (dayOfWeek) {
      case 1: return 'Hétfő';
      case 2: return 'Kedd';
      case 3: return 'Szerda';
      case 4: return 'Csütörtök';
      case 5: return 'Péntek';
      case 6: return 'Szombat';
      case 7: return 'Vasárnap';
      default: return 'Ismeretlen';
    }
  }

  /// Get formatted time range
  String get timeRange {
    return '${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}';
  }

  /// Helper method to format TimeOfDay without BuildContext
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Duration of the slot in minutes
  int get durationMinutes {
    return endTime.toMinutes() - startTime.toMinutes();
  }

  /// Helper method to parse time string
  static TimeOfDay? _parseTimeOfDay(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) return null;
    
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ScheduleSlot &&
        other.dayOfWeek == dayOfWeek &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.location == location;
  }

  @override
  int get hashCode {
    return dayOfWeek.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        location.hashCode;
  }

  @override
  String toString() {
    return 'ScheduleSlot{day: $dayOfWeek, time: ${timeRange}, location: $location}';
  }
}

/// Extension for TimeOfDay to add utility methods
extension TimeOfDayExtension on TimeOfDay {
  /// Convert to minutes since midnight
  int toMinutes() {
    return hour * 60 + minute;
  }

  /// Compare two TimeOfDay objects
  int compareTo(TimeOfDay other) {
    return toMinutes().compareTo(other.toMinutes());
  }

  /// Check if this time is after another time
  bool isAfter(TimeOfDay other) {
    return compareTo(other) > 0;
  }

  /// Check if this time is before another time
  bool isBefore(TimeOfDay other) {
    return compareTo(other) < 0;
  }

  /// Format time as HH:MM string
  String format(BuildContext? context) {
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}