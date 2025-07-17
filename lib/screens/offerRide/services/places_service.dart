import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlacesService {
  static final Dio _dio = Dio();
  
  // Use the same API key that works with your maps
  static const String apiKey = 'AIzaSyA6kCI_ITuLpWODKjCkaZ8NhUssyMoMNY8';
  
  // Get place suggestions based on input
  static Future<List<PlaceSuggestion>> getPlaceSuggestions(String input) async {
    if (input.isEmpty) {
      return [];
    }
    
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': input,
          'key': apiKey,
          // Optional parameters
          // 'components': 'country:bi', // Restrict to Burundi
          'language': 'en',
        },
      );
      
      if (response.statusCode == 200) {
        final predictions = response.data['predictions'] as List;
        return predictions
            .map((prediction) => PlaceSuggestion.fromJson(prediction))
            .toList();
      } else {
        debugPrint('Error getting place suggestions: ${response.statusCode}');
        debugPrint('Response: ${response.data}');
        return [];
      }
    } catch (e) {
      debugPrint('Exception getting place suggestions: $e');
      return [];
    }
  }
  
  // Get place details including coordinates
  static Future<PlaceDetail?> getPlaceDetails(String placeId) async {
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'fields': 'geometry,formatted_address,name',
          'key': apiKey,
        },
      );
      
      if (response.statusCode == 200) {
        if (response.data['status'] == 'OK') {
          return PlaceDetail.fromJson(response.data['result']);
        } else {
          debugPrint('Error getting place details: ${response.data['status']}');
          debugPrint('Response: ${response.data}');
          return null;
        }
      } else {
        debugPrint('Error getting place details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception getting place details: $e');
      return null;
    }
  }
}

class PlaceSuggestion {
  final String placeId;
  final String description;
  
  PlaceSuggestion({
    required this.placeId,
    required this.description,
  });
  
  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      placeId: json['place_id'],
      description: json['description'],
    );
  }
}

class PlaceDetail {
  final LatLng location;
  final String formattedAddress;
  final String name;
  
  PlaceDetail({
    required this.location,
    required this.formattedAddress,
    required this.name,
  });
  
  factory PlaceDetail.fromJson(Map<String, dynamic> json) {
    final lat = json['geometry']['location']['lat'];
    final lng = json['geometry']['location']['lng'];
    
    return PlaceDetail(
      location: LatLng(lat, lng),
      formattedAddress: json['formatted_address'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
