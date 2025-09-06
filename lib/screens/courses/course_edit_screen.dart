// File: lib/screens/courses/course_edit_screen.dart
// Purpose: Course creation and editing interface with comprehensive form validation
// Step: 6.3 - Course Creation and Editing Implementation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../config/localization_config.dart';
import '../../models/course_model.dart';
import '../../services/calendar_service.dart';
import '../../services/semester_service.dart';

/// Course creation and editing screen with comprehensive form
class CourseEditScreen extends StatefulWidget {
  final Course? course; // null for creating new course

  const CourseEditScreen({
    super.key,
    this.course,
  });

  @override
  State<CourseEditScreen> createState() => _CourseEditScreenState();
}

class _CourseEditScreenState extends State<CourseEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _creditsController;
  late TextEditingController _descriptionController;
  
  // Form state
  CourseType _selectedType = CourseType.lecture;
  List<String> _instructors = [];
  List<ScheduleSlot> _scheduleSlots = [];
  bool _isLoading = false;

  // Instructor management
  final TextEditingController _instructorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadExistingCourseData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _creditsController.dispose();
    _descriptionController.dispose();
    _instructorController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _codeController = TextEditingController();
    _creditsController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  void _loadExistingCourseData() {
    if (widget.course != null) {
      final course = widget.course!;
      _nameController.text = course.name;
      _codeController.text = course.code;
      _creditsController.text = course.credits?.toString() ?? '';
      _descriptionController.text = course.description ?? '';
      _selectedType = course.type;
      _instructors = List.from(course.instructors);
      _scheduleSlots = List.from(course.scheduleSlots);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isEditing = widget.course != null;
    
    return Scaffold(
      appBar: _buildAppBar(context, localizations, isEditing),
      body: _buildBody(context, localizations),
      bottomNavigationBar: _buildBottomActions(context, localizations, isEditing),
    );
  }

  /// Build app bar
  AppBar _buildAppBar(BuildContext context, AppLocalizations? localizations, bool isEditing) {
    return AppBar(
      title: Text(
        isEditing 
          ? (localizations?.getString('editCourse') ?? 'Edit Course')
          : (localizations?.getString('createCourse') ?? 'Create Course'),
      ),
      backgroundColor: ThemeConfig.lightBackground,
      foregroundColor: ThemeConfig.primaryDarkBlue,
      elevation: 0,
      actions: [
        if (isEditing)
          IconButton(
            onPressed: _showDeleteConfirmation,
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
      ],
    );
  }

  /// Build main body content
  Widget _buildBody(BuildContext context, AppLocalizations? localizations) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoSection(localizations),
            const SizedBox(height: 32),
            _buildCourseTypeSection(localizations),
            const SizedBox(height: 32),
            _buildInstructorsSection(localizations),
            const SizedBox(height: 32),
            _buildScheduleSection(localizations),
            const SizedBox(height: 32),
            _buildDescriptionSection(localizations),
            const SizedBox(height: 100), // Space for bottom actions
          ],
        ),
      ),
    );
  }

  /// Build basic information section
  Widget _buildBasicInfoSection(AppLocalizations? localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations?.getString('basicInformation') ?? 'Basic Information',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ThemeConfig.darkTextElements,
          ),
        ),
        const SizedBox(height: 16),
        
        // Course name
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: localizations?.getString('courseName') ?? 'Course Name',
            hintText: 'Enter course name',
            prefixIcon: const Icon(Icons.school),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Course name is required';
            }
            if (value.trim().length < 3) {
              return 'Course name must be at least 3 characters';
            }
            return null;
          },
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        
        // Course code and credits row
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: localizations?.getString('courseCode') ?? 'Course Code',
                  hintText: 'e.g., CS101',
                  prefixIcon: const Icon(Icons.code),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Course code is required';
                  }
                  // Basic course code format validation
                  if (!RegExp(r'^[A-Za-z0-9-]+$').hasMatch(value.trim())) {
                    return 'Invalid course code format';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _creditsController,
                decoration: InputDecoration(
                  labelText: localizations?.getString('credits') ?? 'Credits',
                  hintText: '3',
                  prefixIcon: const Icon(Icons.star),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final credits = int.tryParse(value.trim());
                    if (credits == null || credits < 0 || credits > 20) {
                      return 'Invalid credits (0-20)';
                    }
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build course type selection section
  Widget _buildCourseTypeSection(AppLocalizations? localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations?.getString('courseType') ?? 'Course Type',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ThemeConfig.darkTextElements,
          ),
        ),
        const SizedBox(height: 16),
        
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: CourseType.values.map((type) {
            final isSelected = _selectedType == type;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedType = type;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? type.color : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? type.color : Colors.grey.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: type.color.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      type.icon,
                      color: isSelected ? Colors.white : type.color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type.displayName,
                      style: TextStyle(
                        color: isSelected ? Colors.white : type.color,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build instructors management section
  Widget _buildInstructorsSection(AppLocalizations? localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations?.getString('instructors') ?? 'Instructors',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ThemeConfig.darkTextElements,
          ),
        ),
        const SizedBox(height: 16),
        
        // Add instructor field
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _instructorController,
                decoration: InputDecoration(
                  hintText: localizations?.getString('addInstructor') ?? 'Add instructor',
                  prefixIcon: const Icon(Icons.person_add),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: _addInstructor,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _addInstructor(_instructorController.text),
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: ThemeConfig.primaryDarkBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Instructors list
        if (_instructors.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _instructors.map((instructor) {
              return Chip(
                label: Text(instructor),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removeInstructor(instructor),
                backgroundColor: ThemeConfig.primaryDarkBlue.withOpacity(0.1),
                labelStyle: const TextStyle(
                  color: ThemeConfig.primaryDarkBlue,
                ),
              );
            }).toList(),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
            child: Text(
              localizations?.getString('noInstructorsAdded') ?? 'No instructors added',
              style: TextStyle(
                color: Colors.grey.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  /// Build schedule management section
  Widget _buildScheduleSection(AppLocalizations? localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              localizations?.getString('schedule') ?? 'Schedule',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ThemeConfig.darkTextElements,
              ),
            ),
            TextButton.icon(
              onPressed: _addScheduleSlot,
              icon: const Icon(Icons.add, size: 18),
              label: Text(localizations?.getString('addSession') ?? 'Add Session'),
              style: TextButton.styleFrom(
                foregroundColor: ThemeConfig.primaryDarkBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Schedule slots list
        if (_scheduleSlots.isNotEmpty)
          Column(
            children: _scheduleSlots.asMap().entries.map((entry) {
              final index = entry.key;
              final slot = entry.value;
              return _buildScheduleSlotCard(slot, index, localizations);
            }).toList(),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: 48,
                  color: Colors.grey.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  localizations?.getString('noScheduleAdded') ?? 'No schedule added',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localizations?.getString('addScheduleMessage') ?? 
                    'Add schedule sessions to define when this course takes place.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Build schedule slot card
  Widget _buildScheduleSlotCard(ScheduleSlot slot, int index, AppLocalizations? localizations) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Day indicator
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: _selectedType.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getDayAbbreviation(slot.dayOfWeek),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _selectedType.color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 16),
            
            // Time and location info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${slot.startTime.format(context)} - ${slot.endTime.format(context)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ThemeConfig.darkTextElements,
                    ),
                  ),
                  if (slot.location.isNotEmpty)
                    Text(
                      slot.location,
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeConfig.darkTextElements.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),
            
            // Edit and delete buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _editScheduleSlot(index),
                  icon: const Icon(Icons.edit, size: 18),
                  style: IconButton.styleFrom(
                    foregroundColor: ThemeConfig.primaryDarkBlue,
                  ),
                ),
                IconButton(
                  onPressed: () => _removeScheduleSlot(index),
                  icon: const Icon(Icons.delete, size: 18),
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build course description section
  Widget _buildDescriptionSection(AppLocalizations? localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations?.getString('description') ?? 'Description',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ThemeConfig.darkTextElements,
          ),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            hintText: localizations?.getString('courseDescriptionHint') ?? 
              'Enter course description (optional)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            alignLabelWithHint: true,
          ),
          maxLines: 4,
          maxLength: 500,
        ),
      ],
    );
  }

  /// Build bottom action buttons
  Widget _buildBottomActions(BuildContext context, AppLocalizations? localizations, bool isEditing) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: ThemeConfig.primaryDarkBlue),
              ),
              child: Text(
                localizations?.getString('cancel') ?? 'Cancel',
                style: const TextStyle(color: ThemeConfig.primaryDarkBlue),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveCourse,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConfig.primaryDarkBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    isEditing 
                      ? (localizations?.getString('updateCourse') ?? 'Update Course')
                      : (localizations?.getString('createCourse') ?? 'Create Course'),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  /// Add instructor to list
  void _addInstructor(String instructor) {
    final trimmed = instructor.trim();
    if (trimmed.isNotEmpty && !_instructors.contains(trimmed)) {
      setState(() {
        _instructors.add(trimmed);
        _instructorController.clear();
      });
    }
  }

  /// Remove instructor from list
  void _removeInstructor(String instructor) {
    setState(() {
      _instructors.remove(instructor);
    });
  }

  /// Add new schedule slot
  void _addScheduleSlot() {
    _showScheduleSlotDialog();
  }

  /// Edit existing schedule slot
  void _editScheduleSlot(int index) {
    _showScheduleSlotDialog(_scheduleSlots[index], index);
  }

  /// Remove schedule slot
  void _removeScheduleSlot(int index) {
    setState(() {
      _scheduleSlots.removeAt(index);
    });
  }

  /// Show schedule slot creation/editing dialog
  void _showScheduleSlotDialog([ScheduleSlot? existingSlot, int? index]) {
    showDialog(
      context: context,
      builder: (context) => ScheduleSlotDialog(
        existingSlot: existingSlot,
        onSave: (slot) {
          setState(() {
            if (index != null) {
              _scheduleSlots[index] = slot;
            } else {
              _scheduleSlots.add(slot);
            }
          });
        },
      ),
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "${widget.course?.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close edit screen
              // TODO: Implement course deletion
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Save course
  void _saveCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create course object
      final course = Course(
        id: widget.course?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
        type: _selectedType,
        instructors: _instructors,
        scheduleSlots: _scheduleSlots,
        credits: _creditsController.text.trim().isNotEmpty 
          ? int.parse(_creditsController.text.trim()) 
          : null,
        description: _descriptionController.text.trim().isNotEmpty 
          ? _descriptionController.text.trim() 
          : null,
        semester: context.read<SemesterService>().currentSemester?.id,
      );

      // Save using calendar service
      final calendarService = context.read<CalendarService>();
      await calendarService.saveCourse(course);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.course != null 
            ? 'Course updated successfully!' 
            : 'Course created successfully!'),
          backgroundColor: Colors.green.shade600,
        ),
      );

      // Return to previous screen
      Navigator.of(context).pop();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save course: ${e.toString()}'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Get day abbreviation from day of week
  String _getDayAbbreviation(int dayOfWeek) {
    const abbreviations = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return abbreviations[dayOfWeek - 1];
  }
}

/// Dialog for creating/editing schedule slots
class ScheduleSlotDialog extends StatefulWidget {
  final ScheduleSlot? existingSlot;
  final Function(ScheduleSlot) onSave;

  const ScheduleSlotDialog({
    super.key,
    this.existingSlot,
    required this.onSave,
  });

  @override
  State<ScheduleSlotDialog> createState() => _ScheduleSlotDialogState();
}

class _ScheduleSlotDialogState extends State<ScheduleSlotDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _locationController;

  int _selectedDay = 1; // Monday
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 30);

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController();
    
    if (widget.existingSlot != null) {
      _selectedDay = widget.existingSlot!.dayOfWeek;
      _startTime = widget.existingSlot!.startTime;
      _endTime = widget.existingSlot!.endTime;
      _locationController.text = widget.existingSlot!.location ?? '';
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingSlot != null ? 'Edit Schedule' : 'Add Schedule'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Day selection
            DropdownButtonFormField<int>(
              value: _selectedDay,
              decoration: const InputDecoration(
                labelText: 'Day of Week',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Monday')),
                DropdownMenuItem(value: 2, child: Text('Tuesday')),
                DropdownMenuItem(value: 3, child: Text('Wednesday')),
                DropdownMenuItem(value: 4, child: Text('Thursday')),
                DropdownMenuItem(value: 5, child: Text('Friday')),
                DropdownMenuItem(value: 6, child: Text('Saturday')),
                DropdownMenuItem(value: 7, child: Text('Sunday')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedDay = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Time selection
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start Time',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_startTime.format(context)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'End Time',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_endTime.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location (optional)',
                hintText: 'e.g., Room 101, Building A',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveScheduleSlot,
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeConfig.primaryDarkBlue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  /// Select time
  void _selectTime(bool isStartTime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    
    if (time != null) {
      setState(() {
        if (isStartTime) {
          _startTime = time;
          // Ensure end time is after start time
          if (_endTime.hour * 60 + _endTime.minute <= _startTime.hour * 60 + _startTime.minute) {
            _endTime = TimeOfDay(
              hour: _startTime.hour + 1,
              minute: _startTime.minute,
            );
          }
        } else {
          _endTime = time;
        }
      });
    }
  }

  /// Save schedule slot
  void _saveScheduleSlot() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate time order
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    
    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final slot = ScheduleSlot(
      dayOfWeek: _selectedDay,
      startTime: _startTime,
      endTime: _endTime,
      location: _locationController.text.trim().isNotEmpty 
        ? _locationController.text.trim() 
        : null,
    );

    widget.onSave(slot);
    Navigator.of(context).pop();
  }
}