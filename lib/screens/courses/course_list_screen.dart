// File: lib/screens/courses/course_list_screen.dart
// Purpose: Main course management screen with list, search, and filtering
// Step: 6.1 - Course List and Management Interface

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../config/localization_config.dart';
import '../../services/calendar_service.dart';
import '../../models/course_model.dart';
import '../../models/course_type.dart';
import 'course_detail_screen.dart';
import 'course_edit_screen.dart';

/// Main course management screen with comprehensive course operations
class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  CourseFilterType _selectedFilter = CourseFilterType.all;
  CourseSortType _selectedSort = CourseSortType.name;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: _buildAppBar(context, localizations),
      body: Consumer<CalendarService>(
        builder: (context, calendarService, child) {
          return Column(
            children: [
              _buildSearchAndFilters(context, localizations),
              Expanded(
                child: _buildCourseList(context, calendarService, localizations),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(context, localizations),
    );
  }

  /// Build app bar with title and action buttons
  AppBar _buildAppBar(BuildContext context, AppLocalizations? localizations) {
    return AppBar(
      title: Text(localizations?.courses ?? 'Courses'),
      backgroundColor: ThemeConfig.lightBackground,
      foregroundColor: ThemeConfig.primaryDarkBlue,
      elevation: 0,
      actions: [
        // Search toggle button
        IconButton(
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                _searchQuery = '';
              }
            });
          },
          icon: Icon(_isSearching ? Icons.close : Icons.search),
        ),
        
        // Sort menu
        PopupMenuButton<CourseSortType>(
          onSelected: (sortType) {
            setState(() {
              _selectedSort = sortType;
            });
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: CourseSortType.name,
              child: Row(
                children: [
                  const Icon(Icons.sort_by_alpha, size: 18),
                  const SizedBox(width: 8),
                  const Text('Sort by Name'),
                  if (_selectedSort == CourseSortType.name)
                    const Spacer(),
                  if (_selectedSort == CourseSortType.name)
                    const Icon(Icons.check, size: 16, color: ThemeConfig.goldAccent),
                ],
              ),
            ),
            PopupMenuItem(
              value: CourseSortType.code,
              child: Row(
                children: [
                  const Icon(Icons.code, size: 18),
                  const SizedBox(width: 8),
                  const Text('Sort by Code'),
                  if (_selectedSort == CourseSortType.code)
                    const Spacer(),
                  if (_selectedSort == CourseSortType.code)
                    const Icon(Icons.check, size: 16, color: ThemeConfig.goldAccent),
                ],
              ),
            ),
            PopupMenuItem(
              value: CourseSortType.type,
              child: Row(
                children: [
                  const Icon(Icons.category, size: 18),
                  const SizedBox(width: 8),
                  const Text('Sort by Type'),
                  if (_selectedSort == CourseSortType.type)
                    const Spacer(),
                  if (_selectedSort == CourseSortType.type)
                    const Icon(Icons.check, size: 16, color: ThemeConfig.goldAccent),
                ],
              ),
            ),
            PopupMenuItem(
              value: CourseSortType.credits,
              child: Row(
                children: [
                  const Icon(Icons.school, size: 18),
                  const SizedBox(width: 8),
                  const Text('Sort by Credits'),
                  if (_selectedSort == CourseSortType.credits)
                    const Spacer(),
                  if (_selectedSort == CourseSortType.credits)
                    const Icon(Icons.check, size: 16, color: ThemeConfig.goldAccent),
                ],
              ),
            ),
          ],
          child: const Padding(
            padding: EdgeInsets.all(12.0),
            child: Icon(Icons.sort),
          ),
        ),
      ],
    );
  }

  /// Build search bar and filter chips
  Widget _buildSearchAndFilters(BuildContext context, AppLocalizations? localizations) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: ThemeConfig.lightBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar (only shown when searching)
          if (_isSearching)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: localizations?.getString('searchCourses') ?? 'Search courses...',
                  prefixIcon: const Icon(Icons.search, color: ThemeConfig.primaryDarkBlue),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', CourseFilterType.all, Icons.view_list),
                const SizedBox(width: 8),
                _buildFilterChip('Lectures', CourseFilterType.lecture, Icons.school),
                const SizedBox(width: 8),
                _buildFilterChip('Seminars', CourseFilterType.seminar, Icons.group),
                const SizedBox(width: 8),
                _buildFilterChip('Practicals', CourseFilterType.practical, Icons.science),
                const SizedBox(width: 8),
                _buildFilterChip('Labs', CourseFilterType.laboratory, Icons.biotech),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build filter chip
  Widget _buildFilterChip(String label, CourseFilterType filterType, IconData icon) {
    final isSelected = _selectedFilter == filterType;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, 
            color: isSelected ? Colors.white : ThemeConfig.primaryDarkBlue),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = filterType;
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

  /// Build course list with filtering and sorting
  Widget _buildCourseList(BuildContext context, CalendarService calendarService, AppLocalizations? localizations) {
    final courses = calendarService.courses;
    
    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No courses found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter criteria',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    // Apply search and filter
    var filteredCourses = _applySearchAndFilter(courses);
    
    // Apply sorting
    _applySorting(filteredCourses);

    if (filteredCourses.isEmpty && (_searchQuery.isNotEmpty || _selectedFilter != CourseFilterType.all)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              localizations?.getString('noResultsTitle') ?? 'No Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localizations?.getString('noResultsMessage') ?? 'No courses match your search criteria.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _selectedFilter = CourseFilterType.all;
                });
              },
              child: Text(localizations?.getString('clearFilters') ?? 'Clear Filters'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredCourses.length,
      itemBuilder: (context, index) {
        final course = filteredCourses[index];
        return _buildCourseCard(context, course, calendarService, localizations);
      },
    );
  }

  /// Apply search query and filter to courses list
  List<Course> _applySearchAndFilter(List<Course> courses) {
    var filtered = courses.where((course) {
      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase();
        if (!course.courseName.toLowerCase().contains(searchLower) &&
            !course.courseCode.toLowerCase().contains(searchLower) &&
            !course.classCode.toLowerCase().contains(searchLower) &&
            !course.instructors.any((instructor) => 
              instructor.toLowerCase().contains(searchLower))) {
          return false;
        }
      }

      // Apply type filter
      if (_selectedFilter != CourseFilterType.all) {
        final classTypeLower = course.classType.toLowerCase();
        switch (_selectedFilter) {
          case CourseFilterType.lecture:
            return classTypeLower.contains('előadás') || classTypeLower.contains('ea');
          case CourseFilterType.seminar:
            return classTypeLower.contains('szeminárium');
          case CourseFilterType.practical:
            return classTypeLower.contains('gyakorlat') || classTypeLower.contains('gy');
          case CourseFilterType.laboratory:
            return classTypeLower.contains('labor') || classTypeLower.contains('lb');
          case CourseFilterType.all:
            break;
        }
      }

      return true;
    }).toList();

    debugPrint('🔍 CourseList: Filtered ${courses.length} courses to ${filtered.length} courses');
    return filtered;
  }

  /// Apply sorting to courses list
  void _applySorting(List<Course> courses) {
    switch (_selectedSort) {
      case CourseSortType.name:
        courses.sort((a, b) => a.name.compareTo(b.name));
        break;
      case CourseSortType.code:
        courses.sort((a, b) => a.code.compareTo(b.code));
        break;
      case CourseSortType.type:
        courses.sort((a, b) => CourseType.fromString(a.type)?.displayName.compareTo(CourseType.fromString(b.type)?.displayName ?? '') ?? 0);
        break;
      case CourseSortType.credits:
        courses.sort((a, b) => b.credits.compareTo(a.credits));
        break;
    }
  }

  /// Build individual course card
  Widget _buildCourseCard(BuildContext context, Course course, CalendarService calendarService, AppLocalizations? localizations) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: Colors.white,
      child: InkWell(
        onTap: () => _navigateToCourseDetail(course),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course header with name and type
              Row(
                children: [
                  // Course type indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CourseType.fromString(course.classType)?.color.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      CourseType.fromString(course.classType)?.displayName ?? course.classType,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: CourseType.fromString(course.classType)?.color ?? Colors.grey,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // More options menu
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleCourseAction(value, course, calendarService),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
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
                    child: const Icon(Icons.more_vert, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Course name
              Text(
                course.courseName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ThemeConfig.darkTextElements,
                ),
              ),
              const SizedBox(height: 4),
              
              // Course code
              Text(
                course.courseCode,
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeConfig.darkTextElements.withOpacity(0.7),
                  fontFamily: 'monospace',
                ),
              ),
              
              if (course.instructors.isNotEmpty) ...[
                const SizedBox(height: 8),
                // Instructors
                Row(
                  children: [
                    Icon(Icons.person, size: 16, 
                      color: ThemeConfig.darkTextElements.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        course.instructors.join(', '),
                        style: TextStyle(
                          fontSize: 13,
                          color: ThemeConfig.darkTextElements.withOpacity(0.7),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Schedule preview and statistics
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Schedule count
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, 
                        color: ThemeConfig.darkTextElements.withOpacity(0.6)),
                      const SizedBox(width: 4),
                      Text(
                        '${course.scheduleSlots.length} session${course.scheduleSlots.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeConfig.darkTextElements.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  
                  // Credits
                  Row(
                    children: [
                      Icon(Icons.school, size: 16, 
                        color: ThemeConfig.darkTextElements.withOpacity(0.6)),
                      const SizedBox(width: 4),
                      Text(
                        '${course.credits} credits',
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeConfig.darkTextElements.withOpacity(0.7),
                        ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build floating action button for adding new course
  Widget _buildFloatingActionButton(BuildContext context, AppLocalizations? localizations) {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToCreateCourse(),
      backgroundColor: ThemeConfig.primaryDarkBlue,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: Text(localizations?.getString('addCourse') ?? 'Add Course'),
    );
  }

  /// Handle course action menu selections
  void _handleCourseAction(String action, Course course, CalendarService calendarService) {
    switch (action) {
      case 'edit':
        _navigateToEditCourse(course);
        break;
      case 'delete':
        _showDeleteConfirmation(course, calendarService);
        break;
    }
  }

  /// Navigate to course detail screen
  void _navigateToCourseDetail(Course course) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(course: course),
      ),
    );
  }

  /// Navigate to course edit screen
  void _navigateToEditCourse(Course course) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CourseEditScreen(course: course),
      ),
    );
  }

  /// Navigate to create new course screen
  void _navigateToCreateCourse() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CourseEditScreen(),
      ),
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(Course course, CalendarService calendarService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "${course.courseName}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteCourse(course, calendarService);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Delete course from calendar service
  void _deleteCourse(Course course, CalendarService calendarService) async {
    try {
      await calendarService.deleteCourse(course.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Course "${course.courseName}" deleted'),
          backgroundColor: Colors.red.shade600,
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.white,
            onPressed: () async {
              // Restore the course
              try {
                await calendarService.saveCourse(course);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to restore course: ${e.toString()}'),
                    backgroundColor: Colors.red.shade600,
                  ),
                );
              }
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete course: ${e.toString()}'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }
}

/// Enum for course filtering options
enum CourseFilterType {
  all,
  lecture,
  seminar,
  practical,
  laboratory,
}

/// Enum for course sorting options
enum CourseSortType {
  name,
  code,
  type,
  credits,
}