// File: lib/services/excel_parser_service.dart
// Purpose: Excel file parsing service for Hungarian university schedules
// Step: 3.1 - Excel Parser Service Implementation

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
      final extension = fileName.toLowerCase();
      if (!extension.endsWith('.xlsx') && 
          !extension.endsWith('.xls') &&
          !extension.endsWith('.xlsm')) {
        return ExcelParseResult(
          success: false,
          message: 'Invalid file format. Please use .xlsx, .xls, or .xlsm files.',
          courses: [],
        );
      }

      // Parse Excel file
      Excel excel;
      try {
        debugPrint('$_logTag: Attempting to decode Excel file of ${fileBytes.length} bytes');
        excel = Excel.decodeBytes(fileBytes);
        debugPrint('$_logTag: Excel file decoded successfully');
      } catch (e) {
        debugPrint('$_logTag: Failed to decode Excel file: $e');
        
        // Handle specific style-related errors
        if (e.toString().contains('styles') || 
            e.toString().contains('Damaged Excel') ||
            e.toString().contains('Invalid argument')) {
          return ExcelParseResult(
            success: false,
            message: 'Excel file contains formatting that cannot be processed.\n\n'
                    'To fix this issue:\n'
                    '1. Open the file in Microsoft Excel or Google Sheets\n'
                    '2. Select all data (Ctrl+A)\n'
                    '3. Copy the data (Ctrl+C)\n'
                    '4. Create a new workbook\n'
                    '5. Paste as Values Only (Ctrl+Shift+V → Values)\n'
                    '6. Save as a new .xlsx file\n'
                    '7. Try uploading the new file\n\n'
                    'This removes complex formatting that causes parsing issues.\n\n'
                    'Technical details: ${e.toString()}',
            courses: [],
          );
        } else {
          return ExcelParseResult(
            success: false,
            message: 'Unable to read Excel file: ${e.toString()}.\n\n'
                    'Please ensure the file is:\n'
                    '• Not corrupted\n'
                    '• Not password-protected\n'
                    '• A valid Excel format (.xlsx, .xls, .xlsm)',
            courses: [],
          );
        }
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

    // Generate unique ID to avoid overwriting courses with same class code
    // Use combination of subject code, class code, type, and schedule to ensure uniqueness
    final uniqueId = '${subjectCode}_${courseCode}_${courseType}_${scheduleInfo.hashCode.abs()}'.replaceAll(' ', '_');
    
    // Update schedule slots with the course ID
    final updatedScheduleSlots = scheduleSlots.map((slot) => slot.copyWith(courseId: uniqueId)).toList();
    
    debugPrint('$_logTag: Creating course: "$subjectName" ($subjectCode) with unique ID: $uniqueId and ${updatedScheduleSlots.length} schedule slots');

    return Course(
      id: uniqueId, // Use unique generated ID
      courseCode: subjectCode, // Tárgy kódja
      courseName: subjectName, // Tárgy neve
      classCode: courseCode, // Kurzus kódja 
      classType: courseType, // Kurzus típusa
      weeklyHours: hours, // Using hours as weekly hours
      rawScheduleInfo: scheduleInfo,
      instructors: instructors.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      scheduleSlots: updatedScheduleSlots,
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
  /// - "SZE:16:45-17:30(00-114 (LD-00-114))" (single slot)
  /// - "H:08:00-09:30(A1-101 (EA-A1-101)); CS:10:00-11:30(B2-205 (GY-B2-205))" (multiple slots)
  /// - Sessions separated by semicolon
  static List<ScheduleSlot> _parseScheduleInfo(String scheduleInfo) {
    final List<ScheduleSlot> slots = [];
    
    debugPrint('$_logTag: Parsing schedule info: "$scheduleInfo"');
    
    if (scheduleInfo.isEmpty) {
      debugPrint('$_logTag: Schedule info is empty');
      return slots;
    }

    try {
      // Split by semicolon to handle multiple time slots
      final parts = scheduleInfo.split(';');
      debugPrint('$_logTag: Split into ${parts.length} parts: ${parts.map((p) => '"${p.trim()}"').toList()}');
      
      for (final part in parts) {
        final trimmedPart = part.trim();
        if (trimmedPart.isEmpty) continue;

        // Parse individual schedule slot
        final slot = _parseScheduleSlot(trimmedPart);
        if (slot != null) {
          debugPrint('$_logTag: Successfully parsed slot: day=${slot.dayOfWeek}, ${slot.startTime.hour}:${slot.startTime.minute.toString().padLeft(2, '0')}-${slot.endTime.hour}:${slot.endTime.minute.toString().padLeft(2, '0')}, location="${slot.location}"');
          slots.add(slot);
        } else {
          debugPrint('$_logTag: Failed to parse slot: "$trimmedPart"');
        }
      }
    } catch (e) {
      debugPrint('$_logTag: Error parsing schedule info "$scheduleInfo": $e');
    }

    debugPrint('$_logTag: Parsed ${slots.length} schedule slots total');
    return slots;
  }

  /// Parse a single schedule slot (e.g., "SZE:16:45-17:30(00-114 (LD-00-114))")
  static ScheduleSlot? _parseScheduleSlot(String slotInfo) {
    try {
      // Updated regex to handle the new format with location in parentheses
      // Format: DAY:HH:MM-HH:MM(LOCATION (EXACT_CODE))
      final regex = RegExp(r'^(H|K|SZE|CS|P|SZ)\s*:\s*(\d{1,2}):(\d{2})-(\d{1,2}):(\d{2})\s*\(([^)]+)\)');
      final match = regex.firstMatch(slotInfo.trim());

      if (match == null) {
        debugPrint('$_logTag: Could not parse schedule slot: "$slotInfo"');
        return null;
      }

      final dayAbbr = match.group(1)!;
      final startHour = int.parse(match.group(2)!);
      final startMinute = int.parse(match.group(3)!);
      final endHour = int.parse(match.group(4)!);
      final endMinute = int.parse(match.group(5)!);
      final locationInfo = match.group(6)!; // e.g., "00-114 (LD-00-114)"

      // Parse location info to extract classroom and exact code
      String classroom = locationInfo;
      String exactCode = '';
      
      // Check if there's an exact code in parentheses within the location
      final locationMatch = RegExp(r'^([^(]+)\s*\(([^)]+)\)').firstMatch(locationInfo);
      if (locationMatch != null) {
        classroom = locationMatch.group(1)!.trim();
        exactCode = locationMatch.group(2)!.trim();
      }

      // Map day abbreviation to day of week
      int? dayOfWeek = _dayMapping[dayAbbr];

      if (dayOfWeek == null) {
        debugPrint('$_logTag: Unknown day abbreviation: "$dayAbbr"');
        return null;
      }

      // Create location string with both classroom and exact code
      final fullLocation = exactCode.isNotEmpty ? '$classroom ($exactCode)' : classroom;

      debugPrint('$_logTag: Parsed slot - Day: $dayAbbr ($dayOfWeek), Time: $startHour:$startMinute-$endHour:$endMinute, Location: $fullLocation');

      return ScheduleSlot(
        dayOfWeek: dayOfWeek,
        startTime: TimeOfDay(hour: startHour, minute: startMinute),
        endTime: TimeOfDay(hour: endHour, minute: endMinute),
        location: fullLocation,
        courseId: '',
        displayColor: const Color(0xFF03284F), // Default color
      );

    } catch (e) {
      debugPrint('$_logTag: Error parsing schedule slot "$slotInfo": $e');
      return null;
    }
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