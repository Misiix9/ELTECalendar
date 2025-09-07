// File: lib/models/course_type.dart
// Purpose: Course type enumeration according to specification
// Step: 2.1 - Data Models

import 'package:flutter/material.dart';

/// Enum for course types as specified in the technical specification
/// Maps to Hungarian course type values from Excel import
enum CourseType {
  /// Előadás (Lecture)
  lecture('Előadás', Icons.school, Color(0xFF03284F)),
  
  /// Gyakorlat (Practice)  
  practice('Gyakorlat', Icons.assignment, Color(0xFFC6A882)),
  
  /// Labor (Laboratory)
  laboratory('Labor', Icons.science, Color(0xFF4A5C73));

  const CourseType(this.hungarianName, this.icon, this.color);

  /// Hungarian name as it appears in Excel files
  final String hungarianName;
  
  /// Icon representation for UI
  final IconData icon;
  
  /// Color for UI display according to specification
  final Color color;

  /// Get CourseType from Hungarian string
  static CourseType? fromString(String? type) {
    if (type == null) return null;
    
    final lowerType = type.toLowerCase().trim();
    switch (lowerType) {
      case 'előadás':
        return CourseType.lecture;
      case 'gyakorlat':
        return CourseType.practice;
      case 'labor':
        return CourseType.laboratory;
      default:
        return null;
    }
  }

  /// Get display name in current locale (for future localization)
  String get displayName {
    switch (this) {
      case CourseType.lecture:
        return 'Előadás'; // TODO: Localize
      case CourseType.practice:
        return 'Gyakorlat'; // TODO: Localize
      case CourseType.laboratory:
        return 'Labor'; // TODO: Localize
    }
  }

  /// Get short abbreviation
  String get abbreviation {
    switch (this) {
      case CourseType.lecture:
        return 'E';
      case CourseType.practice:
        return 'G';
      case CourseType.laboratory:
        return 'L';
    }
  }

  @override
  String toString() => hungarianName;
}

/// Extension to add utility methods to CourseType
extension CourseTypeExtension on CourseType {
  /// Check if this is a lecture type
  bool get isLecture => this == CourseType.lecture;
  
  /// Check if this is a practice type
  bool get isPractice => this == CourseType.practice;
  
  /// Check if this is a laboratory type
  bool get isLaboratory => this == CourseType.laboratory;

  /// Get priority for sorting (lectures first, then practice, then lab)
  int get sortPriority {
    switch (this) {
      case CourseType.lecture:
        return 1;
      case CourseType.practice:
        return 2;
      case CourseType.laboratory:
        return 3;
    }
  }
}
