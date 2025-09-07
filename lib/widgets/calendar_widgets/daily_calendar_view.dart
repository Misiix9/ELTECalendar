// File: lib/widgets/calendar_widgets/daily_calendar_view.dart
// Purpose: Daily calendar view widget following specification
// Step: 4.2 - Daily Calendar View Implementation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/calendar_service.dart';
import '../../config/theme_config.dart';
import '../../models/course_model.dart';

/// Daily calendar view showing courses for a single day
class DailyCalendarView extends StatelessWidget {
  const DailyCalendarView({super.key});

    @override
  Widget build(BuildContext context) {
    return Consumer<CalendarService>(
      builder: (context, calendarService, child) {
        debugPrint('📅 DailyCalendarView: Building view, currentSemester: ${calendarService.currentSemester}');
        debugPrint('📅 DailyCalendarView: Total courses loaded: ${calendarService.courses.length}');
        debugPrint('📅 DailyCalendarView: IsLoading: ${calendarService.isLoading}');
        debugPrint('📅 DailyCalendarView: ErrorMessage: ${calendarService.errorMessage}');
        
        if (calendarService.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: ThemeConfig.goldAccent,
            ),
          );
        }

        if (calendarService.errorMessage != null) {
          return _buildErrorView(context, calendarService.errorMessage!);
        }

        final selectedDate = calendarService.selectedDate;
        debugPrint('📅 DailyCalendarView: Selected date: ${selectedDate.toIso8601String()}');
        
        final scheduleSlots = calendarService.getScheduleSlotsForDate(selectedDate);
        debugPrint('📅 DailyCalendarView: Schedule slots found: ${scheduleSlots.length}');

        if (scheduleSlots.isEmpty) {
          return _buildEmptyView(context, selectedDate);
        }

        return _buildDailySchedule(context, calendarService, scheduleSlots);
      },
    );
  }

  /// Build the daily schedule with time slots
  Widget _buildDailySchedule(BuildContext context, CalendarService calendarService, List<ScheduleSlot> slots) {
    return Column(
      children: [
        // Date header
        _buildDateHeader(context, calendarService),
        
        // Schedule timeline
        Expanded(
          child: _buildScheduleTimeline(context, calendarService, slots),
        ),
      ],
    );
  }

  /// Build date header with navigation
  Widget _buildDateHeader(BuildContext context, CalendarService calendarService) {
    final selectedDate = calendarService.selectedDate;
    final isToday = calendarService.isToday(selectedDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // Previous day button
          IconButton(
            onPressed: calendarService.goToPrevious,
            icon: const Icon(Icons.chevron_left),
            color: ThemeConfig.primaryDarkBlue,
          ),
          
          // Date display
          Expanded(
            child: Column(
              children: [
                Text(
                  _getDayName(selectedDate),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: isToday ? ThemeConfig.goldAccent : ThemeConfig.primaryDarkBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getFormattedDate(selectedDate),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ThemeConfig.darkTextElements.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          
          // Next day button
          IconButton(
            onPressed: calendarService.goToNext,
            icon: const Icon(Icons.chevron_right),
            color: ThemeConfig.primaryDarkBlue,
          ),
        ],
      ),
    );
  }

  /// Build schedule timeline with time markers
  Widget _buildScheduleTimeline(BuildContext context, CalendarService calendarService, List<ScheduleSlot> slots) {
    const startHour = 8; // 8:00 AM
    const endHour = 22;  // 10:00 PM
    const hourHeight = 80.0;

    return SingleChildScrollView(
      child: Container(
        height: (endHour - startHour) * hourHeight,
        child: Stack(
          children: [
            // Hour markers and grid lines
            _buildTimeGrid(context, startHour, endHour, hourHeight),
            
            // Current time indicator
            if (calendarService.isToday(calendarService.selectedDate))
              _buildCurrentTimeIndicator(context, calendarService.getCurrentTime(), startHour, hourHeight),
            
            // Course slots
            ..._buildCourseSlots(context, calendarService, slots, startHour, hourHeight),
          ],
        ),
      ),
    );
  }

  /// Build time grid with hour markers
  Widget _buildTimeGrid(BuildContext context, int startHour, int endHour, double hourHeight) {
    final children = <Widget>[];

    for (int hour = startHour; hour <= endHour; hour++) {
      children.add(
        Positioned(
          top: (hour - startHour) * hourHeight,
          left: 0,
          right: 0,
          child: Container(
            height: hourHeight,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: ThemeConfig.darkTextElements.withOpacity(0.1),
                  width: hour == startHour ? 1 : 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                // Time label
                Container(
                  width: 60,
                  padding: const EdgeInsets.only(top: 4, left: 8),
                  child: Text(
                    _formatHour(hour),
                    style: TextStyle(
                      color: ThemeConfig.darkTextElements.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                // Hour line
                Expanded(
                  child: Container(
                    height: 1,
                    color: ThemeConfig.darkTextElements.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Stack(children: children);
  }

  /// Build current time indicator (horizontal line)
  Widget _buildCurrentTimeIndicator(BuildContext context, TimeOfDay currentTime, int startHour, double hourHeight) {
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final startMinutes = startHour * 60;
    final position = ((currentMinutes - startMinutes) / 60) * hourHeight;

    if (position < 0 || position > (22 - startHour) * hourHeight) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: position,
      left: 60,
      right: 0,
      child: Container(
        height: 2,
        decoration: BoxDecoration(
          color: Colors.red,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(left: -4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }

  /// Build course slot widgets
  List<Widget> _buildCourseSlots(BuildContext context, CalendarService calendarService, List<ScheduleSlot> slots, int startHour, double hourHeight) {
    final courseSlots = <Widget>[];

    for (final slot in slots) {
      final course = calendarService.getCourseById(slot.courseId);
      if (course == null) continue;

      final startMinutes = slot.startTime.hour * 60 + slot.startTime.minute;
      final endMinutes = slot.endTime.hour * 60 + slot.endTime.minute;
      final duration = endMinutes - startMinutes;
      
      final topPosition = ((startMinutes - (startHour * 60)) / 60) * hourHeight;
      final height = (duration / 60) * hourHeight - 4; // 4px margin between slots

      // Skip slots outside visible hours
      if (topPosition < 0 || topPosition > (22 - startHour) * hourHeight) {
        continue;
      }

      final isCurrentClass = calendarService.isCurrentTimeInSlot(slot);

      courseSlots.add(
        Positioned(
          top: topPosition,
          left: 70, // After time labels
          right: 16,
          child: GestureDetector(
            onTap: () => _showCourseDetails(context, course, slot),
            child: Container(
              height: height,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: course.displayColor.withOpacity(isCurrentClass ? 0.9 : 0.8),
                borderRadius: BorderRadius.circular(8),
                border: isCurrentClass
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
                boxShadow: isCurrentClass
                    ? [
                        BoxShadow(
                          color: course.displayColor.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course name
                  Text(
                    course.courseName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  if (height > 40) ...[
                    const SizedBox(height: 4),
                    
                    // Time and location
                    Text(
                      '${slot.timeRange}${slot.location.isNotEmpty ? ' • ${slot.location}' : ''}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  if (height > 60) ...[
                    const SizedBox(height: 2),
                    
                    // Course type
                    Text(
                      course.classType,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    return courseSlots;
  }

  /// Build empty view when no courses
  Widget _buildEmptyView(BuildContext context, DateTime date) {
    final isToday = DateTime.now().day == date.day &&
                   DateTime.now().month == date.month &&
                   DateTime.now().year == date.year;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: ThemeConfig.primaryDarkBlue.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            isToday ? 'No classes today' : 'No classes on this day',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: ThemeConfig.darkTextElements.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enjoy your free time!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: ThemeConfig.darkTextElements.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// Build error view
  Widget _buildErrorView(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load schedule',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ThemeConfig.darkTextElements.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Show course details in a bottom sheet
  void _showCourseDetails(BuildContext context, Course course, ScheduleSlot slot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CourseDetailsSheet(course: course, slot: slot),
    );
  }

  /// Get day name in English
  String _getDayName(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  /// Get formatted date string
  String _getFormattedDate(DateTime date) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
                   'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Format hour for display
  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : hour == 0 ? 12 : hour;
    return '$displayHour:00 $period';
  }
}

/// Course details bottom sheet
class CourseDetailsSheet extends StatelessWidget {
  final Course course;
  final ScheduleSlot slot;

  const CourseDetailsSheet({
    super.key,
    required this.course,
    required this.slot,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: course.displayColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.courseName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${course.courseCode} • ${course.classType}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          
          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(Icons.access_time, 'Time', slot.timeRange),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.location_on, 'Location', slot.location.isNotEmpty ? slot.location : 'Not specified'),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.person, 'Instructors', course.formattedInstructors),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.schedule, 'Weekly Hours', '${course.weeklyHours} hours'),
                if (course.notes?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.note, 'Notes', course.notes!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: ThemeConfig.primaryDarkBlue.withOpacity(0.7),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: ThemeConfig.darkTextElements.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
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
        ),
      ],
    );
  }
}