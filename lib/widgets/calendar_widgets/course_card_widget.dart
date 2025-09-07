// File: lib/widgets/calendar_widgets/course_card_widget.dart
// Purpose: Reusable course card widget for calendar views
// Step: 4.5 - Course Card Widget Implementation

import 'package:flutter/material.dart';
import '../../models/course_model.dart';
import '../../config/theme_config.dart';

/// Reusable course card widget for displaying course information
class CourseCard extends StatelessWidget {
  final Course course;
  final ScheduleSlot? slot;
  final bool isCompact;
  final bool isCurrentClass;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.course,
    this.slot,
    this.isCompact = false,
    this.isCurrentClass = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isCompact ? 8 : 12),
        decoration: BoxDecoration(
          color: isCurrentClass 
              ? course.displayColor.withOpacity(0.9)
              : course.displayColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(isCompact ? 6 : 12),
          border: isCurrentClass
              ? Border.all(color: Colors.white, width: 2)
              : null,
          boxShadow: isCurrentClass
              ? [
                  BoxShadow(
                    color: course.displayColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isCompact) {
      return _buildCompactContent();
    } else {
      return _buildFullContent();
    }
  }

  Widget _buildCompactContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Course name
        Text(
          course.courseName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        if (slot != null) ...[
          const SizedBox(height: 2),
          
          // Time
          Text(
            slot!.timeRange,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFullContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Course name and type
        Row(
          children: [
            Expanded(
              child: Text(
                course.courseName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Course type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                course.classType,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Course code
        Text(
          course.courseCode,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        if (slot != null) ...[
          const SizedBox(height: 4),
          
          // Time and location
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: Colors.white.withOpacity(0.8),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                slot!.timeRange,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
              
              if (slot!.location.isNotEmpty) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.location_on,
                  color: Colors.white.withOpacity(0.8),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    slot!.location,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
        
        // Instructors
        if (course.instructors.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.white.withOpacity(0.8),
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  course.formattedInstructors,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
        
        // Current class indicator
        if (isCurrentClass) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'CURRENT CLASS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Course summary card for overview displays
class CourseSummaryCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;
  final bool showSchedule;

  const CourseSummaryCard({
    super.key,
    required this.course,
    this.onTap,
    this.showSchedule = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: course.displayColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with color indicator
              Row(
                children: [
                  // Color indicator
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: course.displayColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Course info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Course name
                        Text(
                          course.courseName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ThemeConfig.darkTextElements,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Course details
                        Text(
                          '${course.courseCode} • ${course.classType}',
                          style: TextStyle(
                            fontSize: 12,
                            color: ThemeConfig.darkTextElements.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Weekly hours badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: course.displayColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${course.weeklyHours}h/week',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: course.displayColor,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Schedule information
              if (showSchedule && course.scheduleSlots.isNotEmpty) ...[
                const SizedBox(height: 12),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: course.scheduleSlots.map((slot) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        '${slot.dayNameHu} ${slot.timeRange}',
                        style: TextStyle(
                          fontSize: 11,
                          color: ThemeConfig.darkTextElements.withOpacity(0.7),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              
              // Instructors
              if (course.instructors.isNotEmpty) ...[
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: ThemeConfig.darkTextElements.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        course.formattedInstructors,
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeConfig.darkTextElements.withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}