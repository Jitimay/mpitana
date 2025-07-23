import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:math' show cos, sqrt, asin;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mpitana/common/config/maps_config.dart';

class EnhancedDirectionsService {
  // Use API key from central configuration
  static String get _apiKey => MapsConfig.apiKey;

  /// Get route between two points, optionally with traffic data for a future departure time
  static Future<Map<String, dynamic>> getDirections({
    required LatLng origin,
    required LatLng destination,
    DateTime? departureTime,
    bool alternatives = true,
  }) async {
    try {
      debugPrint('=== DIRECTIONS SERVICE DEBUG ===');
      debugPrint('API Key available: ${_apiKey.isNotEmpty}');
      debugPrint('API Key length: ${_apiKey.length}');
      debugPrint('Getting directions between: ${origin.latitude},${origin.longitude} and ${destination.latitude},${destination.longitude}');

      // Validate API key
      if (_apiKey.isEmpty) {
        debugPrint('ERROR: API key is empty!');
        return _getFallbackStraightLine(origin, destination);
      }

      // Try direct API call first as it's more reliable
      final directApiResult = await _getDetailedRouteUsingDirectApi(
        origin, 
        destination, 
        departureTime,
        alternatives,
      );

      debugPrint('Direct API result isFallback: ${directApiResult['isFallback']}');

      // If direct API call fails, try using the package
      if (directApiResult['isFallback'] == true) {
        debugPrint('Direct API call failed, trying package method');
        final packageResult = await _getPolylineUsingPackage(origin, destination);
        if (packageResult['polylineCoordinates'].isNotEmpty) {
          debugPrint('Package method succeeded');
          return packageResult;
        }
        debugPrint('Package method also failed');
      } else {
        debugPrint('Direct API call succeeded');
        return directApiResult;
      }

      // If both methods fail, return fallback
      debugPrint('Both methods failed, using fallback');
      return _getFallbackStraightLine(origin, destination);
    } catch (e) {
      debugPrint('Error getting directions: $e');
      return _getFallbackStraightLine(origin, destination);
    }
  }

  /// Get detailed route information by directly calling the Google Directions API
  static Future<Map<String, dynamic>> _getDetailedRouteUsingDirectApi(
    LatLng origin,
    LatLng destination,
    DateTime? departureTime,
    bool alternatives,
  ) async {
    String departureTimeParam = '';
    if (departureTime != null) {
      final timestamp = (departureTime.millisecondsSinceEpoch / 1000).round();
      departureTimeParam = '&departure_time=$timestamp';
    }

    final String url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=driving'
        '&alternatives=${alternatives ? 'true' : 'false'}'
        '$departureTimeParam'
        '&key=$_apiKey';

    // Don't log the full URL with API key for security
    debugPrint('Calling Directions API directly...');
    debugPrint('Origin: ${origin.latitude},${origin.longitude}');
    debugPrint('Destination: ${destination.latitude},${destination.longitude}');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10)); // Add timeout

      debugPrint('API Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        debugPrint('API Response status: ${data['status']}');
        debugPrint('Routes count: ${data['routes']?.length ?? 0}');

        if (data['status'] == 'OK' && data['routes'] != null && data['routes'].isNotEmpty) {
          // Get primary route details
          final primaryRoute = data['routes'][0];
          final primaryLeg = primaryRoute['legs'][0];
          
          // Extract distance and duration
          final distance = primaryLeg['distance']['value'] / 1000.0; // Convert to km
          final durationText = primaryLeg.containsKey('duration_in_traffic')
              ? primaryLeg['duration_in_traffic']['text']
              : primaryLeg['duration']['text'];
          final isTrafficEstimate = primaryLeg.containsKey('duration_in_traffic');

          debugPrint('Route distance: ${distance}km');
          debugPrint('Route duration: $durationText');

          // Extract steps for turn-by-turn directions
          final List<dynamic> steps = primaryLeg['steps'] ?? [];
          final List<Map<String, dynamic>> turnByTurnDirections = [];
          final List<Marker> stepMarkers = [];
          int stepCounter = 1;

          debugPrint('Processing ${steps.length} steps');

          // Process each step in the route
          for (var step in steps) {
            final startLat = step['start_location']['lat'];
            final startLng = step['start_location']['lng'];
            final instruction = step['html_instructions'];
            final maneuver = step['maneuver'] ?? '';
            final distance = step['distance']['text'];
            final duration = step['duration']['text'];
            
            // Create a marker for this step
            if (stepCounter <= 10) { // Limit to 10 markers to avoid clutter
              final marker = Marker(
                markerId: MarkerId('step_$stepCounter'),
                position: LatLng(startLat, startLng),
                infoWindow: InfoWindow(
                  title: 'Step $stepCounter',
                  snippet: _stripHtmlTags(instruction),
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(_getMarkerHueForManeuver(maneuver)),
              );
              stepMarkers.add(marker);
            }
            
            // Add to turn-by-turn directions
            turnByTurnDirections.add({
              'instruction': _stripHtmlTags(instruction),
              'distance': distance,
              'duration': duration,
              'maneuver': maneuver,
              'position': LatLng(startLat, startLng),
            });
            
            stepCounter++;
          }

          // Decode polyline points for the main route
          final List<LatLng> polylineCoordinates = [];
          final polylineString = primaryRoute['overview_polyline']['points'];
          
          debugPrint('Polyline string length: ${polylineString.length}');
          
          if (polylineString.isNotEmpty) {
            try {
              final points = PolylinePoints().decodePolyline(polylineString);
              debugPrint('Decoded ${points.length} polyline points');
              
              for (var point in points) {
                polylineCoordinates.add(LatLng(point.latitude, point.longitude));
              }
              
              if (polylineCoordinates.isEmpty) {
                debugPrint('WARNING: No polyline coordinates after decoding');
                return {'isFallback': true};
              }
            } catch (e) {
              debugPrint('Error decoding polyline: $e');
              return {'isFallback': true};
            }
          } else {
            debugPrint('ERROR: Empty polyline string');
            return {'isFallback': true};
          }
          
          // Create the main polyline
          final mainPolyline = Polyline(
            polylineId: const PolylineId('main_route'),
            color: Colors.blue,
            points: polylineCoordinates,
            width: 5,
          );
          
          // Process alternative routes if available
          final List<Polyline> alternativePolylines = [];
          if (alternatives && data['routes'].length > 1) {
            debugPrint('Processing ${data['routes'].length - 1} alternative routes');
            int altRouteIndex = 1;
            for (var altRoute in data['routes'].skip(1)) {
              try {
                final altPoints = PolylinePoints().decodePolyline(altRoute['overview_polyline']['points']);
                final altCoordinates = altPoints.map((point) => 
                  LatLng(point.latitude, point.longitude)).toList();
                
                if (altCoordinates.isNotEmpty) {
                  alternativePolylines.add(
                    Polyline(
                      polylineId: PolylineId('alt_route_$altRouteIndex'),
                      color: Colors.grey,
                      points: altCoordinates,
                      width: 4,
                      patterns: [PatternItem.dot, PatternItem.gap(10)],
                    )
                  );
                }
                
                altRouteIndex++;
              } catch (e) {
                debugPrint('Error processing alternative route $altRouteIndex: $e');
              }
            }
          }
          
          // Combine all polylines
          final Set<Polyline> allPolylines = {mainPolyline, ...alternativePolylines};

          debugPrint('Successfully created route with ${polylineCoordinates.length} points');
          debugPrint('Alternative routes: ${alternativePolylines.length}');

          return {
            'polyline': mainPolyline,
            'polylines': allPolylines,
            'distance': distance,
            'duration': durationText,
            'polylineCoordinates': polylineCoordinates,
            'turnByTurnDirections': turnByTurnDirections,
            'stepMarkers': stepMarkers,
            'hasAlternativeRoutes': alternativePolylines.isNotEmpty,
            'isFallback': false,
            'isTrafficEstimate': isTrafficEstimate,
            'rawRouteData': primaryRoute, // Include raw data for advanced usage
          };
        } else {
          debugPrint('Error from Google Directions API: ${data['status']}');
          if (data.containsKey('error_message')) {
            debugPrint('Error message: ${data['error_message']}');
          }
          if (data.containsKey('available_travel_modes')) {
            debugPrint('Available travel modes: ${data['available_travel_modes']}');
          }
          return {'isFallback': true};
        }
      } else {
        debugPrint('Failed to fetch directions: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return {'isFallback': true};
      }
    } catch (e) {
      debugPrint('Exception during API call: $e');
      return {'isFallback': true};
    }
  }

  /// Get polyline using the flutter_polyline_points package
  static Future<Map<String, dynamic>> _getPolylineUsingPackage(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      debugPrint('Trying to get route using flutter_polyline_points package');
      PolylinePoints polylinePoints = PolylinePoints();

      // Fetch route using the package
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: _apiKey,
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
        ),
      );

      debugPrint('PolylinePoints result status: ${result.status}');
      debugPrint('PolylinePoints error message: ${result.errorMessage}');
      debugPrint('PolylinePoints points count: ${result.points.length}');

      List<LatLng> polylineCoordinates = [];

      if (result.status == 'OK' && result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }

        debugPrint('Package method succeeded with ${polylineCoordinates.length} points');
        return _createDirectionsResponse(polylineCoordinates, origin, destination);
      } else {
        debugPrint('Error getting route via package: ${result.errorMessage}');
        return {'polylineCoordinates': [], 'isFallback': true};
      }
    } catch (e) {
      debugPrint('Error using polyline package: $e');
      return {'polylineCoordinates': [], 'isFallback': true};
    }
  }

  /// Create a response with polyline, distance, and duration
  static Map<String, dynamic> _createDirectionsResponse(
    List<LatLng> polylineCoordinates,
    LatLng origin,
    LatLng destination,
  ) {
    double distance = 0;

    // Calculate distance along the route
    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      distance += _calculateDistance(
        polylineCoordinates[i].latitude,
        polylineCoordinates[i].longitude,
        polylineCoordinates[i + 1].latitude,
        polylineCoordinates[i + 1].longitude,
      );
    }

    // Create polyline
    final polyline = Polyline(
      polylineId: const PolylineId('main_route'),
      color: Colors.blue,
      points: polylineCoordinates,
      width: 5,
    );

    // Estimate duration (assuming average speed of 50 km/h)
    final durationInHours = distance / 50;
    final durationInMinutes = (durationInHours * 60).round();

    String durationText;
    if (durationInMinutes < 60) {
      durationText = "$durationInMinutes min";
    } else {
      final hours = durationInMinutes ~/ 60;
      final minutes = durationInMinutes % 60;
      durationText = "$hours h ${minutes > 0 ? '$minutes min' : ''}";
    }

    return {
      'polyline': polyline,
      'polylines': {polyline},
      'distance': distance,
      'duration': durationText,
      'polylineCoordinates': polylineCoordinates,
      'turnByTurnDirections': [],
      'stepMarkers': [],
      'hasAlternativeRoutes': false,
      'isFallback': false,
      'isTrafficEstimate': false, 
    };
  }

  /// Get fallback straight line if all else fails
  static Map<String, dynamic> _getFallbackStraightLine(
    LatLng origin,
    LatLng destination,
  ) {
    debugPrint('Using fallback straight line');
    final straightLineCoordinates = [origin, destination];
    final distance = _calculateDistance(
      origin.latitude,
      origin.longitude,
      destination.latitude,
      destination.longitude,
    );

    // Use a dashed red line to indicate this is a fallback
    final polyline = Polyline(
      polylineId: const PolylineId('main_route'),
      color: Colors.red,
      points: straightLineCoordinates,
      width: 5,
      patterns: [
        PatternItem.dash(20),
        PatternItem.gap(10),
      ],
    );

    return {
      'polyline': polyline,
      'polylines': {polyline},
      'distance': distance,
      'duration': '${(distance / 50 * 60).round()} min',
      'polylineCoordinates': straightLineCoordinates,
      'turnByTurnDirections': [],
      'stepMarkers': [],
      'hasAlternativeRoutes': false,
      'isFallback': true,
      'isTrafficEstimate': false,
    };
  }

  /// Calculate distance between two coordinates using the Haversine formula
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
  
  /// Strip HTML tags from instructions
  static String _stripHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, ' ').replaceAll('  ', ' ').trim();
  }
  
  /// Get appropriate marker hue based on maneuver type
  static double _getMarkerHueForManeuver(String maneuver) {
    switch (maneuver) {
      case 'turn-right':
      case 'turn-slight-right':
      case 'turn-sharp-right':
        return BitmapDescriptor.hueGreen;
      case 'turn-left':
      case 'turn-slight-left':
      case 'turn-sharp-left':
        return BitmapDescriptor.hueOrange;
      case 'roundabout-right':
      case 'roundabout-left':
      case 'roundabout':
        return BitmapDescriptor.hueYellow;
      case 'uturn-right':
      case 'uturn-left':
      case 'uturn':
        return BitmapDescriptor.hueRed;
      case 'ramp-right':
      case 'ramp-left':
      case 'merge':
      case 'fork-right':
      case 'fork-left':
        return BitmapDescriptor.hueCyan;
      default:
        return BitmapDescriptor.hueViolet;
    }
  }
}