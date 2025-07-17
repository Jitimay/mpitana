import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:math' show asin, cos, sin, sqrt;

class RouteService {
  // Calculate the route between two points and return polyline points
  static Future<List<LatLng>> getPolylinePoints(LatLng origin, LatLng destination) async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    
    try {
      // Note: In a real app, you would use your Google Maps API key here
      // and make an actual API call. This is a simplified version.
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
        ),
        googleApiKey: 'AIzaSyA6kCI_ITuLpWODKjCkaZ8NhUssyMoMNY8',
      );

      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      } else {
        // Fallback: Create a straight line if API call fails or in development
        polylineCoordinates = [origin, destination];
      }
    } catch (e) {
      debugPrint('Error getting polyline points: $e');
      // Fallback: Create a straight line
      polylineCoordinates = [origin, destination];
    }

    return polylineCoordinates;
  }

  // Calculate the distance between two coordinates in kilometers
  static double calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    double latDifference = _degreesToRadians(end.latitude - start.latitude);
    double lngDifference = _degreesToRadians(end.longitude - start.longitude);
    
    double a = sin(latDifference / 2) * sin(latDifference / 2) +
        cos(_degreesToRadians(start.latitude)) * cos(_degreesToRadians(end.latitude)) *
        sin(lngDifference / 2) * sin(lngDifference / 2);
    
    double c = 2 * asin(sqrt(a));
    double distance = earthRadius * c;
    
    return distance;
  }
  
  // Calculate estimated travel time in minutes based on distance
  static int calculateTravelTime(double distanceInKm) {
    // Assuming average speed of 60 km/h
    const double averageSpeedKmPerHour = 60;
    double timeInHours = distanceInKm / averageSpeedKmPerHour;
    int timeInMinutes = (timeInHours * 60).round();
    
    return timeInMinutes;
  }
  
  // Helper method to convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }
  
  // Format travel time to a readable string
  static String formatTravelTime(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      int hours = minutes ~/ 60;
      int remainingMinutes = minutes % 60;
      return '$hours h ${remainingMinutes > 0 ? '$remainingMinutes min' : ''}';
    }
  }
}
