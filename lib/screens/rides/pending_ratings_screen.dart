import 'package:flutter/material.dart';
import 'package:mpitana/screens/offerRide/models/ride_booking.dart';
import 'package:mpitana/screens/offerRide/models/ride_offer.dart';
import 'package:mpitana/common/services/rating_service.dart';
import 'package:mpitana/common/database/objectbox_db.dart';
import 'package:mpitana/common/widgets/rating_dialog.dart';

class AppColors {
  static const Color primary = Color(0xFF2196F3);
}

class PendingRatingsScreen extends StatefulWidget {
  final String currentUserId;

  const PendingRatingsScreen({
    Key? key,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<PendingRatingsScreen> createState() => _PendingRatingsScreenState();
}

class _PendingRatingsScreenState extends State<PendingRatingsScreen> {
  List<RideBooking> _pendingRatings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingRatings();
  }

  Future<void> _loadPendingRatings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bookings = await RatingService.getRideBookingsForRating(widget.currentUserId);
      setState(() {
        _pendingRatings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading pending ratings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Your Rides'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingRatings.isEmpty
              ? _buildEmptyState()
              : _buildRatingsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No rides to rate',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete some rides to rate your experience',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsList() {
    return RefreshIndicator(
      onRefresh: _loadPendingRatings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingRatings.length,
        itemBuilder: (context, index) {
          final booking = _pendingRatings[index];
          return _buildRatingCard(booking);
        },
      ),
    );
  }

  Widget _buildRatingCard(RideBooking booking) {
    final isRatingDriver = booking.riderId == widget.currentUserId;
    final otherUserName = isRatingDriver ? booking.driverName : booking.riderName;
    final otherUserPhone = isRatingDriver ? booking.driverPhone : booking.riderPhone;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isRatingDriver ? Icons.drive_eta : Icons.person,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rate ${isRatingDriver ? 'Driver' : 'Rider'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (otherUserName != null)
                        Text(
                          otherUserName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<RideOffer?>(
              future: ObjectBoxDb.getRideOffer(booking.rideOfferId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final rideOffer = snapshot.data!;
                  return _buildRideDetails(rideOffer, booking);
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showRatingDialog(booking, otherUserName ?? 'User'),
                icon: const Icon(Icons.star),
                label: const Text('Rate Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideDetails(RideOffer rideOffer, RideBooking booking) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.location_on, color: Colors.green, size: 16),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                rideOffer.from,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.location_on, color: Colors.red, size: 16),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                rideOffer.to,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey[600], size: 16),
            const SizedBox(width: 4),
            Text(
              _formatDateTime(rideOffer.dateTime),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const Spacer(),
            if (booking.rideCompletedAt != null) ...[
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Text(
                'Completed ${_formatDateTime(booking.rideCompletedAt!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.people, color: Colors.grey[600], size: 16),
            const SizedBox(width: 4),
            Text(
              '${booking.seatsBooked} seat${booking.seatsBooked > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const Spacer(),
            Text(
              '\$${booking.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${_formatTime(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  void _showRatingDialog(RideBooking booking, String ratedUserName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RatingDialog(
        booking: booking,
        currentUserId: widget.currentUserId,
        ratedUserName: ratedUserName,
        onRatingSubmitted: () {
          _loadPendingRatings(); // Refresh the list
        },
      ),
    );
  }
}
