// File: lib/screens/settings/notification_settings_screen.dart
// Purpose: Notification preferences and settings management
// Step: 7.3 - Notification Settings Interface

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../config/localization_config.dart';
import '../../services/notification_service.dart';

/// Notification settings screen for managing user preferences
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: _buildAppBar(context, localizations),
      body: Consumer<NotificationService>(
        builder: (context, notificationService, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGlobalToggle(context, notificationService, localizations),
                const SizedBox(height: 32),
                _buildNotificationTypes(context, notificationService, localizations),
                const SizedBox(height: 32),
                _buildReminderSettings(context, notificationService, localizations),
                const SizedBox(height: 32),
                _buildNotificationHistory(context, notificationService, localizations),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build app bar
  AppBar _buildAppBar(BuildContext context, AppLocalizations? localizations) {
    return AppBar(
      title: Text(localizations?.getString('notificationSettings') ?? 'Notification Settings'),
      backgroundColor: ThemeConfig.lightBackground,
      foregroundColor: ThemeConfig.primaryDarkBlue,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: _showNotificationHelp,
          icon: const Icon(Icons.help_outline),
        ),
      ],
    );
  }

  /// Build global notification toggle
  Widget _buildGlobalToggle(BuildContext context, NotificationService notificationService, AppLocalizations? localizations) {
    return Container(
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
          Text(
            localizations?.getString('notifications') ?? 'Notifications',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ThemeConfig.darkTextElements,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                notificationService.notificationsEnabled 
                  ? Icons.notifications_active 
                  : Icons.notifications_off,
                color: notificationService.notificationsEnabled 
                  ? ThemeConfig.primaryDarkBlue 
                  : Colors.grey,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations?.getString('enableNotifications') ?? 'Enable Notifications',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: ThemeConfig.darkTextElements,
                      ),
                    ),
                    Text(
                      localizations?.getString('enableNotificationsDesc') ?? 
                        'Receive course reminders and important updates',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeConfig.darkTextElements.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: notificationService.notificationsEnabled,
                onChanged: (value) {
                  notificationService.toggleNotifications(value);
                },
                activeThumbColor: ThemeConfig.primaryDarkBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build notification types settings
  Widget _buildNotificationTypes(BuildContext context, NotificationService notificationService, AppLocalizations? localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations?.getString('notificationTypes') ?? 'Notification Types',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ThemeConfig.darkTextElements,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
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
              _buildNotificationTypeTile(
                context,
                notificationService,
                NotificationService.courseReminderType,
                'Course Reminders',
                'Get notified 15 minutes before your courses start',
                Icons.schedule,
                localizations,
              ),
              const Divider(height: 1),
              _buildNotificationTypeTile(
                context,
                notificationService,
                NotificationService.scheduleChangeType,
                'Schedule Changes',
                'When your course schedule is updated',
                Icons.update,
                localizations,
              ),
              const Divider(height: 1),
              _buildNotificationTypeTile(
                context,
                notificationService,
                NotificationService.semesterUpdateType,
                'Semester Updates',
                'When switching between semesters',
                Icons.school,
                localizations,
              ),
              const Divider(height: 1),
              _buildNotificationTypeTile(
                context,
                notificationService,
                NotificationService.importCompleteType,
                'Import Complete',
                'When Excel schedule import finishes',
                Icons.file_upload,
                localizations,
              ),
              const Divider(height: 1),
              _buildNotificationTypeTile(
                context,
                notificationService,
                NotificationService.systemUpdateType,
                'System Updates',
                'Important app updates and announcements',
                Icons.system_update_alt,
                localizations,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build individual notification type tile
  Widget _buildNotificationTypeTile(
    BuildContext context,
    NotificationService notificationService,
    String type,
    String title,
    String description,
    IconData icon,
    AppLocalizations? localizations,
  ) {
    final isEnabled = notificationService.notificationPreferences[type] ?? false;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(
        icon,
        color: isEnabled ? ThemeConfig.primaryDarkBlue : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isEnabled ? ThemeConfig.darkTextElements : Colors.grey,
        ),
      ),
      subtitle: Text(
        description,
        style: TextStyle(
          fontSize: 13,
          color: isEnabled 
            ? ThemeConfig.darkTextElements.withOpacity(0.7)
            : Colors.grey.withOpacity(0.7),
        ),
      ),
      trailing: Switch(
        value: isEnabled && notificationService.notificationsEnabled,
        onChanged: notificationService.notificationsEnabled 
          ? (value) {
              notificationService.updateNotificationPreference(type, value);
            }
          : null,
        activeThumbColor: ThemeConfig.primaryDarkBlue,
      ),
    );
  }

  /// Build reminder settings
  Widget _buildReminderSettings(BuildContext context, NotificationService notificationService, AppLocalizations? localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations?.getString('reminderSettings') ?? 'Reminder Settings',
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
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: ThemeConfig.primaryDarkBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    localizations?.getString('reminderTiming') ?? 'Reminder Timing',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ThemeConfig.darkTextElements,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                localizations?.getString('reminderTimingDesc') ?? 
                  'Course reminders are sent 15 minutes before each scheduled session.',
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeConfig.darkTextElements.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              
              // Statistics
              Row(
                children: [
                  Expanded(
                    child: _buildReminderStat(
                      'Today',
                      '${_getTodayRemindersCount(notificationService)}',
                      Icons.today,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildReminderStat(
                      'This Week',
                      '${_getWeekRemindersCount(notificationService)}',
                      Icons.date_range,
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

  /// Build reminder statistics card
  Widget _buildReminderStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeConfig.primaryDarkBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: ThemeConfig.primaryDarkBlue, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeConfig.primaryDarkBlue,
            ),
          ),
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

  /// Build notification history section
  Widget _buildNotificationHistory(BuildContext context, NotificationService notificationService, AppLocalizations? localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations?.getString('notificationHistory') ?? 'Notification History',
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${notificationService.notifications.length} Total',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeConfig.darkTextElements,
                        ),
                      ),
                      Text(
                        '${notificationService.unreadCount} Unread',
                        style: TextStyle(
                          fontSize: 14,
                          color: ThemeConfig.darkTextElements.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: notificationService.unreadCount > 0 
                          ? () => notificationService.markAllAsRead()
                          : null,
                        child: const Text('Mark All Read'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: notificationService.notifications.isNotEmpty 
                          ? _showClearConfirmation
                          : null,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/notifications');
                },
                icon: const Icon(Icons.list),
                label: Text(localizations?.getString('viewAllNotifications') ?? 'View All Notifications'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ThemeConfig.primaryDarkBlue,
                  side: const BorderSide(color: ThemeConfig.primaryDarkBlue),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Get today's reminders count
  int _getTodayRemindersCount(NotificationService notificationService) {
    return notificationService.recentNotifications
        .where((n) => n.type == NotificationService.courseReminderType && n.isToday)
        .length;
  }

  /// Get this week's reminders count
  int _getWeekRemindersCount(NotificationService notificationService) {
    return notificationService.notifications
        .where((n) => n.type == NotificationService.courseReminderType && n.isThisWeek)
        .length;
  }

  /// Show notification help dialog
  void _showNotificationHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('📅 Course Reminders', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Get notified 15 minutes before each scheduled course session.\n'),
              
              Text('🔄 Schedule Changes', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Receive updates when your course schedule is modified.\n'),
              
              Text('🎓 Semester Updates', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Get notified when switching between semesters or semester milestones.\n'),
              
              Text('📊 Import Complete', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Confirmation when Excel schedule imports finish successfully.\n'),
              
              Text('⚙️ System Updates', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Important app updates and announcements from the development team.'),
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

  /// Show clear confirmation dialog
  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to clear all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<NotificationService>().clearAllNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}