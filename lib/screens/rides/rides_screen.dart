import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpitana/bloc/ride/ride_bloc.dart';
import 'package:mpitana/bloc/ride/ride_event.dart';
import 'package:mpitana/bloc/ride/ride_state.dart';
import 'package:mpitana/screens/offerRide/models/ride_offer.dart';

class RidesScreen extends StatefulWidget {
  const RidesScreen({super.key});

  @override
  State<RidesScreen> createState() => _RidesScreenState();
}

class _RidesScreenState extends State<RidesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load all rides when screen initializes
    context.read<RideBloc>().add(LoadRidesEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('All Rides'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Available Rides'),
            Tab(text: 'All Rides'),
          ],
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: Theme.of(context).colorScheme.primary,
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<RideBloc>().add(LoadRidesEvent());
            },
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Available Rides Tab
          BlocBuilder<RideBloc, RideState>(
            builder: (context, state) {
              if (state is RideLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (state is RideError) {
                return _buildErrorWidget(context, state.message);
              }
              
              if (state is RideLoaded) {
                final availableRides = state.rides.where((ride) => 
                  ride.isActive && 
                  ride.availableSeats > 0 && 
                  ride.dateTime.isAfter(DateTime.now())
                ).toList();
                
                return _buildRidesList(context, availableRides, 'No available rides at the moment');
              }
              
              return const Center(child: Text('Something went wrong'));
            },
          ),
          
          // All Rides Tab
          BlocBuilder<RideBloc, RideState>(
            builder: (context, state) {
              if (state is RideLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (state is RideError) {
                return _buildErrorWidget(context, state.message);
              }
              
              if (state is RideLoaded) {
                return _buildRidesList(context, state.rides, 'No rides found');
              }
              
              return const Center(child: Text('Something went wrong'));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading rides',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<RideBloc>().add(LoadRidesEvent());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildRidesList(BuildContext context, List<RideOffer> rides, String emptyMessage) {
    if (rides.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later or offer a ride yourself!',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<RideBloc>().add(LoadRidesEvent());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rides.length,
        itemBuilder: (context, index) {
          final ride = rides[index];
          return RideCard(ride: ride);
        },
      ),
    );
  }
}

class RideCard extends StatelessWidget {
  final RideOffer ride;
  
  const RideCard({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    final isExpired = ride.dateTime.isBefore(DateTime.now());
    final hasSeats = ride.availableSeats > 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showRideDetails(context, ride);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and price
              Row(
                children: [
                  // Status indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(context, ride, isExpired, hasSeats).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(ride, isExpired, hasSeats),
                      style: TextStyle(
                        color: _getStatusColor(context, ride, isExpired, hasSeats),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'BIF ${ride.price.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Route
              Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 20,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.from,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          ride.to,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Details row
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(ride.dateTime),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.event_seat,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${ride.availableSeats} seats',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const Spacer(),
                  if (ride.driverName != null)
                    Text(
                      ride.driverName!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getStatusColor(BuildContext context, RideOffer ride, bool isExpired, bool hasSeats) {
    if (!ride.isActive) return Theme.of(context).colorScheme.error;
    if (isExpired) return Theme.of(context).colorScheme.onSurface.withOpacity(0.5);
    if (!hasSeats) return Colors.orange;
    return Colors.green;
  }
  
  String _getStatusText(RideOffer ride, bool isExpired, bool hasSeats) {
    if (!ride.isActive) return 'Cancelled';
    if (isExpired) return 'Expired';
    if (!hasSeats) return 'Full';
    return 'Available';
  }
  
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inDays == 0) {
      return 'Today ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow ${_formatTime(dateTime)}';
    } else if (difference.inDays < 0) {
      return 'Past ride';
    } else {
      return '${dateTime.day}/${dateTime.month} ${_formatTime(dateTime)}';
    }
  }
  
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  void _showRideDetails(BuildContext context, RideOffer ride) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              Text(
                'Ride Details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 20),
              
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Route details
                      Text(
                        'Route',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('From: ${ride.from}'),
                      const SizedBox(height: 8),
                      Text('To: ${ride.to}'),
                      
                      const SizedBox(height: 20),
                      
                      // Trip details
                      Text(
                        'Trip Details',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Date & Time: ${_formatDateTime(ride.dateTime)}'),
                      const SizedBox(height: 8),
                      Text('Available Seats: ${ride.availableSeats}'),
                      const SizedBox(height: 8),
                      Text('Price: BIF ${ride.price.toStringAsFixed(0)}'),
                      
                      if (ride.description.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(ride.description),
                      ],
                      
                      if (ride.driverName != null) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Driver',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(ride.driverName!),
                      ],
                      
                      if (ride.vehicleInfo != null) ...[
                        const SizedBox(height: 12),
                        Text('Vehicle: ${ride.vehicleInfo!}'),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Action buttons
              if (ride.isActive && ride.availableSeats > 0 && ride.dateTime.isAfter(DateTime.now()))
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Implement booking logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Booking ride from ${ride.from} to ${ride.to}'),
                          ),
                        );
                      },
                      child: const Text('Book This Ride'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
