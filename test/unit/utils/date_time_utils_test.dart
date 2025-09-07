// File: test/unit/utils/date_time_utils_test.dart
// Purpose: Unit tests for DateTimeUtils
// Step: 11.2 - Unit Tests for Core Business Logic

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elte_calendar/utils/date_time_utils.dart';

void main() {
  group('DateTimeUtils Tests', () {
    late DateTime testDate;
    late DateTime testTime;

    setUp(() {
      testDate = DateTime(2024, 12, 25, 14, 30, 0); // Christmas Day 2024, 2:30 PM
      testTime = DateTime(2024, 1, 1, 9, 15, 0); // 9:15 AM
    });

    group('Date Formatting', () {
      test('should format date correctly for Hungarian', () {
        final formatted = DateTimeUtils.formatDate(testDate, 'hu');
        expect(formatted, contains('2024'));
        expect(formatted, contains('12'));
        expect(formatted, contains('25'));
      });

      test('should format date correctly for English', () {
        final formatted = DateTimeUtils.formatDate(testDate, 'en');
        expect(formatted, contains('2024'));
        expect(formatted, contains('Dec'));
        expect(formatted, contains('25'));
      });

      test('should format date correctly for German', () {
        final formatted = DateTimeUtils.formatDate(testDate, 'de');
        expect(formatted, contains('25.12.2024'));
      });

      test('should use fallback format for unknown language', () {
        final formatted = DateTimeUtils.formatDate(testDate, 'fr');
        expect(formatted, isNotEmpty);
        expect(formatted, contains('2024'));
      });
    });

    group('Time Formatting', () {
      test('should format time consistently across languages', () {
        final timeHu = DateTimeUtils.formatTime(testTime, 'hu');
        final timeEn = DateTimeUtils.formatTime(testTime, 'en');
        final timeDe = DateTimeUtils.formatTime(testTime, 'de');

        expect(timeHu, equals('09:15'));
        expect(timeEn, equals('09:15'));
        expect(timeDe, equals('09:15'));
      });

      test('should format time with correct padding', () {
        final earlyTime = DateTime(2024, 1, 1, 5, 5, 0);
        final formatted = DateTimeUtils.formatTime(earlyTime, 'en');
        expect(formatted, equals('05:05'));
      });
    });

    group('DateTime Formatting', () {
      test('should combine date and time correctly', () {
        final formatted = DateTimeUtils.formatDateTime(testDate, 'en');
        expect(formatted, contains('Dec 25, 2024'));
        expect(formatted, contains('14:30'));
      });
    });

    group('Day Name Formatting', () {
      test('should format day names correctly for Hungarian', () {
        final monday = DateTime(2024, 12, 23); // Monday
        
        final fullName = DateTimeUtils.formatDayName(monday, 'hu', abbreviated: false);
        final abbrevName = DateTimeUtils.formatDayName(monday, 'hu', abbreviated: true);
        
        expect(fullName, isNotEmpty);
        expect(abbrevName, isNotEmpty);
        expect(abbrevName.length, lessThan(fullName.length));
      });

      test('should format day names correctly for English', () {
        final monday = DateTime(2024, 12, 23); // Monday
        
        final fullName = DateTimeUtils.formatDayName(monday, 'en', abbreviated: false);
        final abbrevName = DateTimeUtils.formatDayName(monday, 'en', abbreviated: true);
        
        expect(fullName, isNotEmpty);
        expect(abbrevName, isNotEmpty);
        expect(abbrevName.length, lessThan(fullName.length));
      });
    });

    group('Month Name Formatting', () {
      test('should format month names correctly', () {
        final december = DateTime(2024, 12, 1);
        
        final fullHu = DateTimeUtils.formatMonthName(december, 'hu', abbreviated: false);
        final abbrevHu = DateTimeUtils.formatMonthName(december, 'hu', abbreviated: true);
        
        expect(fullHu, isNotEmpty);
        expect(abbrevHu, isNotEmpty);
        expect(abbrevHu.length, lessThan(fullHu.length));
      });
    });

    group('Time Range Formatting', () {
      test('should format time range correctly', () {
        const startTime = TimeOfDay(hour: 9, minute: 0);
        const endTime = TimeOfDay(hour: 10, minute: 30);
        
        final formatted = DateTimeUtils.formatTimeRange(startTime, endTime, 'en');
        expect(formatted, contains('09:00'));
        expect(formatted, contains('10:30'));
        expect(formatted, contains('-'));
      });

      test('should format time range with different languages', () {
        const startTime = TimeOfDay(hour: 14, minute: 15);
        const endTime = TimeOfDay(hour: 15, minute: 45);
        
        final formattedHu = DateTimeUtils.formatTimeRange(startTime, endTime, 'hu');
        final formattedEn = DateTimeUtils.formatTimeRange(startTime, endTime, 'en');
        final formattedDe = DateTimeUtils.formatTimeRange(startTime, endTime, 'de');
        
        // Should be the same format for all languages (24-hour)
        expect(formattedHu, equals(formattedEn));
        expect(formattedEn, equals(formattedDe));
        expect(formattedHu, contains('14:15 - 15:45'));
      });
    });

    group('Duration Formatting', () {
      test('should format duration with hours and minutes in Hungarian', () {
        const duration = Duration(hours: 2, minutes: 30);
        final formatted = DateTimeUtils.formatDuration(duration, 'hu');
        
        expect(formatted, contains('2'));
        expect(formatted, contains('30'));
        expect(formatted, contains('óra'));
        expect(formatted, contains('perc'));
      });

      test('should format duration with hours and minutes in English', () {
        const duration = Duration(hours: 2, minutes: 30);
        final formatted = DateTimeUtils.formatDuration(duration, 'en');
        
        expect(formatted, contains('2'));
        expect(formatted, contains('30'));
        expect(formatted, contains('hours'));
        expect(formatted, contains('minutes'));
      });

      test('should format duration with hours and minutes in German', () {
        const duration = Duration(hours: 2, minutes: 30);
        final formatted = DateTimeUtils.formatDuration(duration, 'de');
        
        expect(formatted, contains('2'));
        expect(formatted, contains('30'));
        expect(formatted, contains('Stunden'));
        expect(formatted, contains('Minuten'));
      });

      test('should format duration with only hours', () {
        const duration = Duration(hours: 3);
        final formattedHu = DateTimeUtils.formatDuration(duration, 'hu');
        final formattedEn = DateTimeUtils.formatDuration(duration, 'en');
        final formattedDe = DateTimeUtils.formatDuration(duration, 'de');
        
        expect(formattedHu, contains('3 óra'));
        expect(formattedEn, contains('3 hours'));
        expect(formattedDe, contains('3 Stunden'));
      });

      test('should format duration with only minutes', () {
        const duration = Duration(minutes: 45);
        final formattedHu = DateTimeUtils.formatDuration(duration, 'hu');
        final formattedEn = DateTimeUtils.formatDuration(duration, 'en');
        final formattedDe = DateTimeUtils.formatDuration(duration, 'de');
        
        expect(formattedHu, contains('45 perc'));
        expect(formattedEn, contains('45 minutes'));
        expect(formattedDe, contains('45 Minuten'));
      });

      test('should handle singular forms correctly', () {
        const duration = Duration(hours: 1, minutes: 1);
        final formattedEn = DateTimeUtils.formatDuration(duration, 'en');
        
        expect(formattedEn, contains('1 hour'));
        expect(formattedEn, contains('1 minute'));
      });
    });

    group('Date Comparison Utilities', () {
      test('should correctly identify today', () {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day, 15, 30);
        
        expect(DateTimeUtils.isToday(today), isTrue);
        expect(DateTimeUtils.isToday(now), isTrue);
      });

      test('should correctly identify tomorrow', () {
        final now = DateTime.now();
        final tomorrow = now.add(const Duration(days: 1));
        final tomorrowSameTime = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0);
        
        expect(DateTimeUtils.isTomorrow(tomorrowSameTime), isTrue);
        expect(DateTimeUtils.isTomorrow(now), isFalse);
      });

      test('should correctly identify yesterday', () {
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final yesterdaySameTime = DateTime(yesterday.year, yesterday.month, yesterday.day, 16, 45);
        
        expect(DateTimeUtils.isYesterday(yesterdaySameTime), isTrue);
        expect(DateTimeUtils.isYesterday(now), isFalse);
      });
    });

    group('Today/Tomorrow/Yesterday Strings', () {
      test('should return correct strings for Hungarian', () {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));
        final yesterday = today.subtract(const Duration(days: 1));
        
        expect(DateTimeUtils.getTodayTomorrowYesterday(today, 'hu'), equals('ma'));
        expect(DateTimeUtils.getTodayTomorrowYesterday(tomorrow, 'hu'), equals('holnap'));
        expect(DateTimeUtils.getTodayTomorrowYesterday(yesterday, 'hu'), equals('tegnap'));
      });

      test('should return correct strings for English', () {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));
        final yesterday = today.subtract(const Duration(days: 1));
        
        expect(DateTimeUtils.getTodayTomorrowYesterday(today, 'en'), equals('today'));
        expect(DateTimeUtils.getTodayTomorrowYesterday(tomorrow, 'en'), equals('tomorrow'));
        expect(DateTimeUtils.getTodayTomorrowYesterday(yesterday, 'en'), equals('yesterday'));
      });

      test('should return correct strings for German', () {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));
        final yesterday = today.subtract(const Duration(days: 1));
        
        expect(DateTimeUtils.getTodayTomorrowYesterday(today, 'de'), equals('heute'));
        expect(DateTimeUtils.getTodayTomorrowYesterday(tomorrow, 'de'), equals('morgen'));
        expect(DateTimeUtils.getTodayTomorrowYesterday(yesterday, 'de'), equals('gestern'));
      });

      test('should return formatted date for other dates', () {
        final pastDate = DateTime(2024, 1, 1);
        final result = DateTimeUtils.getTodayTomorrowYesterday(pastDate, 'en');
        
        expect(result, isNot('today'));
        expect(result, isNot('tomorrow'));
        expect(result, isNot('yesterday'));
        expect(result, contains('2024')); // Should be a formatted date
      });
    });

    group('Relative Time Formatting', () {
      late DateTime now;

      setUp(() {
        now = DateTime.now();
      });

      test('should format past time correctly in Hungarian', () {
        final twoHoursAgo = now.subtract(const Duration(hours: 2));
        final result = DateTimeUtils.formatRelativeTime(twoHoursAgo, 'hu');
        
        expect(result, contains('2'));
        expect(result, contains('órája'));
      });

      test('should format future time correctly in Hungarian', () {
        final inThreeHours = now.add(const Duration(hours: 3));
        final result = DateTimeUtils.formatRelativeTime(inThreeHours, 'hu');
        
        expect(result, contains('3'));
        expect(result, contains('óra múlva'));
      });

      test('should format past time correctly in English', () {
        final thirtyMinutesAgo = now.subtract(const Duration(minutes: 30));
        final result = DateTimeUtils.formatRelativeTime(thirtyMinutesAgo, 'en');
        
        expect(result, contains('30'));
        expect(result, contains('minutes ago'));
      });

      test('should format future time correctly in English', () {
        final inFortyFiveMinutes = now.add(const Duration(minutes: 45));
        final result = DateTimeUtils.formatRelativeTime(inFortyFiveMinutes, 'en');
        
        expect(result, contains('45'));
        expect(result, contains('minutes'));
      });

      test('should handle just now correctly', () {
        final justNow = now.subtract(const Duration(seconds: 30));
        
        final resultHu = DateTimeUtils.formatRelativeTime(justNow, 'hu');
        final resultEn = DateTimeUtils.formatRelativeTime(justNow, 'en');
        final resultDe = DateTimeUtils.formatRelativeTime(justNow, 'de');
        
        expect(resultHu, equals('most'));
        expect(resultEn, equals('just now'));
        expect(resultDe, equals('gerade eben'));
      });

      test('should format days correctly', () {
        final threeDaysAgo = now.subtract(const Duration(days: 3));
        final inFiveDays = now.add(const Duration(days: 5));
        
        final pastResultEn = DateTimeUtils.formatRelativeTime(threeDaysAgo, 'en');
        final futureResultEn = DateTimeUtils.formatRelativeTime(inFiveDays, 'en');
        
        expect(pastResultEn, contains('3 days ago'));
        expect(futureResultEn, contains('in 5 days'));
      });

      test('should fall back to date format for distant dates', () {
        final longAgo = now.subtract(const Duration(days: 60));
        final result = DateTimeUtils.formatRelativeTime(longAgo, 'en');
        
        // Should be a formatted date, not relative time
        expect(result, isNot(contains('days ago')));
        expect(result, isNotEmpty);
      });
    });

    group('Edge Cases', () {
      test('should handle null and edge cases gracefully', () {
        final midnight = DateTime(2024, 1, 1, 0, 0, 0);
        expect(DateTimeUtils.formatTime(midnight, 'en'), equals('00:00'));
        
        final noon = DateTime(2024, 1, 1, 12, 0, 0);
        expect(DateTimeUtils.formatTime(noon, 'en'), equals('12:00'));
      });

      test('should handle zero duration', () {
        const zeroDuration = Duration();
        final result = DateTimeUtils.formatDuration(zeroDuration, 'en');
        expect(result, equals('0 minutes'));
      });

      test('should handle very short duration', () {
        const shortDuration = Duration(minutes: 1);
        final resultEn = DateTimeUtils.formatDuration(shortDuration, 'en');
        expect(resultEn, equals('1 minute')); // Singular form
      });
    });
  });
}