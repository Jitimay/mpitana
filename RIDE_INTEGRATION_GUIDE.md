# Ride Integration Guide

## Overview
This guide explains how rides posted on the "Offer Ride" screen automatically appear in the "Available Rides" (Find tab) using the BLoC pattern for state management.

## Integration Flow

### 1. Offer Ride Screen → BLoC
When a user posts a ride on the **Offer Ride** screen:

```dart
// OfferRideScreen triggers BLoC event
context.read<RideBloc>().add(CreateRideOfferEvent(
  from: _departureAddress!,
  to: _destinationAddress!,
  dateTime: dateTime,
  availableSeats: _availableSeats,
  price: double.parse(_priceController.text),
  description: _descriptionController.text,
  driverName: 'Current User',
  driverId: 'user_id',
  vehicleInfo: 'Toyota Camry',
));
```

### 2. BLoC Processing
The **RideBloc** processes the event:

```dart
Future<void> _onCreateRideOffer(CreateRideOfferEvent event, Emitter<RideState> emit) async {
  emit(RideLoading());
  
  // Create and save ride to ObjectBox
  final rideOffer = RideOffer(...);
  final id = _rideOfferBox!.put(rideOffer);
  
  // Emit success state
  emit(RideCreated(ride: rideOffer));
  
  // Emit updated rides list
  final rides = _rideOfferBox!.getAll();
  emit(RideLoaded(rides: rides));
}
```

### 3. Automatic UI Updates
Multiple screens listen for BLoC state changes:

#### A. Offer Ride Screen
```dart
BlocListener<RideBloc, RideState>(
  listener: (context, state) {
    if (state is RideCreated) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ride offer posted successfully!')),
      );
      // Navigate back to home
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  },
  child: Scaffold(...),
)
```

#### B. Home Screen
```dart
BlocListener<RideBloc, RideState>(
  listener: (context, state) {
    if (state is RideCreated) {
      // Automatically switch to Find tab
      setState(() {
        _selectedIndex = 0; // Find tab
      });
      // Show notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ride posted! Check the Find tab to see your ride.')),
      );
    }
  },
  child: Scaffold(...),
)
```

#### C. Find Ride Screen
```dart
BlocListener<RideBloc, RideState>(
  listener: (context, state) {
    if (state is RideCreated) {
      // Refresh available rides
      context.read<RideBloc>().add(LoadAvailableRides());
    }
  },
  child: BlocBuilder<RideBloc, RideState>(
    builder: (context, state) {
      // Automatically rebuilds when RideLoaded is emitted
      if (state is RideLoaded) {
        final availableRides = state.rides.where((ride) => 
          ride.isActive && 
          ride.availableSeats > 0 && 
          ride.dateTime.isAfter(DateTime.now())
        ).toList();
        
        return ListView.builder(
          itemCount: availableRides.length,
          itemBuilder: (context, index) {
            return RidePostCard(ride: availableRides[index]);
          },
        );
      }
    },
  ),
)
```

## Key Components

### 1. BLoC Events
- `CreateRideOfferEvent`: Triggered when posting a new ride
- `LoadAvailableRides`: Loads filtered available rides
- `LoadRidesEvent`: Loads all rides

### 2. BLoC States
- `RideLoading`: Shows loading indicators
- `RideCreated`: Emitted when a ride is successfully created
- `RideLoaded`: Contains list of rides for display
- `RideError`: Contains error messages

### 3. Data Flow
```
Offer Ride Screen → CreateRideOfferEvent → RideBloc → ObjectBox Database
                                                   ↓
Find Ride Screen ← LoadAvailableRides ← RideCreated + RideLoaded
```

## Features

### Automatic Filtering
The Find Ride Screen automatically filters rides to show only:
- Active rides (`ride.isActive = true`)
- Rides with available seats (`ride.availableSeats > 0`)
- Future rides (`ride.dateTime.isAfter(DateTime.now())`)

### Real-time Updates
- New rides appear immediately in the Find tab
- No manual refresh required
- Automatic navigation to Find tab after posting

### Post-style Display
Rides are displayed as social media-style cards with:
- Driver information and profile picture placeholder
- Route visualization (departure → destination)
- Price prominently displayed
- Date, time, and seat availability
- Ride description
- Status indicators

## Testing

### Manual Testing
1. Go to "Offer Ride" tab
2. Fill in ride details (departure, destination, date, time, seats, price)
3. Submit the ride offer
4. Observe automatic navigation to Find tab
5. Verify the new ride appears in the available rides list

### Using Test Data
```dart
import 'package:mpitana/common/utils/test_data.dart';

// Create sample rides for testing
TestDataUtils.createSampleRides(context.read<RideBloc>());

// Create a specific test ride
TestDataUtils.createTestRide(
  context.read<RideBloc>(),
  from: 'Test Location A',
  to: 'Test Location B',
  price: 20.0,
);
```

## Troubleshooting

### Rides Not Appearing
1. Check if BLoC is properly initialized in main.dart
2. Verify ObjectBox database is initialized
3. Ensure ride has `isActive = true` and `availableSeats > 0`
4. Check if ride date is in the future

### State Not Updating
1. Verify BlocListener is properly wrapped around screens
2. Check if correct events are being dispatched
3. Ensure BlocBuilder is used for UI updates

### Navigation Issues
1. Verify home screen has proper BlocListener
2. Check if `_selectedIndex` is being updated correctly
3. Ensure navigation logic in offer ride screen is correct

## Future Enhancements

1. **Real-time Sync**: Add Firebase integration for real-time updates across devices
2. **Push Notifications**: Notify users when new rides matching their preferences are posted
3. **Advanced Filtering**: Add filters by price range, departure time, location radius
4. **Ride Matching**: Automatically suggest rides based on user's frequent routes
5. **Social Features**: Add driver ratings, reviews, and social verification

## File Structure
```
lib/
├── bloc/ride/
│   ├── ride_bloc.dart          # Main BLoC logic
│   ├── ride_event.dart         # BLoC events
│   └── ride_state.dart         # BLoC states
├── screens/
│   ├── findRideScreen/
│   │   └── find_ride_screen.dart    # Available rides display
│   ├── offerRide/
│   │   └── offer_ride_screen.dart   # Ride creation form
│   └── home/
│       └── home_screen.dart         # Main navigation
└── common/utils/
    └── test_data.dart              # Test utilities
```

This integration ensures a seamless user experience where posted rides immediately become available for other users to discover and book.
