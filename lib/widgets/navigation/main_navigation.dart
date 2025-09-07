// File: lib/widgets/navigation/main_navigation.dart
// Purpose: Main navigation wrapper with persistent bottom navigation
// Step: Navigation System Implementation

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../config/localization_config.dart';
import '../../screens/calendar/calendar_main_screen.dart';
import '../../screens/courses/course_list_screen.dart';
import '../../screens/settings/semester_management_screen.dart';
import '../../screens/notifications/notifications_screen.dart';

/// Main navigation wrapper that provides consistent bottom navigation
/// across all main screens of the application
class MainNavigation extends StatefulWidget {
  final int initialIndex;
  
  const MainNavigation({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;
  late PageController _pageController;

  // Define the main screens
  final List<Widget> _screens = [
    const CalendarMainScreen(),
    const CourseListScreen(),
    const NotificationsScreen(),
    const SemesterManagementScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavigation(localizations),
    );
  }

  /// Handle page changes from PageView
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// Handle bottom navigation taps
  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Build the bottom navigation bar
  Widget _buildBottomNavigation(AppLocalizations? localizations) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: ThemeConfig.primaryDarkBlue,
        unselectedItemColor: ThemeConfig.darkTextElements.withOpacity(0.6),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today),
            activeIcon: const Icon(Icons.calendar_today),
            label: localizations?.calendar ?? 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.school_outlined),
            activeIcon: const Icon(Icons.school),
            label: localizations?.courses ?? 'Courses',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications_outlined),
            activeIcon: const Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: localizations?.settings ?? 'Settings',
          ),
        ],
        onTap: _onBottomNavTap,
      ),
    );
  }
}
