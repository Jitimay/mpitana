# BLoC State Management Implementation

This document outlines the BLoC (Business Logic Component) state management implementation for the Mpitana Flutter project.

## Overview

The project now uses BLoC pattern for state management across all features. Each feature has its own BLoC with events, states, and business logic separated from the UI.

## BLoC Structure

### 1. Authentication BLoC (`lib/bloc/auth/`)
- **Events**: Login, SignUp, Logout, CheckAuthStatus
- **States**: Initial, Loading, Authenticated, Unauthenticated, Error
- **Features**: User authentication, session management

### 2. Theme BLoC (`lib/bloc/theme/`)
- **Events**: ToggleTheme, SystemTheme
- **States**: Initial, Changed
- **Features**: Dark/Light theme switching, system theme support

### 3. Location BLoC (`lib/bloc/location/`)
- **Events**: RequestPermission, GetCurrentLocation, UpdateLocation
- **States**: Initial, Loading, PermissionDenied, PermissionGranted, Loaded, Error
- **Features**: GPS location, permissions, geocoding

### 4. Ride BLoC (`lib/bloc/ride/`)
- **Events**: LoadRides, CreateRideOffer, SearchRides, BookRide, CancelRide
- **States**: Initial, Loading, Loaded, Created, Booked, Error
- **Features**: Ride management, booking, searching with Isar database

### 5. Chat BLoC (`lib/bloc/chat/`)
- **Events**: LoadChats, LoadMessages, SendMessage, CreateChat, MarkAsRead
- **States**: Initial, Loading, ChatsLoaded, MessagesLoaded, MessageSent, ChatCreated, Error
- **Features**: Real-time messaging, chat management

### 6. Profile BLoC (`lib/bloc/profile/`)
- **Events**: LoadProfile, UpdateProfile, UpdateImage, UpdateNotifications, ChangePassword, DeleteAccount
- **States**: Initial, Loading, Loaded, Updated, ImageUpdated, NotificationsUpdated, PasswordChanged, AccountDeleted, Error
- **Features**: User profile management, settings, account operations

## Key Features

### MultiBlocProvider Setup
```dart
MultiBlocProvider(
  providers: [
    BlocProvider<AuthBloc>(create: (context) => AuthBloc()..add(CheckAuthStatusEvent())),
    BlocProvider<ThemeBloc>(create: (context) => ThemeBloc()),
    BlocProvider<LocationBloc>(create: (context) => LocationBloc()),
    BlocProvider<RideBloc>(create: (context) => RideBloc()),
    BlocProvider<ChatBloc>(create: (context) => ChatBloc()),
    BlocProvider<ProfileBloc>(create: (context) => ProfileBloc()),
  ],
  child: MyApp(),
)
```

### BLoC Observer
- Debugging and logging for all BLoC events and state changes
- Located in `lib/bloc/app_bloc_observer.dart`

### State-based Navigation
- Authentication state determines app navigation
- Automatic routing between login and home screens

## Usage Examples

### Listening to State Changes
```dart
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthAuthenticated) {
      return HomeScreen();
    } else if (state is AuthLoading) {
      return LoadingScreen();
    } else {
      return LoginScreen();
    }
  },
)
```

### Triggering Events
```dart
// Login
context.read<AuthBloc>().add(LoginEvent(email: email, password: password));

// Get location
context.read<LocationBloc>().add(GetCurrentLocationEvent());

// Load rides
context.read<RideBloc>().add(LoadRidesEvent());
```

### Multiple BLoC Listeners
```dart
MultiBlocListener(
  listeners: [
    BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
    ),
    BlocListener<RideBloc, RideState>(
      listener: (context, state) {
        if (state is RideCreated) {
          Navigator.pop(context);
        }
      },
    ),
  ],
  child: YourWidget(),
)
```

## Integration with Existing Features

### Database Integration
- Ride BLoC integrates with Isar database
- Automatic data persistence and retrieval
- Real-time updates across the app

### Permission Handling
- Location BLoC handles GPS permissions
- Graceful error handling and user feedback

### Theme Management
- System-wide theme switching
- Persistent theme preferences
- Automatic UI updates

## Best Practices Implemented

1. **Separation of Concerns**: Business logic separated from UI
2. **Single Responsibility**: Each BLoC handles one feature area
3. **Immutable States**: All states are immutable classes
4. **Error Handling**: Comprehensive error states and handling
5. **Loading States**: User feedback during async operations
6. **Event-Driven**: All state changes triggered by events

## Testing Support

Each BLoC can be easily unit tested:
```dart
blocTest<AuthBloc, AuthState>(
  'emits [AuthLoading, AuthAuthenticated] when login succeeds',
  build: () => AuthBloc(),
  act: (bloc) => bloc.add(LoginEvent(email: 'test@test.com', password: 'password')),
  expect: () => [AuthLoading(), AuthAuthenticated(userId: '123', email: 'test@test.com', name: 'User')],
);
```

## Next Steps

1. **API Integration**: Replace mock data with actual API calls
2. **Real-time Features**: Implement WebSocket for chat and ride updates
3. **Offline Support**: Add offline capabilities with local storage
4. **Push Notifications**: Integrate with Firebase for notifications
5. **Testing**: Add comprehensive unit and widget tests

## Dependencies

```yaml
dependencies:
  flutter_bloc: ^9.1.1
  bloc: ^9.0.0
  # ... other dependencies
```

The BLoC implementation provides a solid foundation for scalable state management across the entire Mpitana application.
