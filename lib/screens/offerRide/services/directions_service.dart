import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:math' show cos, sqrt, asin;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mpitana/common/config/maps_config.dart';

class DirectionsService {
  // Use API key from central configuration
  static String get _apiKey => MapsConfig.apiKey;
  
  /// Get route between two points
  static Future<Map<String, dynamic>> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      debugPrint('Getting directions between: ${origin.latitude},${origin.longitude} and ${destination.latitude},${destination.longitude}');
      
      // Try direct API call first as it's more reliable
      final directApiResult = await _getPolylineUsingDirectApi(origin, destination);
      
      // If direct API call fails, try using the package
      if (directApiResult['isFallback'] == true) {
        debugPrint('Direct API call failed, trying package method');
        final packageResult = await _getPolylineUsingPackage(origin, destination);
        if (packageResult['polylineCoordinates'].isNotEmpty) {
          return packageResult;
        }
      } else {
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
  
  /// Try to get polyline using the flutter_polyline_points package
  static Future<Map<String, dynamic>> _getPolylineUsingPackage(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      debugPrint('Trying to get route using flutter_polyline_points package');
      PolylinePoints polylinePoints = PolylinePoints();
      
      // Use the correct method signature for the package version
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
        ),
        googleApiKey: _apiKey,
      );
      
      debugPrint('PolylinePoints result status: ${result.status}');
      debugPrint('PolylinePoints error message: ${result.errorMessage}');
      debugPrint('PolylinePoints points count: ${result.points.length}');
      
      List<LatLng> polylineCoordinates = [];
      
      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
        
        return _createDirectionsResponse(polylineCoordinates, origin, destination);
      } else {
        debugPrint('Error getting route: ${result.errorMessage}');
        return {'polylineCoordinates': [], 'isFallback': true};
      }
    } catch (e) {
      debugPrint('Error using polyline package: $e');
      return {'polylineCoordinates': [], 'isFallback': true};
    }
  }
  
  /// Get polyline by directly calling the Google Directions API
  static Future<Map<String, dynamic>> _getPolylineUsingDirectApi(
    LatLng origin,
    LatLng destination,
  ) async {
    final String url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=driving'
        '&key=$_apiKey';
    
    debugPrint('Calling Directions API directly: $url');
    
    try {
      final response = await http.get(Uri.parse(url));
      
      debugPrint('API Response status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        debugPrint('API Response status: ${data['status']}');
        
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          List<LatLng> polylineCoordinates = [];
          
          // Get route details
          final route = data['routes'][0];
          final leg = route['legs'][0];
          final distance = leg['distance']['value'] / 1000.0; // Convert to km
          final duration = leg['duration']['text'];
          
          // Decode polyline points
          final points = PolylinePoints().decodePolyline(
            route['overview_polyline']['points']
          );
          
          debugPrint('Decoded ${points.length} points from polyline');
          
          for (var point in points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
          
          // Create polyline
          final polyline = Polyline(
            polylineId: const PolylineId('route'),
            color: Colors.blue,
            points: polylineCoordinates,
            width: 5,
          );
          
          return {
            'polyline': polyline,
            'distance': distance,
            'duration': duration,
            'polylineCoordinates': polylineCoordinates,
            'isFallback': false,
          };
        } else {
          debugPrint('Error from Google Directions API: ${data['status']}');
          if (data.containsKey('error_message')) {
            debugPrint('Error message: ${data['error_message']}');
          }
          return _getFallbackStraightLine(origin, destination);
        }
      } else {
        debugPrint('Failed to fetch directions: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return _getFallbackStraightLine(origin, destination);
      }
    } catch (e) {
      debugPrint('Exception during API call: $e');
      return _getFallbackStraightLine(origin, destination);
    }
  }
  
  /// Create a response with polyline, distance and duration
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
      polylineId: const PolylineId('route'),
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
      'distance': distance,
      'duration': durationText,
      'polylineCoordinates': polylineCoordinates,
      'isFallback': false,
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
      polylineId: const PolylineId('route'),
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
      'distance': distance,
      'duration': '${(distance / 50 * 60).round()} min',
      'polylineCoordinates': straightLineCoordinates,
      'isFallback': true,
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
}
