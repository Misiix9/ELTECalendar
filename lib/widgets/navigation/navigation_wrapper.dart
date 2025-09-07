// File: lib/widgets/navigation/navigation_wrapper.dart
// Purpose: Navigation wrapper that adds bottom navigation to any screen
// Step: Navigation System Implementation

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../config/localization_config.dart';

/// Wrapper that adds bottom navigation to any screen
class NavigationWrapper extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  
  const NavigationWrapper({
    super.key,
    required this.child,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavigation(context, localizations),
    );
  }

  /// Build the persistent bottom navigation bar
  Widget _buildBottomNavigation(BuildContext context, AppLocalizations? localizations) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
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
        currentIndex: currentIndex,
        selectedItemColor: ThemeConfig.primaryDarkBlue,
        unselectedItemColor: isDarkMode ? ThemeConfig.lightBackground.withOpacity(0.6) : ThemeConfig.goldAccent,
        selectedLabelStyle: const TextStyle(
          color: ThemeConfig.primaryDarkBlue,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          color: isDarkMode ? ThemeConfig.lightBackground.withOpacity(0.6) : ThemeConfig.goldAccent,
        ),
        backgroundColor: isDarkMode ? ThemeConfig.darkTextElements : ThemeConfig.lightBackground,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today_outlined),
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
        onTap: (index) => _onBottomNavTap(context, index),
      ),
    );
  }

  /// Handle bottom navigation taps
  void _onBottomNavTap(BuildContext context, int index) {
    // Determine the target route based on the tapped index
    String targetRoute;
    switch (index) {
      case 0:
        targetRoute = '/calendar';
        break;
      case 1:
        targetRoute = '/courses';
        break;
      case 2:
        targetRoute = '/notifications';
        break;
      case 3:
        targetRoute = '/settings';
        break;
      default:
        targetRoute = '/calendar';
    }

    // Only navigate if we're not already on the target screen
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != targetRoute) {
      Navigator.of(context).pushReplacementNamed(targetRoute);
    }
  }
}
