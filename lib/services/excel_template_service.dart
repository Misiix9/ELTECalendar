// File: lib/services/excel_template_service.dart
// Purpose: Service for generating Excel templates and validating file structures
// Step: Excel Template Service Implementation

import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';

/// Service for creating Excel templates and validating file structures
class ExcelTemplateService {
  static const String _logTag = 'ExcelTemplateService';

  /// Hungarian column headers for the template
  static const List<String> _templateHeaders = [
    'Tárgy kódja',      // Subject code
    'Tárgy neve',       // Subject name
    'Kurzus kódja',     // Course code
    'Kurzus típusa',    // Course type
    'Óraszám:',         // Hours
    'Órarend infó',     // Schedule info
    'Oktatók',          // Instructors
  ];

  /// Generate a sample Excel template with example data
  static Uint8List generateTemplate() {
    try {
      debugPrint('$_logTag: Generating Excel template');
      
      final excel = Excel.createExcel();
      final sheet = excel['Schedule Template'];
      
      // Add headers
      for (int i = 0; i < _templateHeaders.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(_templateHeaders[i]);
        
        // Style the header
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.blue,
          fontColorHex: ExcelColor.white,
        );
      }
      
      // Add sample data rows
      final sampleData = [
        [
          'IK-1234',
          'Algoritmusok és adatszerkezetek',
          'IK-1234-01',
          'Előadás',
          '2',
          'H 10:00-12:00 PC111',
          'Dr. Nagy Péter'
        ],
        [
          'IK-1234',
          'Algoritmusok és adatszerkezetek', 
          'IK-1234-02',
          'Gyakorlat',
          '2',
          'K 14:00-16:00 PC202',
          'Kiss Anna'
        ],
        [
          'IK-5678',
          'Adatbázisok',
          'IK-5678-01',
          'Előadás',
          '3',
          'SZE 9:00-12:00 0.81',
          'Dr. Kovács János'
        ],
        [
          'IK-5678',
          'Adatbázisok',
          'IK-5678-02',
          'Labor',
          '2',
          'CS 16:00-18:00 PC115',
          'Szabó Mária'
        ],
      ];
      
      for (int rowIndex = 0; rowIndex < sampleData.length; rowIndex++) {
        final rowData = sampleData[rowIndex];
        for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
          final cell = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: colIndex, 
            rowIndex: rowIndex + 1
          ));
          cell.value = TextCellValue(rowData[colIndex]);
        }
      }
      
      // Auto-size columns (Excel package doesn't support setColWidth, so we skip this)
      // for (int i = 0; i < _templateHeaders.length; i++) {
      //   sheet.setColWidth(i, 20.0);
      // }
      
      // Add instructions sheet
      final instructionsSheet = excel['Import Instructions'];
      final instructions = [
        'Excel Import Instructions',
        '',
        'Required Columns:',
        '• Tárgy kódja - Subject/course identifier code',
        '• Tárgy neve - Full name of the subject',
        '• Kurzus kódja - Specific course section code', 
        '• Kurzus típusa - Type (Előadás, Gyakorlat, Labor, etc.)',
        '• Óraszám: - Number of hours per week',
        '• Órarend infó - Schedule information in format: "DAY HH:MM-HH:MM ROOM"',
        '• Oktatók - Instructor names',
        '',
        'Day Abbreviations:',
        '• H = Hétfő (Monday)',
        '• K = Kedd (Tuesday)', 
        '• SZE = Szerda (Wednesday)',
        '• CS = Csütörtök (Thursday)',
        '• P = Péntek (Friday)',
        '• SZ = Szombat (Saturday)',
        '',
        'Schedule Format Examples:',
        '• "H 10:00-12:00 PC111" - Monday 10-12 AM in PC111',
        '• "K,CS 14:00-16:00 0.81" - Tuesday and Thursday 2-4 PM in room 0.81',
        '• "P 09:00-11:00 Zöld u. 1." - Friday 9-11 AM at Zöld u. 1.',
        '',
        'Tips:',
        '• Keep the exact column headers from the template',
        '• One row per course section',
        '• Use Hungarian day abbreviations',
        '• Include room/location information',
        '• Time format: HH:MM-HH:MM (24-hour)',
      ];
      
      for (int i = 0; i < instructions.length; i++) {
        final cell = instructionsSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i));
        cell.value = TextCellValue(instructions[i]);
        
        if (i == 0) {
          // Title styling
          cell.cellStyle = CellStyle(
            bold: true,
            fontSize: 16,
            fontColorHex: ExcelColor.blue,
          );
        } else if (instructions[i].startsWith('•')) {
          // Bullet point styling
          cell.cellStyle = CellStyle(fontSize: 11);
        } else if (instructions[i].endsWith(':')) {
          // Section headers
          cell.cellStyle = CellStyle(
            bold: true,
            fontSize: 12,
            fontColorHex: ExcelColor.blue,
          );
        }
      }
      
      // instructionsSheet.setColWidth(0, 50.0); // Not supported by Excel package
      
      debugPrint('$_logTag: Template generated successfully');
      return Uint8List.fromList(excel.encode()!);
      
    } catch (e) {
      debugPrint('$_logTag: Error generating template: $e');
      // Return empty Excel file if generation fails
      final excel = Excel.createExcel();
      return Uint8List.fromList(excel.encode()!);
    }
  }

  /// Validate file structure and provide suggestions
  static FileValidationResult validateFileStructure(Excel excel) {
    try {
      if (excel.tables.isEmpty) {
        return FileValidationResult(
          isValid: false,
          message: 'Excel file contains no worksheets.',
          suggestions: ['Ensure the file is a valid Excel document'],
        );
      }

      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName]!;

      if (sheet.maxRows < 2) {
        return FileValidationResult(
          isValid: false,
          message: 'Excel file must contain at least a header row and one data row.',
          suggestions: [
            'Add at least one row of course data',
            'Ensure the first row contains column headers'
          ],
        );
      }

      // Check for required columns
      final headerRow = sheet.row(0);
      final foundHeaders = <String>[];
      final missingHeaders = <String>[];
      
      for (final header in _templateHeaders) {
        bool found = false;
        for (int i = 0; i < headerRow.length; i++) {
          final cellValue = headerRow[i]?.value?.toString().trim() ?? '';
          if (cellValue.toLowerCase() == header.toLowerCase()) {
            foundHeaders.add(header);
            found = true;
            break;
          }
        }
        if (!found && header != 'Várólista') { // Várólista is optional
          missingHeaders.add(header);
        }
      }

      if (missingHeaders.isNotEmpty) {
        return FileValidationResult(
          isValid: false,
          message: 'Missing required columns: ${missingHeaders.join(", ")}',
          suggestions: [
            'Download the template file to see the correct format',
            'Ensure all required column headers are present',
            'Check for spelling errors in column headers'
          ],
        );
      }

      return FileValidationResult(
        isValid: true,
        message: 'File structure looks good! Found ${foundHeaders.length} required columns and ${sheet.maxRows - 1} data rows.',
        suggestions: [],
      );

    } catch (e) {
      return FileValidationResult(
        isValid: false,
        message: 'Error validating file: ${e.toString()}',
        suggestions: ['Try using a different Excel file or check if it\'s corrupted'],
      );
    }
  }
}

/// Result of file structure validation
class FileValidationResult {
  final bool isValid;
  final String message;
  final List<String> suggestions;

  const FileValidationResult({
    required this.isValid,
    required this.message,
    required this.suggestions,
  });
}
