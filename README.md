# ELTE Calendar

ELTE Calendar is a Flutter application for ELTE students to import timetable data from university Excel exports and manage courses in a modern calendar interface.

## What this project is

ELTE Calendar focuses on one core workflow:
1. Sign in
2. Import timetable data from a Neptun/Excel export
3. View and manage courses in daily, weekly, and monthly calendar views

The app is built with Firebase-backed services and local/offline-friendly storage patterns.

## Key features

- Authentication (email/password, password reset, verification flow)
- Excel import with Hungarian header parsing
- Calendar views: daily, weekly, monthly
- Semester-aware course organization
- Course management screens (list, details, edit)
- Notification and settings screens
- Theme and language preferences

## Excel format support

The parser is built for Hungarian course export columns:

- `Tárgy kódja`
- `Tárgy neve`
- `Kurzus kódja`
- `Kurzus típusa`
- `Óraszám:`
- `Órarend infó`
- `Oktatók`
- `Várólista` (ignored)

Day abbreviations:
- `H` = Monday
- `K` = Tuesday
- `SZE` = Wednesday
- `CS` = Thursday
- `P` = Friday
- `SZ` = Saturday

## Tech stack

- Flutter / Dart
- Firebase (Auth, Firestore, Storage, Analytics, Crashlytics)
- Hive + SharedPreferences
- Provider state management
- Syncfusion + Table Calendar components

## Repository structure

```text
lib/
  config/        # Firebase, theme, localization setup
  models/        # App domain models
  screens/       # Feature screens (auth, calendar, import, settings, etc.)
  services/      # Business logic and integrations
  widgets/       # Reusable UI components
  utils/         # Constants and helper utilities
test/
  unit/          # Unit tests
  widget/        # Widget tests
  integration/   # Integration tests
```

## Running locally

Prerequisites:
- Flutter SDK (stable)
- Firebase project configured for this app

Commands:

```bash
flutter pub get
flutter run
```

Run tests:

```bash
flutter test
```

### Firebase and Google Sign-In setup (without committing secrets)

This repository does not store real Firebase secrets. Configure Firebase via runtime defines and local platform files:

```bash
flutter run \
  --dart-define=FIREBASE_WEB_API_KEY=... \
  --dart-define=FIREBASE_WEB_AUTH_DOMAIN=... \
  --dart-define=FIREBASE_WEB_PROJECT_ID=... \
  --dart-define=FIREBASE_WEB_STORAGE_BUCKET=... \
  --dart-define=FIREBASE_WEB_MESSAGING_SENDER_ID=... \
  --dart-define=FIREBASE_WEB_APP_ID=... \
  --dart-define=FIREBASE_ANDROID_API_KEY=... \
  --dart-define=FIREBASE_ANDROID_APP_ID=... \
  --dart-define=FIREBASE_ANDROID_MESSAGING_SENDER_ID=... \
  --dart-define=FIREBASE_ANDROID_PROJECT_ID=... \
  --dart-define=FIREBASE_ANDROID_STORAGE_BUCKET=... \
  --dart-define=FIREBASE_IOS_API_KEY=... \
  --dart-define=FIREBASE_IOS_APP_ID=... \
  --dart-define=FIREBASE_IOS_MESSAGING_SENDER_ID=... \
  --dart-define=FIREBASE_IOS_PROJECT_ID=... \
  --dart-define=FIREBASE_IOS_STORAGE_BUCKET=... \
  --dart-define=FIREBASE_IOS_BUNDLE_ID=com.elte.calendar \
  --dart-define=FIREBASE_MACOS_API_KEY=... \
  --dart-define=FIREBASE_MACOS_APP_ID=... \
  --dart-define=FIREBASE_MACOS_MESSAGING_SENDER_ID=... \
  --dart-define=FIREBASE_MACOS_PROJECT_ID=... \
  --dart-define=FIREBASE_MACOS_STORAGE_BUCKET=... \
  --dart-define=FIREBASE_MACOS_BUNDLE_ID=com.elte.calendar \
  --dart-define=GOOGLE_SIGN_IN_CLIENT_ID=... \
  --dart-define=GOOGLE_SIGN_IN_SERVER_CLIENT_ID=...
```

For Android/iOS native setup, place your real Firebase config files locally (they are gitignored):

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

## Deployment

This repository includes GitHub Actions workflows for Flutter web deployment to GitHub Pages and Firebase-related workflows under `.github/workflows/`.

For GitHub Pages deployment, configure repository secrets for Firebase web config.  
Supported secret names are either `FIREBASE_WEB_*` or the generic `FIREBASE_*` equivalents:

- `FIREBASE_WEB_API_KEY` or `FIREBASE_API_KEY`
- `FIREBASE_WEB_AUTH_DOMAIN` or `FIREBASE_AUTH_DOMAIN`
- `FIREBASE_WEB_PROJECT_ID` or `FIREBASE_PROJECT_ID`
- `FIREBASE_WEB_STORAGE_BUCKET` or `FIREBASE_STORAGE_BUCKET`
- `FIREBASE_WEB_MESSAGING_SENDER_ID` or `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_WEB_APP_ID` or `FIREBASE_APP_ID`
- Optional: `FIREBASE_WEB_MEASUREMENT_ID` or `FIREBASE_MEASUREMENT_ID`

## Contributing

Issues and pull requests are welcome. For meaningful changes, include:
- Clear problem statement
- Scoped commits
- Updated tests/docs when behavior changes

## License

No license file is currently defined in this repository.
