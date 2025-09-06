// File: lib/widgets/calendar_widgets/weekly_calendar_view.dart
// Purpose: Weekly calendar view widget following specification
// Step: 4.3 - Weekly Calendar View Implementation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/calendar_service.dart';
import '../../config/theme_config.dart';
import '../../models/course_model.dart';
import 'daily_calendar_view.dart';

/// Weekly calendar view showing courses for 7 days
class WeeklyCalendarView extends StatelessWidget {
  const WeeklyCalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarService>(
      builder: (context, calendarService, child) {
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
        final weekStart = calendarService.getWeekStart(selectedDate);
        final weekCourses = calendarService.getCoursesForWeek(weekStart);

        return _buildWeeklySchedule(context, calendarService, weekStart, weekCourses);
      },
    );
  }

  /// Build the weekly schedule view
  Widget _buildWeeklySchedule(
    BuildContext context,
    CalendarService calendarService,
    DateTime weekStart,
    Map<DateTime, List<Course>> weekCourses,
  ) {
    return Column(
      children: [
        // Week header with navigation
        _buildWeekHeader(context, calendarService, weekStart),
        
        // Days of week header
        _buildDaysHeader(context, calendarService, weekStart),
        
        // Weekly grid
        Expanded(
          child: _buildWeekGrid(context, calendarService, weekStart),
        ),
      ],
    );
  }

  /// Build week navigation header
  Widget _buildWeekHeader(BuildContext context, CalendarService calendarService, DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final isCurrentWeek = calendarService.isCurrentWeek(weekStart);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeConfig.lightBackground,
        border: Border(
          bottom: BorderSide(
            color: ThemeConfig.darkTextElements.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // Previous week button
          IconButton(
            onPressed: calendarService.goToPrevious,
            icon: const Icon(Icons.chevron_left),
            color: ThemeConfig.primaryDarkBlue,
          ),
          
          // Week range display
          Expanded(
            child: Column(
              children: [
                Text(
                  _getWeekRangeText(weekStart, weekEnd),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isCurrentWeek ? ThemeConfig.goldAccent : ThemeConfig.primaryDarkBlue,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isCurrentWeek) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Current Week',
                    style: TextStyle(
                      color: ThemeConfig.goldAccent.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Next week button
          IconButton(
            onPressed: calendarService.goToNext,
            icon: const Icon(Icons.chevron_right),
            color: ThemeConfig.primaryDarkBlue,
          ),
        ],
      ),
    );
  }

  /// Build days of week header
  Widget _buildDaysHeader(BuildContext context, CalendarService calendarService, DateTime weekStart) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: ThemeConfig.lightBackground,
        border: Border(
          bottom: BorderSide(
            color: ThemeConfig.darkTextElements.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // Time column header
          Container(
            width: 60,
            alignment: Alignment.center,
            child: Text(
              'Time',
              style: TextStyle(
                color: ThemeConfig.darkTextElements.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // Day headers
          ...List.generate(7, (index) {
            final date = weekStart.add(Duration(days: index));
            final isToday = calendarService.isToday(date);
            final hasClasses = calendarService.getCoursesForDate(date).isNotEmpty;
            
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  calendarService.setSelectedDate(date);
                  calendarService.setViewType(CalendarViewType.daily);
                },
                child: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: isToday ? ThemeConfig.goldAccent.withOpacity(0.1) : null,
                    border: Border.all(
                      color: isToday 
                          ? ThemeConfig.goldAccent 
                          : ThemeConfig.darkTextElements.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayNames[index],
                        style: TextStyle(
                          color: isToday 
                              ? ThemeConfig.goldAccent 
                              : ThemeConfig.darkTextElements.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isToday ? ThemeConfig.goldAccent : null,
                          shape: BoxShape.circle,
                          border: hasClasses && !isToday 
                              ? Border.all(color: ThemeConfig.primaryDarkBlue, width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              color: isToday 
                                  ? Colors.white 
                                  : hasClasses 
                                      ? ThemeConfig.primaryDarkBlue 
                                      : ThemeConfig.darkTextElements,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Build week grid with time slots and courses
  Widget _buildWeekGrid(BuildContext context, CalendarService calendarService, DateTime weekStart) {
    const startHour = 8;  // 8:00 AM
    const endHour = 22;   // 10:00 PM
    const hourHeight = 60.0;
    const hours = endHour - startHour;

    return SingleChildScrollView(
      child: Container(
        height: hours * hourHeight,
        child: Row(
          children: [
            // Time column
            _buildTimeColumn(context, startHour, endHour, hourHeight),
            
            // Day columns
            ...List.generate(7, (dayIndex) {
              final date = weekStart.add(Duration(days: dayIndex));
              return _buildDayColumn(context, calendarService, date, startHour, hourHeight);
            }),
          ],
        ),
      ),
    );
  }

  /// Build time column with hour markers
  Widget _buildTimeColumn(BuildContext context, int startHour, int endHour, double hourHeight) {
    return Container(
      width: 60,
      child: Column(
        children: List.generate(endHour - startHour, (index) {
          final hour = startHour + index;
          return Container(
            height: hourHeight,
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: ThemeConfig.darkTextElements.withOpacity(0.1),
                ),
              ),
            ),
            child: Text(
              _formatHour(hour),
              style: TextStyle(
                color: ThemeConfig.darkTextElements.withOpacity(0.6),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Build day column with courses
  Widget _buildDayColumn(BuildContext context, CalendarService calendarService, DateTime date, int startHour, double hourHeight) {
    final isToday = calendarService.isToday(date);
    final scheduleSlots = calendarService.getScheduleSlotsForDate(date);

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isToday ? ThemeConfig.goldAccent.withOpacity(0.05) : null,
          border: Border(
            left: BorderSide(
              color: ThemeConfig.darkTextElements.withOpacity(0.1),
            ),
            top: BorderSide(
              color: ThemeConfig.darkTextElements.withOpacity(0.1),
            ),
          ),
        ),
        child: Stack(
          children: [
            // Hour grid lines
            ...List.generate(22 - startHour, (index) {
              return Positioned(
                top: index * hourHeight,
                left: 0,
                right: 0,
                child: Container(
                  height: 1,
                  color: ThemeConfig.darkTextElements.withOpacity(0.05),
                ),
              );
            }),
            
            // Current time indicator
            if (isToday)
              _buildCurrentTimeIndicator(context, calendarService.getCurrentTime(), startHour, hourHeight),
            
            // Course slots
            ..._buildCourseSlots(context, calendarService, scheduleSlots, startHour, hourHeight),
          ],
        ),
      ),
    );
  }

  /// Build current time indicator for the day column
  Widget _buildCurrentTimeIndicator(BuildContext context, TimeOfDay currentTime, int startHour, double hourHeight) {
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final startMinutes = startHour * 60;
    final position = ((currentMinutes - startMinutes) / 60) * hourHeight;

    if (position < 0 || position > (22 - startHour) * hourHeight) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: position,
      left: 0,
      right: 0,
      child: Container(
        height: 2,
        color: Colors.red,
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(left: 2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build course slot widgets for a day column
  List<Widget> _buildCourseSlots(BuildContext context, CalendarService calendarService, List<ScheduleSlot> slots, int startHour, double hourHeight) {
    final courseSlots = <Widget>[];

    for (final slot in slots) {
      final course = calendarService.getCourseById(slot.courseId);
      if (course == null) continue;

      final startMinutes = slot.startTime.hour * 60 + slot.startTime.minute;
      final endMinutes = slot.endTime.hour * 60 + slot.endTime.minute;
      final duration = endMinutes - startMinutes;
      
      final topPosition = ((startMinutes - (startHour * 60)) / 60) * hourHeight;
      final height = (duration / 60) * hourHeight - 2; // Small margin

      // Skip slots outside visible hours
      if (topPosition < 0 || topPosition > (22 - startHour) * hourHeight) {
        continue;
      }

      final isCurrentClass = calendarService.isCurrentTimeInSlot(slot);

      courseSlots.add(
        Positioned(
          top: topPosition,
          left: 2,
          right: 2,
          child: GestureDetector(
            onTap: () => _showCourseDetails(context, course, slot),
            child: Container(
              height: height,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: course.displayColor.withOpacity(isCurrentClass ? 0.9 : 0.8),
                borderRadius: BorderRadius.circular(4),
                border: isCurrentClass
                    ? Border.all(color: Colors.white, width: 1)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Course name (abbreviated if needed)
                  Text(
                    _abbreviateCourseName(course.courseName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: height > 30 ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  if (height > 25) ...[
                    const SizedBox(height: 2),
                    
                    // Time
                    Text(
                      slot.timeRange,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  if (height > 40 && slot.location.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    
                    // Location
                    Text(
                      slot.location,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 8,
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
            'Failed to load weekly schedule',
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

  /// Get week range text
  String _getWeekRangeText(DateTime weekStart, DateTime weekEnd) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    if (weekStart.month == weekEnd.month) {
      return '${months[weekStart.month - 1]} ${weekStart.day} - ${weekEnd.day}, ${weekStart.year}';
    } else {
      return '${months[weekStart.month - 1]} ${weekStart.day} - ${months[weekEnd.month - 1]} ${weekEnd.day}, ${weekStart.year}';
    }
  }

  /// Format hour for display
  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : hour == 0 ? 12 : hour;
    return '$displayHour$period';
  }

  /// Abbreviate course name for compact display
  String _abbreviateCourseName(String courseName) {
    if (courseName.length <= 15) return courseName;
    
    // Split by spaces and take first letters of longer words
    final words = courseName.split(' ');
    if (words.length > 1) {
      final abbreviated = words.map((word) {
        if (word.length > 3) {
          return '${word.substring(0, 1).toUpperCase()}.';
        }
        return word;
      }).join(' ');
      
      if (abbreviated.length < courseName.length) {
        return abbreviated;
      }
    }
    
    // Fallback: truncate with ellipsis
    return '${courseName.substring(0, 12)}...';
  }
}