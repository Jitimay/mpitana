import 'dart:async';
import 'dart:math' show cos, sqrt, asin;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mpitana/screens/offerRide/services/enhanced_directions_service.dart';
import 'package:mpitana/common/utils/map_marker_utils.dart';

class EnhancedRouteMapWidget extends StatefulWidget {
  final LatLng? origin;
  final LatLng? destination;
  final double height;
  final Function(String, double)? onRouteUpdated;
  final bool trackUserLocation;
  final bool showAlternativeRoutes;
  final bool showTurnByTurnMarkers;

  const EnhancedRouteMapWidget({
    Key? key,
    this.origin,
    this.destination,
    this.height = 300,
    this.onRouteUpdated,
    this.trackUserLocation = true,
    this.showAlternativeRoutes = true,
    this.showTurnByTurnMarkers = true,
  }) : super(key: key);

  @override
  State<EnhancedRouteMapWidget> createState() => _EnhancedRouteMapWidgetState();
}

class _EnhancedRouteMapWidgetState extends State<EnhancedRouteMapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoading = false;
  String _travelTimeText = '';
  double _distance = 0.0;
  
  // Location tracking
  Location _locationService = Location();
  LocationData? _currentLocation;
  StreamSubscription<LocationData>? _locationSubscription;
  bool _isFirstLocationUpdate = true;
  Timer? _routeUpdateTimer;
  List<LatLng> _routePolylinePoints = [];
  
  // Turn-by-turn directions
  List<Map<String, dynamic>> _turnByTurnDirections = [];
  List<Marker> _stepMarkers = [];
  bool _showDirectionsList = false;
  int _selectedDirectionIndex = -1;
  
  // UI elements
  BitmapDescriptor _originIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  BitmapDescriptor _destinationIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  BitmapDescriptor _currentLocationIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  bool _customMarkersLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers();
    _setupLocationService();
    _updateRoute();
  }

  @override
  void didUpdateWidget(EnhancedRouteMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.origin != oldWidget.origin || widget.destination != oldWidget.destination) {
      _updateRoute();
    }
    
    if (widget.trackUserLocation != oldWidget.trackUserLocation) {
      if (widget.trackUserLocation) {
        _setupLocationService();
      } else {
        _stopLocationUpdates();
      }
    }
  }

  @override
  void dispose() {
    _stopLocationUpdates();
    _routeUpdateTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadCustomMarkers() async {
    try {
      final currentLocationMarker = await MapMarkerUtils.createCurrentLocationMarker();
      final originMarker = await MapMarkerUtils.createRoutePointMarker(
        isOrigin: true, 
        label: 'Departure'
      );
      final destinationMarker = await MapMarkerUtils.createRoutePointMarker(
        isOrigin: false,
        label: 'Destination'
      );
      
      setState(() {
        _currentLocationIcon = currentLocationMarker;
        _originIcon = originMarker;
        _destinationIcon = destinationMarker;
        _customMarkersLoaded = true;
      });
      
      // Update markers if they're already on the map
      if (_markers.isNotEmpty) {
        _updateMarkers();
      }
    } catch (e) {
      debugPrint('Error loading custom markers: $e');
    }
  }

  Future<void> _setupLocationService() async {
    if (!widget.trackUserLocation) return;
    
    try {
      // Check if location service is enabled
      bool serviceEnabled = await _locationService.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationService.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      // Check for location permission
      PermissionStatus permissionGranted = await _locationService.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _locationService.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      // Configure location service
      await _locationService.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 5000, // Update every 5 seconds
        distanceFilter: 10, // Update if moved at least 10 meters
      );

      // Get initial location
      _currentLocation = await _locationService.getLocation();
      
      // Start listening to location updates
      _locationSubscription = _locationService.onLocationChanged.listen(_onLocationChanged);
      
      // Start periodic route updates
      _routeUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        if (_currentLocation != null && widget.destination != null) {
          _updateDynamicRoute();
        }
      });
    } catch (e) {
      debugPrint('Error setting up location service: $e');
    }
  }

  void _stopLocationUpdates() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _routeUpdateTimer?.cancel();
    _routeUpdateTimer = null;
  }

  void _onLocationChanged(LocationData locationData) {
    setState(() {
      _currentLocation = locationData;
      
      // Update current location marker
      _updateCurrentLocationMarker();
      
      // If this is the first location update and we don't have an origin set,
      // use the current location as origin
      if (_isFirstLocationUpdate && widget.origin == null && widget.destination != null) {
        _isFirstLocationUpdate = false;
        _updateDynamicRoute();
      }
    });
    
    // Update the camera position to follow the user if tracking is enabled
    if (widget.trackUserLocation && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(locationData.latitude!, locationData.longitude!),
        ),
      );
    }
  }

  void _updateCurrentLocationMarker() {
    if (_currentLocation == null) return;
    
    // Remove old current location marker if it exists
    _markers.removeWhere((marker) => marker.markerId.value == 'current_location');
    
    // Add new current location marker
    _markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        icon: _currentLocationIcon,
        rotation: _currentLocation!.heading ?? 0,
        infoWindow: const InfoWindow(title: 'Current Location'),
        zIndex: 2, // Ensure it's above other markers
      ),
    );
  }

  void _updateMarkers() {
    if (widget.origin == null || widget.destination == null) return;
    
    // Clear existing origin and destination markers
    _markers.removeWhere((marker) => 
      marker.markerId.value == 'origin' || 
      marker.markerId.value == 'destination'
    );
    
    // Add origin marker
    _markers.add(
      Marker(
        markerId: const MarkerId('origin'),
        position: widget.origin!,
        icon: _originIcon,
        infoWindow: const InfoWindow(title: 'Departure'),
        zIndex: 1,
      ),
    );
    
    // Add destination marker
    _markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: widget.destination!,
        icon: _destinationIcon,
        infoWindow: const InfoWindow(title: 'Destination'),
        zIndex: 1,
      ),
    );
    
    // Add step markers if enabled
    if (widget.showTurnByTurnMarkers) {
      _markers.addAll(_stepMarkers);
    }
  }

  Future<void> _updateRoute() async {
    if (widget.origin == null || widget.destination == null) {
      setState(() {
        _markers = {};
        _polylines = {};
        _travelTimeText = '';
        _turnByTurnDirections = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _updateMarkers();
      
      // Add current location marker if available
      if (_currentLocation != null) {
        _updateCurrentLocationMarker();
      }
    });

    try {
      // Get directions between origin and destination
      final directionsResult = await EnhancedDirectionsService.getDirections(
        origin: widget.origin!,
        destination: widget.destination!,
        alternatives: widget.showAlternativeRoutes,
      );

      setState(() {
        // Use all polylines if available, otherwise just the main one
        _polylines = directionsResult.containsKey('polylines') 
            ? directionsResult['polylines'] 
            : {directionsResult['polyline']};
            
        _distance = directionsResult['distance'];
        _travelTimeText = directionsResult['duration'];
        _routePolylinePoints = directionsResult['polylineCoordinates'];
        
        // Store turn-by-turn directions and step markers
        _turnByTurnDirections = List<Map<String, dynamic>>.from(
          directionsResult['turnByTurnDirections'] ?? []
        );
        _stepMarkers = List<Marker>.from(directionsResult['stepMarkers'] ?? []);
        
        // Update markers to include step markers if enabled
        if (widget.showTurnByTurnMarkers) {
          _updateMarkers();
        }
        
        _isLoading = false;
      });

      // Notify parent about the route update
      if (widget.onRouteUpdated != null) {
        widget.onRouteUpdated!(_travelTimeText, _distance);
      }

      // Adjust camera to show the entire route
      if (_mapController != null) {
        final bounds = _calculateBounds(_routePolylinePoints);
        _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 50),
        );
      }
    } catch (e) {
      debugPrint('Error updating route: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateDynamicRoute() async {
    if (_currentLocation == null || widget.destination == null) return;
    
    final currentPosition = LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
    
    try {
      // Get updated directions from current location to destination
      final directionsResult = await EnhancedDirectionsService.getDirections(
        origin: currentPosition,
        destination: widget.destination!,
        alternatives: widget.showAlternativeRoutes,
      );

      setState(() {
        // Use all polylines if available, otherwise just the main one
        _polylines = directionsResult.containsKey('polylines') 
            ? directionsResult['polylines'] 
            : {directionsResult['polyline']};
            
        _distance = directionsResult['distance'];
        _travelTimeText = directionsResult['duration'];
        _routePolylinePoints = directionsResult['polylineCoordinates'];
        
        // Store turn-by-turn directions and step markers
        _turnByTurnDirections = List<Map<String, dynamic>>.from(
          directionsResult['turnByTurnDirections'] ?? []
        );
        _stepMarkers = List<Marker>.from(directionsResult['stepMarkers'] ?? []);
        
        // Update markers to include step markers if enabled
        if (widget.showTurnByTurnMarkers) {
          _updateMarkers();
        }
      });

      // Notify parent about the route update
      if (widget.onRouteUpdated != null) {
        widget.onRouteUpdated!(_travelTimeText, _distance);
      }
    } catch (e) {
      debugPrint('Error updating dynamic route: $e');
    }
  }

  void _onMapTapped(LatLng position) {
    // Find the closest point on the route to where the user tapped
    if (_routePolylinePoints.isEmpty) return;
    
    // Show directions panel when map is tapped
    setState(() {
      _showDirectionsList = true;
    });
    
    // Find the closest route segment to the tap position
    double minDistance = double.infinity;
    int closestPointIndex = 0;
    
    for (int i = 0; i < _routePolylinePoints.length; i++) {
      final point = _routePolylinePoints[i];
      final distance = _calculateDistance(
        position.latitude, 
        position.longitude, 
        point.latitude, 
        point.longitude
      );
      
      if (distance < minDistance) {
        minDistance = distance;
        closestPointIndex = i;
      }
    }
    
    // Zoom in to the route segment
    if (_mapController != null) {
      // Calculate a good zoom level based on the route segment
      final zoomLevel = 16.0; // Higher zoom level for more detail
      
      // Get the point on the route closest to the tap
      final targetPoint = _routePolylinePoints[closestPointIndex];
      
      // Animate to that point with increased zoom
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(targetPoint, zoomLevel),
      );
      
      // Find the closest direction step to this point
      if (_turnByTurnDirections.isNotEmpty) {
        double minStepDistance = double.infinity;
        int closestStepIndex = 0;
        
        for (int i = 0; i < _turnByTurnDirections.length; i++) {
          final step = _turnByTurnDirections[i];
          if (step['position'] != null) {
            final stepPosition = step['position'] as LatLng;
            final distance = _calculateDistance(
              targetPoint.latitude,
              targetPoint.longitude,
              stepPosition.latitude,
              stepPosition.longitude
            );
            
            if (distance < minStepDistance) {
              minStepDistance = distance;
              closestStepIndex = i;
            }
          }
        }
        
        // Highlight this step in the directions list
        setState(() {
          _selectedDirectionIndex = closestStepIndex;
        });
      }
    }
  }

  /// Calculate distance between two coordinates using the Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    if (points.isEmpty) {
      // Fallback if no points
      return LatLngBounds(
        southwest: widget.origin ?? const LatLng(0, 0),
        northeast: widget.destination ?? const LatLng(0, 0),
      );
    }
    
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    // Include current location in bounds if available
    if (_currentLocation != null) {
      final lat = _currentLocation!.latitude!;
      final lng = _currentLocation!.longitude!;
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _toggleDirectionsList() {
    setState(() {
      _showDirectionsList = !_showDirectionsList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.origin ?? const LatLng(-3.3732, 29.3623), // Default to Bujumbura
                zoom: 13,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                if (widget.origin != null && widget.destination != null) {
                  _updateRoute();
                }
              },
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              mapToolbarEnabled: true,
              compassEnabled: true,
              trafficEnabled: true,
              onTap: _onMapTapped,
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (_travelTimeText.isNotEmpty)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.directions_car, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            _travelTimeText,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.straighten, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            '${_distance.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (_currentLocation != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              const Icon(Icons.speed, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                'Speed: ${(_currentLocation!.speed! * 3.6).toStringAsFixed(1)} km/h',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const Spacer(),
                              const Icon(Icons.update, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              const Text(
                                'Live updates',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      if (_turnByTurnDirections.isNotEmpty)
                        TextButton(
                          onPressed: _toggleDirectionsList,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _showDirectionsList 
                                    ? Icons.keyboard_arrow_down 
                                    : Icons.keyboard_arrow_up,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _showDirectionsList 
                                    ? 'Hide directions' 
                                    : 'Show turn-by-turn directions',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      if (_showDirectionsList && _turnByTurnDirections.isNotEmpty)
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.3,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: List.generate(_turnByTurnDirections.length, (index) {
                                final step = _turnByTurnDirections[index];
                                final isSelected = index == _selectedDirectionIndex;
                                
                                return Container(
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.blue.withOpacity(0.1) : null,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ListTile(
                                    dense: true,
                                    leading: _getIconForManeuver(step['maneuver'] ?? ''),
                                    title: Text(
                                      step['instruction'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${step['distance']} · ${step['duration']}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isSelected ? Colors.blue : Colors.grey,
                                      ),
                                    ),
                                    onTap: () {
                                      if (_mapController != null && step['position'] != null) {
                                        final position = step['position'] as LatLng;
                                        _mapController!.animateCamera(
                                          CameraUpdate.newLatLngZoom(position, 16),
                                        );
                                        setState(() {
                                          _selectedDirectionIndex = index;
                                        });
                                      }
                                    },
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            // Map control buttons
            Positioned(
              top: 16,
              right: 16,
              child: Column(
                children: [
                  // Recenter button
                  FloatingActionButton(
                    heroTag: "btn1",
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: () {
                      if (_currentLocation != null && _mapController != null) {
                        _mapController!.animateCamera(
                          CameraUpdate.newLatLngZoom(
                            LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
                            15,
                          ),
                        );
                      }
                    },
                    child: const Icon(Icons.my_location, color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  // Show full route button
                  FloatingActionButton(
                    heroTag: "btn2",
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: () {
                      if (_mapController != null && _routePolylinePoints.isNotEmpty) {
                        final bounds = _calculateBounds(_routePolylinePoints);
                        _mapController!.animateCamera(
                          CameraUpdate.newLatLngBounds(bounds, 50),
                        );
                      }
                    },
                    child: const Icon(Icons.route, color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  // Toggle directions button
                  FloatingActionButton(
                    heroTag: "btn3",
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: () {
                      _toggleDirectionsList();
                    },
                    child: Icon(
                      _showDirectionsList ? Icons.directions_off : Icons.directions,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            // Tap to view directions hint
            if (!_showDirectionsList)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.touch_app, size: 16, color: Colors.blue),
                      SizedBox(width: 4),
                      Text(
                        'Tap map for directions',
                        style: TextStyle(fontSize: 12),
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
  
  Widget _getIconForManeuver(String maneuver) {
    IconData iconData;
    Color color;
    
    switch (maneuver) {
      case 'turn-right':
        iconData = Icons.turn_right;
        color = Colors.green;
        break;
      case 'turn-slight-right':
        iconData = Icons.turn_slight_right;
        color = Colors.green;
        break;
      case 'turn-sharp-right':
        iconData = Icons.turn_sharp_right;
        color = Colors.green;
        break;
      case 'turn-left':
        iconData = Icons.turn_left;
        color = Colors.orange;
        break;
      case 'turn-slight-left':
        iconData = Icons.turn_slight_left;
        color = Colors.orange;
        break;
      case 'turn-sharp-left':
        iconData = Icons.turn_sharp_left;
        color = Colors.orange;
        break;
      case 'roundabout-right':
      case 'roundabout-left':
      case 'roundabout':
        iconData = Icons.roundabout_left;
        color = Colors.yellow;
        break;
      case 'uturn-right':
      case 'uturn-left':
      case 'uturn':
        iconData = Icons.u_turn_left;
        color = Colors.red;
        break;
      case 'ramp-right':
      case 'ramp-left':
        iconData = Icons.fork_right;
        color = Colors.cyan;
        break;
      case 'merge':
        iconData = Icons.merge;
        color = Colors.cyan;
        break;
      case 'fork-right':
      case 'fork-left':
        iconData = Icons.fork_right;
        color = Colors.cyan;
        break;
      case 'straight':
        iconData = Icons.straight;
        color = Colors.blue;
        break;
      default:
        iconData = Icons.arrow_forward;
        color = Colors.blue;
        break;
    }
    
    return Icon(iconData, color: color, size: 20);
  }
}
