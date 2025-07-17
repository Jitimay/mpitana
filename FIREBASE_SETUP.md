# Firebase Authentication Setup for Mpitana

This document provides instructions on how to set up Firebase Authentication for the Mpitana app.

## Prerequisites

- A Google account
- Flutter SDK installed
- Firebase project created

## Step 1: Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click on "Add project"
3. Enter "Mpitana" as the project name
4. Follow the setup wizard to create the project

## Step 2: Register Your Android App

1. In the Firebase Console, click on the Android icon to add an Android app
2. Enter the package name: `com.example.mpitana` (or your custom package name)
3. Enter a nickname for your app (optional)
4. Click "Register app"
5. Download the `google-services.json` file
6. Place the `google-services.json` file in the `android/app` directory of your Flutter project

## Step 3: Register Your iOS App (if applicable)

1. In the Firebase Console, click on the iOS icon to add an iOS app
2. Enter the Bundle ID from your iOS app
3. Enter a nickname for your app (optional)
4. Click "Register app"
5. Download the `GoogleService-Info.plist` file
6. Place the file in the `ios/Runner` directory of your Flutter project
7. Open Xcode, right-click on the Runner directory, select "Add Files to Runner", and add the downloaded file

## Step 4: Enable Authentication Methods

1. In the Firebase Console, go to "Authentication" in the left sidebar
2. Click on "Get started"
3. Enable "Email/Password" authentication method
4. (Optional) Enable other authentication methods like Google, Facebook, etc.

## Step 5: Update Firebase Dependencies

The project already includes the necessary Firebase dependencies in the `pubspec.yaml` file:

```yaml
dependencies:
  firebase_core: ^2.27.1
  firebase_auth: ^4.17.9
  cloud_firestore: ^4.15.9
```

## Step 6: Initialize Firebase in Your App

The project already initializes Firebase in the `main.dart` file:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Rest of your code...
}
```

## Step 7: Test Firebase Authentication

1. Run the app
2. Try to sign up with a new account
3. Try to log in with the created account
4. Check the Firebase Console to verify that the user was created

## Troubleshooting

If you encounter any issues:

1. Make sure the `google-services.json` file is correctly placed in the `android/app` directory
2. Verify that the package name in your `AndroidManifest.xml` matches the one you registered in Firebase
3. Check that you've enabled Email/Password authentication in the Firebase Console
4. Ensure you have the correct Firebase dependencies in your `pubspec.yaml` file
5. Check the Firebase documentation for more information: [Firebase Auth for Flutter](https://firebase.google.com/docs/auth/flutter/start)

## Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/docs/overview/)
- [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)
