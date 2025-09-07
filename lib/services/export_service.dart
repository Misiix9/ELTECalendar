// File: lib/services/export_service.dart
// Purpose: Comprehensive export functionality for schedules in multiple formats
// Step: 8.1 - Export Service Implementation

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/course_model.dart';
import '../models/semester_model.dart';
import '../models/export_model.dart';
import '../services/calendar_service.dart';
import '../services/semester_service.dart';
// import '../services/auth_service.dart'; // TODO: Uncomment when user preferences are implemented

/// Comprehensive export service handling multiple export formats
/// Supports ICS calendar, PDF schedule, and Excel exports
class ExportService extends ChangeNotifier {
  static const String _logTag = 'ExportService';

  // Dependencies
  final CalendarService _calendarService;
  final SemesterService _semesterService;
  // final AuthService _authService; // TODO: Will be used for user preferences - currently unused

  // State
  bool _isExporting = false;
  String? _lastExportPath;
  ExportProgress? _currentProgress;

  // Constructor
  ExportService(
    this._calendarService,
    this._semesterService,
    // this._authService, // TODO: Add back when user preferences are implemented
  );

  // Getters
  bool get isExporting => _isExporting;
  String? get lastExportPath => _lastExportPath;
  ExportProgress? get currentProgress => _currentProgress;

  /// Export schedule to ICS (iCalendar) format
  Future<ExportResult> exportToICS({
    required ExportOptions options,
  }) async {
    try {
      _setExporting(true, ExportType.ics);
      _updateProgress('Preparing calendar data...', 0.1);

      final courses = await _getCoursesForExport(options);
      if (courses.isEmpty) {
        throw Exception('No courses found for the selected criteria');
      }

      _updateProgress('Generating ICS calendar...', 0.3);
      final icsContent = _generateICSContent(courses, options);

      _updateProgress('Finalizing export...', 0.8);
      final fileName = _generateFileName('schedule', 'ics', options);
      
      _updateProgress('Export complete!', 1.0);
      
      final result = ExportResult(
        success: true,
        filePath: fileName,
        fileContent: icsContent,
        exportType: ExportType.ics,
        itemCount: courses.length,
        fileSize: icsContent.length,
      );

      _lastExportPath = fileName;
      debugPrint('$_logTag: ICS export completed - ${courses.length} courses');
      
      return result;

    } catch (e) {
      debugPrint('$_logTag: ICS export failed: $e');
      return ExportResult(
        success: false,
        error: e.toString(),
        exportType: ExportType.ics,
      );
    } finally {
      _setExporting(false);
    }
  }

  /// Export schedule to PDF format
  Future<ExportResult> exportToPDF({
    required ExportOptions options,
  }) async {
    try {
      _setExporting(true, ExportType.pdf);
      _updateProgress('Preparing schedule data...', 0.1);

      final courses = await _getCoursesForExport(options);
      if (courses.isEmpty) {
        throw Exception('No courses found for the selected criteria');
      }

      _updateProgress('Generating PDF layout...', 0.3);
      final pdfBytes = await _generatePDFContent(courses, options);

      _updateProgress('Finalizing PDF...', 0.8);
      final fileName = _generateFileName('schedule', 'pdf', options);
      
      _updateProgress('Export complete!', 1.0);
      
      final result = ExportResult(
        success: true,
        filePath: fileName,
        fileContent: pdfBytes,
        exportType: ExportType.pdf,
        itemCount: courses.length,
        fileSize: pdfBytes.length,
      );

      _lastExportPath = fileName;
      debugPrint('$_logTag: PDF export completed - ${courses.length} courses');
      
      return result;

    } catch (e) {
      debugPrint('$_logTag: PDF export failed: $e');
      return ExportResult(
        success: false,
        error: e.toString(),
        exportType: ExportType.pdf,
      );
    } finally {
      _setExporting(false);
    }
  }

  /// Export schedule to Excel format
  Future<ExportResult> exportToExcel({
    required ExportOptions options,
  }) async {
    try {
      _setExporting(true, ExportType.excel);
      _updateProgress('Preparing course data...', 0.1);

      final courses = await _getCoursesForExport(options);
      if (courses.isEmpty) {
        throw Exception('No courses found for the selected criteria');
      }

      _updateProgress('Generating Excel workbook...', 0.3);
      final excelBytes = await _generateExcelContent(courses, options);

      _updateProgress('Finalizing Excel file...', 0.8);
      final fileName = _generateFileName('schedule', 'xlsx', options);
      
      _updateProgress('Export complete!', 1.0);
      
      final result = ExportResult(
        success: true,
        filePath: fileName,
        fileContent: excelBytes,
        exportType: ExportType.excel,
        itemCount: courses.length,
        fileSize: excelBytes.length,
      );

      _lastExportPath = fileName;
      debugPrint('$_logTag: Excel export completed - ${courses.length} courses');
      
      return result;

    } catch (e) {
      debugPrint('$_logTag: Excel export failed: $e');
      return ExportResult(
        success: false,
        error: e.toString(),
        exportType: ExportType.excel,
      );
    } finally {
      _setExporting(false);
    }
  }

  /// Get courses for export based on options
  Future<List<Course>> _getCoursesForExport(ExportOptions options) async {
    List<Course> courses = _calendarService.courses;

    // Filter by course types
    if (options.courseTypes.isNotEmpty) {
      courses = courses.where((course) {
        final courseType = CourseTypeExtension.fromString(course.classType);
        return courseType != null && options.courseTypes.contains(courseType);
      }).toList();
    }

    // Filter by date range
    if (options.startDate != null || options.endDate != null) {
      final semester = _semesterService.currentSemester;
      if (semester != null) {
        // TODO: Implement date range filtering based on actual schedule dates
        // For now, include all courses in semester
        // final semesterStart = options.startDate ?? semester.startDate;
        // final semesterEnd = options.endDate ?? semester.endDate;
      }
    }

    return courses;
  }

  /// Generate ICS calendar content
  String _generateICSContent(List<Course> courses, ExportOptions options) {
    final buffer = StringBuffer();
    
    // ICS Header
    buffer.writeln('BEGIN:VCALENDAR');
    buffer.writeln('VERSION:2.0');
    buffer.writeln('PRODID:-//ELTE Calendar//Course Schedule//EN');
    buffer.writeln('CALSCALE:GREGORIAN');
    buffer.writeln('METHOD:PUBLISH');
    buffer.writeln('X-WR-CALNAME:${options.title ?? 'ELTE Course Schedule'}');
    buffer.writeln('X-WR-CALDESC:University course schedule exported from ELTE Calendar');
    
    final semester = _semesterService.selectedSemester;
    if (semester != null) {
      // Generate events for each course session
      for (final course in courses) {
        for (final slot in course.scheduleSlots) {
          _addICSEvent(buffer, course, slot, semester, options);
        }
      }
    }
    
    // ICS Footer
    buffer.writeln('END:VCALENDAR');
    
    return buffer.toString();
  }

  /// Add individual ICS event
  void _addICSEvent(
    StringBuffer buffer, 
    Course course, 
    ScheduleSlot slot, 
    Semester semester,
    ExportOptions options,
  ) {
    final semesterWeeks = _calculateSemesterWeeks(semester);
    
    for (int week = 0; week < semesterWeeks; week++) {
      final eventDate = _getWeeklyEventDate(semester.startDate, week, slot.dayOfWeek);
      
      // Skip if outside semester bounds
      if (eventDate.isAfter(semester.endDate)) continue;
      
      final eventStart = _combineDateAndTime(eventDate, slot.startTime);
      final eventEnd = _combineDateAndTime(eventDate, slot.endTime);
      
      buffer.writeln('BEGIN:VEVENT');
      buffer.writeln('UID:${course.id}-${slot.dayOfWeek}-$week@elte-calendar.com');
      buffer.writeln('DTSTAMP:${_formatICSDateTime(DateTime.now())}');
      buffer.writeln('DTSTART:${_formatICSDateTime(eventStart)}');
      buffer.writeln('DTEND:${_formatICSDateTime(eventEnd)}');
      buffer.writeln('SUMMARY:${_escapeICSText(course.courseName)}');
      
      // Description with course details
      final description = _buildEventDescription(course, slot, options);
      buffer.writeln('DESCRIPTION:${_escapeICSText(description)}');
      
      if (slot.location.isNotEmpty) {
        buffer.writeln('LOCATION:${_escapeICSText(slot.location)}');
      }
      
      // Categories
      buffer.writeln('CATEGORIES:${course.classType}');
      
      // Organizer (instructors)
      if (course.instructors.isNotEmpty) {
        buffer.writeln('ORGANIZER:CN=${_escapeICSText(course.instructors.first)}');
      }
      
      buffer.writeln('END:VEVENT');
    }
  }

  /// Generate PDF content
  Future<Uint8List> _generatePDFContent(List<Course> courses, ExportOptions options) async {
    final pdf = pw.Document();
    final semester = _semesterService.selectedSemester;
    
    // Create PDF document
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            _buildPDFHeader(options, semester),
            pw.SizedBox(height: 20),
            
            // Course schedule table
            if (options.layoutType == ExportLayoutType.weekly)
              _buildPDFWeeklyView(courses, options, semester)
            else if (options.layoutType == ExportLayoutType.list)
              _buildPDFListView(courses, options)
            else
              _buildPDFScheduleTable(courses, options),
              
            pw.SizedBox(height: 20),
            
            // Footer
            _buildPDFFooter(),
          ];
        },
      ),
    );

    return await pdf.save();
  }

  /// Generate Excel content
  Future<Uint8List> _generateExcelContent(List<Course> courses, ExportOptions options) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Course Schedule'];
    
    // Remove default sheet if needed
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    // Set up header row
    const headers = [
      'Course Name',
      'Course Code', 
      'Type',
      'Weekly Hours',
      'Instructors',
      'Day',
      'Time',
      'Location',
      'Semester'
    ];
    
    // Add headers with styling
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = headers[i] as CellValue?;
      cell.cellStyle = CellStyle(
        fontColorHex: ExcelColor.white,
        backgroundColorHex: ExcelColor.blue900, // Close to primary dark blue
        bold: true,
      );
    }
    
    // Add course data
    int currentRow = 1;
    final semester = _semesterService.selectedSemester;
    
    for (final course in courses) {
      if (course.scheduleSlots.isEmpty) {
        // Course without specific schedule
        _addExcelCourseRow(sheet, currentRow, course, null, semester);
        currentRow++;
      } else {
        // Course with schedule slots
        for (final slot in course.scheduleSlots) {
          _addExcelCourseRow(sheet, currentRow, course, slot, semester);
          currentRow++;
        }
      }
    }
    
    // Auto-size columns
    for (int i = 0; i < headers.length; i++) {
      sheet.setColumnAutoFit(i);
    }
    
    // Add summary row
    currentRow += 2;
    final summaryCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    summaryCell.value = 'Total Courses: ${courses.length}' as CellValue?;
    summaryCell.cellStyle = CellStyle(bold: true);
    
    // Generate export timestamp
    currentRow++;
    final timestampCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    timestampCell.value = 'Exported: ${DateTime.now().toString().substring(0, 16)}' as CellValue?;
    
    final bytes = excel.encode();
    return bytes != null ? Uint8List.fromList(bytes) : Uint8List(0);
  }

  /// Build event description for ICS
  String _buildEventDescription(Course course, ScheduleSlot slot, ExportOptions options) {
    final parts = <String>[];
    
    parts.add('Course: ${course.courseName}');
    parts.add('Code: ${course.courseCode}');
    parts.add('Type: ${course.classType}');
    
    if (course.instructors.isNotEmpty) {
      parts.add('Instructor(s): ${course.instructors.join(', ')}');
    }
    
    parts.add('Weekly Hours: ${course.weeklyHours}');
    
    if (options.includeDescription && course.notes != null) {
      parts.add('Notes: ${course.notes}');
    }
    
    parts.add('\\nExported from ELTE Calendar');
    
    return parts.join('\\n');
  }

  /// Generate filename based on options
  String _generateFileName(String baseName, String extension, ExportOptions options) {
    final timestamp = DateTime.now();
    final dateStr = '${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}';
    
    String fileName = baseName;
    
    if (options.semesterIds.length == 1) {
      final semester = _semesterService.availableSemesters
          .where((s) => options.semesterIds.contains(s.id))
          .firstOrNull;
      if (semester != null) {
        fileName += '_${semester.shortDisplayName.replaceAll('/', '-')}';
      }
    }
    
    fileName += '_$dateStr.$extension';
    return fileName;
  }

  /// Calculate number of weeks in semester
  int _calculateSemesterWeeks(Semester semester) {
    return semester.endDate.difference(semester.startDate).inDays ~/ 7 + 1;
  }

  /// Get event date for specific week and day
  DateTime _getWeeklyEventDate(DateTime semesterStart, int week, int dayOfWeek) {
    final weekStart = semesterStart.add(Duration(days: week * 7));
    final dayOffset = (dayOfWeek - weekStart.weekday) % 7;
    return weekStart.add(Duration(days: dayOffset));
  }

  /// Combine date and time
  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  /// Format datetime for ICS
  String _formatICSDateTime(DateTime dateTime) {
    final utc = dateTime.toUtc();
    return '${utc.year}${utc.month.toString().padLeft(2, '0')}${utc.day.toString().padLeft(2, '0')}'
        'T${utc.hour.toString().padLeft(2, '0')}${utc.minute.toString().padLeft(2, '0')}${utc.second.toString().padLeft(2, '0')}Z';
  }

  /// Escape text for ICS format
  String _escapeICSText(String text) {
    return text
        .replaceAll('\\', '\\\\')
        .replaceAll(',', '\\,')
        .replaceAll(';', '\\;')
        .replaceAll('\n', '\\n');
  }

  /// Set export state
  void _setExporting(bool exporting, [ExportType? type]) {
    _isExporting = exporting;
    if (exporting && type != null) {
      _currentProgress = ExportProgress(
        type: type,
        progress: 0.0,
        message: 'Starting export...',
      );
    } else {
      _currentProgress = null;
    }
    notifyListeners();
  }

  /// Update export progress
  void _updateProgress(String message, double progress) {
    if (_currentProgress != null) {
      _currentProgress = _currentProgress!.copyWith(
        message: message,
        progress: progress,
      );
      notifyListeners();
    }
  }

  /// Get export history (could be expanded)
  List<ExportHistoryItem> getExportHistory() {
    // TODO: Implement export history tracking
    return [];
  }

  /// Clear export history
  void clearExportHistory() {
    // TODO: Implement history clearing
    notifyListeners();
  }

  /// Add Excel course row
  void _addExcelCourseRow(Sheet sheet, int row, Course course, ScheduleSlot? slot, Semester? semester) {
    final cells = [
      course.courseName,
      course.courseCode,
      course.classType,
      course.weeklyHours.toString(),
      course.instructors.join(', '),
      slot != null ? _getDayName(slot.dayOfWeek) : '',
      slot != null ? '${_formatTimeOfDay(slot.startTime)} - ${_formatTimeOfDay(slot.endTime)}' : '',
      slot?.location ?? '',
      semester?.displayName ?? '',
    ];
    
    for (int i = 0; i < cells.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row));
      cell.value = cells[i] as CellValue?;
    }
  }
  
  /// Get day name from day of week number
  String _getDayName(int dayOfWeek) {
    const days = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return dayOfWeek >= 1 && dayOfWeek <= 7 ? days[dayOfWeek] : 'Unknown';
  }
  
  /// Format TimeOfDay for display
  String _formatTimeOfDay(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  /// Build PDF header
  pw.Widget _buildPDFHeader(ExportOptions options, Semester? semester) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          options.title ?? 'Course Schedule',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        if (semester != null) ...[
          pw.SizedBox(height: 8),
          pw.Text(
            'Semester: ${semester.displayName}',
            style: pw.TextStyle(fontSize: 16),
          ),
        ],
        pw.SizedBox(height: 8),
        pw.Text(
          'Generated: ${DateTime.now().toString().substring(0, 16)}',
          style: pw.TextStyle(fontSize: 12),
        ),
        pw.Divider(),
      ],
    );
  }

  /// Build PDF schedule table
  pw.Widget _buildPDFScheduleTable(List<Course> courses, ExportOptions options) {
    final headers = ['Course', 'Code', 'Type', 'Day', 'Time', 'Location', 'Instructor'];
    final data = <List<String>>[];
    
    for (final course in courses) {
      if (course.scheduleSlots.isEmpty) {
        data.add([
          course.courseName,
          course.courseCode,
          course.classType,
          '-',
          '-',
          '-',
          course.instructors.join(', '),
        ]);
      } else {
        for (final slot in course.scheduleSlots) {
          data.add([
            course.courseName,
            course.courseCode,
            course.classType,
            _getDayName(slot.dayOfWeek),
            '${_formatTimeOfDay(slot.startTime)} - ${_formatTimeOfDay(slot.endTime)}',
            slot.location,
            course.instructors.join(', '),
          ]);
        }
      }
    }
    
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellAlignment: pw.Alignment.centerLeft,
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(2),
        5: const pw.FlexColumnWidth(2),
        6: const pw.FlexColumnWidth(2.5),
      },
    );
  }

  /// Build PDF weekly view
  pw.Widget _buildPDFWeeklyView(List<Course> courses, ExportOptions options, Semester? semester) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final weekData = <String, List<String>>{};
    
    // Initialize days
    for (final day in days) {
      weekData[day] = [];
    }
    
    // Group courses by day
    for (final course in courses) {
      for (final slot in course.scheduleSlots) {
        final dayName = _getDayName(slot.dayOfWeek);
        if (weekData.containsKey(dayName)) {
          weekData[dayName]!.add(
            '${_formatTimeOfDay(slot.startTime)}-${_formatTimeOfDay(slot.endTime)} ${course.courseName} (${course.courseCode})'
          );
        }
      }
    }
    
    return pw.Column(
      children: days.map((day) {
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                day,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              ...weekData[day]!.map((courseInfo) => pw.Padding(
                padding: const pw.EdgeInsets.only(left: 16, bottom: 4),
                child: pw.Text(courseInfo, style: const pw.TextStyle(fontSize: 12)),
              )),
              if (weekData[day]!.isEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 16),
                  child: pw.Text('No courses', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Build PDF list view
  pw.Widget _buildPDFListView(List<Course> courses, ExportOptions options) {
    return pw.Column(
      children: courses.map((course) {
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 16),
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                course.courseName,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text('Code: ${course.courseCode}', style: const pw.TextStyle(fontSize: 12)),
              pw.Text('Type: ${course.classType}', style: const pw.TextStyle(fontSize: 12)),
              if (course.instructors.isNotEmpty)
                pw.Text('Instructors: ${course.instructors.join(', ')}', style: const pw.TextStyle(fontSize: 12)),
              if (course.scheduleSlots.isNotEmpty) ...[
                pw.SizedBox(height: 8),
                pw.Text('Schedule:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                ...course.scheduleSlots.map((slot) => pw.Text(
                  '${_getDayName(slot.dayOfWeek)} ${_formatTimeOfDay(slot.startTime)} - ${_formatTimeOfDay(slot.endTime)}${slot.location.isNotEmpty ? ' at ${slot.location}' : ''}',
                  style: const pw.TextStyle(fontSize: 11),
                )),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Build PDF footer
  pw.Widget _buildPDFFooter() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.Text(
          'Generated by ELTE Calendar App',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
        ),
      ],
    );
  }

  @override
  void dispose() {
    debugPrint('$_logTag: Export service disposed');
    super.dispose();
  }
}

/// Extension for nullable list firstWhere
extension ListExtension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}