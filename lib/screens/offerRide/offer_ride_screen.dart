import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:mpitana/screens/offerRide/location_picker_screen.dart';
import 'package:mpitana/screens/offerRide/models/location.dart' as MyLocation;
import 'package:mpitana/screens/offerRide/models/ride_offer.dart';
import 'package:mpitana/screens/offerRide/services/location_service.dart';
import 'package:mpitana/screens/offerRide/services/directions_service.dart';
import 'package:mpitana/common/database/objectbox_db.dart';
import 'package:mpitana/common/widgets/enhanced_route_map_widget.dart';

class OfferRideScreen extends StatefulWidget {
  const OfferRideScreen({super.key});

  @override
  State<OfferRideScreen> createState() => _OfferRideScreenState();
}

class _OfferRideScreenState extends State<OfferRideScreen> {
  // Location selection
  LatLng? _departureLocation;
  LatLng? _destinationLocation;
  String? _departureAddress;
  String? _destinationAddress;
  bool _isTrafficEstimate = false;
  
  // Map controller
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  
  // Route details
  double _distance = 0.0;
  String _duration = "0 min";
  
  // Ride details
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _availableSeats = 1;
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // UI state
  bool _isLoading = false;
  bool _showMap = false;
  bool _showRideDetails = false;
  final _formKey = GlobalKey<FormState>();
  
  // Scroll controller for the form
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _priceController.text = "0.00";
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _selectDepartureLocation() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationPickerScreen(isDeparture: true),
        fullscreenDialog: true,
      ),
    );

    if (result != null) {
      setState(() {
        _departureLocation = result;
        _showMap = false;
        _showRideDetails = false;
      });
      _getAddressFromLatLng(result, true);
      _saveLocationToIsar(result, true);
      
      // If both locations are selected, show the route
      if (_destinationLocation != null) {
        _showRouteOnMap();
      }
    }
  }

  Future<void> _selectDestinationLocation() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationPickerScreen(isDeparture: false),
        fullscreenDialog: true,
      ),
    );

    if (result != null) {
      setState(() {
        _destinationLocation = result;
      });
      _getAddressFromLatLng(result, false);
      _saveLocationToIsar(result, false);
      
      // If both locations are selected, show the route
      if (_departureLocation != null) {
        _showRouteOnMap();
      }
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position, bool isDeparture) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
        setState(() {
          if (isDeparture) {
            _departureAddress = address;
          } else {
            _destinationAddress = address;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting address: $e')),
      );
    }
  }

  Future<void> _saveLocationToIsar(LatLng position, bool isDeparture) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        
        final location = MyLocation.Location.create(
          latitude: position.latitude,
          longitude: position.longitude,
          address: "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}",
          city: place.locality,
          country: place.country,
          isDeparture: isDeparture,
        );

        await LocationService.saveLocation(location);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving location: $e')),
      );
    }
  }


Future<void> _showRouteOnMap() async {
  if (_departureLocation == null || _destinationLocation == null) return;

  setState(() => _isLoading = true);

  try {
    _markers = {
      Marker(
        markerId: const MarkerId('departure'),
        position: _departureLocation!,
        infoWindow: InfoWindow(title: 'Departure', snippet: _departureAddress),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: _destinationLocation!,
        infoWindow: InfoWindow(title: 'Destination', snippet: _destinationAddress),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };

    final directionsResult = await DirectionsService.getDirections(
      origin: _departureLocation!,
      destination: _destinationLocation!,
    );

    setState(() {
      _polylines = {directionsResult['polyline']};
      _distance = directionsResult['distance'];
      _duration = directionsResult['duration'];
      _isTrafficEstimate = directionsResult['isTrafficEstimate'] ?? false;
      _showMap = true;
      _showRideDetails = true;
      _isLoading = false;
    });

    _priceController.text = (_distance * 0.5).toStringAsFixed(2);

    if (directionsResult['isFallback'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Showing approximate route (no traffic data).'),
          duration: Duration(seconds: 5),
        ),
      );
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(300, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      }
    });
  } catch (e) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error showing route: $e')));
  }
}

  Future<void> _updateRouteWithDepartureTime() async {
  if (_departureLocation == null || _destinationLocation == null) return;

  setState(() => _isLoading = true);

  try {
    final departureDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final directionsResult = await DirectionsService.getDirections(
      origin: _departureLocation!,
      destination: _destinationLocation!,
      departureTime: departureDateTime,
    );

    setState(() {
      _polylines = {directionsResult['polyline']};
      _distance = directionsResult['distance'];
      _duration = directionsResult['duration'];
      _isTrafficEstimate = directionsResult['isTrafficEstimate'] ?? false;
      _isLoading = false;
    });
  } catch (e) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating route: $e')));
  }
}

Future<void> _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: _selectedDate,
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
  );
  if (picked != null && picked != _selectedDate) {
    setState(() => _selectedDate = picked);
    if (_departureLocation != null && _destinationLocation != null) {
      await _updateRouteWithDepartureTime();
    }
  }
}

Future<void> _selectTime(BuildContext context) async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: _selectedTime,
  );
  if (picked != null && picked != _selectedTime) {
    setState(() => _selectedTime = picked);
    if (_departureLocation != null && _destinationLocation != null) {
      await _updateRouteWithDepartureTime();
    }
  }
}
  Future<void> _submitRideOffer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Combine date and time
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final rideOffer = RideOffer(
        departureLat: _departureLocation!.latitude,
        departureLng: _departureLocation!.longitude,
        destinationLat: _destinationLocation!.latitude,
        destinationLng: _destinationLocation!.longitude,
        from: _departureAddress!,
        to: _destinationAddress!,
        dateTime: dateTime,
        availableSeats: _availableSeats,
        price: double.parse(_priceController.text),
        description: _descriptionController.text,
        // You would typically get these from user authentication
        driverName: 'Current User',
        driverId: 'user_id',
      );

      final id = await ObjectBoxDb.saveRideOffer(rideOffer);
      
      if (id > 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ride offer posted successfully!')),
          );
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to post ride offer')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offer a Ride'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Text(
                      'Where are you going?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your departure and destination to offer a ride',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Departure location
                    _buildLocationCard(
                      title: 'Departure',
                      address: _departureAddress,
                      placeholder: 'Where are you departing from?',
                      icon: Icons.trip_origin,
                      iconColor: Colors.blue,
                      onTap: _selectDepartureLocation,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Destination location
                    _buildLocationCard(
                      title: 'Destination',
                      address: _destinationAddress,
                      placeholder: 'Where are you going?',
                      icon: Icons.location_on,
                      iconColor: Colors.red,
                      onTap: _selectDestinationLocation,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Map view
                    if (_showMap && _departureLocation != null && _destinationLocation != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Interactive Route Navigation',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Map container
                          Container(
                            height: 350,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: EnhancedRouteMapWidget(
                              origin: _departureLocation,
                              destination: _destinationLocation,
                              height: 350,
                              onRouteUpdated: (duration, distance) {
                                setState(() {
                                  _duration = duration;
                                  _distance = distance;
                                });
                              },
                              showAlternativeRoutes: true,
                              showTurnByTurnMarkers: true,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                         Card(
  elevation: 2,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.straighten, size: 18, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Distance', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('${_distance.toStringAsFixed(1)} km', 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 4),
                  const Icon(Icons.sync, size: 14, color: Colors.green),
                ],
              ),
            ],
          ),
        ),
        Container(height: 40, width: 1, color: Colors.grey.shade300),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.access_time, size: 18, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Est. Duration', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(_duration, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 4),
                    const Icon(Icons.sync, size: 14, color: Colors.green),
                  ],
                ),
                const Text(
                  '(real-time traffic)',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
),
                          const SizedBox(height: 24),
                        ],
                      ),
                    
                    // Ride details section
                    if (_showRideDetails)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ride Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Date and time section
                          const Text(
                            'When are you leaving?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Date picker
                          Row(
                            children: [
                              // Date picker
                              Expanded(
                                flex: 3,
                                child: InkWell(
                                  onTap: () => _selectDate(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 20),
                                        const SizedBox(width: 12),
                                        Text(
                                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 12),
                              
                              // Time picker
                              Expanded(
                                flex: 2,
                                child: InkWell(
                                  onTap: () => _selectTime(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 20),
                                        const SizedBox(width: 12),
                                        Text(
                                          _selectedTime.format(context),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Available seats
                          const Text(
                            'How many seats are available?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (_availableSeats > 1) {
                                    setState(() {
                                      _availableSeats--;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.remove_circle_outline),
                                color: Colors.blue,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$_availableSeats',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  if (_availableSeats < 8) {
                                    setState(() {
                                      _availableSeats++;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.add_circle_outline),
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              const Text('seats'),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Price
                          const Text(
                            'Price per passenger',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Price',
                              prefixIcon: const Icon(Icons.attach_money),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a price';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Description
                          const Text(
                            'Additional information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Add any details about your ride...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitRideOffer,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Post Ride Offer',
                                      style: TextStyle(fontSize: 16),
                                    ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationCard({
    required String title,
    required String? address,
    required String placeholder,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address ?? placeholder,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: address != null ? Colors.black : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
