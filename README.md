# mpitana

A new Flutter project.

## Database

This project uses ObjectBox as the local database solution. ObjectBox is a NoSQL, object-oriented database that offers high performance and a simple API.

### Models

The database models are located in:
- `lib/screens/offerRide/models/location.dart`
- `lib/screens/offerRide/models/ride_offer.dart`
- `lib/screens/offerRide/models/ride_booking.dart`
- `lib/screens/offerRide/models/rating.dart`

### Database Service

The ObjectBox database service is implemented in `lib/common/database/objectbox_db.dart`. This service provides methods for:
- Initializing the database
- Performing CRUD operations on entities
- Querying data with filters

## Rating System

The app includes a comprehensive rating system that allows users to rate each other after completing rides. This system helps build trust and accountability within the ride-sharing community.

### Features

- **Dual Rating System**: Both drivers and riders can rate each other after completing a ride
- **Detailed Ratings**: Users can provide ratings in multiple categories:
  - Overall rating (1-5 stars)
  - Punctuality
  - Communication
  - Safety
  - Vehicle cleanliness (for driver ratings)
  - Friendliness
- **Reviews and Tags**: Users can leave written reviews and select predefined tags
- **Rating History**: View all ratings received and given
- **Rating Statistics**: Comprehensive stats including average rating, rating distribution, and breakdown by driver/rider roles

### Components

#### Models
- **RideBooking**: Tracks ride bookings between riders and drivers
- **Rating**: Stores ratings and reviews with detailed category breakdowns

#### Services
- **RatingService** (`lib/common/services/rating_service.dart`): Handles all rating-related business logic including:
  - Submitting new ratings
  - Updating existing ratings
  - Retrieving user rating statistics
  - Managing rating permissions and validation

#### UI Components
- **RatingDialog** (`lib/common/widgets/rating_dialog.dart`): Modal dialog for submitting ratings
- **UserRatingsWidget** (`lib/common/widgets/user_ratings_widget.dart`): Displays user ratings and statistics
- **PendingRatingsScreen** (`lib/screens/rides/pending_ratings_screen.dart`): Shows rides that can be rated

### Usage Flow

1. **Ride Completion**: After a ride is marked as completed, both the driver and rider become eligible to rate each other
2. **Rating Notification**: Users see pending ratings in their rides screen
3. **Rating Submission**: Users can rate each other within 30 days of ride completion
4. **Rating Display**: Ratings are displayed on user profiles and contribute to overall user reputation

### Implementation Example

```dart
// Submit a rating
final success = await RatingService.submitRating(
  raterId: 'user123',
  ratedUserId: 'driver456',
  rideBookingId: bookingId,
  rideOfferId: rideOfferId,
  rating: 4.5,
  ratingType: 'driver_rating',
  review: 'Great driver, very punctual!',
  punctualityRating: 5.0,
  communicationRating: 4.0,
  safetyRating: 5.0,
  tags: ['Punctual', 'Friendly', 'Safe Driver'],
);

// Get user rating statistics
final stats = await RatingService.getUserRatingStats('user123');
print('Average rating: ${stats['averageRating']}');
print('Total ratings: ${stats['totalRatings']}');
```

### Demo & Testing

The app includes comprehensive testing tools for the rating system:

#### Rating System Demo (`lib/screens/rides/rating_demo_screen.dart`)
- Create demo users and ride offers
- Book rides and mark them as completed
- Test the rating functionality end-to-end

#### Rating UI Test (`lib/screens/rides/rating_ui_test_screen.dart`)
A simple test screen with buttons to easily test rating UI components:

**Features:**
- **Setup Test Data**: Create sample users and ratings with one click
- **Test Rating Dialogs**: 
  - Rate Driver Dialog - Test the driver rating interface
  - Rate Rider Dialog - Test the rider rating interface
- **View Rating Widgets**:
  - My Ratings - See your own rating summary and reviews
  - Friend's Ratings - See another user's rating summary and reviews
- **Quick Actions**:
  - Add random ratings to test profiles
  - View detailed rating statistics
  - Refresh data in real-time

**How to Access:**
1. Go to **Rides Screen**
2. Tap **"Rating UI Test"**
3. Click **"Create Test Data"** to set up sample data
4. Use the various buttons to test different UI components

**Perfect for:**
- Testing rating dialog functionality
- Viewing how ratings appear on profiles
- Testing different rating scenarios
- UI/UX validation

Access both demos through: **Rides Screen → Rating System Demo** or **Rides Screen → Rating UI Test**

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
