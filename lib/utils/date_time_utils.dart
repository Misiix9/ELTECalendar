// File: lib/utils/date_time_utils.dart
// Purpose: Locale-aware date and time formatting utilities
// Step: 10.6 - Locale-aware Date and Time Formatting

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utility class for formatting dates and times based on current locale
class DateTimeUtils {
  
  /// Format date according to locale
  static String formatDate(DateTime date, String languageCode) {
    switch (languageCode) {
      case 'hu':
        return DateFormat('yyyy. MM. dd.', 'hu').format(date);
      case 'en':
        return DateFormat('MMM d, yyyy', 'en').format(date);
      case 'de':
        return DateFormat('dd.MM.yyyy', 'de').format(date);
      default:
        return DateFormat.yMMMd().format(date);
    }
  }
  
  /// Format time according to locale (24-hour format)
  static String formatTime(DateTime time, String languageCode) {
    return DateFormat('HH:mm').format(time); // 24-hour format is universal
  }
  
  /// Format date and time together
  static String formatDateTime(DateTime dateTime, String languageCode) {
    return '${formatDate(dateTime, languageCode)} ${formatTime(dateTime, languageCode)}';
  }
  
  /// Format day name according to locale
  static String formatDayName(DateTime date, String languageCode, {bool abbreviated = false}) {
    switch (languageCode) {
      case 'hu':
        return abbreviated 
          ? DateFormat('E', 'hu').format(date)
          : DateFormat('EEEE', 'hu').format(date);
      case 'en':
        return abbreviated 
          ? DateFormat('E', 'en').format(date)
          : DateFormat('EEEE', 'en').format(date);
      case 'de':
        return abbreviated 
          ? DateFormat('E', 'de').format(date)
          : DateFormat('EEEE', 'de').format(date);
      default:
        return abbreviated 
          ? DateFormat.E().format(date)
          : DateFormat.EEEE().format(date);
    }
  }
  
  /// Format month name according to locale
  static String formatMonthName(DateTime date, String languageCode, {bool abbreviated = false}) {
    switch (languageCode) {
      case 'hu':
        return abbreviated 
          ? DateFormat('MMM', 'hu').format(date)
          : DateFormat('MMMM', 'hu').format(date);
      case 'en':
        return abbreviated 
          ? DateFormat('MMM', 'en').format(date)
          : DateFormat('MMMM', 'en').format(date);
      case 'de':
        return abbreviated 
          ? DateFormat('MMM', 'de').format(date)
          : DateFormat('MMMM', 'de').format(date);
      default:
        return abbreviated 
          ? DateFormat.MMM().format(date)
          : DateFormat.MMMM().format(date);
    }
  }
  
  /// Format relative time (e.g., "2 hours ago", "in 3 days")
  static String formatRelativeTime(DateTime dateTime, String languageCode) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.isNegative) {
      // Past time
      final absDifference = difference.abs();
      
      if (absDifference.inMinutes < 1) {
        return _getLocalizedString(languageCode, 'justNow', 'just now');
      } else if (absDifference.inHours < 1) {
        final minutes = absDifference.inMinutes;
        return _getLocalizedString(languageCode, 'minutesAgo', '$minutes minutes ago')
            .replaceAll('{minutes}', minutes.toString());
      } else if (absDifference.inDays < 1) {
        final hours = absDifference.inHours;
        return _getLocalizedString(languageCode, 'hoursAgo', '$hours hours ago')
            .replaceAll('{hours}', hours.toString());
      } else if (absDifference.inDays < 30) {
        final days = absDifference.inDays;
        return _getLocalizedString(languageCode, 'daysAgo', '$days days ago')
            .replaceAll('{days}', days.toString());
      } else {
        return formatDate(dateTime, languageCode);
      }
    } else {
      // Future time
      if (difference.inMinutes < 1) {
        return _getLocalizedString(languageCode, 'now', 'now');
      } else if (difference.inHours < 1) {
        final minutes = difference.inMinutes;
        return _getLocalizedString(languageCode, 'inMinutes', 'in $minutes minutes')
            .replaceAll('{minutes}', minutes.toString());
      } else if (difference.inDays < 1) {
        final hours = difference.inHours;
        return _getLocalizedString(languageCode, 'inHours', 'in $hours hours')
            .replaceAll('{hours}', hours.toString());
      } else if (difference.inDays < 30) {
        final days = difference.inDays;
        return _getLocalizedString(languageCode, 'inDays', 'in $days days')
            .replaceAll('{days}', days.toString());
      } else {
        return formatDate(dateTime, languageCode);
      }
    }
  }
  
  /// Get localized strings for relative time formatting
  static String _getLocalizedString(String languageCode, String key, String fallback) {
    const Map<String, Map<String, String>> relativeTimeStrings = {
      'hu': {
        'justNow': 'most',
        'minutesAgo': '{minutes} perce',
        'hoursAgo': '{hours} órája',
        'daysAgo': '{days} napja',
        'now': 'most',
        'inMinutes': '{minutes} perc múlva',
        'inHours': '{hours} óra múlva',
        'inDays': '{days} nap múlva',
      },
      'en': {
        'justNow': 'just now',
        'minutesAgo': '{minutes} minutes ago',
        'hoursAgo': '{hours} hours ago',
        'daysAgo': '{days} days ago',
        'now': 'now',
        'inMinutes': 'in {minutes} minutes',
        'inHours': 'in {hours} hours',
        'inDays': 'in {days} days',
      },
      'de': {
        'justNow': 'gerade eben',
        'minutesAgo': 'vor {minutes} Minuten',
        'hoursAgo': 'vor {hours} Stunden',
        'daysAgo': 'vor {days} Tagen',
        'now': 'jetzt',
        'inMinutes': 'in {minutes} Minuten',
        'inHours': 'in {hours} Stunden',
        'inDays': 'in {days} Tagen',
      },
    };
    
    return relativeTimeStrings[languageCode]?[key] ?? fallback;
  }
  
  /// Format time range (e.g., "9:00 - 10:30")
  static String formatTimeRange(TimeOfDay startTime, TimeOfDay endTime, String languageCode) {
    final start = DateTime(2000, 1, 1, startTime.hour, startTime.minute);
    final end = DateTime(2000, 1, 1, endTime.hour, endTime.minute);
    
    return '${formatTime(start, languageCode)} - ${formatTime(end, languageCode)}';
  }
  
  /// Format duration (e.g., "2 hours 30 minutes")
  static String formatDuration(Duration duration, String languageCode) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0 && minutes > 0) {
      switch (languageCode) {
        case 'hu':
          return '$hours óra $minutes perc';
        case 'en':
          return '$hours ${hours == 1 ? 'hour' : 'hours'} $minutes ${minutes == 1 ? 'minute' : 'minutes'}';
        case 'de':
          return '$hours ${hours == 1 ? 'Stunde' : 'Stunden'} $minutes ${minutes == 1 ? 'Minute' : 'Minuten'}';
        default:
          return '$hours:${minutes.toString().padLeft(2, '0')}';
      }
    } else if (hours > 0) {
      switch (languageCode) {
        case 'hu':
          return '$hours óra';
        case 'en':
          return '$hours ${hours == 1 ? 'hour' : 'hours'}';
        case 'de':
          return '$hours ${hours == 1 ? 'Stunde' : 'Stunden'}';
        default:
          return '$hours:00';
      }
    } else {
      switch (languageCode) {
        case 'hu':
          return '$minutes perc';
        case 'en':
          return '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
        case 'de':
          return '$minutes ${minutes == 1 ? 'Minute' : 'Minuten'}';
        default:
          return '0:${minutes.toString().padLeft(2, '0')}';
      }
    }
  }
  
  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  
  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }
  
  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }
  
  /// Get localized "today", "tomorrow", "yesterday" strings
  static String getTodayTomorrowYesterday(DateTime date, String languageCode) {
    if (isToday(date)) {
      switch (languageCode) {
        case 'hu': return 'ma';
        case 'en': return 'today';
        case 'de': return 'heute';
        default: return 'today';
      }
    } else if (isTomorrow(date)) {
      switch (languageCode) {
        case 'hu': return 'holnap';
        case 'en': return 'tomorrow';
        case 'de': return 'morgen';
        default: return 'tomorrow';
      }
    } else if (isYesterday(date)) {
      switch (languageCode) {
        case 'hu': return 'tegnap';
        case 'en': return 'yesterday';
        case 'de': return 'gestern';
        default: return 'yesterday';
      }
    } else {
      return formatDate(date, languageCode);
    }
  }
}