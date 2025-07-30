import 'package:flutter/material.dart';
import 'package:mpitana/screens/offerRide/models/ride_booking.dart';
import 'package:mpitana/common/services/rating_service.dart';

class AppColors {
  static const Color primary = Color(0xFF2196F3);
}

class RatingDialog extends StatefulWidget {
  final RideBooking booking;
  final String currentUserId;
  final String ratedUserName;
  final VoidCallback? onRatingSubmitted;

  const RatingDialog({
    Key? key,
    required this.booking,
    required this.currentUserId,
    required this.ratedUserName,
    this.onRatingSubmitted,
  }) : super(key: key);

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _overallRating = 5.0;
  double? _punctualityRating;
  double? _communicationRating;
  double? _safetyRating;
  double? _cleanlinessRating;
  double? _friendlinessRating;
  
  final TextEditingController _reviewController = TextEditingController();
  final Set<String> _selectedTags = {};
  bool _isSubmitting = false;
  
  // Predefined tags
  final List<String> _availableTags = [
    'Punctual',
    'Friendly',
    'Safe Driver',
    'Clean Vehicle',
    'Good Communication',
    'Respectful',
    'Helpful',
    'Professional',
    'Reliable',
    'Courteous',
  ];

  String get _ratingType => RatingService.getRatingType(widget.booking, widget.currentUserId);
  String get _ratedUserId => RatingService.getOtherUserInBooking(widget.booking, widget.currentUserId) ?? '';
  bool get _isRatingDriver => _ratingType == 'driver_rating';

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverallRating(),
                    const SizedBox(height: 20),
                    _buildDetailedRatings(),
                    const SizedBox(height: 20),
                    _buildReviewSection(),
                    const SizedBox(height: 20),
                    _buildTagsSection(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          _isRatingDriver ? Icons.drive_eta : Icons.person,
          color: AppColors.primary,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rate ${_isRatingDriver ? 'Driver' : 'Rider'}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.ratedUserName,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildOverallRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overall Rating',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStarRating(
                rating: _overallRating,
                onRatingChanged: (rating) {
                  setState(() {
                    _overallRating = rating;
                  });
                },
              ),
            ),
            Text(
              _overallRating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailedRatings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detailed Ratings (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailedRatingItem(
          'Punctuality',
          _punctualityRating,
          (rating) => setState(() => _punctualityRating = rating),
        ),
        _buildDetailedRatingItem(
          'Communication',
          _communicationRating,
          (rating) => setState(() => _communicationRating = rating),
        ),
        _buildDetailedRatingItem(
          'Safety',
          _safetyRating,
          (rating) => setState(() => _safetyRating = rating),
        ),
        if (_isRatingDriver)
          _buildDetailedRatingItem(
            'Vehicle Cleanliness',
            _cleanlinessRating,
            (rating) => setState(() => _cleanlinessRating = rating),
          ),
        _buildDetailedRatingItem(
          'Friendliness',
          _friendlinessRating,
          (rating) => setState(() => _friendlinessRating = rating),
        ),
      ],
    );
  }

  Widget _buildDetailedRatingItem(
    String label,
    double? rating,
    Function(double) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            child: _buildStarRating(
              rating: rating ?? 0,
              onRatingChanged: onChanged,
              allowZero: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating({
    required double rating,
    required Function(double) onRatingChanged,
    bool allowZero = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        return GestureDetector(
          onTap: () {
            if (allowZero && rating == starValue) {
              onRatingChanged(0);
            } else {
              onRatingChanged(starValue);
            }
          },
          child: Icon(
            rating >= starValue ? Icons.star : Icons.star_border,
            color: rating >= starValue ? Colors.amber : Colors.grey,
            size: 24,
          ),
        );
      }),
    );
  }

  Widget _buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _reviewController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Share your experience...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitRating,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Submit Rating'),
          ),
        ),
      ],
    );
  }

  Future<void> _submitRating() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await RatingService.submitRating(
        raterId: widget.currentUserId,
        ratedUserId: _ratedUserId,
        rideBookingId: widget.booking.id,
        rideOfferId: widget.booking.rideOfferId,
        rating: _overallRating,
        ratingType: _ratingType,
        review: _reviewController.text.trim().isEmpty ? null : _reviewController.text.trim(),
        punctualityRating: _punctualityRating,
        communicationRating: _communicationRating,
        safetyRating: _safetyRating,
        cleanlinessRating: _cleanlinessRating,
        friendlinessRating: _friendlinessRating,
        tags: _selectedTags.isEmpty ? null : _selectedTags.toList(),
      );

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rating submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onRatingSubmitted?.call();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit rating. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
