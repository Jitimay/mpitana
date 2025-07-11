import 'package:flutter/material.dart';
import 'package:mpitana/screens/findRideScreen/find_ride_screen.dart';
import 'package:mpitana/screens/map/map_screen.dart';
import 'package:mpitana/screens/offerRide/offer_ride_screen.dart';
import 'package:mpitana/screens/profile/profile_screen.dart';
import 'package:mpitana/screens/settings/settings_screen.dart'; // Import the new settings screen


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const FindRideScreen(),
    const OfferRideScreen(),
    const SettingsScreen(), // Use SettingsScreen for the center button
    const MapScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background, // Use background color from theme
      body: _selectedIndex == 0 ? const MainContent() : _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Find Ride',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_road),
            label: 'Offer Ride',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings), // Changed to settings icon
            label: 'Settings', // Changed label to Settings
          ),
                    BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),

        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary, // Use primary color from theme
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), // Use onSurface with opacity
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        backgroundColor: Theme.of(context).colorScheme.surface, // Use surface color from theme
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
         // Action for the center button
          _onItemTapped(2); // Navigate to SettingsScreen when the FAB is pressed
        },
        backgroundColor: Theme.of(context).colorScheme.primary, // Use primary color from theme
        child: Icon(Icons.settings, color: Theme.of(context).colorScheme.onPrimary), // Changed to settings icon and use onPrimary color
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class MainContent extends StatelessWidget {
  const MainContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 70),
          // Logo and Title
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.surface, // Use surface color from theme
            child: CircleAvatar(
                radius: 48,
                backgroundImage: NetworkImage('https://i.ibb.co/6rP1gQ3/burundi-flag-logo.png') // A placeholder for your logo
            ),
          ),
          const SizedBox(height: 10),
          Text('Burundi', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground)), // Use onBackground color
          const SizedBox(height: 10),
          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary, // Use primary color from theme
                ),
              ),
              const SizedBox(width: 5),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), // Use onSurface with opacity for inactive dots
                ),
              ),
              const SizedBox(width: 5),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), // Use onSurface with opacity for inactive dots
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Request tion a ride',
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface), // Use onSurface color for icon
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface, // Use surface color from theme
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface), // Set text color
            ),
          ),
          const SizedBox(height: 15),
          // Offer Ride Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary, // Use primary color from theme
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: Text('Offer ride in loat Burundi', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onPrimary)), // Use onPrimary color
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Map Section
          SizedBox(
            height: 300,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: MapScreen(),
          ),
          )
        ],
      ),
    );
  }
}