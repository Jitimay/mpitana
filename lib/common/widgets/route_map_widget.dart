import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mpitana/common/services/route_service.dart';

class RouteMapWidget extends StatefulWidget {
  final LatLng? origin;
  final LatLng? destination;
  final double height;
  final Function(String)? onTravelTimeCalculated;

  const RouteMapWidget({
    Key? key,
    this.origin,
    this.destination,
    this.height = 200,
    this.onTravelTimeCalculated,
  }) : super(key: key);

  @override
  State<RouteMapWidget> createState() => _RouteMapWidgetState();
}

class _RouteMapWidgetState extends State<RouteMapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoading = false;
  String _travelTimeText = '';

  @override
  void initState() {
    super.initState();
    _updateRoute();
  }

  @override
  void didUpdateWidget(RouteMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.origin != oldWidget.origin || widget.destination != oldWidget.destination) {
      _updateRoute();
    }
  }

  Future<void> _updateRoute() async {
    if (widget.origin == null || widget.destination == null) {
      setState(() {
        _markers = {};
        _polylines = {};
        _travelTimeText = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _markers = {
        Marker(
          markerId: const MarkerId('origin'),
          position: widget.origin!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
        Marker(
          markerId: const MarkerId('destination'),
          position: widget.destination!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      };
    });

    try {
      // Get polyline points for the route
      final polylinePoints = await RouteService.getPolylinePoints(
        widget.origin!,
        widget.destination!,
      );

      // Calculate distance and travel time
      final distance = RouteService.calculateDistance(widget.origin!, widget.destination!);
      final travelTimeMinutes = RouteService.calculateTravelTime(distance);
      final travelTimeFormatted = RouteService.formatTravelTime(travelTimeMinutes);

      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: polylinePoints,
            color: Colors.blue,
            width: 5,
          ),
        };
        _travelTimeText = 'Est. travel time: $travelTimeFormatted';
      });

      // Notify parent about the calculated travel time
      if (widget.onTravelTimeCalculated != null) {
        widget.onTravelTimeCalculated!(travelTimeFormatted);
      }

      // Adjust camera to show the entire route
      if (_mapController != null) {
        final bounds = _calculateBounds(polylinePoints);
        _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 50),
        );
      }
    } catch (e) {
      debugPrint('Error updating route: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
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

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
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
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.directions_car, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        _travelTimeText,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
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
}
