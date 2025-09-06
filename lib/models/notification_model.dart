// File: lib/models/notification_model.dart
// Purpose: Notification data model for the notification system
// Step: 7.2 - Notification Model Implementation

import 'package:hive/hive.dart';

part 'notification_model.g.dart';

/// Notification model representing app notifications
@HiveType(typeId: 4)
class AppNotification {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String message;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final bool isRead;

  @HiveField(6)
  final Map<String, dynamic>? data;

  @HiveField(7)
  final NotificationPriority priority;

  @HiveField(8)
  final String? actionUrl;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    this.data,
    this.priority = NotificationPriority.normal,
    this.actionUrl,
  });

  /// Get display-friendly time string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      // More than a week ago - show date
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      // Days ago
      return '${difference.inDays} day${difference.inDays != 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      // Hours ago
      return '${difference.inHours} hour${difference.inHours != 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      // Minutes ago
      return '${difference.inMinutes} minute${difference.inMinutes != 1 ? 's' : ''} ago';
    } else {
      // Just now
      return 'Just now';
    }
  }

  /// Get notification icon based on type
  String get iconName {
    switch (type) {
      case 'course_reminder':
        return 'schedule';
      case 'schedule_change':
        return 'update';
      case 'semester_update':
        return 'school';
      case 'import_complete':
        return 'file_upload';
      case 'system_update':
        return 'system_update_alt';
      default:
        return 'notifications';
    }
  }

  /// Get notification color based on priority
  String get priorityColor {
    switch (priority) {
      case NotificationPriority.low:
        return '#9E9E9E'; // Gray
      case NotificationPriority.normal:
        return '#03284F'; // Primary blue
      case NotificationPriority.high:
        return '#FF9800'; // Orange
      case NotificationPriority.urgent:
        return '#F44336'; // Red
    }
  }

  /// Check if notification is today
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notificationDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    return today.isAtSameMomentAs(notificationDate);
  }

  /// Check if notification is from this week
  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    return timestamp.isAfter(weekStartDate);
  }

  /// Get formatted time for display
  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get formatted date for display
  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${timestamp.day} ${months[timestamp.month - 1]} ${timestamp.year}';
  }

  /// Create copy with updated values
  AppNotification copyWith({
    String? id,
    String? type,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
    NotificationPriority? priority,
    String? actionUrl,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      priority: priority ?? this.priority,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  /// Convert to JSON for storage/transmission
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'data': data,
      'priority': priority.name,
      'actionUrl': actionUrl,
    };
  }

  /// Create from JSON
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool,
      data: json['data'] as Map<String, dynamic>?,
      priority: NotificationPriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      actionUrl: json['actionUrl'] as String?,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'timestamp': timestamp,
      'isRead': isRead,
      'data': data ?? {},
      'priority': priority.name,
      'actionUrl': actionUrl,
    };
  }

  /// Create from Firestore document
  factory AppNotification.fromFirestore(Map<String, dynamic> doc) {
    return AppNotification(
      id: doc['id'] as String,
      type: doc['type'] as String,
      title: doc['title'] as String,
      message: doc['message'] as String,
      timestamp: (doc['timestamp'] as dynamic).toDate() as DateTime,
      isRead: doc['isRead'] as bool,
      data: doc['data'] as Map<String, dynamic>?,
      priority: NotificationPriority.values.firstWhere(
        (p) => p.name == doc['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      actionUrl: doc['actionUrl'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is AppNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AppNotification{id: $id, type: $type, title: $title, timestamp: $timestamp, isRead: $isRead}';
  }
}

/// Notification priority levels
@HiveType(typeId: 5)
enum NotificationPriority {
  @HiveField(0)
  low,
  
  @HiveField(1)
  normal,
  
  @HiveField(2)
  high,
  
  @HiveField(3)
  urgent,
}

/// Extension methods for notification priority
extension NotificationPriorityExtension on NotificationPriority {
  /// Get display name for priority
  String get displayName {
    switch (this) {
      case NotificationPriority.low:
        return 'Low';
      case NotificationPriority.normal:
        return 'Normal';
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.urgent:
        return 'Urgent';
    }
  }

  /// Get numeric value for sorting
  int get value {
    switch (this) {
      case NotificationPriority.low:
        return 1;
      case NotificationPriority.normal:
        return 2;
      case NotificationPriority.high:
        return 3;
      case NotificationPriority.urgent:
        return 4;
    }
  }
}

/// Notification grouping helper
class NotificationGroup {
  final String title;
  final List<AppNotification> notifications;
  final DateTime date;

  const NotificationGroup({
    required this.title,
    required this.notifications,
    required this.date,
  });

  /// Get unread count for this group
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  /// Check if all notifications in group are read
  bool get allRead => notifications.every((n) => n.isRead);

  /// Get most recent notification timestamp
  DateTime get lastNotificationTime {
    if (notifications.isEmpty) return date;
    
    return notifications
        .map((n) => n.timestamp)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }
}

/// Extension methods for List<AppNotification>
extension AppNotificationListExtensions on List<AppNotification> {
  /// Group notifications by date
  List<NotificationGroup> groupByDate() {
    if (isEmpty) return [];

    final groups = <DateTime, List<AppNotification>>{};
    
    for (final notification in this) {
      final date = DateTime(
        notification.timestamp.year,
        notification.timestamp.month,
        notification.timestamp.day,
      );
      
      groups.putIfAbsent(date, () => []).add(notification);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    return groups.entries.map((entry) {
      String title;
      if (entry.key.isAtSameMomentAs(today)) {
        title = 'Today';
      } else if (entry.key.isAtSameMomentAs(yesterday)) {
        title = 'Yesterday';
      } else if (now.difference(entry.key).inDays < 7) {
        const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        title = weekdays[entry.key.weekday - 1];
      } else {
        title = '${entry.key.day}/${entry.key.month}/${entry.key.year}';
      }

      // Sort notifications within group by timestamp (newest first)
      final sortedNotifications = entry.value
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return NotificationGroup(
        title: title,
        notifications: sortedNotifications,
        date: entry.key,
      );
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort groups by date (newest first)
  }

  /// Get unread notifications
  List<AppNotification> get unread => where((n) => !n.isRead).toList();

  /// Get notifications by type
  List<AppNotification> ofType(String type) => where((n) => n.type == type).toList();

  /// Get notifications with high priority
  List<AppNotification> get highPriority => 
    where((n) => n.priority == NotificationPriority.high || n.priority == NotificationPriority.urgent).toList();

  /// Get recent notifications (last 24 hours)
  List<AppNotification> get recent {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return where((n) => n.timestamp.isAfter(yesterday)).toList();
  }
}