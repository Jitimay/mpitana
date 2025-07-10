import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  String? _errorMessage;

  // Initial camera position set to Bujumbura, Burundi as a fallback
  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(-3.3732, 29.3623),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _requestLocationPermissionAndGetLocation();
  }

  Future<void> _requestLocationPermissionAndGetLocation() async {
    try {
      debugPrint("Requesting location permission...");
      
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
      _handleLocationError('Failed to get location: ${e.toString()}');
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
    
    // Check permission status first
    PermissionStatus status = await Permission.location.status;
    
    if (status == PermissionStatus.granted) {
      await _getCurrentLocation();
    } else {
      await _requestLocationPermissionAndGetLocation();
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
              // If we already have the location, animate to it
              if (_currentPosition != null) {
                _mapController!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      zoom: 15.0,
                    ),
                  ),
                );
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
            markers: _currentPosition != null
                ? {
                    Marker(
                      markerId: const MarkerId('currentLocation'),
                      position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      infoWindow: const InfoWindow(title: 'Your Location'),
                    ),
                  }
                : {},
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