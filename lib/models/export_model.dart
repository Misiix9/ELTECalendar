// File: lib/models/export_model.dart
// Purpose: Export data models for schedule export functionality
// Step: 8.2 - Export Model Implementation

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'export_model.g.dart';

/// Export format types
@HiveType(typeId: 6)
enum ExportType {
  @HiveField(0)
  ics,
  
  @HiveField(1)
  pdf,
  
  @HiveField(2)
  excel,
}

/// Extension methods for ExportType
extension ExportTypeExtension on ExportType {
  /// Get display name for export type
  String get displayName {
    switch (this) {
      case ExportType.ics:
        return 'ICS Calendar';
      case ExportType.pdf:
        return 'PDF Schedule';
      case ExportType.excel:
        return 'Excel Spreadsheet';
    }
  }

  /// Get file extension
  String get extension {
    switch (this) {
      case ExportType.ics:
        return 'ics';
      case ExportType.pdf:
        return 'pdf';
      case ExportType.excel:
        return 'xlsx';
    }
  }

  /// Get MIME type
  String get mimeType {
    switch (this) {
      case ExportType.ics:
        return 'text/calendar';
      case ExportType.pdf:
        return 'application/pdf';
      case ExportType.excel:
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }
  }

  /// Get icon for export type
  IconData get icon {
    switch (this) {
      case ExportType.ics:
        return Icons.calendar_today;
      case ExportType.pdf:
        return Icons.picture_as_pdf;
      case ExportType.excel:
        return Icons.table_chart;
    }
  }

  /// Get description for export type
  String get description {
    switch (this) {
      case ExportType.ics:
        return 'Standard calendar format compatible with Google Calendar, Apple Calendar, and Outlook';
      case ExportType.pdf:
        return 'Printable schedule with customizable layout and formatting';
      case ExportType.excel:
        return 'Spreadsheet format for data analysis and custom modifications';
    }
  }
}

/// Export options configuration
@HiveType(typeId: 7)
class ExportOptions {
  @HiveField(0)
  final List<String> semesterIds;

  @HiveField(1)
  final List<CourseType> courseTypes;

  @HiveField(2)
  final DateTime? startDate;

  @HiveField(3)
  final DateTime? endDate;

  @HiveField(4)
  final bool includeInstructors;

  @HiveField(5)
  final bool includeLocation;

  @HiveField(6)
  final bool includeDescription;

  @HiveField(7)
  final bool includeCredits;

  @HiveField(8)
  final String? title;

  @HiveField(9)
  final ExportLayoutType layoutType;

  @HiveField(10)
  final bool includeWeekends;

  @HiveField(11)
  final TimeOfDay? dayStartTime;

  @HiveField(12)
  final TimeOfDay? dayEndTime;

  const ExportOptions({
    this.semesterIds = const [],
    this.courseTypes = const [],
    this.startDate,
    this.endDate,
    this.includeInstructors = true,
    this.includeLocation = true,
    this.includeDescription = false,
    this.includeCredits = true,
    this.title,
    this.layoutType = ExportLayoutType.weekly,
    this.includeWeekends = false,
    this.dayStartTime,
    this.dayEndTime,
  });

  /// Create copy with updated values
  ExportOptions copyWith({
    List<String>? semesterIds,
    List<CourseType>? courseTypes,
    DateTime? startDate,
    DateTime? endDate,
    bool? includeInstructors,
    bool? includeLocation,
    bool? includeDescription,
    bool? includeCredits,
    String? title,
    ExportLayoutType? layoutType,
    bool? includeWeekends,
    TimeOfDay? dayStartTime,
    TimeOfDay? dayEndTime,
  }) {
    return ExportOptions(
      semesterIds: semesterIds ?? this.semesterIds,
      courseTypes: courseTypes ?? this.courseTypes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      includeInstructors: includeInstructors ?? this.includeInstructors,
      includeLocation: includeLocation ?? this.includeLocation,
      includeDescription: includeDescription ?? this.includeDescription,
      includeCredits: includeCredits ?? this.includeCredits,
      title: title ?? this.title,
      layoutType: layoutType ?? this.layoutType,
      includeWeekends: includeWeekends ?? this.includeWeekends,
      dayStartTime: dayStartTime ?? this.dayStartTime,
      dayEndTime: dayEndTime ?? this.dayEndTime,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'semesterIds': semesterIds,
      'courseTypes': courseTypes.map((t) => t.name).toList(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'includeInstructors': includeInstructors,
      'includeLocation': includeLocation,
      'includeDescription': includeDescription,
      'includeCredits': includeCredits,
      'title': title,
      'layoutType': layoutType.name,
      'includeWeekends': includeWeekends,
      'dayStartTime': dayStartTime != null 
        ? '${dayStartTime!.hour}:${dayStartTime!.minute}' 
        : null,
      'dayEndTime': dayEndTime != null 
        ? '${dayEndTime!.hour}:${dayEndTime!.minute}' 
        : null,
    };
  }

  /// Create from JSON
  factory ExportOptions.fromJson(Map<String, dynamic> json) {
    return ExportOptions(
      semesterIds: List<String>.from(json['semesterIds'] ?? []),
      courseTypes: (json['courseTypes'] as List<dynamic>?)
          ?.map((t) => CourseType.values.firstWhere((ct) => ct.name == t))
          .toList() ?? [],
      startDate: json['startDate'] != null 
        ? DateTime.parse(json['startDate']) 
        : null,
      endDate: json['endDate'] != null 
        ? DateTime.parse(json['endDate']) 
        : null,
      includeInstructors: json['includeInstructors'] ?? true,
      includeLocation: json['includeLocation'] ?? true,
      includeDescription: json['includeDescription'] ?? false,
      includeCredits: json['includeCredits'] ?? true,
      title: json['title'],
      layoutType: ExportLayoutType.values.firstWhere(
        (l) => l.name == json['layoutType'], 
        orElse: () => ExportLayoutType.weekly,
      ),
      includeWeekends: json['includeWeekends'] ?? false,
      dayStartTime: json['dayStartTime'] != null
        ? _parseTimeOfDay(json['dayStartTime'])
        : null,
      dayEndTime: json['dayEndTime'] != null
        ? _parseTimeOfDay(json['dayEndTime'])
        : null,
    );
  }

  /// Parse TimeOfDay from string
  static TimeOfDay? _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    if (parts.length == 2) {
      return TimeOfDay(
        hour: int.parse(parts[0]), 
        minute: int.parse(parts[1]),
      );
    }
    return null;
  }

  @override
  String toString() {
    return 'ExportOptions{semesters: ${semesterIds.length}, types: ${courseTypes.length}, layout: $layoutType}';
  }
}

/// Course types for filtering exports
@HiveType(typeId: 8)
enum CourseType {
  @HiveField(0)
  lecture, // Előadás
  
  @HiveField(1)
  practice, // Gyakorlat
  
  @HiveField(2)
  laboratory, // Labor
  
  @HiveField(3)
  seminar, // Szeminárium
  
  @HiveField(4)
  consultation, // Konzultáció
}

/// Extension methods for CourseType
extension CourseTypeExtension on CourseType {
  /// Get display name
  String get displayName {
    switch (this) {
      case CourseType.lecture:
        return 'Előadás';
      case CourseType.practice:
        return 'Gyakorlat';
      case CourseType.laboratory:
        return 'Labor';
      case CourseType.seminar:
        return 'Szeminárium';
      case CourseType.consultation:
        return 'Konzultáció';
    }
  }
  
  /// Get English name
  String get englishName {
    switch (this) {
      case CourseType.lecture:
        return 'Lecture';
      case CourseType.practice:
        return 'Practice';
      case CourseType.laboratory:
        return 'Laboratory';
      case CourseType.seminar:
        return 'Seminar';
      case CourseType.consultation:
        return 'Consultation';
    }
  }
  
  /// Get icon for this course type
  IconData get icon {
    switch (this) {
      case CourseType.lecture:
        return Icons.school;
      case CourseType.practice:
        return Icons.assignment;
      case CourseType.laboratory:
        return Icons.science;
      case CourseType.seminar:
        return Icons.group;
      case CourseType.consultation:
        return Icons.question_answer;
    }
  }
  
  /// Get color for this course type
  Color get color {
    switch (this) {
      case CourseType.lecture:
        return const Color(0xFF03284F);
      case CourseType.practice:
        return const Color(0xFFC6A882);
      case CourseType.laboratory:
        return const Color(0xFF4A5C73);
      case CourseType.seminar:
        return const Color(0xFF8B5A3C);
      case CourseType.consultation:
        return const Color(0xFF5D4E75);
    }
  }
  
  /// Match from string (Hungarian class type)
  static CourseType? fromString(String classType) {
    final type = classType.toLowerCase();
    if (type.contains('előadás')) return CourseType.lecture;
    if (type.contains('gyakorlat')) return CourseType.practice;
    if (type.contains('labor')) return CourseType.laboratory;
    if (type.contains('szeminárium')) return CourseType.seminar;
    if (type.contains('konzultáció')) return CourseType.consultation;
    return null;
  }
}

/// Export layout types for PDF
@HiveType(typeId: 9)
enum ExportLayoutType {
  @HiveField(0)
  daily,
  
  @HiveField(1)
  weekly,
  
  @HiveField(2)
  monthly,
  
  @HiveField(3)
  list,
}

/// Extension methods for ExportLayoutType
extension ExportLayoutTypeExtension on ExportLayoutType {
  /// Get display name
  String get displayName {
    switch (this) {
      case ExportLayoutType.daily:
        return 'Daily View';
      case ExportLayoutType.weekly:
        return 'Weekly View';
      case ExportLayoutType.monthly:
        return 'Monthly View';
      case ExportLayoutType.list:
        return 'List View';
    }
  }

  /// Get description
  String get description {
    switch (this) {
      case ExportLayoutType.daily:
        return 'One day per page with detailed schedule';
      case ExportLayoutType.weekly:
        return 'Weekly grid layout showing all days';
      case ExportLayoutType.monthly:
        return 'Monthly overview with course summaries';
      case ExportLayoutType.list:
        return 'Simple list of all courses and times';
    }
  }

  /// Get icon
  IconData get icon {
    switch (this) {
      case ExportLayoutType.daily:
        return Icons.view_day;
      case ExportLayoutType.weekly:
        return Icons.view_week;
      case ExportLayoutType.monthly:
        return Icons.calendar_month;
      case ExportLayoutType.list:
        return Icons.view_list;
    }
  }
}

/// Export result
class ExportResult {
  final bool success;
  final String? filePath;
  final dynamic fileContent; // String for text formats, Uint8List for binary
  final ExportType exportType;
  final String? error;
  final int itemCount;
  final int fileSize;
  final DateTime timestamp;

  ExportResult({
    required this.success,
    this.filePath,
    this.fileContent,
    required this.exportType,
    this.error,
    this.itemCount = 0,
    this.fileSize = 0,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Get human readable file size
  String get fileSizeString {
    if (fileSize < 1024) {
      return '${fileSize}B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  /// Get formatted timestamp
  String get formattedTimestamp {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} '
           '${timestamp.hour.toString().padLeft(2, '0')}:'
           '${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'ExportResult{success: $success, type: $exportType, items: $itemCount}';
  }
}

/// Export progress tracking
class ExportProgress {
  final ExportType type;
  final double progress; // 0.0 to 1.0
  final String message;
  final DateTime timestamp;

  ExportProgress({
    required this.type,
    required this.progress,
    required this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Get progress percentage
  int get progressPercentage => (progress * 100).round();

  /// Create copy with updated values
  ExportProgress copyWith({
    ExportType? type,
    double? progress,
    String? message,
    DateTime? timestamp,
  }) {
    return ExportProgress(
      type: type ?? this.type,
      progress: progress ?? this.progress,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'ExportProgress{type: $type, progress: ${progressPercentage}%, message: $message}';
  }
}

/// Export history item
@HiveType(typeId: 9)
class ExportHistoryItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final ExportType exportType;

  @HiveField(2)
  final String fileName;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final int itemCount;

  @HiveField(5)
  final int fileSize;

  @HiveField(6)
  final bool success;

  @HiveField(7)
  final String? error;

  @HiveField(8)
  final Map<String, dynamic> options;

  const ExportHistoryItem({
    required this.id,
    required this.exportType,
    required this.fileName,
    required this.timestamp,
    required this.itemCount,
    required this.fileSize,
    required this.success,
    this.error,
    this.options = const {},
  });

  /// Get human readable file size
  String get fileSizeString {
    if (fileSize < 1024) {
      return '${fileSize}B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  /// Get formatted timestamp
  String get formattedTimestamp {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} '
           '${timestamp.hour.toString().padLeft(2, '0')}:'
           '${timestamp.minute.toString().padLeft(2, '0')}';
  }

  /// Get relative time string
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays != 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours != 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes != 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Create copy with updated values
  ExportHistoryItem copyWith({
    String? id,
    ExportType? exportType,
    String? fileName,
    DateTime? timestamp,
    int? itemCount,
    int? fileSize,
    bool? success,
    String? error,
    Map<String, dynamic>? options,
  }) {
    return ExportHistoryItem(
      id: id ?? this.id,
      exportType: exportType ?? this.exportType,
      fileName: fileName ?? this.fileName,
      timestamp: timestamp ?? this.timestamp,
      itemCount: itemCount ?? this.itemCount,
      fileSize: fileSize ?? this.fileSize,
      success: success ?? this.success,
      error: error ?? this.error,
      options: options ?? this.options,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exportType': exportType.name,
      'fileName': fileName,
      'timestamp': timestamp.toIso8601String(),
      'itemCount': itemCount,
      'fileSize': fileSize,
      'success': success,
      'error': error,
      'options': options,
    };
  }

  /// Create from JSON
  factory ExportHistoryItem.fromJson(Map<String, dynamic> json) {
    return ExportHistoryItem(
      id: json['id'] as String,
      exportType: ExportType.values.firstWhere(
        (t) => t.name == json['exportType'],
      ),
      fileName: json['fileName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      itemCount: json['itemCount'] as int,
      fileSize: json['fileSize'] as int,
      success: json['success'] as bool,
      error: json['error'] as String?,
      options: Map<String, dynamic>.from(json['options'] ?? {}),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ExportHistoryItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ExportHistoryItem{id: $id, type: $exportType, fileName: $fileName, success: $success}';
  }
}

/// Predefined export templates
class ExportTemplates {
  /// Full semester export with all details
  static ExportOptions get fullSemester => const ExportOptions(
    includeInstructors: true,
    includeLocation: true,
    includeDescription: true,
    includeCredits: true,
    layoutType: ExportLayoutType.weekly,
    includeWeekends: false,
    title: 'Complete Semester Schedule',
  );

  /// Quick schedule export with minimal details
  static ExportOptions get quickSchedule => const ExportOptions(
    includeInstructors: false,
    includeLocation: true,
    includeDescription: false,
    includeCredits: false,
    layoutType: ExportLayoutType.weekly,
    includeWeekends: false,
    title: 'Quick Schedule',
  );

  /// Printable schedule for posting
  static ExportOptions get printable => const ExportOptions(
    includeInstructors: true,
    includeLocation: true,
    includeDescription: false,
    includeCredits: false,
    layoutType: ExportLayoutType.weekly,
    includeWeekends: false,
    dayStartTime: TimeOfDay(hour: 8, minute: 0),
    dayEndTime: TimeOfDay(hour: 20, minute: 0),
    title: 'Weekly Schedule',
  );

  /// Course list for academic records
  static ExportOptions get courseList => const ExportOptions(
    includeInstructors: true,
    includeLocation: false,
    includeDescription: true,
    includeCredits: true,
    layoutType: ExportLayoutType.list,
    includeWeekends: false,
    title: 'Course List',
  );

  /// Get all templates
  static Map<String, ExportOptions> get all => {
    'full': fullSemester,
    'quick': quickSchedule,
    'printable': printable,
    'list': courseList,
  };

  /// Get template display names
  static Map<String, String> get displayNames => {
    'full': 'Complete Schedule',
    'quick': 'Quick Export',
    'printable': 'Printable Version',
    'list': 'Course List',
  };
}