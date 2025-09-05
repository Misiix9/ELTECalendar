# ELTE Calendar - University Schedule Management App

A cross-platform university calendar application built with Flutter/Dart and Firebase for ELTE students to import and manage their course schedules from Excel files.

## Project Status

### ✅ Completed (Step 1.1 - Project Initialization)

1. **Flutter Project Structure**: Complete project structure with web and mobile platform support
2. **Minimum SDK Configuration**: Android API 21+ and iOS 12.0+ as specified
3. **Dependencies**: All required packages added to `pubspec.yaml`
4. **Theme Configuration**: Complete theme system using specified color palette:
   - Primary Dark Blue: `#03284F`
   - Gold Accent: `#C6A882`  
   - Light Background: `#F4F4F4`
   - Dark Text/Elements: `#060605`
5. **Folder Structure**: Organized according to specification
6. **Firebase Configuration**: Base configuration files created (need actual credentials)
7. **Localization Setup**: Hungarian (default), English, and German language support
8. **Platform Configuration**: Android, iOS, and Web platform files configured

### 🔄 Next Steps Required

1. **Create Firebase Project** (Step 1.2)
   - Set up Firebase project at https://console.firebase.google.com
   - Enable Authentication, Firestore, and Storage services
   - Add actual Firebase configuration credentials
   - Set up security rules

2. **Install Flutter SDK** (if not available)
   - Required to build and run the project
   - Run `flutter pub get` to install dependencies
   - Run `flutter run` to test the application

## Project Structure

```
lib/
├── main.dart                          # Application entry point
├── config/
│   ├── firebase_config.dart          # Firebase configuration
│   ├── theme_config.dart             # Theme with specified colors
│   └── localization_config.dart      # Multi-language support
├── models/                           # Data models (to be implemented)
├── services/                         # Business logic services
│   ├── auth_service.dart            # Authentication service stub
│   └── semester_service.dart        # Semester management stub
├── screens/                         # UI screens
│   ├── auth/
│   │   └── login_screen.dart        # Login screen placeholder
│   └── calendar/
│       └── calendar_main_screen.dart # Calendar screen placeholder
├── widgets/                         # Reusable widgets (to be created)
└── utils/                          # Utility functions (to be created)
```

## Technical Specifications Implemented

### Color Palette (Strictly Followed)
- **Primary Dark Blue**: `#03284F` - Used for headers, navigation, primary actions
- **Gold Accent**: `#C6A882` - Used for highlights, secondary actions
- **Light Background**: `#F4F4F4` - Main background color for light mode
- **Dark Text**: `#060605` - Text and UI elements

### Platform Support
- **Web**: Complete PWA configuration with manifest and service worker support
- **Android**: Minimum API 21+, Firebase integration, Google Play Services
- **iOS**: Minimum iOS 12.0+, proper permissions, URL scheme configuration

### Dependencies Added
- Firebase suite (Auth, Firestore, Storage)
- Excel processing (excel, file_picker)
- Calendar UI (table_calendar, syncfusion_flutter_calendar)
- State management (Provider)
- Localization (flutter_localizations, intl)
- Local storage (Hive, SharedPreferences)
- UI enhancements (ScreenUtil, CachedNetworkImage)

## Next Implementation Steps

### Step 1.2: Firebase Setup
1. Create Firebase project: `elte-calendar`
2. Enable required services:
   - Authentication (Email/Password, Google, Apple)
   - Cloud Firestore
   - Firebase Storage
3. Update configuration files with real credentials
4. Configure security rules

### Step 2: Authentication System
- User registration and login
- Email verification (non-blocking)
- Google and Apple Sign-in
- Password reset functionality

### Step 3: Excel Import Feature  
- File picker for .xlsx files
- Excel validation and parsing
- Hungarian schedule format parsing:
  - Day abbreviations (H=Monday, K=Tuesday, SZE=Wednesday, CS=Thursday, P=Friday, SZ=Saturday)
  - Time slot extraction
  - Location parsing

### Step 4: Calendar Interface
- Daily, Weekly, Monthly views
- Course color coding by type
- Current time indicator
- Interactive course details

### Step 5: Semester Management
- Current/Next semester calculation
- Semester selection dropdown
- Data organization by semester

## Running the Project

### Prerequisites
1. Flutter SDK installed and configured
2. Firebase project created and configured
3. Platform-specific setup (Android Studio for Android, Xcode for iOS)

### Commands
```bash
# Get dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Run on Android
flutter run -d android

# Run on iOS  
flutter run -d ios

# Build for production
flutter build web
flutter build apk
flutter build ios
```

## Firebase Configuration Required

Update these files with actual Firebase project credentials:
- `lib/config/firebase_config.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `web/index.html` (Firebase config object)

## Development Notes

- All placeholder screens show development status and upcoming features
- Theme system is fully implemented with light/dark mode support
- Localization system supports Hungarian (default), English, and German
- Code follows Flutter best practices with comprehensive commenting
- Error handling framework is established throughout the codebase
- Responsive design considerations are built into the theme system

## Excel File Format Expected

The app will parse Excel files with these Hungarian column headers:
- **Tárgy kódja** (Course code)
- **Tárgy neve** (Course name)  
- **Kurzus kódja** (Class code)
- **Kurzus típusa** (Class type)
- **Óraszám:** (Weekly hours)
- **Órarend infó** (Schedule info)
- **Oktatók** (Instructors)
- **Várólista** (Waiting list - ignored)

Day abbreviation parsing:
- H = Hétfő (Monday)
- K = Kedd (Tuesday)
- SZE = Szerda (Wednesday)  
- CS = Csütörtök (Thursday)
- P = Péntek (Friday)
- SZ = Szombat (Saturday)

## Contact & Development

This project follows the technical specification document exactly. Each implementation step must be completed fully before proceeding to the next step, with comprehensive testing and documentation.

Current Status: **Step 1.1 Complete** - Ready for Firebase setup and authentication implementation.