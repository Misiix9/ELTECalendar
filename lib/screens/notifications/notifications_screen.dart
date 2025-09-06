// File: lib/screens/notifications/notifications_screen.dart
// Purpose: Notification history and management interface
// Step: 7.4 - Notification List and Management

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../config/localization_config.dart';
import '../../services/notification_service.dart';
import '../../models/notification_model.dart';
import '../../widgets/common_widgets/empty_state_widget.dart';
import '../../widgets/common_widgets/loading_indicator.dart';

/// Notifications screen displaying all user notifications with management options
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'all';
  final List<String> _filterOptions = ['all', 'unread', 'course_reminder', 'schedule_change'];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: _buildAppBar(context, localizations),
      body: Consumer<NotificationService>(
        builder: (context, notificationService, child) {
          if (!notificationService.isInitialized) {
            return const Center(child: LoadingIndicator());
          }

          return Column(
            children: [
              _buildFilterBar(context, notificationService, localizations),
              Expanded(
                child: _buildNotificationsList(context, notificationService, localizations),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build app bar with actions
  AppBar _buildAppBar(BuildContext context, AppLocalizations? localizations) {
    return AppBar(
      title: Text(localizations?.getString('notifications') ?? 'Notifications'),
      backgroundColor: ThemeConfig.lightBackground,
      foregroundColor: ThemeConfig.primaryDarkBlue,
      elevation: 0,
      actions: [
        Consumer<NotificationService>(
          builder: (context, notificationService, child) {
            return PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value, notificationService),
              itemBuilder: (context) => [
                if (notificationService.unreadCount > 0)
                  const PopupMenuItem(
                    value: 'mark_all_read',
                    child: Row(
                      children: [
                        Icon(Icons.mark_email_read, size: 16),
                        SizedBox(width: 8),
                        Text('Mark All Read'),
                      ],
                    ),
                  ),
                if (notificationService.notifications.isNotEmpty) ...[
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Clear All', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings, size: 16),
                        SizedBox(width: 8),
                        Text('Notification Settings'),
                      ],
                    ),
                  ),
                ],
              ],
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(Icons.more_vert),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Build filter bar
  Widget _buildFilterBar(BuildContext context, NotificationService notificationService, AppLocalizations? localizations) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: ThemeConfig.lightBackground,
      child: Column(
        children: [
          // Unread count badge
          if (notificationService.unreadCount > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: ThemeConfig.goldAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ThemeConfig.goldAccent.withOpacity(0.3),
                ),
              ),
              child: Text(
                '${notificationService.unreadCount} unread notification${notificationService.unreadCount != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 14,
                  color: ThemeConfig.primaryDarkBlue,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'All', Icons.list, notificationService),
                const SizedBox(width: 8),
                _buildFilterChip('unread', 'Unread', Icons.mark_email_unread, notificationService),
                const SizedBox(width: 8),
                _buildFilterChip('course_reminder', 'Reminders', Icons.schedule, notificationService),
                const SizedBox(width: 8),
                _buildFilterChip('schedule_change', 'Updates', Icons.update, notificationService),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build filter chip
  Widget _buildFilterChip(String value, String label, IconData icon, NotificationService notificationService) {
    final isSelected = _selectedFilter == value;
    final count = _getFilterCount(value, notificationService);
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, 
            color: isSelected ? Colors.white : ThemeConfig.primaryDarkBlue),
          const SizedBox(width: 4),
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.3) : ThemeConfig.goldAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: ThemeConfig.primaryDarkBlue,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : ThemeConfig.primaryDarkBlue,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  /// Build notifications list
  Widget _buildNotificationsList(BuildContext context, NotificationService notificationService, AppLocalizations? localizations) {
    final filteredNotifications = _getFilteredNotifications(notificationService);
    
    if (filteredNotifications.isEmpty) {
      return EmptyStateWidget(
        icon: _selectedFilter == 'unread' ? Icons.mark_email_read : Icons.notifications_none,
        title: _getEmptyTitle(),
        message: _getEmptyMessage(),
        actionLabel: _selectedFilter != 'all' ? 'Clear Filter' : null,
        onActionPressed: _selectedFilter != 'all' ? () {
          setState(() {
            _selectedFilter = 'all';
          });
        } : null,
      );
    }

    // Group notifications by date
    final groupedNotifications = filteredNotifications.groupByDate();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedNotifications.length,
      itemBuilder: (context, index) {
        final group = groupedNotifications[index];
        return _buildNotificationGroup(context, group, notificationService);
      },
    );
  }

  /// Build notification group (day section)
  Widget _buildNotificationGroup(BuildContext context, NotificationGroup group, NotificationService notificationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                group.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ThemeConfig.darkTextElements.withOpacity(0.8),
                ),
              ),
              const SizedBox(width: 8),
              if (group.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: ThemeConfig.goldAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${group.unreadCount}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Notifications in group
        ...group.notifications.map((notification) {
          return _buildNotificationTile(context, notification, notificationService);
        }).toList(),
        
        const SizedBox(height: 16),
      ],
    );
  }

  /// Build individual notification tile
  Widget _buildNotificationTile(BuildContext context, AppNotification notification, NotificationService notificationService) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      elevation: notification.isRead ? 1 : 3,
      color: notification.isRead ? Colors.grey.shade50 : Colors.white,
      child: InkWell(
        onTap: () => _handleNotificationTap(notification, notificationService),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getNotificationIcon(notification),
                  color: _getNotificationColor(notification),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                        color: notification.isRead 
                          ? ThemeConfig.darkTextElements.withOpacity(0.8)
                          : ThemeConfig.darkTextElements,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Message
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: notification.isRead 
                          ? ThemeConfig.darkTextElements.withOpacity(0.6)
                          : ThemeConfig.darkTextElements.withOpacity(0.8),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // Timestamp
                    Text(
                      notification.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeConfig.darkTextElements.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Actions
              PopupMenuButton<String>(
                onSelected: (value) => _handleNotificationAction(value, notification, notificationService),
                itemBuilder: (context) => [
                  if (!notification.isRead)
                    const PopupMenuItem(
                      value: 'mark_read',
                      child: Row(
                        children: [
                          Icon(Icons.mark_email_read, size: 16),
                          SizedBox(width: 8),
                          Text('Mark as Read'),
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
                child: Icon(
                  Icons.more_vert,
                  size: 18,
                  color: ThemeConfig.darkTextElements.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get filtered notifications based on selected filter
  List<AppNotification> _getFilteredNotifications(NotificationService notificationService) {
    switch (_selectedFilter) {
      case 'unread':
        return notificationService.notifications.unread;
      case 'course_reminder':
        return notificationService.notifications.ofType(NotificationService.courseReminderType);
      case 'schedule_change':
        return notificationService.notifications.ofType(NotificationService.scheduleChangeType);
      default:
        return notificationService.notifications;
    }
  }

  /// Get count for filter
  int _getFilterCount(String filter, NotificationService notificationService) {
    switch (filter) {
      case 'unread':
        return notificationService.unreadCount;
      case 'course_reminder':
        return notificationService.notifications.ofType(NotificationService.courseReminderType).length;
      case 'schedule_change':
        return notificationService.notifications.ofType(NotificationService.scheduleChangeType).length;
      default:
        return notificationService.notifications.length;
    }
  }

  /// Get notification icon
  IconData _getNotificationIcon(AppNotification notification) {
    switch (notification.type) {
      case 'course_reminder':
        return Icons.schedule;
      case 'schedule_change':
        return Icons.update;
      case 'semester_update':
        return Icons.school;
      case 'import_complete':
        return Icons.file_upload;
      case 'system_update':
        return Icons.system_update_alt;
      default:
        return Icons.notifications;
    }
  }

  /// Get notification color
  Color _getNotificationColor(AppNotification notification) {
    switch (notification.type) {
      case 'course_reminder':
        return ThemeConfig.primaryDarkBlue;
      case 'schedule_change':
        return Colors.orange;
      case 'semester_update':
        return ThemeConfig.goldAccent;
      case 'import_complete':
        return Colors.green;
      case 'system_update':
        return Colors.purple;
      default:
        return ThemeConfig.primaryDarkBlue;
    }
  }

  /// Get empty state title
  String _getEmptyTitle() {
    switch (_selectedFilter) {
      case 'unread':
        return 'No Unread Notifications';
      case 'course_reminder':
        return 'No Course Reminders';
      case 'schedule_change':
        return 'No Schedule Updates';
      default:
        return 'No Notifications';
    }
  }

  /// Get empty state message
  String _getEmptyMessage() {
    switch (_selectedFilter) {
      case 'unread':
        return 'All caught up! You have no unread notifications.';
      case 'course_reminder':
        return 'No course reminders have been sent yet.';
      case 'schedule_change':
        return 'No schedule changes have occurred recently.';
      default:
        return 'When you receive notifications, they will appear here.';
    }
  }

  /// Handle menu actions
  void _handleMenuAction(String action, NotificationService notificationService) {
    switch (action) {
      case 'mark_all_read':
        notificationService.markAllAsRead();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'clear_all':
        _showClearAllConfirmation(notificationService);
        break;
      case 'settings':
        Navigator.of(context).pushNamed('/notification-settings');
        break;
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(AppNotification notification, NotificationService notificationService) {
    if (!notification.isRead) {
      notificationService.markAsRead(notification.id);
    }

    // Handle navigation based on notification type
    if (notification.actionUrl != null) {
      Navigator.of(context).pushNamed(notification.actionUrl!);
    } else if (notification.data != null) {
      // Handle navigation based on notification data
      switch (notification.type) {
        case 'course_reminder':
          final courseId = notification.data!['courseId'];
          if (courseId != null) {
            // Navigate to course detail or calendar
            Navigator.of(context).pushNamed('/courses');
          }
          break;
        case 'schedule_change':
          Navigator.of(context).pushNamed('/calendar');
          break;
        case 'semester_update':
          Navigator.of(context).pushNamed('/semester-management');
          break;
      }
    }
  }

  /// Handle notification action
  void _handleNotificationAction(String action, AppNotification notification, NotificationService notificationService) {
    switch (action) {
      case 'mark_read':
        notificationService.markAsRead(notification.id);
        break;
      case 'delete':
        notificationService.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
    }
  }

  /// Show clear all confirmation dialog
  void _showClearAllConfirmation(NotificationService notificationService) {
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
              notificationService.clearAllNotifications();
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