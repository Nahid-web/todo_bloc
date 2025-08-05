# 🔥 Firebase Console Setup Guide

This guide will help you set up Firebase Console integration for the Todo BLoC Flutter application.

## Prerequisites

- Flutter development environment set up
- Firebase account (free tier is sufficient)
- Android Studio or VS Code with Flutter extensions

## Step 1: Create Firebase Project

1. **Go to Firebase Console**: Visit [https://console.firebase.google.com](https://console.firebase.google.com)

2. **Create New Project**:

   - Click "Create a project"
   - Project name: `todo-bloc-app` (or your preferred name)
   - Enable/disable Google Analytics (optional)
   - Click "Create project"

3. **Wait for project creation** (usually takes 1-2 minutes)

## Step 2: Enable Required Services

### Enable Firestore Database

1. In your Firebase project, go to **"Firestore Database"**
2. Click **"Create database"**
3. Choose **"Start in test mode"** (for development)
4. Select a location (choose closest to your users)
5. Click **"Done"**

### Enable Authentication

1. Go to **"Authentication"** in the Firebase console
2. Click **"Get started"**
3. Go to **"Sign-in method"** tab
4. Enable **"Email/Password"** authentication:
   - Click on "Email/Password"
   - Toggle "Enable" for Email/Password (first option)
   - Click "Save"
5. Enable **"Anonymous"** authentication:
   - Click on "Anonymous"
   - Toggle "Enable"
   - Click "Save"

## Step 3: Add Flutter App to Firebase Project

### For Android:

1. Click **"Add app"** and select **Android**
2. **Android package name**: `com.example.todo_bloc`
3. **App nickname**: `Todo BLoC Android` (optional)
4. Click **"Register app"**
5. **Download** `google-services.json`
6. **Place** the file in `android/app/` directory
7. Follow the SDK setup instructions (usually auto-configured)

### For iOS (if needed):

1. Click **"Add app"** and select **iOS**
2. **iOS bundle ID**: `com.example.todoBloc`
3. **App nickname**: `Todo BLoC iOS` (optional)
4. Click **"Register app"**
5. **Download** `GoogleService-Info.plist`
6. **Add** the file to your iOS project in Xcode

### For Web (if needed):

1. Click **"Add app"** and select **Web**
2. **App nickname**: `Todo BLoC Web`
3. Click **"Register app"**
4. **Copy** the Firebase config object

## Step 4: Configure Flutter Project

### Install FlutterFire CLI (Recommended):

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your Flutter project
flutterfire configure
```

This will automatically:

- Generate `lib/firebase_options.dart`
- Update platform-specific configuration files
- Set up the correct Firebase project

### Manual Configuration (Alternative):

If you prefer manual setup, ensure you have:

1. **`lib/firebase_options.dart`** with your project configuration
2. **`android/app/google-services.json`** for Android
3. **`ios/Runner/GoogleService-Info.plist`** for iOS (if supporting iOS)

## Step 5: Update Firestore Security Rules

In Firebase Console, go to **Firestore Database > Rules** and update:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to access their own todos
    match /users/{userId}/todos/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

## Step 6: Test the Integration

1. **Run the app**:

   ```bash
   flutter run
   ```

2. **Test the flow**:
   - App should show "Welcome to Todo BLoC" screen
   - Tap "Continue as Guest"
   - Should authenticate anonymously
   - Create a todo - it should sync to Firestore
   - Check Firebase Console > Firestore Database to see the data

## Step 7: Verify Data Structure

In Firestore, you should see:

```
/users/{anonymousUserId}/todos/{todoId}
  - title: "Your todo title"
  - description: "Your todo description"
  - isCompleted: false
  - createdAt: timestamp
  - updatedAt: timestamp
```

## Troubleshooting

### Common Issues:

1. **"No Firebase App '[DEFAULT]' has been created"**

   - Ensure `Firebase.initializeApp()` is called in `main()`
   - Check `firebase_options.dart` exists and is imported

2. **"Permission denied" errors**

   - Verify Firestore security rules allow authenticated users
   - Ensure user is authenticated (check auth state)

3. **Android build errors**

   - Ensure `google-services.json` is in `android/app/`
   - Check `android/app/build.gradle` has Google services plugin
   - Verify `minSdkVersion` is 23 or higher

4. **Network errors**
   - Check internet connectivity
   - Verify Firebase project is active
   - Ensure Firestore is enabled

### Debug Commands:

```bash
# Check Flutter doctor
flutter doctor

# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Check Firebase project
firebase projects:list
```

## Production Considerations

1. **Update Firestore Rules**: Change from test mode to production rules
2. **Enable App Check**: Add additional security layer
3. **Set up monitoring**: Enable Firebase Analytics and Crashlytics
4. **Backup strategy**: Set up Firestore backups
5. **Performance**: Monitor Firestore usage and optimize queries

## Support

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com)

Your Todo BLoC app is now fully integrated with Firebase! 🎉
