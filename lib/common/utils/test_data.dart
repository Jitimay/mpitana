import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpitana/bloc/ride/ride_bloc.dart';
import 'package:mpitana/bloc/ride/ride_event.dart';

class TestDataUtils {
  static void createSampleRides(BuildContext context) {
    final now = DateTime.now();
    
    // Sample ride 1
    context.read<RideBloc>().add(CreateRideOfferEvent(
      from: 'Downtown Mall',
      to: 'University Campus',
      departureLat: 38.0293,
      departureLng: -78.4767,
      destinationLat: 38.0336,
      destinationLng: -78.5080,
      dateTime: now.add(const Duration(hours: 2)),
      availableSeats: 3,
      price: 15.0,
      description: 'Comfortable ride with AC. Non-smoking vehicle.',
      driverName: 'John Doe',
      driverId: 'user_123',
      vehicleInfo: 'Honda Civic 2020',
    ));
    
    // Sample ride 2
    context.read<RideBloc>().add(CreateRideOfferEvent(
      from: 'Airport Terminal',
      to: 'City Center',
      departureLat: 38.1338,
      departureLng: -78.4553,
      destinationLat: 38.0293,
      destinationLng: -78.4767,
      dateTime: now.add(const Duration(hours: 4)),
      availableSeats: 2,
      price: 25.0,
      description: 'Airport pickup service. Luggage space available.',
      driverName: 'Sarah Wilson',
      driverId: 'user_456',
      vehicleInfo: 'Toyota Camry 2021',
    ));
    
    // Sample ride 3
    context.read<RideBloc>().add(CreateRideOfferEvent(
      from: 'Shopping Center',
      to: 'Residential Area',
      departureLat: 38.0489,
      departureLng: -78.5094,
      destinationLat: 38.0522,
      destinationLng: -78.5289,
      dateTime: now.add(const Duration(days: 1, hours: 1)),
      availableSeats: 4,
      price: 10.0,
      description: 'Daily commute route. Friendly driver!',
      driverName: 'Mike Johnson',
      driverId: 'user_789',
      vehicleInfo: 'Ford Explorer 2019',
    ));
  }
  
  static void createTestRide(BuildContext context, {
    required String from,
    required String to,
    required double price,
    int availableSeats = 2,
    String description = 'Test ride',
    String driverName = 'Test Driver',
  }) {
    context.read<RideBloc>().add(CreateRideOfferEvent(
      from: from,
      to: to,
      departureLat: 38.0293,
      departureLng: -78.4767,
      destinationLat: 38.0336,
      destinationLng: -78.5080,
      dateTime: DateTime.now().add(const Duration(hours: 1)),
      availableSeats: availableSeats,
      price: price,
      description: description,
      driverName: driverName,
      driverId: 'test_user',
      vehicleInfo: 'Test Vehicle',
    ));
  }
}
