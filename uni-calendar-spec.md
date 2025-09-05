# University Calendar App - Complete Technical Specification

## Project Overview
Create a cross-platform university calendar application using Flutter/Dart with Firebase backend that allows students to import their course schedules from Excel files (.xlsx) and view them in an interactive calendar interface.

## Technology Stack
- **Frontend**: Flutter/Dart (Web & Mobile)
- **Backend**: Firebase
  - Authentication (Email, Google, Apple Sign-in)
  - Firestore (Database)
  - Firebase Storage (File uploads)
- **Platform Support**: Web browsers, iOS, Android
- **State Management**: Choose appropriate solution (Provider/Riverpod/Bloc/GetX)
- **Localization**: Hungarian (default), English, German

## Design Specifications

### Color Palette (Use ONLY these colors)
- Primary Dark Blue: `#03284F`
- Gold Accent: `#C6A882`
- Light Background: `#F4F4F4`
- Dark Text/Elements: `#060605`

### Theme Modes
- **Light Mode**: Use #F4F4F4 as background, #060605 for text, #03284F for headers/navigation, #C6A882 for accents
- **Dark Mode**: Use #060605 as background, #F4F4F4 for text, #03284F for containers, #C6A882 for accents

## Excel File Structure (Required Fields)
The imported Excel files must contain these columns (Hungarian headers):
- **Tárgy kódja** (Course code)
- **Tárgy neve** (Course name)
- **Kurzus kódja** (Class code)
- **Kurzus típusa** (Class type: Előadás/Gyakorlat/Labor)
- **Óraszám:** (Hours per week)
- **Órarend infó** (Schedule info - complex format)
- **Oktatók** (Instructors)
- **Várólista** (Waiting list - not used)

### Schedule Info Format Parsing Rules
- **Day abbreviations**:
  - H = Hétfő (Monday)
  - K = Kedd (Tuesday)
  - SZE = Szerda (Wednesday)
  - CS = Csütörtök (Thursday)
  - P = Péntek (Friday)
  - SZ (after P) = Szombat (Saturday)
- **Format**: `DAY:HH:MM-HH:MM(Location)`
- **Multiple sessions**: Separated by semicolon (`;`)

## Implementation Steps

### Step 1: Project Setup and Configuration

#### 1.1 Initialize Flutter Project
- Create new Flutter project with web and mobile support
- Configure minimum SDK versions (iOS 12.0+, Android API 21+)
- Set up responsive design framework

#### 1.2 Firebase Setup
- Create Firebase project
- Enable Authentication services (Email/Password, Google, Apple)
- Set up Firestore database
- Configure Firebase Storage for Excel uploads
- Add Firebase configuration files to Flutter project

#### 1.3 Dependencies Installation
Add to `pubspec.yaml`:
```yaml
dependencies:
  # Firebase
  firebase_core: latest
  firebase_auth: latest
  cloud_firestore: latest
  firebase_storage: latest
  
  # Authentication
  google_sign_in: latest
  sign_in_with_apple: latest
  
  # Excel processing
  excel: latest
  file_picker: latest
  
  # Calendar UI
  table_calendar: latest
  syncfusion_flutter_calendar: latest (alternative)
  
  # State Management (choose one)
  provider: latest
  riverpod: latest
  
  # Localization
  flutter_localizations: latest
  intl: latest
  
  # UI/UX
  flutter_screenutil: latest
  cached_network_image: latest
  shimmer: latest
  
  # Local storage
  shared_preferences: latest
  hive: latest
  
  # Notifications
  flutter_local_notifications: latest
  
  # Calendar export
  add_2_calendar: latest
  url_launcher: latest
```

### Step 2: Authentication System

#### 2.1 Create Authentication Service
- Implement email/password registration
- Add email verification (non-blocking)
- Implement Google Sign-In
- Implement Apple Sign-In (iOS)
- Create password reset functionality
- Handle authentication states

#### 2.2 User Data Model
```dart
class StudentUser {
  String uid;
  String email;
  String displayName;
  bool emailVerified;
  DateTime createdAt;
  String currentSemester;
  Map<String, List<Course>> semesters; // semester -> courses
}
```

#### 2.3 Firestore Structure
```
users/
  {userId}/
    profile/
      - email
      - displayName
      - emailVerified
      - createdAt
    semesters/
      {semesterId}/
        courses/
          {courseId}/
            - courseCode
            - courseName
            - classCode
            - classType
            - weeklyHours
            - scheduleInfo
            - instructors
            - parsedSchedule (array of schedule objects)
```

### Step 3: Excel Import Feature

#### 3.1 File Upload Interface
- Create file picker for .xlsx files only
- Show upload progress indicator
- Implement drag-and-drop for web version

#### 3.2 Excel Validation
- Check for required columns
- Validate file format
- Show error messages for invalid files
- Required validation checks:
  - File must be .xlsx format
  - Must contain all required column headers
  - At least one data row

#### 3.3 Excel Parser Service
```dart
class ExcelParserService {
  // Parse Excel file to Course objects
  Future<List<Course>> parseExcelFile(File file);
  
  // Validate Excel structure
  bool validateExcelStructure(Excel excel);
  
  // Parse schedule info string
  List<ScheduleSlot> parseScheduleInfo(String info);
  
  // Parse day abbreviation
  int getDayOfWeek(String abbr);
  
  // Extract time from schedule string
  TimeOfDay parseTime(String timeStr);
}
```

#### 3.4 Schedule Parser Logic
- Parse complex schedule strings (e.g., "H:08:00-10:00(Room)")
- Handle multiple time slots per course
- Extract location information
- Support courses spanning multiple days

### Step 4: Calendar Interface

#### 4.1 Calendar Views Implementation

##### Daily View
- Show 24-hour timeline (6:00 - 22:00 visible by default)
- Display courses as blocks with duration
- Show current time indicator (horizontal line)
- Implement scroll to current time on load

##### Weekly View
- 7-day grid (Monday to Sunday)
- Hide weekends if no Saturday classes
- Color-code by course type
- Show current day highlight
- Display time indicator line

##### Monthly View
- Traditional month calendar
- Show course count badges on days
- Quick preview on tap
- Navigation between months

#### 4.2 Calendar Features
- Current day highlighting
- Real-time indicator (moving horizontal line)
- Color coding:
  - Előadás (Lecture): Use #03284F
  - Gyakorlat (Practice): Use #C6A882
  - Labor (Lab): Use blend of both
- Course detail modal on tap
- Smooth transitions between views

### Step 5: Semester Management

#### 5.1 Semester Selection
- Dropdown with two options:
  - Current semester (e.g., "2025/26/1 (current semester)")
  - Next semester (e.g., "2025/26/2")
- Auto-calculate current semester based on date
- Semester format: YYYY/YY/N where N is 1 or 2

#### 5.2 Semester Logic
```dart
class SemesterService {
  String getCurrentSemester() {
    // Calculate based on current date
    // Sept-Jan = 1st semester
    // Feb-June = 2nd semester
  }
  
  String getNextSemester(String current) {
    // Parse and increment appropriately
  }
}
```

### Step 6: Course Management

#### 6.1 Course Display
- Show all course information
- Group by course when same course has multiple sessions
- Display instructor names
- Show room/location

#### 6.2 Course Editing
- Edit start/end times for individual sessions
- Changes apply to all weeks (recurring)
- Validation for time conflicts
- Save changes to Firestore

#### 6.3 Manual Course Addition
- Form for adding courses manually
- Same fields as Excel import
- Recurring weekly by default

### Step 7: Notifications System

#### 7.1 Local Notifications
- Class reminder notifications
- Configurable advance time (5, 10, 15, 30 min)
- Daily schedule summary notification
- Enable/disable per course

#### 7.2 Notification Settings
- Global on/off toggle
- Per-course settings
- Quiet hours configuration
- Weekend notifications toggle

### Step 8: Export Functionality

#### 8.1 Calendar Export
- Export to device's default calendar
- Google Calendar integration
- iCal format generation
- Semester or custom date range export

#### 8.2 Export Options
- Include/exclude specific courses
- Export as recurring events
- Add reminder settings
- Include location and instructor info

### Step 9: Offline Support

#### 9.1 Local Storage
- Cache user's schedule locally
- Sync when online
- Offline indicators
- Conflict resolution for edits

#### 9.2 Data Persistence
- Use Hive or SharedPreferences
- Store last synced timestamp
- Queue offline changes
- Auto-sync on connection restore

### Step 10: Localization

#### 10.1 Language Support
- Hungarian (default)
- English
- German
- Language selection in settings
- Persist language preference

#### 10.2 Translations
- All UI text
- Day/month names
- Course type labels
- Error messages
- Date/time formats per locale

### Step 11: Responsive Design

#### 11.1 Breakpoints
- Mobile: < 600px
- Tablet: 600px - 1024px
- Desktop: > 1024px

#### 11.2 Adaptive Layouts
- Stack navigation (mobile)
- Side navigation (tablet/desktop)
- Responsive calendar grids
- Touch-optimized for mobile
- Mouse/keyboard support for web

### Step 12: Testing & Deployment

#### 12.1 Testing
- Unit tests for parsers
- Widget tests for UI
- Integration tests for Firebase
- Excel import edge cases
- Multi-language testing

#### 12.2 Deployment
- Web hosting (Firebase Hosting)
- iOS App Store preparation
- Android Play Store preparation
- CI/CD pipeline setup

## Data Models

### Course Model
```dart
class Course {
  String id;
  String courseCode;        // Tárgy kódja
  String courseName;        // Tárgy neve
  String classCode;         // Kurzus kódja
  String classType;         // Kurzus típusa
  int weeklyHours;         // Óraszám
  String rawScheduleInfo;   // Original Órarend infó
  List<String> instructors; // Oktatók
  List<ScheduleSlot> scheduleSlots; // Parsed schedule
}

class ScheduleSlot {
  int dayOfWeek; // 1-7 (Monday-Sunday)
  TimeOfDay startTime;
  TimeOfDay endTime;
  String location;
  String courseId; // Reference to parent course
  Color displayColor; // Based on class type
}
```

## Error Handling

### Import Errors
- Invalid file format
- Missing required columns
- Corrupted file
- Network errors during upload

### User-Friendly Messages
- Provide clear error descriptions
- Suggest solutions
- Allow retry options
- Log errors for debugging

## Security Rules (Firestore)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Performance Optimizations

1. **Lazy Loading**: Load calendar events only for visible date range
2. **Pagination**: For semester course lists
3. **Caching**: Cache parsed Excel data temporarily
4. **Debouncing**: For search and filter operations
5. **Image Optimization**: Compress and cache user avatars
6. **Code Splitting**: Lazy load routes and heavy components

## Accessibility Features

1. **Screen Reader Support**: Semantic labels for all interactive elements
2. **Keyboard Navigation**: Full keyboard support for web
3. **High Contrast Mode**: Respect system settings
4. **Font Scaling**: Support dynamic type sizes
5. **Focus Indicators**: Clear focus states for navigation

## Future Enhancements (Not in MVP)

1. Course search and filtering
2. Friend schedule sharing
3. Group study session planning
4. Grade tracking
5. Assignment deadlines
6. Professor office hours
7. Campus map integration
8. Course reviews/ratings
9. Schedule optimization suggestions
10. Exam schedule integration

## Development Priorities

### Phase 1 (MVP - Current Focus)
1. User registration/login
2. Excel file upload and parsing
3. Basic calendar views (daily, weekly, monthly)
4. Semester selection
5. Offline support

### Phase 2
1. Course editing
2. Notifications
3. Calendar export
4. Localization

### Phase 3
1. Advanced features
2. Performance optimizations
3. Enhanced UI/UX

## Important Notes

1. **Excel Parsing**: The "Órarend infó" field may contain truncated text (indicated by "..."). Handle gracefully.
2. **Time Zones**: All times are in local university time zone (Budapest/Europe)
3. **Validation**: Always validate user input before Firebase operations
4. **Error Recovery**: Implement graceful degradation for feature failures
5. **Privacy**: Ensure GDPR compliance for European users

## Success Metrics

1. Successful Excel import rate > 95%
2. App load time < 2 seconds
3. Calendar render time < 500ms
4. Offline to online sync < 5 seconds
5. User session length > 5 minutes average