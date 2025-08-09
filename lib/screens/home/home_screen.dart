import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpitana/screens/chat/message/message_screen.dart';
import 'package:mpitana/screens/findRideScreen/find_ride_screen.dart';
import 'package:mpitana/screens/map/map_screen.dart';
import 'package:mpitana/screens/offerRide/offer_ride_screen.dart';
import 'package:mpitana/screens/profile/profile_screen.dart';
import 'package:mpitana/screens/wallet/wallet_screen.dart';
import 'package:mpitana/bloc/ride/ride_bloc.dart';
import 'package:mpitana/bloc/ride/ride_state.dart';


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
    const WalletScreen(),
    MessagesScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RideBloc, RideState>(
      listener: (context, state) {
        if (state is RideCreated) {
          // Automatically switch to Find tab when a ride is created
          setState(() {
            _selectedIndex = 0; // Switch to Find tab (index 0)
          });
          // Show a snackbar to inform the user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Ride posted! Check the Find tab to see your ride.'),
              action: SnackBarAction(
                label: 'View',
                onPressed: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background, // Use background color from theme
        body: _widgetOptions[_selectedIndex],
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
                icon: Icon(_selectedIndex == 0 ? Icons.search : Icons.search_outlined),
                label: 'Find',
              ),
              BottomNavigationBarItem(
                icon: Icon(_selectedIndex == 1 ? Icons.add_circle : Icons.add_circle_outline),
                label: 'Offer',
              ),
              BottomNavigationBarItem(
                icon: Icon(_selectedIndex == 2 ? Icons.account_balance_wallet : Icons.account_balance_wallet_outlined),
                label: 'Wallet',
              ),
              BottomNavigationBarItem(
                icon: Icon(_selectedIndex == 3 ? Icons.chat_bubble : Icons.chat_bubble_outline),
                label: 'Messages',
              ),
              BottomNavigationBarItem(
                icon: Icon(_selectedIndex == 4 ? Icons.person : Icons.person_outline),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex >= 5 ? 4 : _selectedIndex, // Handle FAB navigation
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            onTap: (index) {
              _onItemTapped(index);
            },
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0, // Remove default shadow
          ),
        ),
      ),
      // floatingActionButton: Container(
      //   height: 65,
      //   width: 65,
      //   decoration: BoxDecoration(
      //     shape: BoxShape.circle,
      //     gradient: LinearGradient(
      //       begin: Alignment.topLeft,
      //       end: Alignment.bottomRight,
      //       colors: [
      //         Theme.of(context).colorScheme.primary,
      //         Theme.of(context).colorScheme.secondary,
      //       ],
      //     ),
      //     boxShadow: [
      //       BoxShadow(
      //         color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      //         spreadRadius: 1,
      //         blurRadius: 8,
      //         offset: const Offset(0, 4),
      //       ),
      //     ],
      //   ),
      //   child: FloatingActionButton(
      //     onPressed: () {
      //       _onItemTapped(5); // Navigate to RidesScreen when the FAB is pressed
      //     },
      //     backgroundColor: Colors.transparent,
      //     elevation: 0,
      //     child: Icon(
      //       Icons.directions_car_filled,
      //       color: Theme.of(context).colorScheme.onPrimary,
      //       size: 30,
      //     ),
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    ), // End of Scaffold
    ); // End of BlocListener
  }
}