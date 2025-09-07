// File: lib/screens/export/export_screen.dart
// Purpose: Export configuration and management interface
// Step: 8.3 - Export UI Implementation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../models/export_model.dart';
import '../../services/export_service.dart';
import '../../services/calendar_service.dart';
import '../../services/semester_service.dart';
import '../../widgets/common_widgets/loading_overlay.dart';
import '../../config/theme_config.dart';
import '../../config/localization_config.dart';

/// Export configuration and management screen
class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  ExportOptions _options = ExportTemplates.fullSemester;
  ExportType _selectedType = ExportType.ics;
  String? _selectedTemplate = 'full';

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: _buildAppBar(context, localizations),
      body: Consumer<ExportService>(
        builder: (context, exportService, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildExportTypeSelection(localizations),
                    const SizedBox(height: 32),
                    _buildTemplateSelection(localizations),
                    const SizedBox(height: 32),
                    _buildOptionsConfiguration(localizations),
                    const SizedBox(height: 32),
                    _buildExportPreview(context, localizations),
                    const SizedBox(height: 100), // Space for FAB
                  ],
                ),
              ),
              
              // Loading overlay during export
              LoadingOverlay(
                isLoading: exportService.isExporting,
                loadingText: exportService.currentProgress?.message ?? 'Exporting...',
                child: Container(), // Empty container since we're in a Stack
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildExportButton(context),
    );
  }

  /// Build app bar
  AppBar _buildAppBar(BuildContext context, AppLocalizations? localizations) {
    return AppBar(
      title: Text(localizations?.getString('export') ?? 'Export Schedule'),
      backgroundColor: ThemeConfig.lightBackground,
      foregroundColor: ThemeConfig.primaryDarkBlue,
      elevation: 0,
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, context),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'history',
              child: Row(
                children: [
                  Icon(Icons.history, size: 16),
                  SizedBox(width: 8),
                  Text('Export History'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'help',
              child: Row(
                children: [
                  Icon(Icons.help_outline, size: 16),
                  SizedBox(width: 8),
                  Text('Help'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build export type selection
  Widget _buildExportTypeSelection(AppLocalizations? localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations?.getString('exportType') ?? 'Export Format',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ThemeConfig.darkTextElements,
          ),
        ),
        const SizedBox(height: 16),
        
        ...ExportType.values.map((type) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedType == type 
                  ? ThemeConfig.primaryDarkBlue 
                  : Colors.grey.withOpacity(0.3),
                width: _selectedType == type ? 2 : 1,
              ),
              boxShadow: [
                if (_selectedType == type)
                  BoxShadow(
                    color: ThemeConfig.primaryDarkBlue.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: RadioListTile<ExportType>(
              value: type,
              groupValue: _selectedType,
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
              activeColor: ThemeConfig.primaryDarkBlue,
              title: Row(
                children: [
                  Icon(
                    type.icon,
                    color: _selectedType == type 
                      ? ThemeConfig.primaryDarkBlue 
                      : ThemeConfig.darkTextElements.withOpacity(0.7),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    type.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: _selectedType == type 
                        ? FontWeight.bold 
                        : FontWeight.normal,
                      color: _selectedType == type 
                        ? ThemeConfig.primaryDarkBlue 
                        : ThemeConfig.darkTextElements,
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Text(
                  type.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: ThemeConfig.darkTextElements.withOpacity(0.7),
                  ),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        }).toList(),
      ],
    );
  }

  /// Build template selection
  Widget _buildTemplateSelection(AppLocalizations? localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations?.getString('exportTemplate') ?? 'Quick Templates',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ThemeConfig.darkTextElements,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: ExportTemplates.all.entries.map((entry) {
                  final isSelected = _selectedTemplate == entry.key;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTemplate = entry.key;
                        _options = entry.value;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected 
                          ? ThemeConfig.primaryDarkBlue 
                          : ThemeConfig.lightBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected 
                            ? ThemeConfig.primaryDarkBlue 
                            : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        ExportTemplates.displayNames[entry.key] ?? entry.key,
                        style: TextStyle(
                          color: isSelected ? Colors.white : ThemeConfig.darkTextElements,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: ThemeConfig.darkTextElements.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Choose a template or customize options below',
                    style: TextStyle(
                      fontSize: 13,
                      color: ThemeConfig.darkTextElements.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build options configuration
  Widget _buildOptionsConfiguration(AppLocalizations? localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations?.getString('exportOptions') ?? 'Export Options',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ThemeConfig.darkTextElements,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Semester selection
              _buildSemesterSelection(localizations),
              const SizedBox(height: 24),
              
              // Course type selection
              _buildCourseTypeSelection(localizations),
              const SizedBox(height: 24),
              
              // Content options
              _buildContentOptions(localizations),
              
              // Layout options (for PDF)
              if (_selectedType == ExportType.pdf) ...[
                const SizedBox(height: 24),
                _buildLayoutOptions(localizations),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Build semester selection
  Widget _buildSemesterSelection(AppLocalizations? localizations) {
    return Consumer<SemesterService>(
      builder: (context, semesterService, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations?.getString('selectSemesters') ?? 'Select Semesters',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: ThemeConfig.darkTextElements,
              ),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: semesterService.availableSemesters.map((semester) {
                final isSelected = _options.semesterIds.contains(semester.id);
                return FilterChip(
                  label: Text(semester.shortDisplayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      final semesterIds = List<String>.from(_options.semesterIds);
                      if (selected) {
                        semesterIds.add(semester.id);
                      } else {
                        semesterIds.remove(semester.id);
                      }
                      _options = _options.copyWith(semesterIds: semesterIds);
                      _selectedTemplate = null; // Custom configuration
                    });
                  },
                  selectedColor: ThemeConfig.primaryDarkBlue,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : ThemeConfig.darkTextElements,
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  /// Build course type selection
  Widget _buildCourseTypeSelection(AppLocalizations? localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations?.getString('courseTypes') ?? 'Course Types',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ThemeConfig.darkTextElements,
          ),
        ),
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: CourseType.values.map((type) {
            final isSelected = _options.courseTypes.contains(type);
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    type.icon,
                    size: 16,
                    color: isSelected ? Colors.white : type.color,
                  ),
                  const SizedBox(width: 6),
                  Text(type.displayName),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final courseTypes = List<CourseType>.from(_options.courseTypes);
                  if (selected) {
                    courseTypes.add(type);
                  } else {
                    courseTypes.remove(type);
                  }
                  _options = _options.copyWith(courseTypes: courseTypes);
                  _selectedTemplate = null;
                });
              },
              selectedColor: type.color,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : ThemeConfig.darkTextElements,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build content options
  Widget _buildContentOptions(AppLocalizations? localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations?.getString('includeInformation') ?? 'Include Information',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ThemeConfig.darkTextElements,
          ),
        ),
        const SizedBox(height: 12),
        
        ...[
          ('Instructors', _options.includeInstructors, (value) => 
            _options.copyWith(includeInstructors: value)),
          ('Locations', _options.includeLocation, (value) => 
            _options.copyWith(includeLocation: value)),
          ('Course Descriptions', _options.includeDescription, (value) => 
            _options.copyWith(includeDescription: value)),
          ('Credits', _options.includeCredits, (value) => 
            _options.copyWith(includeCredits: value)),
          if (_selectedType == ExportType.pdf || _selectedType == ExportType.excel)
            ('Weekends', _options.includeWeekends, (value) => 
              _options.copyWith(includeWeekends: value)),
        ].map((option) {
          return CheckboxListTile(
            title: Text(option.$1),
            value: option.$2,
            onChanged: (value) {
              setState(() {
                _options = option.$3(value ?? false);
                _selectedTemplate = null;
              });
            },
            activeColor: ThemeConfig.primaryDarkBlue,
            contentPadding: EdgeInsets.zero,
            dense: true,
          );
        }).toList(),
      ],
    );
  }

  /// Build layout options for PDF
  Widget _buildLayoutOptions(AppLocalizations? localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations?.getString('layoutOptions') ?? 'Layout Options',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ThemeConfig.darkTextElements,
          ),
        ),
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: ExportLayoutType.values.map((layout) {
            final isSelected = _options.layoutType == layout;
            return InkWell(
              onTap: () {
                setState(() {
                  _options = _options.copyWith(layoutType: layout);
                  _selectedTemplate = null;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? ThemeConfig.primaryDarkBlue.withOpacity(0.1)
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected 
                      ? ThemeConfig.primaryDarkBlue 
                      : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      layout.icon,
                      size: 18,
                      color: isSelected 
                        ? ThemeConfig.primaryDarkBlue 
                        : ThemeConfig.darkTextElements,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      layout.displayName,
                      style: TextStyle(
                        color: isSelected 
                          ? ThemeConfig.primaryDarkBlue 
                          : ThemeConfig.darkTextElements,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build export preview
  Widget _buildExportPreview(BuildContext context, AppLocalizations? localizations) {
    return Consumer2<CalendarService, SemesterService>(
      builder: (context, calendarService, semesterService, child) {
        final courseCount = _getEstimatedCourseCount(calendarService);
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ThemeConfig.goldAccent.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ThemeConfig.goldAccent.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.preview,
                    color: ThemeConfig.goldAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    localizations?.getString('exportPreview') ?? 'Export Preview',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ThemeConfig.primaryDarkBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildPreviewStat(
                      'Format',
                      _selectedType.displayName,
                      _selectedType.icon,
                    ),
                  ),
                  Expanded(
                    child: _buildPreviewStat(
                      'Courses',
                      '$courseCount',
                      Icons.school,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildPreviewStat(
                      'Semesters',
                      '${_options.semesterIds.length}',
                      Icons.date_range,
                    ),
                  ),
                  Expanded(
                    child: _buildPreviewStat(
                      'File Type',
                      '.${_selectedType.extension}',
                      Icons.insert_drive_file,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build preview statistic
  Widget _buildPreviewStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: ThemeConfig.primaryDarkBlue.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ThemeConfig.primaryDarkBlue,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: ThemeConfig.darkTextElements.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build export button
  Widget _buildExportButton(BuildContext context) {
    return Consumer<ExportService>(
      builder: (context, exportService, child) {
        return FloatingActionButton.extended(
          onPressed: exportService.isExporting ? null : _performExport,
          backgroundColor: ThemeConfig.primaryDarkBlue,
          foregroundColor: Colors.white,
          icon: exportService.isExporting 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.file_download),
          label: Text(exportService.isExporting 
            ? 'Exporting...' 
            : 'Export Schedule'),
        );
      },
    );
  }

  /// Get estimated course count for preview
  int _getEstimatedCourseCount(CalendarService calendarService) {
    List<Course> courses = calendarService.courses;

    if (_options.semesterIds.isNotEmpty) {
      courses = courses.where((course) => 
        course.semester != null && _options.semesterIds.contains(course.semester)
      ).toList();
    }

    if (_options.courseTypes.isNotEmpty) {
      courses = courses.where((course) => 
        _options.courseTypes.contains(course.type)
      ).toList();
    }

    return courses.length;
  }

  /// Handle menu actions
  void _handleMenuAction(String action, BuildContext context) {
    switch (action) {
      case 'history':
        Navigator.of(context).pushNamed('/export-history');
        break;
      case 'help':
        _showHelpDialog(context);
        break;
    }
  }

  /// Show help dialog
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('📅 ICS Calendar', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Import directly into Google Calendar, Apple Calendar, or Outlook. Creates recurring events for the entire semester.\n'),
              
              Text('📄 PDF Schedule', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Printable schedule with customizable layout. Perfect for posting on bulletin boards or keeping as a reference.\n'),
              
              Text('📊 Excel Spreadsheet', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Editable format for data analysis or sharing with academic advisors.\n'),
              
              Text('💡 Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Use templates for quick exports\n• Select specific semesters to avoid clutter\n• Include locations for room finding\n• PDF weekly view works best for printing'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  /// Perform the actual export
  void _performExport() async {
    final exportService = context.read<ExportService>();
    
    // Validate options
    if (_options.semesterIds.isEmpty && _options.courseTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one semester or course type'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      ExportResult result;
      
      switch (_selectedType) {
        case ExportType.ics:
          result = await exportService.exportToICS(options: _options);
          break;
        case ExportType.pdf:
          result = await exportService.exportToPDF(options: _options);
          break;
        case ExportType.excel:
          result = await exportService.exportToExcel(options: _options);
          break;
      }

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export successful! ${result.itemCount} courses exported.'),
            backgroundColor: Colors.green.shade600,
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () {
                // TODO: Open or share the exported file
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${result.error}'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: ${e.toString()}'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }
}