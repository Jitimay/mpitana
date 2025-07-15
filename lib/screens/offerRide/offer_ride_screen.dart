import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' hide Location; // Hide the geocoding Location class
import 'package:mpitana/screens/offerRide/location_picker_screen.dart';
import 'package:mpitana/screens/offerRide/models/location.dart' as MyLocation; 
import 'package:mpitana/screens/offerRide/services/location_service.dart';

class OfferRideScreen extends StatefulWidget {
  const OfferRideScreen({super.key});

  @override
  State<OfferRideScreen> createState() => _OfferRideScreenState();
}

class _OfferRideScreenState extends State<OfferRideScreen> {
  LatLng? _departureLocation;
  LatLng? _destinationLocation;
  String? _departureAddress;
  String? _destinationAddress;

  Future<void> _selectDepartureLocation() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationPickerScreen(isDeparture: true),
        fullscreenDialog: true,
      ),
    );

    if (result != null) {
      setState(() {
        _departureLocation = result;
      });
      _getAddressFromLatLng(result, true);
      _saveLocationToIsar(result, true);
    }
  }

  Future<void> _selectDestinationLocation() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationPickerScreen(isDeparture: false),
        fullscreenDialog: true,
      ),
    );

    if (result != null) {
      setState(() {
        _destinationLocation = result;
      });
      _getAddressFromLatLng(result, false);
      _saveLocationToIsar(result, false);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position, bool isDeparture) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
        setState(() {
          if (isDeparture) {
            _departureAddress = address;
          } else {
            _destinationAddress = address;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting address: $e')),
      );
    }
  }

  Future<void> _saveLocationToIsar(LatLng position, bool isDeparture) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        
        final location = MyLocation.Location.create(
          latitude: position.latitude,
          longitude: position.longitude,
          address: "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}",
          city: place.locality,
          country: place.country,
          isDeparture: isDeparture,
        );

        await LocationService.saveLocation(location);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving location: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offer a Ride'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ride Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Departure location
            InkWell(
              onTap: _selectDepartureLocation,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Departure',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _departureAddress ?? 'Where are you departing from?',
                            style: TextStyle(
                              fontSize: 16,
                              color: _departureAddress != null
                                  ? Colors.black
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Destination location
            InkWell(
              onTap: _selectDestinationLocation,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Destination',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _destinationAddress ?? 'Where are you going?',
                            style: TextStyle(
                              fontSize: 16,
                              color: _destinationAddress != null
                                  ? Colors.black
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Continue button
            if (_departureLocation != null && _destinationLocation != null)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Continue to next step of ride creation
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Continue'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}