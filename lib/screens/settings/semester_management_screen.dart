// File: lib/screens/settings/semester_management_screen.dart
// Purpose: Semester management and overview screen
// Step: 5.3 - Semester Management Interface Implementation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/semester_service.dart';
import '../../services/calendar_service.dart';
import '../../config/theme_config.dart';
import '../../config/localization_config.dart';
import '../../models/semester_model.dart';
import '../../widgets/common_widgets/loading_overlay.dart';

/// Semester management screen with overview and switching functionality
class SemesterManagementScreen extends StatefulWidget {
  const SemesterManagementScreen({super.key});

  @override
  State<SemesterManagementScreen> createState() => _SemesterManagementScreenState();
}

class _SemesterManagementScreenState extends State<SemesterManagementScreen> {
  final _customSemesterController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _customSemesterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: ThemeConfig.lightBackground,
      appBar: AppBar(
        title: const Text('Semester Management'),
        backgroundColor: ThemeConfig.lightBackground,
        foregroundColor: ThemeConfig.primaryDarkBlue,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showAddSemesterDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Add Semester',
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Consumer2<SemesterService, CalendarService>(
          builder: (context, semesterService, calendarService, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current semester overview
                  _buildCurrentSemesterOverview(context, semesterService),
                  
                  const SizedBox(height: 24),
                  
                  // Available semesters
                  _buildAvailableSemesters(context, semesterService, calendarService),
                  
                  const SizedBox(height: 24),
                  
                  // Semester statistics
                  _buildSemesterStatistics(context, semesterService),
                  
                  // Error message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorMessage(),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build current semester overview card
  Widget _buildCurrentSemesterOverview(BuildContext context, SemesterService semesterService) {
    final currentSemester = semesterService.currentSemester;
    if (currentSemester == null) {
      return const SizedBox.shrink();
    }

    final stats = semesterService.getSemesterStats(currentSemester.id);
    final progress = stats['progress'] as double;
    final daysRemaining = stats['daysRemaining'] as int;
    final currentWeek = stats['currentWeek'] as int?;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ThemeConfig.primaryDarkBlue,
              ThemeConfig.primaryDarkBlue.withOpacity(0.8),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Semester',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        currentSemester.displayName.replaceAll(' (current)', ''),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: ThemeConfig.goldAccent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Semester Progress',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(ThemeConfig.goldAccent),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Statistics
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Days Remaining',
                    '$daysRemaining',
                    Icons.calendar_today,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Current Week',
                    currentWeek != null ? 'Week $currentWeek' : 'N/A',
                    Icons.date_range,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build stat item for current semester overview
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build available semesters list
  Widget _buildAvailableSemesters(
    BuildContext context, 
    SemesterService semesterService, 
    CalendarService calendarService
  ) {
    final semesters = semesterService.availableSemesters;
    final selectedSemesterId = calendarService.currentSemester;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Text(
              'Available Semesters',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: ThemeConfig.primaryDarkBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: semesterService.refreshSemesters,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh'),
              style: TextButton.styleFrom(
                foregroundColor: ThemeConfig.primaryDarkBlue,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Semester list
        ...semesters.map((semester) => _buildSemesterCard(
          context, 
          semester, 
          selectedSemesterId == semester.id,
          () => _switchToSemester(context, calendarService, semester.id),
          () => _showSemesterDetails(context, semesterService, semester),
          semesterService.getSemesterStats(semester.id),
        )),
      ],
    );
  }

  /// Build semester card
  Widget _buildSemesterCard(
    BuildContext context,
    Semester semester,
    bool isSelected,
    VoidCallback onSelect,
    VoidCallback onDetails,
    Map<String, dynamic> stats,
  ) {
    final isActive = stats['isActive'] as bool;
    final progress = stats['progress'] as double;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected 
              ? ThemeConfig.goldAccent 
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Semester info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          semester.displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected 
                                ? ThemeConfig.goldAccent
                                : ThemeConfig.darkTextElements,
                          ),
                        ),
                        if (isActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'ACTIVE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      'Progress: ${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeConfig.darkTextElements.withOpacity(0.6),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: ThemeConfig.darkTextElements.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isSelected ? ThemeConfig.goldAccent : ThemeConfig.primaryDarkBlue,
                        ),
                        minHeight: 3,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Actions
              Column(
                children: [
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: ThemeConfig.goldAccent,
                      size: 24,
                    )
                  else
                    Icon(
                      Icons.radio_button_unchecked,
                      color: ThemeConfig.darkTextElements.withOpacity(0.3),
                      size: 24,
                    ),
                  
                  const SizedBox(height: 8),
                  
                  IconButton(
                    onPressed: onDetails,
                    icon: const Icon(Icons.info_outline, size: 20),
                    color: ThemeConfig.primaryDarkBlue,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build semester statistics section
  Widget _buildSemesterStatistics(BuildContext context, SemesterService semesterService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Semester Statistics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: ThemeConfig.primaryDarkBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatRow('Total Semesters', '${semesterService.availableSemesters.length}'),
                const Divider(),
                _buildStatRow('Current Semester', semesterService.currentSemester?.semesterName ?? 'N/A'),
                const Divider(),
                _buildStatRow('Academic Year', semesterService.currentSemester?.academicYearRange ?? 'N/A'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build statistics row
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: ThemeConfig.darkTextElements.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: ThemeConfig.darkTextElements,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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

  /// Switch to a semester
  Future<void> _switchToSemester(BuildContext context, CalendarService calendarService, String semesterId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await calendarService.setCurrentSemester(semesterId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Semester switched successfully!'),
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to switch semester: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Show semester details dialog
  void _showSemesterDetails(BuildContext context, SemesterService semesterService, Semester semester) {
    final stats = semesterService.getSemesterStats(semester.id);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(semester.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Academic Year', semester.academicYearRange),
            _buildDetailRow('Semester', semester.semesterName),
            _buildDetailRow('Start Date', _formatDate(semester.startDate)),
            _buildDetailRow('End Date', _formatDate(semester.endDate)),
            _buildDetailRow('Duration', '${semester.durationInWeeks} weeks'),
            _buildDetailRow('Progress', '${((stats['progress'] as double) * 100).toInt()}%'),
            if (stats['currentWeek'] != null)
              _buildDetailRow('Current Week', 'Week ${stats['currentWeek']}'),
            _buildDetailRow('Days Remaining', '${stats['daysRemaining']} days'),
            _buildDetailRow('Status', stats['isActive'] ? 'Active' : semester.isPast ? 'Past' : 'Future'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Build detail row for dialog
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: ThemeConfig.darkTextElements.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: ThemeConfig.darkTextElements,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show add semester dialog
  void _showAddSemesterDialog() {
    _customSemesterController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Semester'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter semester ID in format YYYY/YY/N\n(e.g., 2023/24/1 for 2023-2024 first semester)',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _customSemesterController,
              decoration: const InputDecoration(
                labelText: 'Semester ID',
                hintText: '2023/24/1',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addCustomSemester,
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.primaryDarkBlue,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  /// Add custom semester
  void _addCustomSemester() {
    final semesterId = _customSemesterController.text.trim();
    
    if (semesterId.isEmpty) {
      return;
    }

    final semesterService = Provider.of<SemesterService>(context, listen: false);
    
    try {
      semesterService.addCustomSemester(semesterId);
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Semester $semesterId added successfully!'),
          backgroundColor: Colors.green.shade600,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}