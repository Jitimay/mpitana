import 'package:flutter/material.dart';
import 'package:mpitana/screens/offerRide/models/ride_offer.dart';
import 'package:mpitana/screens/offerRide/models/ride_booking.dart';
import 'package:mpitana/screens/profile/models/user_profile.dart';
import 'package:mpitana/common/database/objectbox_db.dart';
import 'package:mpitana/common/services/rating_service.dart';
import 'package:mpitana/screens/rides/pending_ratings_screen.dart';

class AppColors {
  static const Color primary = Color(0xFF2196F3);
}

class RatingDemoScreen extends StatefulWidget {
  const RatingDemoScreen({Key? key}) : super(key: key);

  @override
  State<RatingDemoScreen> createState() => _RatingDemoScreenState();
}

class _RatingDemoScreenState extends State<RatingDemoScreen> {
  String _currentUserId = 'user123';
  List<String> _messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rating System Demo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(_messages[index]),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Demo Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: _createDemoUsers,
                      child: const Text('Create Demo Users'),
                    ),
                    ElevatedButton(
                      onPressed: _createDemoRideOffer,
                      child: const Text('Create Ride Offer'),
                    ),
                    ElevatedButton(
                      onPressed: _createDemoBooking,
                      child: const Text('Book Ride'),
                    ),
                    ElevatedButton(
                      onPressed: _completeRide,
                      child: const Text('Complete Ride'),
                    ),
                    ElevatedButton(
                      onPressed: _openPendingRatings,
                      child: const Text('Rate Rides'),
                    ),
                    ElevatedButton(
                      onPressed: _clearMessages,
                      child: const Text('Clear Log'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addMessage(String message) {
    setState(() {
      _messages.add('${DateTime.now().toLocal().toString().substring(11, 19)}: $message');
    });
  }

  Future<void> _createDemoUsers() async {
    try {
      // Create driver profile
      final driverProfile = UserProfile(
        userId: 'driver123',
        name: 'John Driver',
        email: 'john.driver@example.com',
        phone: '+1234567890',
        bio: 'Experienced driver with 5 years of safe driving.',
      );

      // Create rider profile
      final riderProfile = UserProfile(
        userId: 'rider456',
        name: 'Jane Rider',
        email: 'jane.rider@example.com',
        phone: '+0987654321',
        bio: 'Friendly commuter looking for reliable rides.',
      );

      // Create current user profile
      final currentUserProfile = UserProfile(
        userId: _currentUserId,
        name: 'Demo User',
        email: 'demo@example.com',
        phone: '+1122334455',
        bio: 'Demo user for testing the rating system.',
      );

      await ObjectBoxDb.saveUserProfile(driverProfile);
      await ObjectBoxDb.saveUserProfile(riderProfile);
      await ObjectBoxDb.saveUserProfile(currentUserProfile);

      _addMessage('Created demo users: John Driver, Jane Rider, and Demo User');
    } catch (e) {
      _addMessage('Error creating demo users: $e');
    }
  }

  Future<void> _createDemoRideOffer() async {
    try {
      final rideOffer = RideOffer(
        departureLat: 40.7128,
        departureLng: -74.0060,
        destinationLat: 40.7589,
        destinationLng: -73.9851,
        from: 'New York City',
        to: 'Times Square',
        dateTime: DateTime.now().add(const Duration(hours: 1)),
        availableSeats: 3,
        price: 15.0,
        description: 'Comfortable ride to Times Square',
        driverName: 'John Driver',
        driverId: 'driver123',
        driverPhone: '+1234567890',
        vehicleInfo: 'Honda Civic 2020',
      );

      final rideId = await ObjectBoxDb.saveRideOffer(rideOffer);
      _addMessage('Created ride offer with ID: $rideId');
    } catch (e) {
      _addMessage('Error creating ride offer: $e');
    }
  }

  Future<void> _createDemoBooking() async {
    try {
      final rideOffers = await ObjectBoxDb.getAllRideOffers();
      if (rideOffers.isEmpty) {
        _addMessage('No ride offers available. Create a ride offer first.');
        return;
      }

      final rideOffer = rideOffers.first;
      final booking = RideBooking(
        riderId: _currentUserId,
        driverId: rideOffer.driverId!,
        rideOfferId: rideOffer.id,
        seatsBooked: 1,
        totalPrice: rideOffer.price,
        riderName: 'Demo User',
        riderPhone: '+1122334455',
        driverName: rideOffer.driverName,
        driverPhone: rideOffer.driverPhone,
        status: 'confirmed',
      );

      final bookingId = await ObjectBoxDb.saveRideBooking(booking);
      
      // Update ride offer booked seats
      rideOffer.updateBookedSeats(rideOffer.bookedSeats + 1);
      await ObjectBoxDb.saveRideOffer(rideOffer);

      _addMessage('Created booking with ID: $bookingId');
    } catch (e) {
      _addMessage('Error creating booking: $e');
    }
  }

  Future<void> _completeRide() async {
    try {
      final bookings = await ObjectBoxDb.getRideBookingsByRider(_currentUserId);
      if (bookings.isEmpty) {
        _addMessage('No bookings found. Create a booking first.');
        return;
      }

      final booking = bookings.first;
      if (booking.isCompleted) {
        _addMessage('Ride is already completed.');
        return;
      }

      // Mark booking as completed
      booking.status = 'completed';
      booking.rideCompletedAt = DateTime.now();
      await ObjectBoxDb.saveRideBooking(booking);

      // Mark ride offer as completed
      final rideOffer = await ObjectBoxDb.getRideOffer(booking.rideOfferId);
      if (rideOffer != null) {
        rideOffer.markAsCompleted();
        await ObjectBoxDb.saveRideOffer(rideOffer);
      }

      _addMessage('Marked ride as completed. You can now rate it!');
    } catch (e) {
      _addMessage('Error completing ride: $e');
    }
  }

  Future<void> _openPendingRatings() async {
    try {
      final pendingBookings = await RatingService.getRideBookingsForRating(_currentUserId);
      
      if (pendingBookings.isEmpty) {
        _addMessage('No rides available for rating. Complete a ride first.');
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PendingRatingsScreen(
            currentUserId: _currentUserId,
          ),
        ),
      );
    } catch (e) {
      _addMessage('Error opening pending ratings: $e');
    }
  }

  void _clearMessages() {
    setState(() {
      _messages.clear();
    });
  }
}
