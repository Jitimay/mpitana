# mpitana

A new Flutter project.

## Database

This project uses ObjectBox as the local database solution. ObjectBox is a NoSQL, object-oriented database that offers high performance and a simple API.

### Models

The database models are located in:
- `lib/screens/offerRide/models/location.dart`
- `lib/screens/offerRide/models/ride_offer.dart`

### Database Service

The ObjectBox database service is implemented in `lib/common/database/objectbox_db.dart`. This service provides methods for:
- Initializing the database
- Performing CRUD operations on entities
- Querying data with filters

## Google Maps & Places Integration

This project uses Google Maps for displaying maps and Google Places API for location search functionality.

### Location Picker

The enhanced location picker (`lib/screens/offerRide/enhanced_location_picker.dart`) provides:
- Google Places autocomplete search for finding places
- Recent location history from the local database
- Current location detection
- Manual map selection

### Setup

To use the Google Places API:

1. Obtain a Google Maps API key from the [Google Cloud Console](https://console.cloud.google.com/)
2. Enable the following APIs in your project:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API
3. Replace the placeholder API key in `enhanced_location_picker.dart` with your actual API key
4. For Android, add the API key to `android/app/src/main/AndroidManifest.xml`
5. For iOS, add the API key to `ios/Runner/AppDelegate.swift`

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
