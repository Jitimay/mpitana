import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpitana/screens/chat/message/message_screen.dart';
import 'package:mpitana/screens/findRideScreen/find_ride_screen.dart';
import 'package:mpitana/screens/offerRide/offer_ride_screen.dart';
import 'package:mpitana/screens/profile/profile_screen.dart';
import 'package:mpitana/screens/wallet/wallet_screen.dart';
import 'package:mpitana/bloc/ride/ride_bloc.dart';
import 'package:mpitana/bloc/ride/ride_state.dart';
import 'package:mpitana/common/utils/debug_utils.dart';


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
        backgroundColor: Theme.of(context).colorScheme.surface, // Use surface color from theme
        body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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
            unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
      floatingActionButton: Stack(
        children: [
          // Debug FAB (only in debug mode)
          Positioned(
            bottom: 80,
            right: 0,
            child: DebugUtils.buildDebugFab(context),
          ),
        ],
      ),
    ), // End of Scaffold
    ); // End of BlocListener
  }
}