import 'package:flutter/material.dart';
import 'package:mpitana/screens/chat/chat_screen.dart';
import 'package:mpitana/screens/chat/message/message_screen.dart';
import 'package:mpitana/screens/chat/models/chat_model.dart';
import 'package:mpitana/screens/findRideScreen/find_ride_screen.dart';
import 'package:mpitana/screens/map/map_screen.dart';
import 'package:mpitana/screens/offerRide/offer_ride_screen.dart';
import 'package:mpitana/screens/profile/profile_screen.dart';
import 'package:mpitana/screens/rides/rides_screen.dart'; // Import the new rides screen
import 'package:mpitana/screens/wallet/wallet_screen.dart'; // Import the wallet screen


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
  late TextEditingController _departureController;
  late TextEditingController _destinationController;

  @override
  void initState() {
    super.initState();
    _dateTimeController = TextEditingController();
    _departureController = TextEditingController();
    _destinationController = TextEditingController();
  }

  @override
  void dispose() {
    _dateTimeController.dispose();
    _departureController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  final List<Widget> _widgetOptions = <Widget>[
    const FindRideScreen(),
    const OfferRideScreen(),
    const RidesScreen(currentUserId: 'user123'), // Demo user ID
    const WalletScreen(userId: 'user123'), // Demo user ID
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
                          controller: _departureController,
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
                          controller: _destinationController,
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(
                        departure: _departureController.text,
                        destination: _destinationController.text,
                      ),
                    ),
                  );
                },
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
              child: MapScreen(departure: _departureController.text, destination: _destinationController.text,),
          ),
          )
        ],
      ),
            )
          : _widgetOptions[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(_selectedIndex == 0 ? Icons.directions_car_filled : Icons.directions_car_outlined),
                label: 'Find Ride',
              ),
              BottomNavigationBarItem(
                icon: Icon(_selectedIndex == 1 ? Icons.add_circle : Icons.add_circle_outline),
                label: 'Offer Ride',
              ),
              BottomNavigationBarItem(
                icon: const SizedBox(width: 0), // Empty space for FAB
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(_selectedIndex == 3 ? Icons.account_balance_wallet : Icons.account_balance_wallet_outlined),
                label: 'Wallet',
              ),
              BottomNavigationBarItem(
                icon: Icon(_selectedIndex == 4 ? Icons.chat_bubble : Icons.chat_bubble_outline),
                label: 'Messages',
              ),
              BottomNavigationBarItem(
                icon: Icon(_selectedIndex == 5 ? Icons.person : Icons.person_outline),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex == 2 ? 0 : _selectedIndex, // Handle the empty middle item
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            onTap: (index) {
              // Skip the middle item (index 2) as it's reserved for the FAB
              if (index == 2) return;
              
              // Adjust index if it's greater than 2 (after the FAB)
              if (index > 2) {
                _onItemTapped(index);
              } else {
                _onItemTapped(index);
              }
            },
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0, // Remove default shadow
          ),
        ),
      ),
      floatingActionButton: Container(
        height: 65,
        width: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            _onItemTapped(2); // Navigate to RidesScreen when the FAB is pressed
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(
            Icons.directions_car_filled,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 30,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}