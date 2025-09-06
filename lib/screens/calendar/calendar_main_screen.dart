// File: lib/screens/calendar/calendar_main_screen.dart
// Purpose: Main calendar screen with complete calendar interface
// Step: 4.6 - Complete Calendar Interface Implementation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../config/localization_config.dart';
import '../../services/calendar_service.dart';
import '../../services/semester_service.dart';
import '../../widgets/calendar_widgets/daily_calendar_view.dart';
import '../../widgets/calendar_widgets/weekly_calendar_view.dart';
import '../../widgets/calendar_widgets/monthly_calendar_view.dart';
import '../import/excel_import_screen.dart';
import '../settings/semester_management_screen.dart';
import '../../widgets/common_widgets/notification_badge.dart';

/// Main calendar screen with complete calendar interface
class CalendarMainScreen extends StatefulWidget {
  const CalendarMainScreen({super.key});

  @override
  State<CalendarMainScreen> createState() => _CalendarMainScreenState();
}

class _CalendarMainScreenState extends State<CalendarMainScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Consumer<CalendarService>(
      builder: (context, calendarService, child) {
        return Scaffold(
          appBar: _buildAppBar(context, localizations, calendarService),
          body: _buildCalendarView(calendarService),
          
          // Floating action button for importing Excel
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _navigateToImportScreen,
            backgroundColor: ThemeConfig.primaryDarkBlue,
            foregroundColor: ThemeConfig.lightBackground,
            icon: const Icon(Icons.upload_file),
            label: Text(localizations?.getString('importExcel') ?? 'Import Excel'),
          ),
          
          // Bottom navigation
          bottomNavigationBar: _buildBottomNavigation(context, localizations),
        );
      },
    );
  }
  
  /// Build app bar with view selector and actions
  AppBar _buildAppBar(BuildContext context, AppLocalizations? localizations, CalendarService calendarService) {
    return AppBar(
      title: Text(localizations?.calendar ?? 'Calendar'),
      backgroundColor: ThemeConfig.lightBackground,
      foregroundColor: ThemeConfig.primaryDarkBlue,
      elevation: 0,
      actions: [
        // Notification badge
        const NotificationBadge(),
        
        // Today button
        TextButton.icon(
          onPressed: calendarService.goToToday,
          icon: const Icon(Icons.today, size: 18),
          label: const Text('Today'),
          style: TextButton.styleFrom(
            foregroundColor: ThemeConfig.primaryDarkBlue,
          ),
        ),
        
        // View selector
        PopupMenuButton<CalendarViewType>(
          onSelected: (viewType) {
            calendarService.setViewType(viewType);
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: CalendarViewType.daily,
              child: Row(
                children: [
                  const Icon(Icons.view_day, size: 18),
                  const SizedBox(width: 8),
                  const Text('Daily View'),
                  if (calendarService.currentView == CalendarViewType.daily)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: ThemeConfig.goldAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
            PopupMenuItem(
              value: CalendarViewType.weekly,
              child: Row(
                children: [
                  const Icon(Icons.view_week, size: 18),
                  const SizedBox(width: 8),
                  const Text('Weekly View'),
                  if (calendarService.currentView == CalendarViewType.weekly)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: ThemeConfig.goldAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
            PopupMenuItem(
              value: CalendarViewType.monthly,
              child: Row(
                children: [
                  const Icon(Icons.view_month, size: 18),
                  const SizedBox(width: 8),
                  const Text('Monthly View'),
                  if (calendarService.currentView == CalendarViewType.monthly)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: ThemeConfig.goldAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getViewIcon(calendarService.currentView)),
                const SizedBox(width: 4),
                Text(_getViewName(calendarService.currentView)),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        
        // Semester selector
        Consumer<SemesterService>(
          builder: (context, semesterService, child) {
            final semesters = semesterService.availableSemesters;
            
            if (semesters.isEmpty) {
              return const SizedBox.shrink();
            }
            
            return PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'manage') {
                  _navigateToSemesterManagement(context);
                } else {
                  calendarService.setCurrentSemester(value);
                }
              },
              itemBuilder: (context) => [
                ...semesters.map((semester) {
                  return PopupMenuItem(
                    value: semester.id,
                    child: Row(
                      children: [
                        Icon(
                          calendarService.currentSemester == semester.id 
                              ? Icons.check_circle 
                              : Icons.circle_outlined,
                          size: 16,
                          color: calendarService.currentSemester == semester.id 
                              ? ThemeConfig.goldAccent
                              : ThemeConfig.darkTextElements.withOpacity(0.5),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            semester.displayName,
                            style: TextStyle(
                              fontWeight: calendarService.currentSemester == semester.id 
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'manage',
                  child: Row(
                    children: [
                      Icon(Icons.settings, size: 16, color: ThemeConfig.primaryDarkBlue),
                      SizedBox(width: 8),
                      Text('Manage Semesters'),
                    ],
                  ),
                ),
              ],
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(Icons.school),
              ),
            );
          },
        ),
      ],
    );
  }
  
  /// Build calendar view based on selected type
  Widget _buildCalendarView(CalendarService calendarService) {
    switch (calendarService.currentView) {
      case CalendarViewType.daily:
        return const DailyCalendarView();
      case CalendarViewType.weekly:
        return const WeeklyCalendarView();
      case CalendarViewType.monthly:
        return const MonthlyCalendarView();
    }
  }
  
  /// Build bottom navigation
  Widget _buildBottomNavigation(BuildContext context, AppLocalizations? localizations) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      selectedItemColor: ThemeConfig.primaryDarkBlue,
      unselectedItemColor: ThemeConfig.darkTextElements.withOpacity(0.6),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.calendar_today),
          label: localizations?.calendar ?? 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.school),
          label: localizations?.courses ?? 'Courses',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: localizations?.settings ?? 'Settings',
        ),
      ],
      onTap: (index) {
        // Handle bottom navigation taps
        switch (index) {
          case 0:
            // Already on calendar - do nothing
            break;
          case 1:
            // Navigate to courses list
            Navigator.of(context).pushNamed('/courses');
            break;
          case 2:
            // Navigate to semester management (settings)
            _navigateToSemesterManagement(context);
            break;
        }
      },
    );
  }
  
  /// Get view icon for current view type
  IconData _getViewIcon(CalendarViewType viewType) {
    switch (viewType) {
      case CalendarViewType.daily:
        return Icons.view_day;
      case CalendarViewType.weekly:
        return Icons.view_week;
      case CalendarViewType.monthly:
        return Icons.view_month;
    }
  }
  
  /// Get view name for current view type
  String _getViewName(CalendarViewType viewType) {
    switch (viewType) {
      case CalendarViewType.daily:
        return 'Daily';
      case CalendarViewType.weekly:
        return 'Weekly';
      case CalendarViewType.monthly:
        return 'Monthly';
    }
  }

  /// Navigate to Excel import screen
  void _navigateToImportScreen() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const ExcelImportScreen(),
      ),
    );

    // If import was successful, show a success message
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Courses imported successfully!'),
          backgroundColor: Colors.green.shade600,
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () {
              // TODO: Scroll to today or refresh calendar view
            },
          ),
        ),
      );
    }
  }

  /// Navigate to semester management screen
  void _navigateToSemesterManagement(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SemesterManagementScreen(),
      ),
    );
  }
}