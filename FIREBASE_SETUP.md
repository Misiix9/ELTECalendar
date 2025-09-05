# Firebase Setup Guide - Step 1.2

## Overview
This guide provides detailed instructions for setting up the Firebase project for the ELTE Calendar application, following the technical specification exactly.

## Step-by-Step Firebase Console Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project"
3. **Project name**: `elte-calendar`
4. **Project ID**: `elte-calendar` (or accept auto-generated)
5. Enable Google Analytics: **Yes** (recommended)
6. Choose or create Analytics account
7. Click "Create project"

### 2. Enable Authentication Services

1. In Firebase Console, navigate to **Authentication** → **Sign-in method**
2. Enable the following providers:

#### Email/Password Authentication
- Click **Email/Password**
- Toggle **Enable** to ON
- Toggle **Email link (passwordless sign-in)** to OFF
- Click **Save**

#### Google Authentication
- Click **Google**
- Toggle **Enable** to ON
- **Project support email**: (select your email)
- Click **Save**
- **Note**: Download the updated `google-services.json` and `GoogleService-Info.plist` after setup

#### Apple Authentication (iOS only)
- Click **Apple**  
- Toggle **Enable** to ON
- You'll need to configure this with Apple Developer account later
- Click **Save**

### 3. Set Up Firestore Database

1. Navigate to **Firestore Database**
2. Click **Create database**
3. **Security rules**: Start in **production mode** (we'll update rules manually)
4. **Location**: Choose closest region (e.g., `europe-west` for Europe)
5. Click **Create**

#### Configure Firestore Structure
The database will use this structure (as per specification):
```
users/
  {userId}/
    profile/
      - email: string
      - displayName: string
      - emailVerified: boolean
      - createdAt: timestamp
    semesters/
      {semesterId}/
        courses/
          {courseId}/
            - courseCode: string
            - courseName: string
            - classCode: string
            - classType: string
            - weeklyHours: number
            - scheduleInfo: string
            - instructors: array
            - parsedSchedule: array
```

### 4. Set Up Firebase Storage

1. Navigate to **Storage**
2. Click **Get started**
3. **Security rules**: Start in **production mode** 
4. **Location**: Use same as Firestore
5. Click **Done**

#### Storage Structure
Files will be organized as:
```
excel-imports/
  {userId}/
    {semesterId}/
      {timestamp}_schedule.xlsx
temp-uploads/
  {userId}/
    {uploadId}.xlsx
```

### 5. Configure Project Settings

1. Navigate to **Project Settings** (gear icon)
2. **General tab**:
   - **Project name**: ELTE Calendar
   - **Project ID**: elte-calendar
   - **Public-facing name**: ELTE Calendar
   - **Support email**: (your email)

### 6. Add Apps to Project

#### Web App Configuration
1. Click **Add app** → Web (</> icon)
2. **App nickname**: `ELTE Calendar Web`
3. **Firebase Hosting**: Check this box
4. Click **Register app**
5. **Copy the configuration object** - you'll need this for `web/index.html`
6. Click **Continue to console**

#### Android App Configuration
1. Click **Add app** → Android
2. **Android package name**: `com.elte.calendar`
3. **App nickname**: `ELTE Calendar Android`
4. **Debug signing certificate SHA-1**: (optional for now)
5. Click **Register app**
6. **Download `google-services.json`** → Place in `android/app/`
7. Follow the SDK setup instructions
8. Click **Continue to console**

#### iOS App Configuration
1. Click **Add app** → iOS
2. **iOS bundle ID**: `com.elte.calendar`
3. **App nickname**: `ELTE Calendar iOS`
4. **App Store ID**: (leave empty for now)
5. Click **Register app**
6. **Download `GoogleService-Info.plist`** → Place in `ios/Runner/`
7. Follow the SDK setup instructions
8. Click **Continue to console**

### 7. Enable Required APIs (Google Cloud Console)

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select your Firebase project
3. Navigate to **APIs & Services** → **Library**
4. Enable these APIs:
   - **Identity Toolkit API** (for Firebase Auth)
   - **Cloud Firestore API**
   - **Cloud Storage for Firebase API**
   - **Firebase Management API**

### 8. Configure OAuth Consent Screen (for Google Sign-in)

1. In Google Cloud Console, go to **APIs & Services** → **OAuth consent screen**
2. **User Type**: External
3. Fill in required fields:
   - **App name**: ELTE Calendar
   - **User support email**: (your email)
   - **App logo**: (upload ELTE Calendar icon)
   - **Developer contact information**: (your email)
4. **Scopes**: Add email and profile scopes
5. **Test users**: Add your email for testing

## Configuration Files Update

After Firebase setup, update these files with your actual configuration:

### 1. Web Configuration (`web/index.html`)
Replace the firebaseConfig object around line 75:

```javascript
const firebaseConfig = {
  apiKey: "your-actual-api-key",
  authDomain: "elte-calendar.firebaseapp.com", 
  projectId: "elte-calendar",
  storageBucket: "elte-calendar.appspot.com",
  messagingSenderId: "your-actual-sender-id",
  appId: "your-actual-app-id",
  measurementId: "your-actual-measurement-id"
};
```

### 2. Flutter Configuration (`lib/config/firebase_config.dart`)
Update the DefaultFirebaseOptions class with your credentials:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'your-web-api-key',
  appId: 'your-web-app-id',
  messagingSenderId: 'your-sender-id',
  projectId: 'elte-calendar',
  authDomain: 'elte-calendar.firebaseapp.com',
  storageBucket: 'elte-calendar.appspot.com',
  measurementId: 'your-measurement-id',
);
```

### 3. Android Configuration
- Place `google-services.json` in `android/app/`
- Verify `android/app/build.gradle` has the Google Services plugin

### 4. iOS Configuration  
- Add `GoogleService-Info.plist` to `ios/Runner/` in Xcode
- Ensure it's added to the app target

## Security Rules Setup

### Firestore Security Rules (`firestore.rules`)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Additional rules for shared data (if needed in future)
    // match /public/{document=**} {
    //   allow read: if true;
    // }
  }
}
```

### Firebase Storage Security Rules (`storage.rules`)
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Excel imports - users can only access their own files
    match /excel-imports/{userId}/{semesterId}/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Temporary uploads - users can only access their own temp files
    match /temp-uploads/{userId}/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Verification Checklist

After completing setup, verify:

- [ ] Firebase project created with name "elte-calendar"
- [ ] Authentication enabled (Email/Password, Google, Apple)
- [ ] Firestore database created with proper location
- [ ] Firebase Storage enabled
- [ ] Web app added with configuration copied
- [ ] Android app added with google-services.json downloaded
- [ ] iOS app added with GoogleService-Info.plist downloaded
- [ ] Required Google Cloud APIs enabled
- [ ] OAuth consent screen configured
- [ ] Security rules deployed
- [ ] Configuration files updated in project

## Testing Firebase Connection

Run this command to test the connection:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in project (optional)
firebase init

# Deploy security rules
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
```

## Next Steps

After Firebase setup is complete:

1. Update all configuration files with real credentials
2. Test Firebase connection with Flutter app
3. Deploy security rules
4. Proceed to **Step 2: Authentication System** implementation

## Troubleshooting

### Common Issues:

1. **"Default FirebaseApp is not initialized"**
   - Ensure `google-services.json` is in correct location
   - Check that Firebase is initialized in `main.dart`

2. **"API key not found"** 
   - Verify API key in configuration files
   - Check that required APIs are enabled

3. **"Permission denied"**
   - Check Firestore security rules
   - Verify user is authenticated

4. **"Network error"**
   - Check internet connection
   - Verify Firebase project exists and is active

For additional help, refer to [Firebase Documentation](https://firebase.google.com/docs).