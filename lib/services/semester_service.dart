// File: lib/services/semester_service.dart
// Purpose: Semester management service stub
// Step: 1.1 - Initialize Flutter Project

import 'package:flutter/foundation.dart';

/// Semester management service - placeholder implementation
/// Will be fully implemented in Step 5: Semester Management
class SemesterService extends ChangeNotifier {
  /// Get current semester string
  /// TODO: Implement semester calculation based on current date
  String getCurrentSemester() {
    // Placeholder implementation - will calculate based on current date
    // Sept-Jan = 1st semester, Feb-June = 2nd semester
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    
    if (month >= 9 || month <= 1) {
      // First semester
      return '$year/${(year + 1).toString().substring(2)}/1';
    } else {
      // Second semester  
      return '$year/${year.toString().substring(2)}/2';
    }
  }

  /// Get next semester string
  /// TODO: Implement next semester calculation
  String getNextSemester() {
    final current = getCurrentSemester();
    // Placeholder logic to increment semester
    final parts = current.split('/');
    final currentSem = int.parse(parts[2]);
    
    if (currentSem == 1) {
      // Next is second semester of same academic year
      return '${parts[0]}/${parts[1]}/2';
    } else {
      // Next is first semester of next academic year
      final nextYear = int.parse(parts[0]) + 1;
      return '$nextYear/${(nextYear + 1).toString().substring(2)}/1';
    }
  }

  /// Get available semester options for dropdown
  List<String> getAvailableSemesters() {
    return [
      '${getCurrentSemester()} (current semester)',
      getNextSemester(),
    ];
  }
}