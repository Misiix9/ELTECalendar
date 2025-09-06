// File: lib/screens/import/excel_import_screen.dart
// Purpose: Excel file import screen with validation and semester selection
// Step: 3.2 - Excel Import Screen Implementation

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../services/excel_parser_service.dart';
import '../../services/firebase_service.dart';
import '../../services/auth_service.dart';
import '../../services/semester_service.dart';
import '../../config/theme_config.dart';
import '../../config/localization_config.dart';
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
    final localizations = AppLocalizations.of(context);
    
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

  /// Build file selection section
  Widget _buildFileSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Excel File',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: ThemeConfig.primaryDarkBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedFileName != null 
                  ? ThemeConfig.goldAccent 
                  : ThemeConfig.darkTextElements.withOpacity(0.3),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
            color: _selectedFileName != null 
                ? ThemeConfig.goldAccent.withOpacity(0.05)
                : Colors.transparent,
          ),
          child: Column(
            children: [
              Icon(
                _selectedFileName != null ? Icons.file_present : Icons.file_upload_outlined,
                size: 48,
                color: _selectedFileName != null 
                    ? ThemeConfig.goldAccent 
                    : ThemeConfig.darkTextElements.withOpacity(0.5),
              ),
              
              const SizedBox(height: 12),
              
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
                  'File selected successfully',
                  style: TextStyle(
                    color: ThemeConfig.darkTextElements.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ] else ...[
                Text(
                  'Tap to select Excel file',
                  style: TextStyle(
                    color: ThemeConfig.darkTextElements.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Supported formats: .xlsx, .xls',
                  style: TextStyle(
                    color: ThemeConfig.darkTextElements.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // File selection button
        AuthButton(
          text: _selectedFileName != null ? 'Change File' : 'Select File',
          onPressed: _isLoading ? null : _selectFile,
          backgroundColor: _selectedFileName != null 
              ? Colors.transparent
              : ThemeConfig.primaryDarkBlue,
          textColor: _selectedFileName != null 
              ? ThemeConfig.primaryDarkBlue
              : ThemeConfig.lightBackground,
          hasBorder: _selectedFileName != null,
          icon: Icons.folder_open,
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
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        if (file.bytes != null) {
          setState(() {
            _selectedFileName = file.name;
            _selectedFileBytes = file.bytes!;
            _errorMessage = null;
            _successMessage = null;
            _parsedCourses = null;
          });
        } else {
          setState(() {
            _errorMessage = 'Could not read file. Please try again.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error selecting file: ${e.toString()}';
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

    try {
      // Import courses to the selected semester
      await firebaseService.importCoursesToSemester(
        userId: user.uid,
        semesterId: _selectedSemester!,
        courses: _parsedCourses!,
      );

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
          Navigator.of(context).pop(true); // Return true to indicate successful import
        }
      });

    } catch (e) {
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