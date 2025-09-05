// File: lib/screens/calendar/calendar_main_screen.dart
// Purpose: Main calendar screen stub for project initialization
// Step: 1.1 - Initialize Flutter Project

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../config/localization_config.dart';

/// Main calendar screen - placeholder implementation
/// Will be fully implemented in Step 4: Calendar Interface
class CalendarMainScreen extends StatefulWidget {
  const CalendarMainScreen({super.key});

  @override
  State<CalendarMainScreen> createState() => _CalendarMainScreenState();
}

class _CalendarMainScreenState extends State<CalendarMainScreen> {
  int _selectedViewIndex = 1; // Default to weekly view
  final List<String> _viewTypes = ['Daily', 'Weekly', 'Monthly'];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.calendar ?? 'Calendar'),
        actions: [
          // View selector
          PopupMenuButton<int>(
            onSelected: (index) {
              setState(() {
                _selectedViewIndex = index;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 0,
                child: Text(localizations?.getString('dailyView') ?? 'Daily View'),
              ),
              PopupMenuItem(
                value: 1,
                child: Text(localizations?.getString('weeklyView') ?? 'Weekly View'),
              ),
              PopupMenuItem(
                value: 2,
                child: Text(localizations?.getString('monthlyView') ?? 'Monthly View'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_viewTypes[_selectedViewIndex]),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          
          // Settings button
          IconButton(
            onPressed: () {
              // TODO: Navigate to settings
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Calendar view placeholder
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: ThemeConfig.lightBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ThemeConfig.primaryDarkBlue.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_view_week,
                      size: 64,
                      color: ThemeConfig.primaryDarkBlue.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${_viewTypes[_selectedViewIndex]} View',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations?.getString('noClassesToday') ?? 'No classes to display',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: ThemeConfig.darkTextElements.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Placeholder information
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ThemeConfig.goldAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: ThemeConfig.goldAccent.withOpacity(0.3),
                        ),
                      ),
                      child: const Text(
                        'Placeholder Calendar Screen\n\nCalendar interface will be implemented in Step 4.\n\nThis includes:\n• Daily, Weekly, Monthly views\n• Course display with color coding\n• Current time indicator\n• Interactive course details',
                        style: TextStyle(
                          fontSize: 14,
                          color: ThemeConfig.darkTextElements,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Floating action button for importing Excel
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to Excel import screen
          _showImportDialog();
        },
        icon: const Icon(Icons.upload_file),
        label: Text(localizations?.getString('importExcel') ?? 'Import Excel'),
      ),
      
      // Bottom navigation for future features
      bottomNavigationBar: BottomNavigationBar(
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
      ),
    );
  }

  /// Show import dialog placeholder
  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Excel File'),
        content: const Text(
          'Excel import functionality will be implemented in Step 3.\n\nThis will include:\n• File picker for .xlsx files\n• Excel validation and parsing\n• Course schedule extraction\n• Semester assignment',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}