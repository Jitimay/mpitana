import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mpitana/screens/offerRide/services/directions_service.dart';

class RouteMapScreen extends StatefulWidget {
  final LatLng departureLocation;
  final LatLng destinationLocation;
  final String departureAddress;
  final String destinationAddress;

  const RouteMapScreen({
    super.key,
    required this.departureLocation,
    required this.destinationLocation,
    required this.departureAddress,
    required this.destinationAddress,
  });

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  double _distance = 0.0;
  String _duration = '';
  bool _isLoading = false;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _setMarkers();
    _getDirections();
  }

  void _setMarkers() {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('departure'),
          position: widget.departureLocation,
          infoWindow: InfoWindow(
            title: 'Departure',
            snippet: widget.departureAddress,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
        Marker(
          markerId: const MarkerId('destination'),
          position: widget.destinationLocation,
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: widget.destinationAddress,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      };
    });
  }

  Future<void> _getDirections() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final directions = await DirectionsService.getDirections(
        origin: widget.departureLocation,
        destination: widget.destinationLocation,
      );

      setState(() {
        _polylines.add(directions['polyline']);
        _distance = directions['distance'];
        _duration = directions['duration'];
        _isLoading = false;
      });

      // Fit the map to show the route
      if (_mapController != null) {
        _fitMapToRoute(directions['polylineCoordinates']);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading route: $e')),
        );
      }
    }
  }

  void _fitMapToRoute(List<LatLng> coordinates) {
    if (coordinates.isEmpty || _mapController == null) return;

    double minLat = coordinates.first.latitude;
    double maxLat = coordinates.first.latitude;
    double minLng = coordinates.first.longitude;
    double maxLng = coordinates.first.longitude;

    for (LatLng coord in coordinates) {
      minLat = minLat < coord.latitude ? minLat : coord.latitude;
      maxLat = maxLat > coord.latitude ? maxLat : coord.latitude;
      minLng = minLng < coord.longitude ? minLng : coord.longitude;
      maxLng = maxLng > coord.longitude ? maxLng : coord.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getDirections,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
              // Delay to ensure polyline is loaded
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_polylines.isNotEmpty) {
                  _fitMapToRoute(_polylines.first.points);
                }
              });
            },
            initialCameraPosition: CameraPosition(
              target: widget.departureLocation,
              zoom: 12,
            ),
            markers: _markers,
            polylines: _polylines,
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading route...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.departureAddress,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.destinationAddress,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.straighten, color: Colors.grey, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_distance.toStringAsFixed(1)} km',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, color: Colors.grey, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    _duration.isEmpty ? 'Calculating...' : _duration,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : () {
                            Navigator.pop(context, _distance);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: const Text('Continue'),
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
    );
  }
}