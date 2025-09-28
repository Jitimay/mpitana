import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mpitana/common/config/maps_config.dart';

class MapsDiagnostic {
  static Future<Map<String, dynamic>> testGoogleMapsAPI() async {
    final String apiKey = MapsConfig.apiKey;
    
    // Test coordinates (Bujumbura area)
    const double originLat = -3.3732;
    const double originLng = 29.3623;
    const double destLat = -3.3500;
    const double destLng = 29.3800;
    
    final String url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=$originLat,$originLng'
        '&destination=$destLat,$destLng'
        '&mode=driving'
        '&key=$apiKey';
    
    try {
      debugPrint('🔍 Testing Google Maps API...');
      debugPrint('API Key: ${apiKey.substring(0, 10)}...');
      
      final response = await http.get(Uri.parse(url));
      final Map<String, dynamic> data = json.decode(response.body);
      
      debugPrint('📡 Response Status Code: ${response.statusCode}');
      debugPrint('📊 API Response Status: ${data['status']}');
      
      if (data.containsKey('error_message')) {
        debugPrint('❌ Error Message: ${data['error_message']}');
      }
      
      if (data.containsKey('routes')) {
        debugPrint('🛣️ Routes Found: ${data['routes'].length}');
      }
      
      return {
        'success': data['status'] == 'OK',
        'status': data['status'],
        'error_message': data['error_message'] ?? '',
        'routes_count': data['routes']?.length ?? 0,
        'response_code': response.statusCode,
        'has_polyline': data['routes']?.isNotEmpty == true && 
                      data['routes'][0]['overview_polyline']?.isNotEmpty == true,
      };
    } catch (e) {
      debugPrint('💥 Exception during API test: $e');
      return {
        'success': false,
        'error_message': e.toString(),
        'status': 'EXCEPTION',
        'routes_count': 0,
        'response_code': 0,
        'has_polyline': false,
      };
    }
  }
  
  static void printDiagnosticInfo() {
    debugPrint('🔧 === MAPS DIAGNOSTIC INFO ===');
    debugPrint('API Key Length: ${MapsConfig.apiKey.length}');
    debugPrint('API Key Prefix: ${MapsConfig.apiKey.substring(0, 10)}...');
    debugPrint('API Key Valid Format: ${MapsConfig.apiKey.startsWith('AIza')}');
    debugPrint('===============================');
  }
  
  static Future<void> runFullDiagnostic() async {
    printDiagnosticInfo();
    final result = await testGoogleMapsAPI();
    
    debugPrint('🔍 === FULL DIAGNOSTIC RESULTS ===');
    debugPrint('Success: ${result['success']}');
    debugPrint('Status: ${result['status']}');
    debugPrint('Error: ${result['error_message']}');
    debugPrint('Routes: ${result['routes_count']}');
    debugPrint('Has Polyline: ${result['has_polyline']}');
    debugPrint('==================================');
    
    // Provide recommendations
    if (!result['success']) {
      debugPrint('🚨 === TROUBLESHOOTING RECOMMENDATIONS ===');
      
      switch (result['status']) {
        case 'REQUEST_DENIED':
          debugPrint('❌ API Key Issue:');
          debugPrint('   1. Check if Directions API is enabled');
          debugPrint('   2. Check API key restrictions');
          debugPrint('   3. Verify billing is enabled');
          break;
        case 'OVER_QUERY_LIMIT':
          debugPrint('❌ Quota Exceeded:');
          debugPrint('   1. Check your Google Cloud Console quotas');
          debugPrint('   2. Consider upgrading your plan');
          break;
        case 'ZERO_RESULTS':
          debugPrint('⚠️ No Route Found:');
          debugPrint('   1. Check if coordinates are valid');
          debugPrint('   2. Try different locations');
          break;
        default:
          debugPrint('❌ Unknown Error:');
          debugPrint('   1. Check internet connection');
          debugPrint('   2. Verify API key is correct');
          debugPrint('   3. Check Google Cloud Console');
      }
      debugPrint('==========================================');
    }
  }
}