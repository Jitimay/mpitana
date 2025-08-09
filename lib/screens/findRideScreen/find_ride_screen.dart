import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpitana/bloc/ride/ride_bloc.dart';
import 'package:mpitana/bloc/ride/ride_event.dart';
import 'package:mpitana/bloc/ride/ride_state.dart';
import 'package:mpitana/screens/offerRide/models/ride_offer.dart';
import 'package:mpitana/screens/map/map_screen.dart';
import 'package:mpitana/screens/offerRide/location_picker_screen.dart';

class FindRideScreen extends StatefulWidget {
  const FindRideScreen({super.key});

  @override
  State<FindRideScreen> createState() => _FindRideScreenState();
}

class _FindRideScreenState extends State<FindRideScreen> {
  final _departureController = TextEditingController();
  final _destinationController = TextEditingController();
  final _dateTimeController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    // Load available rides when screen initializes
    context.read<RideBloc>().add(LoadAvailableRides());
  }

  @override
  void dispose() {
    _departureController.dispose();
    _destinationController.dispose();
    _dateTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectDepartureLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationPickerScreen(isDeparture: true),
        fullscreenDialog: true,
      ),
    );
    
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _departureController.text = result['address'] ?? '';
      });
    }
  }

  Future<void> _selectDestinationLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationPickerScreen(isDeparture: false),
        fullscreenDialog: true,
      ),
    );
    
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _destinationController.text = result['address'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RideBloc, RideState>(
      listener: (context, state) {
        if (state is RideCreated) {
          // Automatically refresh available rides when a new ride is created
          context.read<RideBloc>().add(LoadAvailableRides());
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: Column(
          children: [
            // Search Form Section
            Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find a Ride',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Search Form
                  TextField(
                    controller: _departureController,
                    readOnly: true,
                    onTap: _selectDepartureLocation,
                    decoration: InputDecoration(
                      hintText: 'From where?',
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                      prefixIcon: Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
                      suffixIcon: Icon(Icons.map, color: Theme.of(context).colorScheme.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  TextField(
                    controller: _destinationController,
                    readOnly: true,
                    onTap: _selectDestinationLocation,
                    decoration: InputDecoration(
                      hintText: 'Where to?',
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                      prefixIcon: Icon(Icons.location_on, color: Theme.of(context).colorScheme.secondary),
                      suffixIcon: Icon(Icons.map, color: Theme.of(context).colorScheme.secondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _dateTimeController,
                          decoration: InputDecoration(
                            hintText: 'When?',
                            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                            prefixIcon: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.onSurface),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                          ),
                          readOnly: true,
                          onTap: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              final TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: _selectedTime ?? TimeOfDay.now(),
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  _selectedDate = pickedDate;
                                  _selectedTime = pickedTime;
                                  _dateTimeController.text = "${_selectedDate!.toLocal().toString().split(' ')[0]} ${_selectedTime!.format(context)}";
                                });
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (_departureController.text.isNotEmpty && _destinationController.text.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapScreen(
                                  departure: _departureController.text,
                                  destination: _destinationController.text,
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        child: Icon(
                          Icons.search,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Divider
            Divider(
              thickness: 1,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            ),
            
            // Available Rides Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                children: [
                  Text(
                    'Available Rides',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      context.read<RideBloc>().add(LoadAvailableRides());
                    },
                    icon: Icon(
                      Icons.refresh,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Rides List
            Expanded(
              child: BlocBuilder<RideBloc, RideState>(
                builder: (context, state) {
                  if (state is RideLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  
                  if (state is RideError) {
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
                            state.message,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<RideBloc>().add(LoadAvailableRides());
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  if (state is RideLoaded) {
                    // Use rides directly from BLoC since it already filters properly
                    final availableRides = state.rides;
                    
                    if (availableRides.isEmpty) {
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
                              'No rides available',
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
                        context.read<RideBloc>().add(LoadAvailableRides());
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        itemCount: availableRides.length,
                        itemBuilder: (context, index) {
                          final ride = availableRides[index];
                          return RidePostCard(ride: ride);
                        },
                      ),
                    );
                  }
                  
                  return const Center(
                    child: Text('Something went wrong'),
                  );
                },
              ), // End of BlocBuilder
            ), // End of Expanded
          ], // End of Column children
        ), // End of Column
      ), // End of SafeArea
    ), // End of Scaffold
    ); // End of BlocListener
  }
}

class RidePostCard extends StatelessWidget {
  final RideOffer ride;
  
  const RidePostCard({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to ride details screen
          _showRideDetails(context, ride);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with driver info and price
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.driverName ?? 'Driver',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (ride.vehicleInfo != null)
                          Text(
                            ride.vehicleInfo!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'BIF ${ride.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Route information
              Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 30,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      ),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
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
                        const SizedBox(height: 24),
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
              
              const SizedBox(height: 16),
              
              // Date, time, and seats info
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
                  const Spacer(),
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
                ],
              ),
              
              if (ride.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  ride.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inDays == 0) {
      return 'Today ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow ${_formatTime(dateTime)}';
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
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => RideDetailsSheet(
          ride: ride,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class RideDetailsSheet extends StatelessWidget {
  final RideOffer ride;
  final ScrollController scrollController;
  
  const RideDetailsSheet({
    super.key,
    required this.ride,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          
          // Title
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
                  // Driver info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ride.driverName ?? 'Driver',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (ride.vehicleInfo != null)
                              Text(
                                ride.vehicleInfo!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          'BIF ${ride.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Route details
                  Text(
                    'Route',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Route visualization
                  Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 3,
                            height: 60,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                          ),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'From',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              ride.from,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Text(
                              'To',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              ride.to,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Trip details
                  Text(
                    'Trip Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          context,
                          Icons.schedule,
                          'Date & Time',
                          _formatDateTime(ride.dateTime),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDetailItem(
                          context,
                          Icons.event_seat,
                          'Available Seats',
                          '${ride.availableSeats}',
                        ),
                      ),
                    ],
                  ),
                  
                  if (ride.description.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ride.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Open chat with driver
                  },
                  child: const Text('Message Driver'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Book this ride
                    _bookRide(context, ride);
                  },
                  child: const Text('Book Ride'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailItem(BuildContext context, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inDays == 0) {
      return 'Today ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${_formatTime(dateTime)}';
    }
  }
  
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  void _bookRide(BuildContext context, RideOffer ride) {
    // TODO: Implement ride booking logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking ride from ${ride.from} to ${ride.to}'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Navigate to booking details
          },
        ),
      ),
    );
  }
}