// File: lib/widgets/calendar_widgets/monthly_calendar_view.dart
// Purpose: Monthly calendar view widget following specification
// Step: 4.4 - Monthly Calendar View Implementation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/calendar_service.dart';
import '../../config/theme_config.dart';
import '../../models/course_model.dart';
import 'daily_calendar_view.dart';

/// Monthly calendar view showing courses for an entire month
class MonthlyCalendarView extends StatefulWidget {
  const MonthlyCalendarView({super.key});

  @override
  State<MonthlyCalendarView> createState() => _MonthlyCalendarViewState();
}

class _MonthlyCalendarViewState extends State<MonthlyCalendarView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

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
        final monthStart = calendarService.getMonthStart(selectedDate);
        
        return _buildMonthlyCalendar(context, calendarService, selectedDate, monthStart);
      },
    );
  }

  /// Build the monthly calendar view
  Widget _buildMonthlyCalendar(
    BuildContext context,
    CalendarService calendarService,
    DateTime selectedDate,
    DateTime monthStart,
  ) {
    return Column(
      children: [
        // Calendar widget
        Expanded(
          flex: 2,
          child: _buildCalendarWidget(context, calendarService, selectedDate),
        ),
        
        // Selected day details
        Expanded(
          flex: 1,
          child: _buildSelectedDayDetails(context, calendarService, selectedDate),
        ),
      ],
    );
  }

  /// Build table calendar widget
  Widget _buildCalendarWidget(BuildContext context, CalendarService calendarService, DateTime selectedDate) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeConfig.lightBackground,
        border: Border(
          bottom: BorderSide(
            color: ThemeConfig.darkTextElements.withOpacity(0.1),
          ),
        ),
      ),
      child: TableCalendar<Course>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Month',
          CalendarFormat.twoWeeks: '2 weeks',
          CalendarFormat.week: 'Week',
        },
        
        // Event loader
        eventLoader: (day) => calendarService.getCoursesForDate(day),
        
        // Selected day
        selectedDayPredicate: (day) => isSameDay(selectedDate, day),
        
        // Calendar style
        calendarStyle: CalendarStyle(
          // Today's style
          todayDecoration: BoxDecoration(
            color: ThemeConfig.goldAccent.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          
          // Selected day style
          selectedDecoration: const BoxDecoration(
            color: ThemeConfig.primaryDarkBlue,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          
          // Weekend style
          weekendTextStyle: TextStyle(
            color: ThemeConfig.darkTextElements.withOpacity(0.6),
          ),
          
          // Outside month days
          outsideDaysVisible: true,
          outsideTextStyle: TextStyle(
            color: ThemeConfig.darkTextElements.withOpacity(0.3),
          ),
          
          // Event markers
          markersMaxCount: 3,
          markerDecoration: BoxDecoration(
            color: ThemeConfig.goldAccent,
            shape: BoxShape.circle,
          ),
          markersAlignment: Alignment.bottomCenter,
          markersOffset: const PositionedOffset(bottom: 4),
          
          // Borders
          tableBorder: TableBorder.all(
            color: ThemeConfig.darkTextElements.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        
        // Header style
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            color: ThemeConfig.primaryDarkBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          formatButtonTextStyle: const TextStyle(
            color: ThemeConfig.primaryDarkBlue,
            fontWeight: FontWeight.w600,
          ),
          
          leftChevronIcon: const Icon(
            Icons.chevron_left,
            color: ThemeConfig.primaryDarkBlue,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right,
            color: ThemeConfig.primaryDarkBlue,
          ),
          
          titleTextStyle: const TextStyle(
            color: ThemeConfig.primaryDarkBlue,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          
          headerPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        
        // Days of week style
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: ThemeConfig.darkTextElements.withOpacity(0.8),
            fontWeight: FontWeight.w600,
          ),
          weekendStyle: TextStyle(
            color: ThemeConfig.darkTextElements.withOpacity(0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
        
        // Callbacks
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
          calendarService.setSelectedDate(selectedDay);
        },
        
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
          calendarService.setSelectedDate(focusedDay);
        },
        
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        
        // Event marker builder
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, courses) {
            if (courses.isEmpty) return const SizedBox.shrink();
            
            return Positioned(
              bottom: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(
                    courses.length > 3 ? 3 : courses.length,
                    (index) {
                      final course = courses[index] as Course;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: course.displayColor,
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),
                  if (courses.length > 3)
                    Container(
                      margin: const EdgeInsets.only(left: 2),
                      child: Text(
                        '+${courses.length - 3}',
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: ThemeConfig.primaryDarkBlue,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
          
          // Custom day builder for better event indication
          defaultBuilder: (context, date, _) {
            final courses = calendarService.getCoursesForDate(date);
            final isSelected = isSameDay(date, calendarService.selectedDate);
            final isToday = calendarService.isToday(date);
            final isCurrentMonth = calendarService.isCurrentMonth(date);
            
            Color? backgroundColor;
            Color? textColor;
            
            if (isSelected) {
              backgroundColor = ThemeConfig.primaryDarkBlue;
              textColor = Colors.white;
            } else if (isToday) {
              backgroundColor = ThemeConfig.goldAccent;
              textColor = Colors.white;
            } else if (courses.isNotEmpty) {
              backgroundColor = ThemeConfig.primaryDarkBlue.withOpacity(0.1);
              textColor = ThemeConfig.primaryDarkBlue;
            }
            
            return Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    color: textColor ?? (isCurrentMonth 
                        ? ThemeConfig.darkTextElements 
                        : ThemeConfig.darkTextElements.withOpacity(0.3)),
                    fontWeight: courses.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build selected day details panel
  Widget _buildSelectedDayDetails(BuildContext context, CalendarService calendarService, DateTime selectedDate) {
    final courses = calendarService.getCoursesForDate(selectedDate);
    final isToday = calendarService.isToday(selectedDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeConfig.lightBackground,
        border: Border(
          top: BorderSide(
            color: ThemeConfig.darkTextElements.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected date header
          Row(
            children: [
              Text(
                _getFormattedSelectedDate(selectedDate),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isToday ? ThemeConfig.goldAccent : ThemeConfig.primaryDarkBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isToday) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: ThemeConfig.goldAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Today',
                    style: TextStyle(
                      color: ThemeConfig.goldAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              
              const Spacer(),
              
              // View in daily mode button
              TextButton.icon(
                onPressed: courses.isNotEmpty ? () {
                  calendarService.setSelectedDate(selectedDate);
                  calendarService.setViewType(CalendarViewType.daily);
                } : null,
                icon: const Icon(Icons.view_day, size: 16),
                label: const Text('Daily View'),
                style: TextButton.styleFrom(
                  foregroundColor: ThemeConfig.primaryDarkBlue,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Courses list
          Expanded(
            child: courses.isEmpty 
                ? _buildEmptyDayView(context, isToday)
                : _buildCoursesList(context, calendarService, courses),
          ),
        ],
      ),
    );
  }

  /// Build empty day view
  Widget _buildEmptyDayView(BuildContext context, bool isToday) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 48,
            color: ThemeConfig.primaryDarkBlue.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            isToday ? 'No classes today' : 'No classes scheduled',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: ThemeConfig.darkTextElements.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isToday ? 'Enjoy your free day!' : 'Free day',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ThemeConfig.darkTextElements.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// Build courses list for selected day
  Widget _buildCoursesList(BuildContext context, CalendarService calendarService, List<Course> courses) {
    // Get all schedule slots for the day and sort by time
    final allSlots = <MapEntry<Course, ScheduleSlot>>[];
    for (final course in courses) {
      for (final slot in course.scheduleSlots) {
        if (slot.dayOfWeek == calendarService.selectedDate.weekday) {
          allSlots.add(MapEntry(course, slot));
        }
      }
    }
    
    allSlots.sort((a, b) => a.value.startTime.compareTo(b.value.startTime));

    if (allSlots.isEmpty) {
      return _buildEmptyDayView(context, calendarService.isToday(calendarService.selectedDate));
    }

    return ListView.separated(
      itemCount: allSlots.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = allSlots[index];
        final course = entry.key;
        final slot = entry.value;
        final isCurrentClass = calendarService.isCurrentTimeInSlot(slot);

        return GestureDetector(
          onTap: () => _showCourseDetails(context, course, slot),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCurrentClass 
                  ? course.displayColor.withOpacity(0.9)
                  : course.displayColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: isCurrentClass 
                  ? Border.all(color: course.displayColor, width: 2)
                  : Border.all(color: course.displayColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                // Time indicator
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: course.displayColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Course details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course name and type
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              course.courseName,
                              style: TextStyle(
                                color: isCurrentClass ? Colors.white : ThemeConfig.darkTextElements,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isCurrentClass 
                                  ? Colors.white.withOpacity(0.2)
                                  : course.displayColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              course.classType,
                              style: TextStyle(
                                color: isCurrentClass ? Colors.white : course.displayColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Time and location
                      Text(
                        '${slot.timeRange}${slot.location.isNotEmpty ? ' • ${slot.location}' : ''}',
                        style: TextStyle(
                          color: isCurrentClass 
                              ? Colors.white.withOpacity(0.9)
                              : ThemeConfig.darkTextElements.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      
                      // Course code
                      Text(
                        course.courseCode,
                        style: TextStyle(
                          color: isCurrentClass 
                              ? Colors.white.withOpacity(0.8)
                              : ThemeConfig.darkTextElements.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status indicator
                if (isCurrentClass)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'NOW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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
            'Failed to load monthly calendar',
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

  /// Get formatted selected date
  String _getFormattedSelectedDate(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
                   'July', 'August', 'September', 'October', 'November', 'December'];
    
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}