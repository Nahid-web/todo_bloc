# 🔧 Troubleshooting Guide

This guide helps resolve common issues with the Todo BLoC Firebase integration.

## Common Errors and Solutions

### 1. "CONFIGURATION_NOT_FOUND" Error

**Symptoms:**
- Red error message at bottom of screen
- App shows error instead of authentication screen
- Firebase authentication fails

**Causes & Solutions:**

#### A. Email/Password Authentication Not Enabled
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project (`todo-bloc-1cc94`)
3. Go to **Authentication** → **Sign-in method**
4. Click on **"Email/Password"**
5. Enable the **first toggle** (Email/Password)
6. Click **"Save"**

#### B. Anonymous Authentication Not Enabled
1. In the same **Sign-in method** tab
2. Click on **"Anonymous"**
3. Toggle **"Enable"**
4. Click **"Save"**

#### C. Network Connectivity Issues
1. Check your internet connection
2. Try restarting the app
3. Check if Firebase services are down: [Firebase Status](https://status.firebase.google.com/)

### 2. Build Errors

#### A. NDK Version Warning
**Error:** "Your project is configured with Android NDK 26.3.11579264, but the following plugin(s) depend on a different Android NDK version"

**Solution:** Already fixed in `android/app/build.gradle.kts` with `ndkVersion = "27.0.12077973"`

#### B. Minimum SDK Version Error
**Error:** "firebase_auth requires a minimum Android SDK version of 23"

**Solution:** Already fixed in `android/app/build.gradle.kts` with `minSdk = 23`

### 3. Authentication Errors

#### A. "No user found with this email"
- The email address is not registered
- Use the **"Create Account"** option instead

#### B. "Wrong password provided"
- Check the password is correct
- Use **"Forgot Password"** feature (if implemented)

#### C. "An account already exists with this email"
- The email is already registered
- Use **"Sign In with Email"** instead

#### D. "The password provided is too weak"
- Password must be at least 6 characters
- Use a stronger password

### 4. Firestore Errors

#### A. "Permission denied"
**Cause:** Firestore security rules are too restrictive

**Solution:**
1. Go to Firebase Console → Firestore Database → Rules
2. Update rules to:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/todos/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

#### B. "Firestore has not been initialized"
**Solution:** Ensure Firebase is properly initialized in `main.dart`

### 5. App Crashes

#### A. "No Firebase App '[DEFAULT]' has been created"
**Solution:**
1. Check `lib/firebase_options.dart` exists
2. Verify `Firebase.initializeApp()` is called in `main.dart`
3. Ensure `google-services.json` is in `android/app/`

#### B. "MissingPluginException"
**Solution:**
1. Run `flutter clean`
2. Run `flutter pub get`
3. Restart the app

## Quick Fixes

### Reset Firebase Configuration
```bash
# Clean the project
flutter clean
flutter pub get

# Restart the app
flutter run
```

### Verify Firebase Setup
1. **Check Firebase Console:**
   - Project exists: `todo-bloc-1cc94`
   - Authentication enabled
   - Firestore Database created

2. **Check Local Files:**
   - `lib/firebase_options.dart` exists
   - `android/app/google-services.json` exists
   - `lib/main.dart` calls `Firebase.initializeApp()`

### Test Authentication Flow
1. **Anonymous Sign-in:**
   - Tap "Continue as Guest"
   - Should navigate to todo list

2. **Email Sign-up:**
   - Tap "Create Account"
   - Fill valid email and password (6+ chars)
   - Should create account and navigate to todo list

3. **Email Sign-in:**
   - Tap "Sign In with Email"
   - Use existing credentials
   - Should authenticate and navigate to todo list

## Debug Commands

```bash
# Check Flutter environment
flutter doctor

# Check Firebase project
firebase projects:list

# View app logs
flutter logs

# Run in debug mode
flutter run --debug
```

## Getting Help

If issues persist:

1. **Check Firebase Console** for any error messages
2. **View Flutter logs** for detailed error information
3. **Verify internet connection** and Firebase service status
4. **Try guest authentication** first to isolate the issue
5. **Check the app logs** in the terminal for specific error codes

## Contact Support

- [Firebase Support](https://firebase.google.com/support)
- [Flutter Documentation](https://docs.flutter.dev)
- [GitHub Issues](https://github.com/your-repo/issues) (if applicable)

Most authentication issues are resolved by ensuring Email/Password authentication is properly enabled in Firebase Console.
