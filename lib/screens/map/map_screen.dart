import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async'; // Import for TimeoutException
import 'package:geocoding/geocoding.dart';

class MapScreen extends StatefulWidget {
  final String? departure;
  final String? destination;

  const MapScreen({
    super.key,
    this.departure,
    this.destination,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  String? _errorMessage;
  LatLng? _departureLatLng;
  LatLng? _destinationLatLng;

  // Initial camera position set to Bujumbura, Burundi as a fallback
  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(-3.3732, 29.3623),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add observer
    _requestLocationPermissionAndGetLocation();
    _geocodeAddresses();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _requestLocationPermissionAndGetLocation(); // Re-check on resume
    }
  }

  Future<void> _requestLocationPermissionAndGetLocation() async {
    try {
      debugPrint("Requesting location permission...");
      
      // Check if location services are enabled first
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog(); // Prompt to enable location services
        _handleLocationError('Location services are disabled. Please enable them in your device settings.');
        return;
      }

      // Request location permission
      PermissionStatus permissionStatus = await Permission.location.request();
      
      debugPrint("Permission status: $permissionStatus");
      
      if (permissionStatus == PermissionStatus.granted) {
        // Permission granted, get location
        await _getCurrentLocation();
      } else if (permissionStatus == PermissionStatus.denied) {
        _handleLocationError('Location permission denied. Please grant location permission to use this feature.');
      } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
        _handleLocationError('Location permission permanently denied. Please enable it in app settings.');
        _showSettingsDialog();
      } else if (permissionStatus == PermissionStatus.restricted) {
        _handleLocationError('Location permission restricted.');
      } else {
        _handleLocationError('Location permission status: $permissionStatus');
      }
    } catch (e) {
      debugPrint("Error requesting permission: $e");
      _handleLocationError('Failed to request location permission: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      debugPrint("Starting location fetch...");
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _handleLocationError('Location services are disabled. Please enable them in your device settings.');
        _showLocationServiceDialog(); // Show dialog if service is disabled
        return;
      }

      debugPrint("Location services enabled, getting position...");
      
      // Get current position with timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15), // Increased timeout
      );

      debugPrint("Got position: ${position.latitude}, ${position.longitude}");

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false;
          _errorMessage = null;
        });

        // Animate camera to the new position if controller is available
        if (_mapController != null) {
          await _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 15.0,
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
      if (e is TimeoutException) {
        _handleLocationError('Failed to get location within the time limit. Please check your network connection and GPS signal, and try again.');
      } else {
        _handleLocationError('Failed to get location: ${e.toString()}');
      }
    }
  }

  void _handleLocationError(String message) {
    debugPrint("Location error: $message");
    if (mounted) {
      setState(() {
        _isLoadingLocation = false;
        _errorMessage = message;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enable Location Services'),
          content: const Text(
            'Location services are disabled on your device. Please enable them to allow the app to access your location.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
              },
              child: const Text('Open Location Settings'),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Permission Required'),
          content: Text(
            'This app needs location permission to show your current location on the map. Please enable location permission in app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings(); // Opens app settings
              },
              child: Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _retryLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _errorMessage = null;
    });
    
    // Check if location services are enabled first
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceDialog(); // Prompt to enable location services
      _handleLocationError('Location services are disabled. Please enable them in your device settings.');
      return;
    }

    // Check permission status
    PermissionStatus status = await Permission.location.status;
    
    if (status == PermissionStatus.granted) {
      await _getCurrentLocation();
    } else {
      await _requestLocationPermissionAndGetLocation();
    }
  }

  Future<void> _geocodeAddresses() async {
    try {
      if (widget.departure != null && widget.departure!.isNotEmpty) {
        List<Location> locations = await locationFromAddress(widget.departure!);
        if (locations.isNotEmpty) {
          setState(() {
            _departureLatLng = LatLng(locations.first.latitude, locations.first.longitude);
          });
        }
      }
      if (widget.destination != null && widget.destination!.isNotEmpty) {
        List<Location> locations = await locationFromAddress(widget.destination!);
        if (locations.isNotEmpty) {
          setState(() {
            _destinationLatLng = LatLng(locations.first.latitude, locations.first.longitude);
          });
        }
      }
      _updateCameraToBounds();
    } catch (e) {
      debugPrint("Error geocoding addresses: $e");
    }
  }

  void _updateCameraToBounds() {
    if (_mapController != null && _departureLatLng != null && _destinationLatLng != null) {
      LatLngBounds bounds;
      if (_departureLatLng!.latitude > _destinationLatLng!.latitude) {
        bounds = LatLngBounds(
          southwest: _destinationLatLng!,
          northeast: _departureLatLng!,
        );
      } else {
        bounds = LatLngBounds(
          southwest: _departureLatLng!,
          northeast: _destinationLatLng!,
        );
      }
      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));
    } else if (_mapController != null && _departureLatLng != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(_departureLatLng!));
    } else if (_mapController != null && _destinationLatLng != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(_destinationLatLng!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              debugPrint("Map created");
              _mapController = controller;
              if (_currentPosition != null) {
                _mapController!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      zoom: 15.0,
                    ),
                  ),
                );
              } else if (_departureLatLng != null || _destinationLatLng != null) {
                _updateCameraToBounds();
              }
            },
            initialCameraPosition: _currentPosition != null
                ? CameraPosition(
                    target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    zoom: 15.0,
                  )
                : _initialCameraPosition,
            myLocationEnabled: _currentPosition != null, // Only enable if we have permission
            myLocationButtonEnabled: _currentPosition != null,
            markers: Set<Marker>.of([
              if (_currentPosition != null)
                Marker(
                  markerId: const MarkerId('currentLocation'),
                  position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                  infoWindow: const InfoWindow(title: 'Your Location'),
                ),
              if (_departureLatLng != null)
                Marker(
                  markerId: const MarkerId('departureLocation'),
                  position: _departureLatLng!,
                  infoWindow: const InfoWindow(title: 'Departure'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                ),
              if (_destinationLatLng != null)
                Marker(
                  markerId: const MarkerId('destinationLocation'),
                  position: _destinationLatLng!,
                  infoWindow: const InfoWindow(title: 'Destination'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                ),
            ]),
          ),
          // Show loading indicator
          if (_isLoadingLocation)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Getting your location...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Show error message with retry button
          if (_errorMessage != null && !_isLoadingLocation)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_off, size: 48, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'Location Error',
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: _retryLocation,
                              child: Text('Retry'),
                            ),
                            SizedBox(width: 8),
                            if (_errorMessage!.contains('permanently denied'))
                              ElevatedButton(
                                onPressed: () => openAppSettings(),
                                child: Text('Settings'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}