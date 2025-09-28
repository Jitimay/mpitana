import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mpitana/common/services/maps_diagnostic.dart';
import 'package:mpitana/screens/offerRide/services/enhanced_directions_service.dart';

class MapsDebugScreen extends StatefulWidget {
  const MapsDebugScreen({super.key});

  @override
  State<MapsDebugScreen> createState() => _MapsDebugScreenState();
}

class _MapsDebugScreenState extends State<MapsDebugScreen> {
  Map<String, dynamic>? _diagnosticResult;
  bool _isLoading = false;
  String _testResult = '';

  // Test coordinates in Bujumbura
  final LatLng _origin = const LatLng(-3.3732, 29.3623); // Bujumbura center
  final LatLng _destination = const LatLng(-3.3500, 29.3800); // Nearby location

  @override
  void initState() {
    super.initState();
    _runDiagnostic();
  }

  Future<void> _runDiagnostic() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Running diagnostic...';
    });

    try {
      // Run the diagnostic
      final result = await MapsDiagnostic.testGoogleMapsAPI();
      
      setState(() {
        _diagnosticResult = result;
        _testResult = _formatDiagnosticResult(result);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = 'Error running diagnostic: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testDirectionsService() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing directions service...';
    });

    try {
      final result = await EnhancedDirectionsService.getDirections(
        origin: _origin,
        destination: _destination,
      );

      setState(() {
        _testResult = _formatDirectionsResult(result);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = 'Error testing directions: $e';
        _isLoading = false;
      });
    }
  }

  String _formatDiagnosticResult(Map<String, dynamic> result) {
    final buffer = StringBuffer();
    buffer.writeln('🔍 DIAGNOSTIC RESULTS:');
    buffer.writeln('');
    buffer.writeln('✅ Success: ${result['success']}');
    buffer.writeln('📊 Status: ${result['status']}');
    buffer.writeln('🌐 Response Code: ${result['response_code']}');
    buffer.writeln('🛣️ Routes Found: ${result['routes_count']}');
    buffer.writeln('📍 Has Polyline: ${result['has_polyline']}');
    
    if (result['error_message']?.isNotEmpty == true) {
      buffer.writeln('');
      buffer.writeln('❌ Error: ${result['error_message']}');
    }

    buffer.writeln('');
    buffer.writeln('💡 RECOMMENDATIONS:');
    
    if (!result['success']) {
      switch (result['status']) {
        case 'REQUEST_DENIED':
          buffer.writeln('• Enable Directions API in Google Cloud Console');
          buffer.writeln('• Check API key restrictions');
          buffer.writeln('• Verify billing is enabled');
          break;
        case 'OVER_QUERY_LIMIT':
          buffer.writeln('• Check API quotas in Google Cloud Console');
          buffer.writeln('• Consider upgrading your plan');
          break;
        case 'ZERO_RESULTS':
          buffer.writeln('• Try different coordinates');
          buffer.writeln('• Check if locations are accessible by car');
          break;
        default:
          buffer.writeln('• Check internet connection');
          buffer.writeln('• Verify API key is correct');
          buffer.writeln('• Check Google Cloud Console settings');
      }
    } else {
      buffer.writeln('• API is working correctly!');
      buffer.writeln('• Routes should display properly');
    }

    return buffer.toString();
  }

  String _formatDirectionsResult(Map<String, dynamic> result) {
    final buffer = StringBuffer();
    buffer.writeln('🛣️ DIRECTIONS SERVICE RESULTS:');
    buffer.writeln('');
    buffer.writeln('📍 Is Fallback: ${result['isFallback'] ?? false}');
    buffer.writeln('📏 Distance: ${result['distance']?.toStringAsFixed(2) ?? 'N/A'} km');
    buffer.writeln('⏱️ Duration: ${result['duration'] ?? 'N/A'}');
    buffer.writeln('🗺️ Polyline Points: ${result['polylineCoordinates']?.length ?? 0}');
    buffer.writeln('🔄 Alternative Routes: ${result['hasAlternativeRoutes'] ?? false}');
    buffer.writeln('🚦 Traffic Estimate: ${result['isTrafficEstimate'] ?? false}');
    
    if (result['isFallback'] == true) {
      buffer.writeln('');
      buffer.writeln('⚠️ USING FALLBACK (Red Dashed Line)');
      buffer.writeln('This means the Google Directions API failed.');
      buffer.writeln('Check the diagnostic results above for solutions.');
    } else {
      buffer.writeln('');
      buffer.writeln('✅ SUCCESS: Real route data received!');
      buffer.writeln('Routes should display as blue lines following roads.');
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maps API Debug'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Coordinates',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Origin: ${_origin.latitude}, ${_origin.longitude}'),
                    Text('Destination: ${_destination.latitude}, ${_destination.longitude}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _runDiagnostic,
                    icon: const Icon(Icons.bug_report),
                    label: const Text('Run API Diagnostic'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testDirectionsService,
                    icon: const Icon(Icons.directions),
                    label: const Text('Test Directions'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            'Test Results',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (_isLoading) ...[
                            const SizedBox(width: 16),
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _testResult.isEmpty ? 'Click a button to run tests...' : _testResult,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}