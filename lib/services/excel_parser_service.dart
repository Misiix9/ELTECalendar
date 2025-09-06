// File: lib/services/excel_parser_service.dart
// Purpose: Excel file parsing service for Hungarian university schedules
// Step: 3.1 - Excel Parser Service Implementation

import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/course_model.dart';

/// Service for parsing Excel files containing Hungarian university schedules
/// Handles the specific format with Hungarian column headers and day abbreviations
class ExcelParserService {
  static const String _logTag = 'ExcelParserService';

  /// Required Hungarian column headers
  static const Map<String, String> _requiredColumns = {
    'subject_code': 'Tárgy kódja',
    'subject_name': 'Tárgy neve', 
    'course_code': 'Kurzus kódja',
    'course_type': 'Kurzus típusa',
    'hours': 'Óraszám:',
    'schedule_info': 'Órarend infó',
    'instructors': 'Oktatók',
    'waiting_list': 'Várólista', // This column is ignored
  };

  /// Hungarian day abbreviations mapping
  static const Map<String, int> _dayMapping = {
    'H': 1,    // Hétfő (Monday)
    'K': 2,    // Kedd (Tuesday) 
    'SZE': 3,  // Szerda (Wednesday)
    'CS': 4,   // Csütörtök (Thursday)
    'P': 5,    // Péntek (Friday)
    'SZ': 6,   // Szombat (Saturday) - only when after P
  };

  /// Parse Excel file bytes and return list of courses
  /// 
  /// [fileBytes] - The Excel file as bytes
  /// [fileName] - Original file name for validation
  /// 
  /// Returns [ExcelParseResult] with success status and parsed courses or error message
  static Future<ExcelParseResult> parseExcelFile({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      debugPrint('$_logTag: Starting Excel file parsing for: $fileName');
      
      // Validate file extension
      if (!fileName.toLowerCase().endsWith('.xlsx') && 
          !fileName.toLowerCase().endsWith('.xls')) {
        return ExcelParseResult(
          success: false,
          message: 'Invalid file format. Please use .xlsx or .xls files.',
          courses: [],
        );
      }

      // Parse Excel file
      Excel excel;
      try {
        excel = Excel.decodeBytes(fileBytes);
      } catch (e) {
        debugPrint('$_logTag: Failed to decode Excel file: $e');
        return ExcelParseResult(
          success: false,
          message: 'Unable to read Excel file. Please ensure it is not corrupted.',
          courses: [],
        );
      }

      // Get the first sheet
      if (excel.tables.isEmpty) {
        return ExcelParseResult(
          success: false,
          message: 'Excel file contains no worksheets.',
          courses: [],
        );
      }

      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName]!;

      debugPrint('$_logTag: Processing sheet: $sheetName');
      debugPrint('$_logTag: Sheet has ${sheet.maxRows} rows and ${sheet.maxColumns} columns');

      // Validate sheet has data
      if (sheet.maxRows < 2) {
        return ExcelParseResult(
          success: false,
          message: 'Excel file must contain at least a header row and one data row.',
          courses: [],
        );
      }

      // Find and validate column headers
      final columnMapping = _validateAndMapColumns(sheet);
      if (columnMapping == null) {
        return ExcelParseResult(
          success: false,
          message: 'Excel file does not contain required Hungarian column headers.\n\nRequired columns:\n${_requiredColumns.values.join('\n')}',
          courses: [],
        );
      }

      debugPrint('$_logTag: Column mapping successful');

      // Parse each row into courses
      final List<Course> courses = [];
      int successfulRows = 0;
      int skippedRows = 0;

      for (int rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
        try {
          final course = _parseRowToCourse(sheet, rowIndex, columnMapping);
          if (course != null) {
            courses.add(course);
            successfulRows++;
          } else {
            skippedRows++;
          }
        } catch (e) {
          debugPrint('$_logTag: Error parsing row ${rowIndex + 1}: $e');
          skippedRows++;
        }
      }

      debugPrint('$_logTag: Parsing completed - $successfulRows courses parsed, $skippedRows rows skipped');

      if (courses.isEmpty) {
        return ExcelParseResult(
          success: false,
          message: 'No valid courses found in Excel file. Please check the data format.',
          courses: [],
        );
      }

      return ExcelParseResult(
        success: true,
        message: 'Successfully imported $successfulRows courses from Excel file.',
        courses: courses,
      );

    } catch (e) {
      debugPrint('$_logTag: Unexpected error during Excel parsing: $e');
      return ExcelParseResult(
        success: false,
        message: 'An unexpected error occurred while parsing the Excel file: ${e.toString()}',
        courses: [],
      );
    }
  }

  /// Validate required columns exist and create mapping from column index to field name
  static Map<String, int>? _validateAndMapColumns(Sheet sheet) {
    if (sheet.maxRows == 0) return null;

    final headerRow = sheet.row(0);
    final Map<String, int> columnMapping = {};

    // Find each required column (except waiting list which is optional)
    for (final entry in _requiredColumns.entries) {
      if (entry.key == 'waiting_list') continue; // Skip optional column

      bool found = false;
      for (int colIndex = 0; colIndex < headerRow.length; colIndex++) {
        final cell = headerRow[colIndex];
        final cellValue = cell?.value?.toString().trim() ?? '';
        
        if (cellValue.toLowerCase() == entry.value.toLowerCase()) {
          columnMapping[entry.key] = colIndex;
          found = true;
          break;
        }
      }

      if (!found) {
        debugPrint('ExcelParserService: Required column "${entry.value}" not found');
        return null;
      }
    }

    return columnMapping;
  }

  /// Parse a single row into a Course object
  static Course? _parseRowToCourse(Sheet sheet, int rowIndex, Map<String, int> columnMapping) {
    final row = sheet.row(rowIndex);
    
    // Extract basic course information
    final subjectCode = _getCellValue(row, columnMapping['subject_code']!);
    final subjectName = _getCellValue(row, columnMapping['subject_name']!);
    final courseCode = _getCellValue(row, columnMapping['course_code']!);
    final courseType = _getCellValue(row, columnMapping['course_type']!);
    final hoursStr = _getCellValue(row, columnMapping['hours']!);
    final scheduleInfo = _getCellValue(row, columnMapping['schedule_info']!);
    final instructors = _getCellValue(row, columnMapping['instructors']!);

    // Validate required fields
    if (subjectCode.isEmpty || subjectName.isEmpty || courseCode.isEmpty) {
      debugPrint('ExcelParserService: Skipping row ${rowIndex + 1} - missing required fields');
      return null;
    }

    // Parse hours
    int hours = 0;
    try {
      final hoursMatch = RegExp(r'(\d+)').firstMatch(hoursStr);
      if (hoursMatch != null) {
        hours = int.parse(hoursMatch.group(1)!);
      }
    } catch (e) {
      debugPrint('ExcelParserService: Could not parse hours from "$hoursStr"');
    }

    // Parse schedule information
    final scheduleSlots = _parseScheduleInfo(scheduleInfo);

    return Course(
      id: courseCode, // Use course code as ID  
      courseCode: subjectCode, // Tárgy kódja
      courseName: subjectName, // Tárgy neve
      classCode: courseCode, // Kurzus kódja 
      classType: courseType, // Kurzus típusa
      weeklyHours: hours, // Using hours as weekly hours
      rawScheduleInfo: scheduleInfo,
      instructors: instructors.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      scheduleSlots: scheduleSlots,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Get cell value as string, handling null values
  static String _getCellValue(List<Data?> row, int columnIndex) {
    if (columnIndex >= row.length) return '';
    final cell = row[columnIndex];
    return cell?.value?.toString().trim() ?? '';
  }

  /// Parse the "Órarend infó" field into schedule slots
  /// 
  /// Expected formats:
  /// - "H 08:00-09:30, CS 10:00-11:30" (multiple slots)
  /// - "K 14:00-15:30" (single slot)
  /// - "P 16:00-17:30, SZ 09:00-10:30" (including Saturday)
  static List<ScheduleSlot> _parseScheduleInfo(String scheduleInfo) {
    final List<ScheduleSlot> slots = [];
    
    if (scheduleInfo.isEmpty) return slots;

    try {
      // Split by comma to handle multiple time slots
      final parts = scheduleInfo.split(',');
      
      for (final part in parts) {
        final trimmedPart = part.trim();
        if (trimmedPart.isEmpty) continue;

        // Parse individual schedule slot
        final slot = _parseScheduleSlot(trimmedPart);
        if (slot != null) {
          slots.add(slot);
        }
      }
    } catch (e) {
      debugPrint('ExcelParserService: Error parsing schedule info "$scheduleInfo": $e');
    }

    return slots;
  }

  /// Parse a single schedule slot (e.g., "H 08:00-09:30")
  static ScheduleSlot? _parseScheduleSlot(String slotInfo) {
    try {
      // Regular expression to match day abbreviation and time range
      // Handles: "H 08:00-09:30", "SZE 14:00-15:30", etc.
      final regex = RegExp(r'^(H|K|SZE|CS|P|SZ)\s+(\d{1,2}):(\d{2})-(\d{1,2}):(\d{2})');
      final match = regex.firstMatch(slotInfo);

      if (match == null) {
        debugPrint('ExcelParserService: Could not parse schedule slot: "$slotInfo"');
        return null;
      }

      final dayAbbr = match.group(1)!;
      final startHour = int.parse(match.group(2)!);
      final startMinute = int.parse(match.group(3)!);
      final endHour = int.parse(match.group(4)!);
      final endMinute = int.parse(match.group(5)!);

      // Map day abbreviation to day of week
      int? dayOfWeek;
      
      // Special handling for SZ (Saturday) - only valid after P (Friday)
      if (dayAbbr == 'SZ') {
        dayOfWeek = _dayMapping['SZ'];
      } else {
        dayOfWeek = _dayMapping[dayAbbr];
      }

      if (dayOfWeek == null) {
        debugPrint('ExcelParserService: Unknown day abbreviation: "$dayAbbr"');
        return null;
      }

      return ScheduleSlot(
        dayOfWeek: dayOfWeek,
        startTime: TimeOfDay(hour: startHour, minute: startMinute),
        endTime: TimeOfDay(hour: endHour, minute: endMinute),
        location: _extractLocation(slotInfo) ?? '',
        courseId: '',
        displayColor: const Color(0xFF03284F), // Default color
      );

    } catch (e) {
      debugPrint('ExcelParserService: Error parsing schedule slot "$slotInfo": $e');
      return null;
    }
  }

  /// Extract location information from schedule slot if present
  /// Some schedule formats may include room/building info
  static String? _extractLocation(String slotInfo) {
    // Look for location info after the time (e.g., "H 08:00-09:30 Room 101")
    final parts = slotInfo.split(' ');
    if (parts.length > 2) {
      // Everything after the time range could be location
      final timePattern = RegExp(r'\d{1,2}:\d{2}-\d{1,2}:\d{2}');
      final match = timePattern.firstMatch(slotInfo);
      if (match != null) {
        final afterTime = slotInfo.substring(match.end).trim();
        return afterTime.isNotEmpty ? afterTime : null;
      }
    }
    return null;
  }

}

/// Result class for Excel parsing operations
class ExcelParseResult {
  final bool success;
  final String message;
  final List<Course> courses;

  const ExcelParseResult({
    required this.success,
    required this.message,
    required this.courses,
  });

  @override
  String toString() {
    return 'ExcelParseResult{success: $success, message: $message, coursesCount: ${courses.length}}';
  }
}