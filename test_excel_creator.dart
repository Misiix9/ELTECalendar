import 'dart:io';
import 'package:excel/excel.dart';

void main() {
  // Create a new Excel file with Hungarian headers
  var excel = Excel.createExcel();
  
  // Remove the default sheet
  excel.delete('Sheet1');
  
  // Create a sheet with Hungarian name
  var sheet = excel['Órák'];
  
  // Add Hungarian headers as expected by the parser
  final headers = [
    'Tárgy kódja',      // subject_code
    'Tárgy neve',       // subject_name
    'Kurzus kódja',     // course_code
    'Kurzus típusa',    // course_type
    'Óraszám:',         // hours
    'Órarend infó',     // schedule_info
    'Oktatók',          // instructors
    'Várólista',        // waiting_list (ignored)
  ];
  
  // Add headers to first row
  for (int i = 0; i < headers.length; i++) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = TextCellValue(headers[i]);
  }
  
  // Add sample data rows
  final sampleData = [
    [
      'IK-BSC-001',
      'Programozás alapjai',
      'IK-BSC-001-01',
      'Előadás',
      '2+0',
      'H 10:00-11:30',
      'Dr. Szabó János',
      '0'
    ],
    [
      'IK-BSC-002',
      'Matematika I.',
      'IK-BSC-002-01',
      'Előadás',
      '3+1',
      'K 08:00-09:30, CS 14:00-15:30',
      'Dr. Nagy Anna',
      '5'
    ],
    [
      'IK-BSC-003',
      'Fizika',
      'IK-BSC-003-01',
      'Gyakorlat',
      '0+2',
      'P 16:00-17:30',
      'Dr. Kiss Péter',
      '0'
    ]
  ];
  
  // Add sample data
  for (int row = 0; row < sampleData.length; row++) {
    for (int col = 0; col < sampleData[row].length; col++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1)).value = 
          TextCellValue(sampleData[row][col]);
    }
  }
  
  // Save the Excel file
  final bytes = excel.encode();
  if (bytes != null) {
    File('test_hungarian_schedule.xlsx').writeAsBytesSync(bytes);
    print('✅ Created test_hungarian_schedule.xlsx with proper Hungarian headers');
    print('📊 File contains ${sampleData.length} sample courses');
  } else {
    print('❌ Failed to create Excel file');
  }
}
