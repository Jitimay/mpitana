import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mpitana/screens/offerRide/services/location_service.dart';
import 'package:mpitana/screens/offerRide/models/location.dart' as location_model;

class LocationPickerScreen extends StatefulWidget {
  final bool isDeparture;

  const LocationPickerScreen({super.key, required this.isDeparture});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedPosition;
  final TextEditingController _searchController = TextEditingController();
  Position? _currentPosition;
  String? _selectedAddress;
  List<location_model.Location> _recentLocations = [];
  bool _isLoading = false;

  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(-3.3732, 29.3623), // Default location (e.g., Bujumbura)
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _loadRecentLocations();
    if (widget.isDeparture) {
      _getCurrentLocation();
    }
  }

  Future<void> _loadRecentLocations() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final locations = await LocationService.getRecentLocations(
        isDeparture: widget.isDeparture,
      );
      
      setState(() {
        _recentLocations = locations;
      });
    } catch (e) {
      debugPrint('Error loading recent locations: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services')),
        );
        return;
      }
      PermissionStatus permissionStatus = await Permission.location.request();
      if (permissionStatus == PermissionStatus.granted) {
        setState(() {
          _isLoading = true;
        });
        
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        
        setState(() {
          _currentPosition = position;
          _selectedPosition = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
        
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _selectedPosition!,
              zoom: 15.0,
            ),
          ),
        );
        
        _getAddressFromLatLng(_selectedPosition!);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  Future<void> _searchLocation() async {
    if (_searchController.text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      List<Location> locations = await locationFromAddress(_searchController.text);
      if (locations.isNotEmpty) {
        final location = locations.first;
        setState(() {
          _selectedPosition = LatLng(location.latitude, location.longitude);
        });
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _selectedPosition!,
              zoom: 15.0,
            ),
          ),
        );
        _getAddressFromLatLng(_selectedPosition!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching location: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
    _getAddressFromLatLng(position);
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _selectedAddress = "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
  }

  void _selectRecentLocation(location_model.Location location) {
    setState(() {
      _selectedPosition = LatLng(location.latitude, location.longitude);
      _selectedAddress = location.address;
    });
    
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _selectedPosition!,
          zoom: 15.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isDeparture ? 'Where are you departing from?' : 'Where are you going?'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for a location',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onSubmitted: (_) => _searchLocation(),
                  ),
                ),
                if (widget.isDeparture)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.my_location),
                      label: const Text('Current'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Recent locations
          if (_recentLocations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent locations',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _recentLocations.length,
                      itemBuilder: (context, index) {
                        final location = _recentLocations[index];
                        return GestureDetector(
                          onTap: () => _selectRecentLocation(location),
                          child: Container(
                            width: 200,
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.history,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        location.address,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  location.city ?? '',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          
          // Map
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: _currentPosition != null
                      ? CameraPosition(
                          target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                          zoom: 15.0,
                        )
                      : _initialCameraPosition,
                  onTap: _onMapTap,
                  markers: _selectedPosition != null
                      ? {
                          Marker(
                            markerId: const MarkerId('selected'),
                            position: _selectedPosition!,
                            infoWindow: InfoWindow(
                              title: _selectedAddress ?? 'Selected Location',
                            ),
                          ),
                        }
                      : {},
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
                
                // Loading indicator
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                
                // Selected address display
                if (_selectedAddress != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedAddress!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (_selectedPosition != null) {
                                      Navigator.pop(context, _selectedPosition);
                                    }
                                  },
                                  child: const Text('Select this location'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
