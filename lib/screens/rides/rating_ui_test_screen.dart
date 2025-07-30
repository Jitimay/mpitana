import 'package:flutter/material.dart';
import 'package:mpitana/common/widgets/user_ratings_widget.dart';
import 'package:mpitana/common/widgets/rating_dialog.dart';
import 'package:mpitana/screens/offerRide/models/ride_booking.dart';
import 'package:mpitana/screens/offerRide/models/rating.dart';
import 'package:mpitana/screens/profile/models/user_profile.dart';
import 'package:mpitana/common/database/objectbox_db.dart';
import 'package:mpitana/common/services/rating_service.dart';

class AppColors {
  static const Color primary = Color(0xFF2196F3);
}

class RatingUITestScreen extends StatefulWidget {
  const RatingUITestScreen({Key? key}) : super(key: key);

  @override
  State<RatingUITestScreen> createState() => _RatingUITestScreenState();
}

class _RatingUITestScreenState extends State<RatingUITestScreen> {
  final String _myUserId = 'test_user_123';
  final String _friendUserId = 'friend_user_456';
  bool _isDataCreated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rating UI Test'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Setup Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Setup Test Data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isDataCreated ? null : _createTestData,
                      icon: Icon(_isDataCreated ? Icons.check : Icons.data_object),
                      label: Text(_isDataCreated ? 'Test Data Created' : 'Create Test Data'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isDataCreated ? Colors.green : AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    if (_isDataCreated) ...[
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _clearTestData,
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear Test Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Rating Dialog Tests
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Rating Dialog',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _showDriverRatingDialog,
                      icon: const Icon(Icons.drive_eta),
                      label: const Text('Rate Driver Dialog'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _showRiderRatingDialog,
                      icon: const Icon(Icons.person),
                      label: const Text('Rate Rider Dialog'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // My Ratings Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: AppColors.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'My Ratings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    UserRatingsWidget(
                      userId: _myUserId,
                      showDetailedView: true,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Friend's Ratings Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Text(
                          'Friend\'s Ratings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    UserRatingsWidget(
                      userId: _friendUserId,
                      showDetailedView: true,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Quick Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: _addRandomRatingToMe,
                          child: const Text('Add Rating to Me'),
                        ),
                        ElevatedButton(
                          onPressed: _addRandomRatingToFriend,
                          child: const Text('Add Rating to Friend'),
                        ),
                        ElevatedButton(
                          onPressed: _showMyStats,
                          child: const Text('Show My Stats'),
                        ),
                        ElevatedButton(
                          onPressed: _showFriendStats,
                          child: const Text('Show Friend Stats'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createTestData() async {
    try {
      // Create test users
      final myProfile = UserProfile(
        userId: _myUserId,
        name: 'Test User (Me)',
        email: 'testuser@example.com',
        phone: '+1234567890',
        bio: 'This is my test profile for rating UI testing.',
      );

      final friendProfile = UserProfile(
        userId: _friendUserId,
        name: 'Friend User',
        email: 'friend@example.com',
        phone: '+0987654321',
        bio: 'This is a friend\'s test profile for rating UI testing.',
      );

      await ObjectBoxDb.saveUserProfile(myProfile);
      await ObjectBoxDb.saveUserProfile(friendProfile);

      // Create some sample ratings for both users
      await _createSampleRatings();

      setState(() {
        _isDataCreated = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test data created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating test data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createSampleRatings() async {
    final sampleRatings = [
      // Ratings for me
      Rating(
        raterId: 'driver_001',
        ratedUserId: _myUserId,
        rideBookingId: 1,
        rideOfferId: 1,
        rating: 4.5,
        ratingType: 'rider_rating',
        review: 'Great passenger! Very punctual and friendly.',
        punctualityRating: 5.0,
        communicationRating: 4.0,
        safetyRating: 5.0,
        friendlinessRating: 4.5,
        tags: 'Punctual,Friendly,Respectful',
      ),
      Rating(
        raterId: 'driver_002',
        ratedUserId: _myUserId,
        rideBookingId: 2,
        rideOfferId: 2,
        rating: 5.0,
        ratingType: 'rider_rating',
        review: 'Perfect rider! Would definitely pick up again.',
        punctualityRating: 5.0,
        communicationRating: 5.0,
        safetyRating: 5.0,
        friendlinessRating: 5.0,
        tags: 'Punctual,Friendly,Professional',
      ),
      Rating(
        raterId: 'driver_003',
        ratedUserId: _myUserId,
        rideBookingId: 3,
        rideOfferId: 3,
        rating: 3.5,
        ratingType: 'rider_rating',
        review: 'Good passenger, but was a bit late.',
        punctualityRating: 2.0,
        communicationRating: 4.0,
        safetyRating: 4.0,
        friendlinessRating: 4.0,
        tags: 'Friendly,Respectful',
      ),
      
      // Ratings for friend
      Rating(
        raterId: 'rider_001',
        ratedUserId: _friendUserId,
        rideBookingId: 4,
        rideOfferId: 4,
        rating: 4.8,
        ratingType: 'driver_rating',
        review: 'Excellent driver! Very safe and professional.',
        punctualityRating: 5.0,
        communicationRating: 5.0,
        safetyRating: 5.0,
        cleanlinessRating: 4.5,
        friendlinessRating: 4.5,
        tags: 'Safe Driver,Professional,Clean Vehicle',
      ),
      Rating(
        raterId: 'rider_002',
        ratedUserId: _friendUserId,
        rideBookingId: 5,
        rideOfferId: 5,
        rating: 4.2,
        ratingType: 'driver_rating',
        review: 'Good driver, smooth ride.',
        punctualityRating: 4.0,
        communicationRating: 4.0,
        safetyRating: 4.5,
        cleanlinessRating: 4.0,
        friendlinessRating: 4.0,
        tags: 'Safe Driver,Reliable',
      ),
    ];

    for (final rating in sampleRatings) {
      await ObjectBoxDb.saveRating(rating);
    }

    // Update user profile ratings
    await ObjectBoxDb.updateUserProfileRating(_myUserId);
    await ObjectBoxDb.updateUserProfileRating(_friendUserId);
  }

  Future<void> _clearTestData() async {
    try {
      // Clear ratings
      final allRatings = await ObjectBoxDb.getAllRatings();
      for (final rating in allRatings) {
        if (rating.ratedUserId == _myUserId || rating.ratedUserId == _friendUserId) {
          await ObjectBoxDb.deleteRating(rating.id);
        }
      }

      // Clear user profiles
      await ObjectBoxDb.deleteUserProfileByUserId(_myUserId);
      await ObjectBoxDb.deleteUserProfileByUserId(_friendUserId);

      setState(() {
        _isDataCreated = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test data cleared successfully!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing test data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDriverRatingDialog() {
    final mockBooking = RideBooking(
      riderId: _myUserId,
      driverId: _friendUserId,
      rideOfferId: 999,
      seatsBooked: 1,
      totalPrice: 25.0,
      status: 'completed',
      riderName: 'Test User (Me)',
      driverName: 'Friend User',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RatingDialog(
        booking: mockBooking,
        currentUserId: _myUserId,
        ratedUserName: 'Friend User (Driver)',
        onRatingSubmitted: () {
          setState(() {}); // Refresh the UI
        },
      ),
    );
  }

  void _showRiderRatingDialog() {
    final mockBooking = RideBooking(
      riderId: _friendUserId,
      driverId: _myUserId,
      rideOfferId: 998,
      seatsBooked: 2,
      totalPrice: 30.0,
      status: 'completed',
      riderName: 'Friend User',
      driverName: 'Test User (Me)',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RatingDialog(
        booking: mockBooking,
        currentUserId: _myUserId,
        ratedUserName: 'Friend User (Rider)',
        onRatingSubmitted: () {
          setState(() {}); // Refresh the UI
        },
      ),
    );
  }

  Future<void> _addRandomRatingToMe() async {
    final ratings = [3.5, 4.0, 4.5, 5.0];
    final reviews = [
      'Good passenger!',
      'Very punctual and friendly.',
      'Great communication.',
      'Would ride with again!',
    ];
    final tags = [
      'Punctual,Friendly',
      'Respectful,Professional',
      'Good Communication',
      'Reliable,Courteous',
    ];

    final random = DateTime.now().millisecondsSinceEpoch % 4;
    
    final rating = Rating(
      raterId: 'random_${DateTime.now().millisecondsSinceEpoch}',
      ratedUserId: _myUserId,
      rideBookingId: DateTime.now().millisecondsSinceEpoch,
      rideOfferId: DateTime.now().millisecondsSinceEpoch,
      rating: ratings[random],
      ratingType: 'rider_rating',
      review: reviews[random],
      tags: tags[random],
    );

    await ObjectBoxDb.saveRating(rating);
    await ObjectBoxDb.updateUserProfileRating(_myUserId);
    setState(() {});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added rating to your profile!')),
      );
    }
  }

  Future<void> _addRandomRatingToFriend() async {
    final ratings = [4.0, 4.2, 4.5, 4.8];
    final reviews = [
      'Great driver!',
      'Very safe and professional.',
      'Clean car and smooth ride.',
      'Excellent service!',
    ];
    final tags = [
      'Safe Driver,Professional',
      'Clean Vehicle,Punctual',
      'Friendly,Reliable',
      'Professional,Courteous',
    ];

    final random = DateTime.now().millisecondsSinceEpoch % 4;
    
    final rating = Rating(
      raterId: 'random_${DateTime.now().millisecondsSinceEpoch}',
      ratedUserId: _friendUserId,
      rideBookingId: DateTime.now().millisecondsSinceEpoch,
      rideOfferId: DateTime.now().millisecondsSinceEpoch,
      rating: ratings[random],
      ratingType: 'driver_rating',
      review: reviews[random],
      tags: tags[random],
    );

    await ObjectBoxDb.saveRating(rating);
    await ObjectBoxDb.updateUserProfileRating(_friendUserId);
    setState(() {});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added rating to friend\'s profile!')),
      );
    }
  }

  Future<void> _showMyStats() async {
    final stats = await RatingService.getUserRatingStats(_myUserId);
    _showStatsDialog('My Rating Stats', stats);
  }

  Future<void> _showFriendStats() async {
    final stats = await RatingService.getUserRatingStats(_friendUserId);
    _showStatsDialog('Friend\'s Rating Stats', stats);
  }

  void _showStatsDialog(String title, Map<String, dynamic> stats) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Average Rating: ${stats['averageRating'].toStringAsFixed(2)}'),
            Text('Total Ratings: ${stats['totalRatings']}'),
            Text('Driver Ratings: ${stats['driverRatings']}'),
            Text('Rider Ratings: ${stats['riderRatings']}'),
            const SizedBox(height: 8),
            const Text('Rating Distribution:'),
            ...List.generate(5, (index) {
              final stars = 5 - index;
              final count = stats['ratingDistribution'][stars] ?? 0;
              return Text('$stars stars: $count');
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
