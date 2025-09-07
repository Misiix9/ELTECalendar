// File: lib/screens/import/excel_import_screen.dart
// Purpose: Excel file import screen with validation and semester selection
// Step: 3.2 - Excel Import Screen Implementation

import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:excel/excel.dart' as ExcelLib;
import '../../services/excel_parser_service.dart';
import '../../services/excel_template_service.dart';
import '../../services/firebase_service.dart';
import '../../services/auth_service.dart';
import '../../services/semester_service.dart';
import '../../config/theme_config.dart';
// import '../../config/localization_config.dart'; // TODO: Uncomment when using localization
import '../../models/course_model.dart';
import '../../widgets/common_widgets/loading_overlay.dart';
import '../../widgets/common_widgets/auth_button.dart';

/// Excel file import screen for Hungarian university schedules
class ExcelImportScreen extends StatefulWidget {
  const ExcelImportScreen({super.key});

  @override
  State<ExcelImportScreen> createState() => _ExcelImportScreenState();
}

class _ExcelImportScreenState extends State<ExcelImportScreen> {
  bool _isLoading = false;
  String? _selectedFileName;
  Uint8List? _selectedFileBytes;
  String? _selectedSemester;
  String? _errorMessage;
  String? _successMessage;
  List<Course>? _parsedCourses;

  @override
  Widget build(BuildContext context) {
    // final localizations = AppLocalizations.of(context); // TODO: Use for localization
    
    return Scaffold(
      backgroundColor: ThemeConfig.lightBackground,
      appBar: AppBar(
        title: Text(
          'Import Schedule',
          style: const TextStyle(
            color: ThemeConfig.primaryDarkBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: ThemeConfig.primaryDarkBlue,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header section
                _buildHeader(),
                
                const SizedBox(height: 24),
                
                // Template download section
                _buildTemplateSection(),
                
                const SizedBox(height: 32),
                
                // File selection section
                _buildFileSelection(),
                
                const SizedBox(height: 24),
                
                // Semester selection
                _buildSemesterSelection(),
                
                const SizedBox(height: 24),
                
                // Messages
                if (_errorMessage != null) ...[
                  _buildErrorMessage(),
                  const SizedBox(height: 16),
                ],
                
                if (_successMessage != null) ...[
                  _buildSuccessMessage(),
                  const SizedBox(height: 16),
                ],
                
                // Course preview
                if (_parsedCourses != null) ...[
                  _buildCoursePreview(),
                  const SizedBox(height: 24),
                ],
                
                // Action buttons
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build template download section
  Widget _buildTemplateSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeConfig.primaryDarkBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeConfig.primaryDarkBlue.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.download,
                color: ThemeConfig.primaryDarkBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Need a template?',
                style: const TextStyle(
                  color: ThemeConfig.primaryDarkBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Download our Excel template with the correct format and sample data to get started.',
            style: TextStyle(
              color: ThemeConfig.darkTextElements.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          AuthOutlineButton(
            text: 'Download Template',
            onPressed: _isLoading ? null : _downloadTemplate,
            borderColor: ThemeConfig.primaryDarkBlue,
            textColor: ThemeConfig.primaryDarkBlue,
            icon: Icons.file_download,
          ),
        ],
      ),
    );
  }

  /// Build header section
  Widget _buildHeader() {
    return Column(
      children: [
        // Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: ThemeConfig.goldAccent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.file_upload_outlined,
            color: ThemeConfig.primaryDarkBlue,
            size: 40,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Title
        Text(
          'Import Excel Schedule',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: ThemeConfig.primaryDarkBlue,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        // Description
        Text(
          'Select your Excel file (.xlsx or .xls) containing your university schedule. The file should include Hungarian column headers.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: ThemeConfig.darkTextElements.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build file selection area
  Widget _buildFileSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Excel Schedule File',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: ThemeConfig.primaryDarkBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Enhanced file selection area with drag-and-drop visual hints
        InkWell(
          onTap: _isLoading ? null : _selectFile,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(
                color: _selectedFileName != null 
                    ? ThemeConfig.goldAccent
                    : ThemeConfig.darkTextElements.withOpacity(0.3),
                width: _selectedFileName != null ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
              color: _selectedFileName != null 
                  ? ThemeConfig.goldAccent.withOpacity(0.05)
                  : Colors.transparent,
            ),
            child: Column(
              children: [
                // File icon with animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _selectedFileName != null 
                        ? ThemeConfig.goldAccent.withOpacity(0.2)
                        : ThemeConfig.primaryDarkBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    _selectedFileName != null 
                        ? Icons.check_circle_outline
                        : Icons.upload_file,
                    size: 48,
                    color: _selectedFileName != null 
                        ? ThemeConfig.goldAccent
                        : ThemeConfig.primaryDarkBlue,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                if (_selectedFileName != null) ...[
                  Text(
                    _selectedFileName!,
                    style: const TextStyle(
                      color: ThemeConfig.primaryDarkBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'File ready for import',
                    style: TextStyle(
                      color: ThemeConfig.goldAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ] else ...[
                  Text(
                    'Select your Excel schedule file',
                    style: const TextStyle(
                      color: ThemeConfig.primaryDarkBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Click to browse files or drag and drop',
                    style: TextStyle(
                      color: ThemeConfig.darkTextElements.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Supported: .xlsx, .xls, .xlsm (Max 10MB)',
                    style: TextStyle(
                      color: ThemeConfig.darkTextElements.withOpacity(0.5),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Action buttons
        Row(
          children: [
            Expanded(
              child: AuthButton(
                text: _selectedFileName != null ? 'Change File' : 'Browse Files',
                onPressed: _isLoading ? null : _selectFile,
                backgroundColor: ThemeConfig.primaryDarkBlue,
                textColor: ThemeConfig.lightBackground,
                icon: Icons.folder_open,
              ),
            ),
            if (_selectedFileName != null) ...[
              const SizedBox(width: 12),
              Expanded(
                child: AuthOutlineButton(
                  text: 'Clear',
                  onPressed: _isLoading ? null : _clearSelectedFile,
                  borderColor: ThemeConfig.darkTextElements.withOpacity(0.3),
                  textColor: ThemeConfig.darkTextElements,
                  icon: Icons.clear,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// Build semester selection
  Widget _buildSemesterSelection() {
    return Consumer<SemesterService>(
      builder: (context, semesterService, child) {
        final semesters = semesterService.availableSemesters;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Semester',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: ThemeConfig.primaryDarkBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: ThemeConfig.darkTextElements.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(12),
                color: ThemeConfig.lightBackground,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSemester,
                  hint: Text(
                    'Choose semester for import',
                    style: TextStyle(
                      color: ThemeConfig.darkTextElements.withOpacity(0.6),
                    ),
                  ),
                  isExpanded: true,
                  items: semesters.map((semester) {
                    return DropdownMenuItem<String>(
                      value: semester.id,
                      child: Text(
                        semester.displayName,
                        style: const TextStyle(
                          color: ThemeConfig.darkTextElements,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: _isLoading ? null : (value) {
                    setState(() {
                      _selectedSemester = value;
                    });
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Note: Importing will overwrite existing courses for the selected semester.',
              style: TextStyle(
                color: Colors.orange.shade600,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build error message widget
  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// Build success message widget
  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _successMessage!,
              style: TextStyle(color: Colors.green.shade700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// Build course preview section
  Widget _buildCoursePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview (${_parsedCourses!.length} courses found)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: ThemeConfig.primaryDarkBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _parsedCourses!.length,
            itemBuilder: (context, index) {
              final course = _parsedCourses![index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: course.displayColor.withOpacity(0.2),
                    child: Icon(
                      _getCourseTypeIcon(course.classType),
                      color: course.displayColor,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    course.courseName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${course.courseCode} - ${course.classCode}'),
                      if (course.scheduleSlots.isNotEmpty)
                        Text(
                          course.scheduleSlots.map((slot) => 
                            '${slot.dayNameHu} ${slot.timeRange}'
                          ).join(', '),
                          style: TextStyle(
                            color: ThemeConfig.darkTextElements.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  dense: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build action buttons
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Import button
        AuthButton(
          text: _parsedCourses != null ? 'Import Courses' : 'Parse File',
          onPressed: _canProceed() && !_isLoading ? _handleImport : null,
          isLoading: _isLoading,
          backgroundColor: ThemeConfig.primaryDarkBlue,
          textColor: ThemeConfig.lightBackground,
          icon: _parsedCourses != null ? Icons.save : Icons.analytics,
        ),
        
        const SizedBox(height: 12),
        
        // Cancel button
        AuthOutlineButton(
          text: 'Cancel',
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          borderColor: ThemeConfig.darkTextElements.withOpacity(0.3),
          textColor: ThemeConfig.darkTextElements,
        ),
      ],
    );
  }

  /// Check if user can proceed with import
  bool _canProceed() {
    return _selectedFileName != null && 
           _selectedFileBytes != null && 
           _selectedSemester != null;
  }

  /// Handle file selection
  Future<void> _selectFile() async {
    try {
      setState(() {
        _errorMessage = null;
        _successMessage = null;
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'xlsm'], // Added xlsm support
        allowMultiple: false,
        dialogTitle: 'Select Excel Schedule File',
        withData: true, // Ensure we get the file bytes
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // Validate file size (max 10MB)
        if (file.size > 10 * 1024 * 1024) {
          setState(() {
            _errorMessage = 'File size too large. Maximum allowed size is 10MB.';
          });
          return;
        }
        
        // Validate file extension
        final extension = file.extension?.toLowerCase();
        if (extension == null || !['xlsx', 'xls', 'xlsm'].contains(extension)) {
          setState(() {
            _errorMessage = 'Invalid file type. Please select an Excel file (.xlsx, .xls, or .xlsm).';
          });
          return;
        }
        
        if (file.bytes != null) {
          setState(() {
            _selectedFileName = file.name;
            _selectedFileBytes = file.bytes!;
            _errorMessage = null;
            _successMessage = 'File selected successfully! File size: ${_formatFileSize(file.size)}';
            _parsedCourses = null;
          });
          
          // Auto-analyze the file structure (but don't fail if this doesn't work)
          _analyzeFileStructure();
        } else {
          setState(() {
            _errorMessage = 'Could not read file content. Please try selecting the file again.';
          });
        }
      }
    } catch (e) {
      debugPrint('Error selecting file: $e');
      setState(() {
        _errorMessage = 'Error selecting file: ${e.toString()}';
      });
    }
  }

  /// Clear selected file
  void _clearSelectedFile() {
    setState(() {
      _selectedFileName = null;
      _selectedFileBytes = null;
      _errorMessage = null;
      _successMessage = null;
      _parsedCourses = null;
    });
  }

  /// Download Excel template
  void _downloadTemplate() {
    try {
      final templateBytes = ExcelTemplateService.generateTemplate();
      
      // Create download for web
      final blob = html.Blob([templateBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = 'ELTE_Schedule_Template.xlsx';
      
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Template downloaded successfully!'),
          backgroundColor: Colors.green.shade600,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error downloading template: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error downloading template. Please try again.'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  /// Format file size for display
  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Analyze file structure to provide helpful feedback
  Future<void> _analyzeFileStructure() async {
    if (_selectedFileBytes == null) return;
    
    try {
      debugPrint('Analyzing file structure...');
      debugPrint('File size: ${_selectedFileBytes!.length} bytes');
      
      // Quick analysis without full parsing
      final excel = ExcelLib.Excel.decodeBytes(_selectedFileBytes!);
      final sheetNames = excel.tables.keys.toList();
      
      debugPrint('Found ${sheetNames.length} sheets: $sheetNames');
      
      if (sheetNames.isEmpty) {
        setState(() {
          _successMessage = '''File selected successfully!
File size: ${_formatFileSize(_selectedFileBytes!.length)}

Note: Could not analyze sheet structure, but file upload was successful.
You can proceed with the import to validate the content.''';
        });
        return;
      }
      
      final firstSheet = excel.tables[sheetNames.first];
      
      if (firstSheet == null) {
        setState(() {
          _successMessage = '''File selected successfully!
File size: ${_formatFileSize(_selectedFileBytes!.length)}

Note: Could not access worksheet data, but file upload was successful.
You can proceed with the import to validate the content.''';
        });
        return;
      }
      
      debugPrint('First sheet: ${sheetNames.first}, Rows: ${firstSheet.maxRows}, Columns: ${firstSheet.maxColumns}');
      
      // Try to read the first few cells to validate the structure
      String headerInfo = '';
      if (firstSheet.maxRows > 0) {
        final headerRow = firstSheet.row(0);
        final headerValues = headerRow.take(5).map((cell) => 
          cell?.value?.toString() ?? 'Empty'
        ).join(', ');
        headerInfo = '\n• Sample headers: $headerValues';
        debugPrint('Header row: $headerValues');
      }
      
      setState(() {
        _successMessage = '''File analyzed successfully!
• File size: ${_formatFileSize(_selectedFileBytes!.length)}
• Sheets found: ${sheetNames.length}
• Primary sheet: "${sheetNames.first}"
• Rows: ${firstSheet.maxRows}
• Columns: ${firstSheet.maxColumns}$headerInfo

Ready for import.''';
      });
      
    } catch (e, stackTrace) {
      debugPrint('Error analyzing file structure: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Don't show error - just show success with note
      setState(() {
        _successMessage = '''File uploaded successfully!
File size: ${_formatFileSize(_selectedFileBytes!.length)}

Note: Could not preview file structure, but upload was successful.
You can proceed with the import - detailed validation will happen during processing.

If import fails, please ensure:
• File is a valid Excel format (.xlsx, .xls, .xlsm)
• File is not password-protected
• File contains the required column headers''';
      });
    }
  }

  /// Handle import process (parse and save)
  Future<void> _handleImport() async {
    if (!_canProceed()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      if (_parsedCourses == null) {
        // First step: Parse the Excel file
        await _parseFile();
      } else {
        // Second step: Import the parsed courses
        await _importCourses();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Import failed: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Parse the selected Excel file
  Future<void> _parseFile() async {
    final result = await ExcelParserService.parseExcelFile(
      fileBytes: _selectedFileBytes!,
      fileName: _selectedFileName!,
    );

    if (result.success) {
      setState(() {
        _parsedCourses = result.courses;
        _successMessage = result.message;
      });
    } else {
      setState(() {
        _errorMessage = result.message;
      });
    }
  }

  /// Import the parsed courses to Firebase
  Future<void> _importCourses() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firebaseService = Provider.of<FirebaseService>(context, listen: false);
    
    final user = authService.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'User not authenticated. Please sign in again.';
      });
      return;
    }

    debugPrint('📊 Import: Starting import process');
    debugPrint('📊 Import: User ID: ${user.uid}');
    debugPrint('📊 Import: Selected semester: $_selectedSemester');
    debugPrint('📊 Import: Number of courses: ${_parsedCourses?.length ?? 0}');
    
    if (_parsedCourses != null) {
      for (int i = 0; i < _parsedCourses!.length; i++) {
        final course = _parsedCourses![i];
        debugPrint('📊 Import: Course $i - ${course.courseCode}: ${course.courseName}');
        debugPrint('📊 Import: Course $i - Schedule slots: ${course.scheduleSlots.length}');
      }
    }

    try {
      // Import courses to the selected semester
      await firebaseService.importCoursesToSemester(
        user.uid,
        _selectedSemester!,
        _parsedCourses!,
      );

      debugPrint('📊 Import: Successfully completed Firebase import');

      // Set the imported semester as current semester
      final semesterService = Provider.of<SemesterService>(context, listen: false);
      debugPrint('📊 Import: Setting current semester to $_selectedSemester');
      semesterService.setSelectedSemester(_selectedSemester!);

      setState(() {
        _successMessage = 'Successfully imported ${_parsedCourses!.length} courses to the selected semester!';
        _parsedCourses = null;
        _selectedFileName = null;
        _selectedFileBytes = null;
        _selectedSemester = null;
      });

      // Navigate back after successful import
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          debugPrint('📊 Import: Navigating back with success result');
          Navigator.of(context).pop(true); // Return true to indicate successful import
        }
      });

    } catch (e) {
      debugPrint('❌ Import: Failed with error: $e');
      setState(() {
        _errorMessage = 'Failed to save courses: ${e.toString()}';
      });
    }
  }

  /// Get icon for course type
  IconData _getCourseTypeIcon(String classType) {
    final lowerType = classType.toLowerCase().trim();
    
    if (lowerType.contains('előadás') || lowerType.contains('ea')) {
      return Icons.school;
    } else if (lowerType.contains('gyakorlat') || lowerType.contains('gy')) {
      return Icons.computer;
    } else if (lowerType.contains('labor') || lowerType.contains('lb')) {
      return Icons.science;
    } else {
      return Icons.book;
    }
  }
}