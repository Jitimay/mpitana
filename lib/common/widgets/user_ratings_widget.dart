import 'package:flutter/material.dart';
import 'package:mpitana/screens/offerRide/models/rating.dart';
import 'package:mpitana/common/services/rating_service.dart';

class AppColors {
  static const Color primary = Color(0xFF2196F3);
}

class UserRatingsWidget extends StatefulWidget {
  final String userId;
  final bool showDetailedView;

  const UserRatingsWidget({
    Key? key,
    required this.userId,
    this.showDetailedView = false,
  }) : super(key: key);

  @override
  State<UserRatingsWidget> createState() => _UserRatingsWidgetState();
}

class _UserRatingsWidgetState extends State<UserRatingsWidget> {
  Map<String, dynamic>? _ratingStats;
  List<Rating>? _ratings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await RatingService.getUserRatingStats(widget.userId);
      final ratings = widget.showDetailedView 
          ? await RatingService.getUserRatings(widget.userId)
          : <Rating>[];

      setState(() {
        _ratingStats = stats;
        _ratings = ratings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_ratingStats == null || _ratingStats!['totalRatings'] == 0) {
      return _buildNoRatingsWidget();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRatingSummary(),
        if (widget.showDetailedView) ...[
          const SizedBox(height: 20),
          _buildRatingDistribution(),
          const SizedBox(height: 20),
          _buildRecentRatings(),
        ],
      ],
    );
  }

  Widget _buildNoRatingsWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.star_outline,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'No ratings yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Complete some rides to get rated',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary() {
    final averageRating = _ratingStats!['averageRating'] as double;
    final totalRatings = _ratingStats!['totalRatings'] as int;
    final driverRatings = _ratingStats!['driverRatings'] as int;
    final riderRatings = _ratingStats!['riderRatings'] as int;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              _buildStarRating(averageRating),
              const SizedBox(height: 4),
              Text(
                '$totalRatings rating${totalRatings != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (driverRatings > 0)
                  _buildRatingTypeRow('As Driver', driverRatings, Icons.drive_eta),
                if (riderRatings > 0)
                  _buildRatingTypeRow('As Rider', riderRatings, Icons.person),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingTypeRow(String label, int count, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const Spacer(),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        return Icon(
          rating >= starValue ? Icons.star : 
          rating >= starValue - 0.5 ? Icons.star_half : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  Widget _buildRatingDistribution() {
    final distribution = _ratingStats!['ratingDistribution'] as Map<int, int>;
    final totalRatings = _ratingStats!['totalRatings'] as int;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rating Distribution',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(5, (index) {
          final stars = 5 - index;
          final count = distribution[stars] ?? 0;
          final percentage = totalRatings > 0 ? count / totalRatings : 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text('$stars'),
                const SizedBox(width: 4),
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 12),
                Expanded(
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 30,
                  child: Text(
                    '$count',
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecentRatings() {
    if (_ratings == null || _ratings!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort ratings by date (most recent first)
    final sortedRatings = List<Rating>.from(_ratings!)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Show only the most recent 5 ratings
    final recentRatings = sortedRatings.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Recent Reviews',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (_ratings!.length > 5)
              TextButton(
                onPressed: () {
                  // TODO: Navigate to full ratings screen
                },
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ...recentRatings.map((rating) => _buildRatingCard(rating)).toList(),
      ],
    );
  }

  Widget _buildRatingCard(Rating rating) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStarRating(rating.rating),
                const SizedBox(width: 8),
                Text(
                  rating.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: rating.isDriverRating 
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rating.isDriverRating ? 'Driver' : 'Rider',
                    style: TextStyle(
                      fontSize: 12,
                      color: rating.isDriverRating ? Colors.blue[700] : Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (rating.review != null && rating.review!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                rating.review!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
            if (rating.tagsList.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: rating.tagsList.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              _formatDate(rating.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
