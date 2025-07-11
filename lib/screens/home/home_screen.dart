import 'package:flutter/material.dart';
import 'package:mpitana/screens/chat/chat_screen.dart';
import 'package:mpitana/screens/chat/message/message_screen.dart';
import 'package:mpitana/screens/chat/models/chat_model.dart';
import 'package:mpitana/screens/findRideScreen/find_ride_screen.dart';
import 'package:mpitana/screens/map/map_screen.dart';
import 'package:mpitana/screens/offerRide/offer_ride_screen.dart';
import 'package:mpitana/screens/profile/profile_screen.dart';
import 'package:mpitana/screens/rides/rides_screen.dart'; // Import the new rides screen


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  late TextEditingController _dateTimeController;

  @override
  void initState() {
    super.initState();
    _dateTimeController = TextEditingController();
  }

  @override
  void dispose() {
    _dateTimeController.dispose();
    super.dispose();
  }

  final List<Widget> _widgetOptions = <Widget>[
    const FindRideScreen(),
    const OfferRideScreen(),
    const RidesScreen(),
    MessagesScreen(),
    // ChatScreen(chatItem: ChatItem(name: 'John Doe', lastMessage: 'Hello, how are you?', time: '12:00 PM', profileImage: 'https://i.ibb.co/6rP1gQ3/burundi-flag-logo.png')),
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
      body: _selectedIndex == 0
          ? SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 70),
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
                    child: Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Departure',
                            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)), // Added hintStyle
                            prefixIcon: Icon(Icons.location_on, color: Theme.of(context).colorScheme.onSurface), // Use onSurface color for icon
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)), // Add a visible border
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface, // Use surface color from theme
                          ),
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface), // Set text color
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Destination',
                            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)), // Added hintStyle
                            prefixIcon: Icon(Icons.location_on, color: Theme.of(context).colorScheme.onSurface), // Use onSurface color for icon
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)), // Add a visible border
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface, // Use surface color from theme
                          ),
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface), // Set text color
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _dateTimeController,
                          decoration: InputDecoration(
                            hintText: 'Date and Time',
                            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)), // Added hintStyle
                            prefixIcon: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.onSurface), // Use onSurface color for icon
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)), // Add a visible border
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface, // Use surface color from theme
                          ),
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface), // Set text color
                          readOnly: true, // Make it read-only so a date picker can be used
                          onTap: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              final TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: _selectedTime ?? TimeOfDay.now(),
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  _selectedDate = pickedDate;
                                  _selectedTime = pickedTime;
                                  _dateTimeController.text = "${_selectedDate!.toLocal().toString().split(' ')[0]} ${_selectedTime!.format(context)}";
                                });
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Number of Seats',
                            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)), // Added hintStyle
                            prefixIcon: Icon(Icons.event_seat, color: Theme.of(context).colorScheme.onSurface), // Use onSurface color for icon
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)), // Add a visible border
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface, // Use surface color from theme
                          ),
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface), // Set text color
                        ),
                      ],
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
                child: Text('Find Ride', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onPrimary)),
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
            )
          : _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car_filled), // Changed to a more ride-related icon
            label: 'Find Ride', // Changed label to Rides
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_road),
            label: 'Offer Ride',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car), 
            label: 'Rides',
          ),
                    BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
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
          _onItemTapped(2); // Navigate to RidesScreen when the FAB is pressed
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.directions_car_filled, color: Theme.of(context).colorScheme.onPrimary), // Changed to rides icon and use onPrimary color
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}