// File: lib/screens/courses/course_detail_screen.dart
// Purpose: Detailed course information display with schedule and statistics
// Step: 6.2 - Course Detail View Implementation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../config/localization_config.dart';
import '../../models/course_model.dart';
import '../../services/calendar_service.dart';
import '../../services/semester_service.dart';
import '../../widgets/calendar_widgets/course_card_widget.dart';
import 'course_edit_screen.dart';

/// Detailed course information screen with comprehensive course data
class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({
    super.key,
    required this.course,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: _buildAppBar(context, localizations),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCourseHeader(context, localizations),
            _buildCourseInfo(context, localizations),
            _buildScheduleSection(context, localizations),
            _buildStatisticsSection(context, localizations),
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: _buildEditButton(context, localizations),
    );
  }

  /// Build app bar with course name and actions
  AppBar _buildAppBar(BuildContext context, AppLocalizations? localizations) {
    return AppBar(
      title: Text(
        widget.course.name,
        overflow: TextOverflow.ellipsis,
      ),
      backgroundColor: ThemeConfig.lightBackground,
      foregroundColor: ThemeConfig.primaryDarkBlue,
      elevation: 0,
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) => _handleAppBarAction(value, context),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Edit Course'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share, size: 16),
                  SizedBox(width: 8),
                  Text('Share'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build course header with type, code, and basic info
  Widget _buildCourseHeader(BuildContext context, AppLocalizations? localizations) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.course.type.color,
            widget.course.type.color.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              widget.course.type.displayName.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Course name
          Text(
            widget.course.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          
          // Course code
          Text(
            widget.course.code,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontFamily: 'monospace',
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  /// Build course information section
  Widget _buildCourseInfo(BuildContext context, AppLocalizations? localizations) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations?.getString('courseInformation') ?? 'Course Information',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ThemeConfig.darkTextElements,
            ),
          ),
          const SizedBox(height: 16),
          
          // Course information cards
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.school,
                  label: 'Credits',
                  value: widget.course.credits?.toString() ?? 'N/A',
                  color: ThemeConfig.primaryDarkBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.schedule,
                  label: 'Sessions',
                  value: '${widget.course.scheduleSlots.length}',
                  color: ThemeConfig.goldAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Instructors section
          if (widget.course.instructors.isNotEmpty) ...[
            _buildInstructorsSection(localizations),
            const SizedBox(height: 16),
          ],
          
          // Course description (if available)
          if (widget.course.description != null && widget.course.description!.isNotEmpty) ...[
            _buildDescriptionSection(localizations),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  /// Build info card widget
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
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
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: ThemeConfig.darkTextElements.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Build instructors section
  Widget _buildInstructorsSection(AppLocalizations? localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person, size: 20, color: ThemeConfig.primaryDarkBlue),
            const SizedBox(width: 8),
            Text(
              localizations?.getString('instructors') ?? 'Instructors',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ThemeConfig.darkTextElements,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.course.instructors.map((instructor) {
            return Chip(
              label: Text(instructor),
              backgroundColor: ThemeConfig.primaryDarkBlue.withOpacity(0.1),
              labelStyle: const TextStyle(
                color: ThemeConfig.primaryDarkBlue,
                fontWeight: FontWeight.w500,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build course description section
  Widget _buildDescriptionSection(AppLocalizations? localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.description, size: 20, color: ThemeConfig.primaryDarkBlue),
            const SizedBox(width: 8),
            Text(
              localizations?.getString('description') ?? 'Description',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ThemeConfig.darkTextElements,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
            ),
          ),
          child: Text(
            widget.course.description!,
            style: TextStyle(
              fontSize: 14,
              color: ThemeConfig.darkTextElements.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  /// Build schedule section with weekly breakdown
  Widget _buildScheduleSection(BuildContext context, AppLocalizations? localizations) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations?.getString('schedule') ?? 'Schedule',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ThemeConfig.darkTextElements,
            ),
          ),
          const SizedBox(height: 16),
          
          if (widget.course.scheduleSlots.isEmpty)
            _buildEmptySchedule(localizations)
          else
            _buildScheduleList(localizations),
        ],
      ),
    );
  }

  /// Build empty schedule state
  Widget _buildEmptySchedule(AppLocalizations? localizations) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 48,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            localizations?.getString('noSchedule') ?? 'No Schedule',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations?.getString('noScheduleMessage') ?? 
              'This course has no scheduled sessions.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build schedule list with time slots
  Widget _buildScheduleList(AppLocalizations? localizations) {
    // Group schedule slots by day of week
    final scheduleByDay = <int, List<ScheduleSlot>>{};
    for (final slot in widget.course.scheduleSlots) {
      scheduleByDay.putIfAbsent(slot.dayOfWeek, () => []).add(slot);
    }

    // Sort days
    final sortedDays = scheduleByDay.keys.toList()..sort();

    return Column(
      children: sortedDays.map((dayOfWeek) {
        final slots = scheduleByDay[dayOfWeek]!;
        slots.sort((a, b) => a.startTime.compareTo(b.startTime));

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
              // Day header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.course.type.color.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  _getDayName(dayOfWeek),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.course.type.color,
                  ),
                ),
              ),
              
              // Schedule slots for this day
              ...slots.map((slot) => _buildScheduleSlot(slot)).toList(),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Build individual schedule slot
  Widget _buildScheduleSlot(ScheduleSlot slot) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Time indicator
          Container(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.startTime.format(context),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ThemeConfig.darkTextElements,
                  ),
                ),
                Text(
                  slot.endTime.format(context),
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeConfig.darkTextElements.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          
          // Duration bar
          Container(
            width: 4,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: widget.course.type.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Location and details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (slot.location.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: ThemeConfig.goldAccent),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          slot.location,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: ThemeConfig.darkTextElements,
                          ),
                        ),
                      ),
                    ],
                  ),
                
                // Duration
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: ThemeConfig.primaryDarkBlue),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(slot.startTime, slot.endTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeConfig.darkTextElements.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build statistics section
  Widget _buildStatisticsSection(BuildContext context, AppLocalizations? localizations) {
    return Consumer<SemesterService>(
      builder: (context, semesterService, child) {
        final currentSemester = semesterService.currentSemester;
        if (currentSemester == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations?.getString('statistics') ?? 'Statistics',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ThemeConfig.darkTextElements,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildStatisticsCards(currentSemester, localizations),
            ],
          ),
        );
      },
    );
  }

  /// Build statistics cards
  Widget _buildStatisticsCards(Semester semester, AppLocalizations? localizations) {
    final totalHours = _calculateTotalHours();
    final hoursPerWeek = _calculateHoursPerWeek();
    final totalSessions = widget.course.scheduleSlots.length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.access_time,
                title: 'Total Hours',
                value: '${totalHours.toStringAsFixed(1)}h',
                subtitle: 'This semester',
                color: ThemeConfig.primaryDarkBlue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_today,
                title: 'Per Week',
                value: '${hoursPerWeek.toStringAsFixed(1)}h',
                subtitle: 'Average',
                color: ThemeConfig.goldAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.event,
                title: 'Sessions',
                value: '$totalSessions',
                subtitle: 'Weekly',
                color: widget.course.type.color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up,
                title: 'Progress',
                value: '${(semester.progress * 100).toInt()}%',
                subtitle: 'Completed',
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build individual statistics card
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: ThemeConfig.darkTextElements.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: ThemeConfig.darkTextElements.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// Build edit floating action button
  Widget _buildEditButton(BuildContext context, AppLocalizations? localizations) {
    return FloatingActionButton(
      onPressed: () => _navigateToEditCourse(),
      backgroundColor: ThemeConfig.primaryDarkBlue,
      foregroundColor: Colors.white,
      child: const Icon(Icons.edit),
    );
  }

  /// Handle app bar action menu
  void _handleAppBarAction(String action, BuildContext context) {
    switch (action) {
      case 'edit':
        _navigateToEditCourse();
        break;
      case 'share':
        _shareCourse();
        break;
      case 'delete':
        _showDeleteConfirmation(context);
        break;
    }
  }

  /// Navigate to course edit screen
  void _navigateToEditCourse() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CourseEditScreen(course: widget.course),
      ),
    );
  }

  /// Share course information
  void _shareCourse() {
    // TODO: Implement course sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Course sharing coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "${widget.course.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to previous screen
              // TODO: Implement course deletion
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Helper method to get day name from day of week
  String _getDayName(int dayOfWeek) {
    const dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return dayNames[dayOfWeek - 1];
  }

  /// Format duration between two times
  String _formatDuration(TimeOfDay startTime, TimeOfDay endTime) {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    final durationMinutes = endMinutes - startMinutes;
    
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    
    if (hours == 0) {
      return '${minutes}min';
    } else if (minutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${minutes}min';
    }
  }

  /// Calculate total hours for the course in semester
  double _calculateTotalHours() {
    double totalMinutes = 0;
    
    for (final slot in widget.course.scheduleSlots) {
      final startMinutes = slot.startTime.hour * 60 + slot.startTime.minute;
      final endMinutes = slot.endTime.hour * 60 + slot.endTime.minute;
      totalMinutes += endMinutes - startMinutes;
    }
    
    // Assuming 15 weeks per semester
    return (totalMinutes * 15) / 60;
  }

  /// Calculate hours per week
  double _calculateHoursPerWeek() {
    double totalMinutes = 0;
    
    for (final slot in widget.course.scheduleSlots) {
      final startMinutes = slot.startTime.hour * 60 + slot.startTime.minute;
      final endMinutes = slot.endTime.hour * 60 + slot.endTime.minute;
      totalMinutes += endMinutes - startMinutes;
    }
    
    return totalMinutes / 60;
  }
}