import 'package:flutter/material.dart';

class OfferRideScreen extends StatelessWidget {
  const OfferRideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background, // Use background color from theme
      body: Center(
        child: Text(
          'Offer Ride Screen',
          style: TextStyle(fontSize: 24, color: Theme.of(context).colorScheme.onBackground), // Use onBackground color
        ),
      ),
    );
  }
}