// Firebase Setup Verification Script
// Run this script to verify Firebase configuration is complete
// Usage: dart run scripts/verify_firebase_setup.dart

import 'dart:io';

void main() async {
  print('🔥 ELTE Calendar - Firebase Setup Verification');
  print('=' * 50);
  
  bool allChecksPass = true;
  
  // Check 1: Project structure
  print('\n📁 Checking project structure...');
  allChecksPass &= checkProjectStructure();
  
  // Check 2: Firebase configuration files
  print('\n⚙️  Checking Firebase configuration...');
  allChecksPass &= checkFirebaseConfig();
  
  // Check 3: Security rules
  print('\n🔒 Checking security rules...');
  allChecksPass &= checkSecurityRules();
  
  // Check 4: Platform configurations
  print('\n📱 Checking platform configurations...');
  allChecksPass &= checkPlatformConfig();
  
  // Check 5: Dependencies
  print('\n📦 Checking dependencies...');
  allChecksPass &= checkDependencies();
  
  // Final result
  print('\n' + '=' * 50);
  if (allChecksPass) {
    print('✅ All Firebase setup checks passed!');
    print('🚀 Ready to proceed with authentication implementation.');
    print('\nNext steps:');
    print('1. Create Firebase project at https://console.firebase.google.com');
    print('2. Update configuration files with real credentials');
    print('3. Deploy security rules: firebase deploy --only firestore:rules,storage:rules');
    print('4. Test the connection with: flutter run');
  } else {
    print('❌ Some Firebase setup checks failed.');
    print('📋 Please review the issues above and fix them before proceeding.');
  }
}

bool checkProjectStructure() {
  final requiredFiles = [
    'lib/main.dart',
    'lib/config/firebase_config.dart',
    'lib/config/theme_config.dart',
    'lib/config/localization_config.dart',
    'pubspec.yaml',
    'firebase.json',
    'firestore.rules',
    'storage.rules',
    'firestore.indexes.json',
  ];
  
  bool allExist = true;
  for (final file in requiredFiles) {
    if (File(file).existsSync()) {
      print('   ✅ $file');
    } else {
      print('   ❌ $file (missing)');
      allExist = false;
    }
  }
  
  return allExist;
}

bool checkFirebaseConfig() {
  bool configValid = true;
  
  // Check main Firebase config file
  final configFile = File('lib/config/firebase_config.dart');
  if (configFile.existsSync()) {
    final content = configFile.readAsStringSync();
    if (content.contains('your-web-api-key')) {
      print('   ⚠️  Firebase credentials need to be updated (placeholder values found)');
      configValid = false;
    } else {
      print('   ✅ Firebase configuration file looks updated');
    }
  } else {
    print('   ❌ Firebase configuration file missing');
    configValid = false;
  }
  
  // Check web configuration
  final webIndexFile = File('web/index.html');
  if (webIndexFile.existsSync()) {
    final content = webIndexFile.readAsStringSync();
    if (content.contains('your-web-api-key')) {
      print('   ⚠️  Web Firebase config needs to be updated');
      configValid = false;
    } else {
      print('   ✅ Web Firebase configuration looks updated');
    }
  } else {
    print('   ❌ Web index.html missing');
    configValid = false;
  }
  
  return configValid;
}

bool checkSecurityRules() {
  bool rulesValid = true;
  
  // Check Firestore rules
  final firestoreRules = File('firestore.rules');
  if (firestoreRules.existsSync()) {
    final content = firestoreRules.readAsStringSync();
    if (content.contains('request.auth.uid == userId')) {
      print('   ✅ Firestore security rules configured');
    } else {
      print('   ❌ Firestore security rules may be invalid');
      rulesValid = false;
    }
  } else {
    print('   ❌ Firestore rules file missing');
    rulesValid = false;
  }
  
  // Check Storage rules
  final storageRules = File('storage.rules');
  if (storageRules.existsSync()) {
    final content = storageRules.readAsStringSync();
    if (content.contains('excel-imports') && content.contains('temp-uploads')) {
      print('   ✅ Storage security rules configured');
    } else {
      print('   ❌ Storage security rules may be invalid'); 
      rulesValid = false;
    }
  } else {
    print('   ❌ Storage rules file missing');
    rulesValid = false;
  }
  
  return rulesValid;
}

bool checkPlatformConfig() {
  bool platformValid = true;
  
  // Check Android configuration
  final androidBuildGradle = File('android/app/build.gradle');
  if (androidBuildGradle.existsSync()) {
    final content = androidBuildGradle.readAsStringSync();
    if (content.contains('com.google.gms.google-services') && 
        content.contains('minSdkVersion 21')) {
      print('   ✅ Android configuration looks correct');
    } else {
      print('   ❌ Android configuration needs review');
      platformValid = false;
    }
  } else {
    print('   ❌ Android build.gradle missing');
    platformValid = false;
  }
  
  // Check iOS configuration  
  final iosInfoPlist = File('ios/Runner/Info.plist');
  if (iosInfoPlist.existsSync()) {
    final content = iosInfoPlist.readAsStringSync();
    if (content.contains('<string>12.0</string>')) {
      print('   ✅ iOS configuration looks correct');
    } else {
      print('   ❌ iOS configuration needs review');
      platformValid = false;
    }
  } else {
    print('   ❌ iOS Info.plist missing');
    platformValid = false;
  }
  
  // Check for actual credential files (will be missing until manual setup)
  final androidGoogleServices = File('android/app/google-services.json');
  final iosGoogleServices = File('ios/Runner/GoogleService-Info.plist');
  
  if (!androidGoogleServices.existsSync()) {
    print('   ⚠️  google-services.json needs to be added to android/app/');
    // Not marking as failed since this requires manual Firebase Console setup
  }
  
  if (!iosGoogleServices.existsSync()) {
    print('   ⚠️  GoogleService-Info.plist needs to be added to ios/Runner/');
    // Not marking as failed since this requires manual Firebase Console setup
  }
  
  return platformValid;
}

bool checkDependencies() {
  bool depsValid = true;
  
  final pubspec = File('pubspec.yaml');
  if (pubspec.existsSync()) {
    final content = pubspec.readAsStringSync();
    
    final requiredDeps = [
      'firebase_core',
      'firebase_auth', 
      'cloud_firestore',
      'firebase_storage',
      'provider',
      'excel',
      'file_picker',
    ];
    
    for (final dep in requiredDeps) {
      if (content.contains(dep)) {
        print('   ✅ $dep');
      } else {
        print('   ❌ $dep (missing from pubspec.yaml)');
        depsValid = false;
      }
    }
  } else {
    print('   ❌ pubspec.yaml missing');
    depsValid = false;
  }
  
  return depsValid;
}